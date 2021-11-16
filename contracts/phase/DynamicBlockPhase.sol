// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Phase.sol";

abstract contract DynamicBlockPhase is Phase {
    using SafeMath for uint256;

    event BlockPhaseUpdated(uint256 lastBlock, uint256 phase);

    uint256 public startBlock;
    uint256 public lastBlock;
    uint256 public lastBlockPhase;

    constructor() {
        startBlock = block.number;
        lastBlock = startBlock;
    }

    function updatePhase() public override {
        return updateBlockPhase();
    }

    function updateBlockPhase() public {
        uint256 phaseNum = increasedBlockPhase();
        if (phaseNum >= 1) {
            for (uint256 i = 0; i < phaseNum; i++) {
                lastBlock = lastBlock.add(blocksGivenPhase(lastBlockPhase.add(i)));
            }
            lastBlockPhase = lastBlockPhase.add(phaseNum);
            emit BlockPhaseUpdated(lastBlock, lastBlockPhase);
        }
    }

    function increasedBlockPhase() public virtual view returns(uint256) {
        uint256 duration = block.number.sub(lastBlock);
        uint256 curr = lastBlockPhase;
        while (duration > 0 && duration >= blocksGivenPhase(curr)) {
            duration = duration.sub(blocksGivenPhase(curr));
            curr = curr.add(1);
        }

        return curr.sub(lastBlockPhase);
    }

    function blockPhase() public view returns(uint256) {
        return lastBlockPhase.add(increasedBlockPhase());
    }

    function blocksOfCurrPhase() public virtual view returns(uint256) {
        return blocksGivenPhase(blockPhase());
    }

    /**
     * @dev need to implement in child contract.
     */
    function blocksGivenPhase(uint256 _phase) public virtual pure returns(uint256);
}