// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PhaseWithMax.sol";
import "./DynamicBlockPhase.sol";

abstract contract DynamicBlockPhaseWithMax is PhaseWithMax, DynamicBlockPhase {
    using SafeMath for uint256;

    constructor() DynamicBlockPhase() {}

    function maxPhase() public override pure returns(uint256) {
        return maxBlockPhase();
    }

    /**
     * @dev need to implement in child contract.
     * Its range is from 0 to maxBlockPhase, excluding maxBlockPhase.
     */
    function maxBlockPhase() public virtual pure returns(uint256);

    function increasedBlockPhase() public override view returns(uint256) {
        if (lastBlockPhase >= maxBlockPhase()) {
            return 0;
        }

        uint256 duration = block.number.sub(lastBlock);
        uint256 curr = lastBlockPhase;
        while (duration > 0 && duration >= blocksGivenPhase(curr)) {
            duration = duration.sub(blocksGivenPhase(curr));
            curr = curr.add(1);
        }

        return curr <= maxBlockPhase() ? curr.sub(lastBlockPhase) : maxBlockPhase().sub(lastBlockPhase);
    }

    function blocksOfCurrPhase() public override view returns(uint256) {
        uint256 _phase = blockPhase();
        if (_phase >= maxBlockPhase()) {
            return 0;
        }

        return blocksGivenPhase(_phase);
    }
}