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
}

module.exports = utils