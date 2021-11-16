// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

import "./Phase.sol";

abstract contract PhaseWithMax is Phase {
    function maxPhase() public virtual pure returns(uint256);
}