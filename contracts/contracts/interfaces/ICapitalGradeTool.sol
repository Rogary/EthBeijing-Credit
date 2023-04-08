// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICapitalGradeTool {
    function getGrade(address addr)
        external
        view
        returns (
            uint256[] memory realTimeGrade
        );
}