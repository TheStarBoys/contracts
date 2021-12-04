const { web3 } = require("@openzeppelin/test-helpers/src/setup");
const ethSigUtil = require('eth-sig-util');
const Wallet = require('ethereumjs-wallet').default;

const MetaTxName = 'MinimalForwarder';
const MetaTxVersion = '0.0.1';
const EIP712Domain = [
    { name: 'name', type: 'string' },
    { name: 'version', type: 'string' },
    { name: 'chainId', type: 'uint256' },
    { name: 'verifyingContract', type: 'address' },
];
const MetaTxTypes = {
    EIP712Domain,
    ForwardRequest: [
      { name: 'from', type: 'address' },
      { name: 'to', type: 'address' },
      { name: 'value', type: 'uint256' },
      { name: 'gas', type: 'uint256' },
      { name: 'nonce', type: 'uint256' },
      { name: 'data', type: 'bytes' },
    ],
}

const getTypedMessage = async (req, metaTxAddr) => {
    const domain = {
        name: MetaTxName,
        version: MetaTxVersion,
        chainId: await web3.eth.getChainId(),
        verifyingContract: metaTxAddr,
    }
    return {
        types: MetaTxTypes,
        domain: domain,
        primaryType: 'ForwardRequest',
        message: req,
    }
}

const signTypedData = (wallet, typedData) => {
    return ethSigUtil.signTypedMessage(
        wallet.getPrivateKey(),
        {
            data: typedData,
        },
    )
}

const utils = {
    getEventArgsFromTx: (txReceipt, eventName) => {
        let res = txReceipt.logs.filter((log) => {
            return log.event === eventName
        })
        if (res.length == 0) {
            return null
        }
        return res[0].args
    },
    executeMetaTx: async (wallet, delegatorAddr, metaTxContract, method, to, value, domain) => {
        let fromAddr = web3.utils.toChecksumAddress(wallet.getAddressString())
        let gas = await method.estimateGas({ from: fromAddr })
        let data = method.encodeABI()
        let nonce = await web3.eth.getTransactionCount(fromAddr)
    
        let req = {
            from: fromAddr,
            to: web3.utils.toChecksumAddress(to),
            value: value,
            gas: gas,
            nonce: Number(nonce),
            data: data,
        }
    
        let typedData = await getTypedMessage(req, metaTxContract.address)
        let signature = signTypedData(wallet, typedData)
    
        let [succ, returnData] = await metaTxContract.methods.execute(req, signature).call({ from: delegatorAddr })
        if (!succ) {
            console.error('metaTx does execute call failed')
            return
        }
        // NOTE: MUST estimateGas
        let fnGas = await metaTxContract.methods.execute(req, signature).estimateGas({ from: delegatorAddr })
        let receipt = await metaTxContract.methods.execute(req, signature).send({ from: delegatorAddr, gas: fnGas })
    
        return [returnData, receipt]
    }
}

module.exports = utils