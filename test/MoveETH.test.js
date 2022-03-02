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
const {
  toWei
} = web3.utils

const testUtils = require('./utils')

const MoveETH = artifacts.require('MoveETH')

const publicWallet = Wallet.fromPrivateKey(toBuffer('0x9a01f5c57e377e0239e6036b7b2d700454b760b2dab51390f1eeb2f64fe98b68'))
contract('MoveETH', ([private, dev]) => {
  let public
  beforeEach(async() => {
    public = publicWallet.getAddressString()
    this.contract = MoveETH.new(public, { from: private, value: toWei('1') })
  })

  it('test', async() => {
    assert.equal((await web3.eth.getBalance(public)), toWei('1'))
  })
})