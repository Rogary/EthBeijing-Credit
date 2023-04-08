// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IGradeClient.sol";

contract CreditGradeOracleClient is ChainlinkClient, IGradeClient {
    using Chainlink for Chainlink.Request;

    mapping(address => uint256[]) private userGrades;
    mapping(address => uint256) private userLastUpdated;
    mapping(bytes32 => address) private requestUser;

    bytes32 private jobId;

    uint256 private fee;
    event ResponseFilled(address indexed user, bytes32 requestId);

    constructor() {
        // chain link node job https://github.com/glinknode/chainlink-public-jobs/tree/main/ETH-Sepolia-Testnet/

        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789); // testNet Ethereum Sepolia
        setChainlinkOracle(0x6c2e87340Ef6F3b7e21B2304D6C057091814f25E); // testNet Ethereum Sepolia
        jobId = stringToBytes32("eab9fe9db74f403d967ee207870a943f"); // testNet Ethereum Sepolia	  this job to return uint256[]  fee is 0.05 LINK
        fee = ((1 * LINK_DIVISIBILITY) / 100) * 5; // 0,1 * 10**18 (Varies by network and job)
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data.
     */
    function requestUserGrades(address addr)
        public
        returns (bytes32 requestId)
    {
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillArray.selector
        );
        string memory url = string(
            abi.encodePacked(
                "http://101.36.120.180/credit/chainlink/grade?address=",
                Strings.toHexString(uint160(addr), 20)
            )
        );
        // Set the URL to perform the GET request on
        // request.add("get", url);
        // // // Specify the path for retrieving the data
        // request.add("path", "0,grade");
        // request.addInt("multiply", 1);
        // Set the URL to perform the GET request on
        request.add("get", url);
        // Specify the path for retrieving the data
        request.add("path", "data");
        // Sends the request
        requestId = sendChainlinkRequest(request, fee);
        requestUser[requestId] = addr;
    }

    function fulfillArray(bytes32 requestId, uint256[] memory _arrayOfNumbers)
        public
        recordChainlinkFulfillment(requestId)
    {
        address user = requestUser[requestId];
        emit ResponseFilled(user, requestId);
        userGrades[user] = _arrayOfNumbers;
        userLastUpdated[user] = block.timestamp;
    }

    // function fulfillMultipleParameters(
    //     bytes32 requestId,
    //     uint256 aResponse,
    //     uint256 bResponse,
    //     uint256 cResponse,
    //     uint256 dResponse,
    //     uint256 eResponse,
    //     uint256 fResponse,
    //     uint256 gResponse
    // ) public recordChainlinkFulfillment(requestId) {
    //     address user = requestUser[requestId];
    //     emit ResponseFilled(user, requestId);
    //     while (userGrades[user].length < 7) {
    //         userGrades[user].push(0);
    //     }
    //     userGrades[user][0] = aResponse;
    //     userGrades[user][1] = bResponse;
    //     userGrades[user][2] = cResponse;
    //     userGrades[user][3] = dResponse;
    //     userGrades[user][4] = eResponse;
    //     userGrades[user][5] = fResponse;
    //     userGrades[user][6] = gResponse;
    // }

    // function fulfill(bytes32 requestId, uint256 aResponse)
    //     public
    //     recordChainlinkFulfillment(requestId)
    // {
    //     address user = requestUser[requestId];
    //     emit ResponseFilled(user, requestId);
    //     while (userGrades[user].length < 7) {
    //         userGrades[user].push(0);
    //     }
    //     userGrades[user][0] = aResponse;
    // }

    function getUserGrade(address user)
        external
        view
        override
        returns (uint256[] memory grades, uint256 updatedTime)
    {
        return (userGrades[user], userLastUpdated[user]);
    }

    function getRequestUser(bytes32 requestId) external view returns (address) {
        return requestUser[requestId];
    }

    function stringToBytes32(string memory source)
        private
        pure
        returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
