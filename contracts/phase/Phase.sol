// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

abstract contract Phase {
    function phase() public virtual view returns(uint256);
    function updatePhase() public virtual;
}