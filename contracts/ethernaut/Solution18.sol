// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// TODO
contract Solution18 {
    function whatIsTheMeaningOfLife() public pure returns(uint256 ret) {
        assembly {
            ret := 666
        }
    }
}