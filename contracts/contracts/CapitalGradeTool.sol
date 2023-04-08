// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./interfaces/ICapitalGradeTool.sol";

contract CapitalGradeTool is Ownable, ICapitalGradeTool {
    address[] private _erc20s;
    address[] private _erc721s;
    AggregatorV3Interface private _ethPriceFeed;
    mapping(address => AggregatorV3Interface) private _erc20PriceFeeds;
    mapping(address => AggregatorV3Interface) private _erc721FloorPriceFeeds;

    /// @custom:oz-upgrades-unsafe-allow constructor

    constructor(address ethPriceFeed) {
        _ethPriceFeed = AggregatorV3Interface(ethPriceFeed);
    }

    function addErc20s(address erc20, address priceFeedAddress)
        public
        onlyOwner
    {
        _erc20PriceFeeds[erc20] = AggregatorV3Interface(priceFeedAddress);
        if (_checkNotExist(_erc20s, erc20)) {
            _erc20s.push(erc20);
        }
    }

    function addrc721s(address erc721, address floorPriceFeeds)
        public
        onlyOwner
    {
        _erc721FloorPriceFeeds[erc721] = AggregatorV3Interface(floorPriceFeeds);
        if (_checkNotExist(_erc721s, erc721)) {
            _erc721s.push(erc721);
        }
    }

    function _checkNotExist(address[] memory existd, address newAddress)
        internal
        view
        returns (bool)
    {}

    /***
     * 插件获取 某个地址的钱包信息 50U 1分
     ***/
    function getGrade(address addr)
        external
        view
        override
        returns (uint256[] memory realTimeGrade)
    {
        realTimeGrade = new uint256[](2);
        realTimeGrade[0] = 100;
        uint256 amount = _getRealTimeGrade(addr);
        uint256 grade = amount / 50;
        realTimeGrade[1] = grade > 100 ? 100 : grade;
        // realTimeGrade[1] = 20;
    }

    function _getRealTimeGrade(address addr) internal view returns (uint256) {
        uint256 amount = 0;
        amount += _getEthGrade(addr);
        amount += _getErc20Grade(addr);
        amount += _getErc721Grade(addr);
        return amount;
    }

    /// eth 得分   公式更新
    function _getEthGrade(address addr) internal view returns (uint256 amount) {
        amount = 0;
        (
            ,
            /*uint80 roundID*/
            int256 price, // uint timeStamp, /*uint startedAt*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = _ethPriceFeed.latestRoundData();
        amount +=
            (uint256(addr.balance) * uint256(price)) /
            uint256(_ethPriceFeed.decimals()) /
            1**18;
    }

    /// erc20 得分   公式更新
    function _getErc20Grade(address addr)
        internal
        view
        returns (uint256 amount)
    {
        amount = 0;
        for (uint256 index = 0; index < _erc20s.length; index++) {
            AggregatorV3Interface priceFeed = _erc20PriceFeeds[_erc20s[index]];
            (
                ,
                /*uint80 roundID*/
                int256 price, // uint timeStamp, /*uint startedAt*/ /*uint80 answeredInRound*/
                ,
                ,

            ) = priceFeed.latestRoundData();
            amount +=
                (ERC20(_erc20s[index]).balanceOf(addr) * uint256(price)) /
                priceFeed.decimals() /
                ERC20(_erc20s[index]).decimals();
        }
    }

    /// 721 得分   公式更新
    function _getErc721Grade(address addr)
        internal
        view
        returns (uint256 amount)
    {
        amount = 0;
        for (uint256 index = 0; index < _erc721s.length; index++) {
            AggregatorV3Interface priceFeed = _erc721FloorPriceFeeds[
                _erc721s[index]
            ];
            (
                ,
                /*uint80 roundID*/
                int256 price, // uint timeStamp, /*uint startedAt*/ /*uint80 answeredInRound*/
                ,
                ,

            ) = priceFeed.latestRoundData();

            amount +=
                (IERC721Enumerable(_erc721s[index]).balanceOf(addr) *
                    uint256(price)) /
                priceFeed.decimals();
        }
    }
}
