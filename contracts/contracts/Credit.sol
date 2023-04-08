// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/IERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IGradeClient.sol";
import "./interfaces/ICapitalGradeTool.sol";

contract Credit is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    bytes4 private constant _InterfaceId_ERC721Enumerable =
        bytes4(keccak256("tokenOfOwnerByIndex(address,uint256)"));
    bytes4 private constant _InterfaceId_ERC721 = type(IERC20).interfaceId;
    
    IERC721EnumerableUpgradeable _profileDefauletAddress;
    IGradeClient _gradeClient;
    ICapitalGradeTool _capitalGradeTool;
    uint256[] internal _gradeMax;
    string[] internal _gradeName;
    mapping(address => string) internal _name;
    mapping(address => address) internal _profileAddress;
    mapping(address => uint256) internal _profileTokenId;
    mapping(address => address[]) _nftC; //持有的NFT合约

    /// @custom:oz-upgrades-unsafe-allow constructor

    constructor(
        address gradeClient,
        address capitalGradeTool,
        string[] memory gradeName,
        uint256[] memory gradeMax,
        address defaultProfile
    ) {
        _disableInitializers();
        _profileDefauletAddress = IERC721EnumerableUpgradeable(defaultProfile);
        _gradeMax = gradeMax;
        _gradeName = gradeName;
        _gradeClient = IGradeClient(gradeClient);
        _capitalGradeTool = ICapitalGradeTool(capitalGradeTool);
    }

    function updateGradeMax(uint256[] memory gradeMax) public onlyOwner {
        _gradeMax = gradeMax;
    }

    function updateGradeName(string[] memory gradeName) public onlyOwner {
        _gradeName = gradeName;
    }

    function initialize() public initializer {
        __Ownable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    /***
     * 插件获取 某个地址的得分信息
     ***/
    function getGrade(address addr)
        public
        view
        returns (
            string[] memory gradeName,
            uint256[] memory gradeHistory,
            uint256[] memory gradeMax,
            uint256 lastUpdateTime,
            uint256[] memory realTimeGrade
        )
    {
        (gradeHistory, lastUpdateTime) = _gradeClient.getUserGrade(addr);
        if (gradeHistory.length == 0) {
            gradeHistory = new uint256[](_gradeMax.length);
        }
        return (
            _gradeName,
            gradeHistory,
            _gradeMax,
            lastUpdateTime,
            _capitalGradeTool.getGrade(addr)
        );
    }

    function saveNft(address _nft) public {
        IERC721EnumerableUpgradeable nft = IERC721EnumerableUpgradeable(_nft);
        require(
            nft.supportsInterface(_InterfaceId_ERC721Enumerable),
            "address not IERC721Enumerable"
        );
        require(nft.balanceOf(msg.sender) > 0, "nft balance of user is 0");
        _checkSavedNft(_nft);
        _nftC[msg.sender].push(_nft);
    }

    function saveProfile(address _nft, uint256 _tokenId) public {
        require(
            IERC721EnumerableUpgradeable(_nft).supportsInterface(
                _InterfaceId_ERC721
            ),
            "address not IERC721"
        );
        require(_checkNftOwner(_nft, _tokenId, msg.sender), "nft owner error");
        _profileAddress[msg.sender] = _nft;
        _profileTokenId[msg.sender] = _tokenId;
    }

    // 如果默认有 无聊猿的nft 则直接显示成头像
    function getProfile(address user)
        public
        view
        returns (address _nft, uint256 tokenId)
    {
        address profileAddr = _profileAddress[user];
        if (profileAddr == address(0)) {
            return _getDefaultProfile(user);
        }

        if (_checkNftOwner(profileAddr, _profileTokenId[user], user)) {
            return (profileAddr, _profileTokenId[user]);
        } else {
            return _getDefaultProfile(user);
        }
    }

    struct NftMuseum {
        address nft;
        uint256[] tokenIds;
    }

    /**
        获取 用户NFT 博物馆数据
        返回 用户之前存的展馆NFT 
    **/
    function getNftMuseum(address user)
        public
        view
        returns (NftMuseum[] memory data)
    {
        address[] memory nftcs = _nftC[user];
        uint256 i = 0;
        for (uint256 index = 0; index < nftcs.length; index++) {
            if (
                IERC721EnumerableUpgradeable(nftcs[index]).balanceOf(user) > 0
            ) {
                i++;
            }
        }
        data = new NftMuseum[](i);
        uint256 j = 0;
        for (uint256 index = 0; index < nftcs.length; index++) {
            IERC721EnumerableUpgradeable erc721 = IERC721EnumerableUpgradeable(
                nftcs[index]
            );
            uint256 length = erc721.balanceOf(user);
            if (length > 0) {
                uint256[] memory tokenIds = new uint256[](length);
                for (
                    uint256 indexToken = 0;
                    indexToken < length;
                    indexToken++
                ) {
                    tokenIds[indexToken] = erc721.tokenOfOwnerByIndex(
                        user,
                        indexToken
                    );
                }
                data[j] = NftMuseum(nftcs[index], tokenIds);
                j++;
            }
        }
        return data;
    }

    function _getDefaultProfile(address user)
        internal
        view
        returns (address _nft, uint256 tokenId)
    {
        uint256 defaultProfileBalance = _profileDefauletAddress.balanceOf(user);
        if (defaultProfileBalance > 0) {
            return (
                address(_profileDefauletAddress),
                _profileDefauletAddress.tokenOfOwnerByIndex(user, 0)
            );
        } else {
            return (address(0), 0);
        }
    }

    function _checkNftOwner(
        address nft,
        uint256 tokenId,
        address user
    ) internal view returns (bool) {
        return IERC721EnumerableUpgradeable(nft).ownerOf(tokenId) == user;
    }

    function _checkSavedNft(address _nft) internal view {
        address[] memory userNftC = _nftC[msg.sender];
        bool has = false;
        for (uint256 index = 0; index < userNftC.length; index++) {
            if (userNftC[index] == _nft) {
                has = true;
            }
        }
        require(!has, "nft saved");
    }
}
