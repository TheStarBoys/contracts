const USDTMock = artifacts.require('USDTMock')
const GovernanceToken = artifacts.require('GovernanceToken')
const TimelockController = artifacts.require('MyTimelock')
const MyGovernor = artifacts.require('MyGovernorComp')
const ethers = require('ethers')
const { toWei, fromWei } = web3.utils

const fs = require('fs')

module.exports = async (deployer, network, accounts) => {
    console.log(">>>>> network: ", network)
    await deploy(deployer, network, accounts)
}

let deployedContracts = {
    governance_token: '',
    timelock: '',
    my_governor: '',
    startBlock: 0,
}

const deploy = async (deployer, network, accounts) => {
    deployedContracts.startBlock = await web3.eth.getBlockNumber()
    if (network.indexOf('testnet') != -1 || network == 'development') {
        await deployContractsInTestnet(deployer, accounts)
    } else if (network == 'bscmainnet') {
    }

    if (network != 'test' && network != 'development') {
        console.log('deployedContracts: ', deployedContracts)
        
        let obj = JSON.parse(fs.readFileSync('./deployedContracts.json'))
        obj[network] = deployedContracts
        fs.writeFileSync('./deployedContracts.json', JSON.stringify(obj, null, 2))
    }
}

const deployContractsInTestnet = async (deployer, [dev, alice, bob]) => {
    await deployer.deploy(USDTMock)
    let usdt = await USDTMock.deployed()
    await deployer.deploy(GovernanceToken)
    let governanceToken = await GovernanceToken.deployed()
    deployedContracts.governance_token = governanceToken.address

    // self-delegate
    await governanceToken.delegate(dev)

    let nonce = await web3.eth.getTransactionCount(dev)
    let timelockAddr = ethers.utils.getContractAddress({from: dev, nonce: nonce})
    let myGovernorAddr = ethers.utils.getContractAddress({from: dev, nonce: nonce+1})
    console.log(`dev: ${dev} nonce: ${nonce} timelockAddr: ${timelockAddr}, myGovernorAddr: ${myGovernorAddr}`)

    await deployer.deploy(TimelockController, 1 * 60, [myGovernorAddr], ['0x0000000000000000000000000000000000000000'])
    deployedContracts.timelock = timelockAddr

    await deployer.deploy(MyGovernor, governanceToken.address, timelockAddr)
    // await deployer.deploy(MyGovernor, governanceToken.address)
    deployedContracts.my_governor = myGovernorAddr

    // Transfer USDT into treasury of the DAO.
    await usdt.transfer(timelockAddr, '1000')

    showTokenBalance(timelockAddr, usdt)

    const usdtContract = new ethers.Contract(usdt.address, `[{
        "inputs": [
          {
            "internalType": "address",
            "name": "recipient",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "amount",
            "type": "uint256"
          }
        ],
        "name": "transfer",
        "outputs": [
          {
            "internalType": "bool",
            "name": "",
            "type": "bool"
          }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
      }]`)

    const transferCalldata = usdtContract.interface.encodeFunctionData('transfer', [alice, '50'])
    // Create a proposal
    let myGovernor = await MyGovernor.deployed()
    let proposalCreatedTx = await myGovernor.propose(
        [usdt.address], // targets
        ['0'], // values
        [transferCalldata], // calldatas
        'Proposal #1: Give grant to team' // description
    )
    console.log('proposalCreatedTx: ', proposalCreatedTx)

    console.log('proposalId: ', proposalCreatedTx.logs[0].args.proposalId.toString())
}

const showTokenBalance = async (targetAddr, token) => {
    console.log('token balance: ', (await token.balanceOf(targetAddr)).toString())
}