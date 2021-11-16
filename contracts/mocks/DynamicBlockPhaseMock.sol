// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

import "../phase/DynamicBlockPhase.sol";

contract DynamicBlockPhaseMock is DynamicBlockPhase {
    using SafeMath for uint256;

    constructor() DynamicBlockPhase() {}

    function maxBlockPhase() public override virtual pure returns(uint256) {
        return 4;
    }

    function blocksGivenPhase(uint256 _phase) public override virtual pure returns(uint256) {
        return _phase.add(1);
    }
}