const { assert } = require("chai")
const { web3, BN } = require("@openzeppelin/test-helpers/src/setup");

const {
    expectRevert,
    time
} = require('@openzeppelin/test-helpers')
const testUtils = require('./utils')

const DynamicBlockPhase = artifacts.require('DynamicBlockPhaseMock')

contract('DynamicBlockPhase', ([dev]) => {
    beforeEach(async () => {
        this.phase = await DynamicBlockPhase.new({ from: dev })
        this.startBlock = await time.latestBlock()
        this.expect = async (expectedPhase, expectedBlocksGiven, expectedBlocks, expectedIncreasedBlockPhase) => {

            assert.equal(await this.phase.blocksGivenPhase(expectedPhase), expectedBlocksGiven, 'unexpected blocks given phase')
            assert.equal(await this.phase.increasedBlockPhase(), expectedIncreasedBlockPhase, 'unexpected increased block phase')
            assert.equal(await this.phase.blockPhase(), expectedPhase, 'unexpected block phase')
            assert.equal(await this.phase.blocksOfCurrPhase(), expectedBlocks, 'unexpected blocks of current phase')
        }

        this.expectState = async (expectedStartBlock, expectedLastBlock, expectedLastBlockPhase) => {
            assert.equal((await this.phase.startBlock()).toString(), expectedStartBlock, 'unexpected start block')
            assert.equal((await this.phase.lastBlock()).toString(), expectedLastBlock, 'unexpected last block')
            assert.equal((await this.phase.lastBlockPhase()).toString(), expectedLastBlockPhase, 'unexpected last block phase')
        }

        this.advance = async (number) => {
            await time.advanceBlockTo(this.startBlock.add(new BN(number)))
        }
    })

    it('Nothing to update', async () => {
        await this.expectState(this.startBlock, this.startBlock, '0')
        await this.expect('0', '1', '1', '0')

        await this.advance(6)
        await this.expect('3', '4', '4', '3')
        await this.phase.updateBlockPhase()
        await this.expect('3', '4', '4', '0')

        await this.advance(7)
        await this.expect('3', '4', '4', '0')
        // Nothing to update
        await this.phase.updateBlockPhase()
        await this.expect('3', '4', '4', '0')
        
        await this.advance(8)
        await this.expect('3', '4', '4','0')
        // Nothing to update
        await this.phase.updateBlockPhase()
        await this.expect('3', '4', '4', '0')
    })

    it('Just reach max phase', async () => {
        await this.expectState(this.startBlock, this.startBlock, '0')
        await this.expect('0', '1', '1', '0')

        await this.advance(1)
        await this.expect('1', '2', '2', '1')

        await this.advance(3)
        await this.expect('2', '3', '3', '2')

        await this.advance(6)
        await this.expect('3', '4', '4', '3')

        // Reach max phase
        await this.advance(10)
        await this.expect('4', '5', '0', '4')
        await this.phase.updateBlockPhase()
        await this.expectState(this.startBlock, this.startBlock.add(new BN(10)), '4')
        await this.expect('4', '5', '0', '0')

        // Do not increase phase anymore
        await this.advance(15)
        await this.expect('4', '5', '0', '0')
    })

    it('Beyond max phase directly', async () => {
        await this.expectState(this.startBlock, this.startBlock, '0')
        await this.expect('0', '1', '1', '0')

        // Reach max phase
        await this.advance(10)
        await this.expect('4', '5', '0', '4')

        // Do not increase phase anymore
        await this.advance(20)
        await this.phase.updateBlockPhase()
        await this.expect('4', '5', '0', '0')
    })
})