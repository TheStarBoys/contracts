const { assert } = require("chai")
const { web3, BN } = require("@openzeppelin/test-helpers/src/setup");
const Wallet = require('ethereumjs-wallet').default;
const {
  toBuffer,
  keccak256,
} = require("ethereumjs-util");

const {
    expectRevert,
    time
} = require('@openzeppelin/test-helpers')
const testUtils = require('./utils')

const MetaTx = artifacts.require('MetaTx')
const SweeperKiller = artifacts.require('SweeperKiller')
const USDT = artifacts.require('USDTMock')

const publicWallet = Wallet.fromPrivateKey(toBuffer('0x9a01f5c57e377e0239e6036b7b2d700454b760b2dab51390f1eeb2f64fe98b68'))

contract('SweeperKiller', ([public, private, dev]) => {
  // The public address where locked a number of ERC20 tokens but without any ETH.
  // The private address which owned a number of ETH tries to transfer tokens from the public address.
  beforeEach(async() => {
    this.metaTx = await MetaTx.new({ from: dev })
    this.usdt = await USDT.new({ from: public })
    this.sk = await SweeperKiller.new(this.metaTx.address, { from: dev })
  })

  it('If public has enough ETH', async() => {
    // the public address does call.
    const receipt = await this.sk.delegateTransfer(this.usdt.address, private, { from: public })
    const transferEvent = testUtils.getEventArgsFromTx(receipt, 'Transfer')
    console.log('event: ', transferEvent)
    console.log('msgSender: ', await this.usdt.transferMsgSender())
  })

  // it('If public does not have enough ETH', async() => {

  // })
})