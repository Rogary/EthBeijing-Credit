// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IGradeClient {

function getUserGrade(address user)
        external
        view
        returns (uint256[] memory grades, uint256 updatedTime);
 
}