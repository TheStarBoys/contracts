// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract DynamicBlockPhase {
    using SafeMath for uint256;

    event BlockPhaseUpdated(uint256 lastBlock, uint256 phase);

    uint256 public startBlock;
    uint256 public lastBlock;
    uint256 public lastBlockPhase;

    constructor() {
        startBlock = block.number;
        lastBlock = startBlock;
    }

    /**
     * @dev need to implement in child contract.
     * Its range is from 0 to maxBlockPhase, excluding maxBlockPhase.
     */
    function maxBlockPhase() public virtual pure returns(uint256);

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

    function increasedBlockPhase() public view returns(uint256) {
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

    function blockPhase() public view returns(uint256) {
        return lastBlockPhase.add(increasedBlockPhase());
    }

    function blocksOfCurrPhase() public view returns(uint256) {
        uint256 _phase = blockPhase();
        if (_phase >= maxBlockPhase()) {
            return 0;
        }

        return blocksGivenPhase(_phase);
    }

    /**
     * @dev need to implement in child contract.
     */
    function blocksGivenPhase(uint256 _phase) public virtual pure returns(uint256);
}