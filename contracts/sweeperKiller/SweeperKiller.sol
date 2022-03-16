// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

contract SweeperKiller is ERC2771Context {
  constructor(address trustedForwarder) ERC2771Context(trustedForwarder) {}
  /**
   * @dev The public address calls this function for move tokens to another address
   * without any gas fee.
   * The middle node pays gas fee -> MetaTx generated by the public address -> 
   * The contract does delegate call on ERC20.transfer
   */
  function delegateTransfer(address _erc20Addr, address recipient) public returns(bytes memory) {
    ERC20 erc20 = ERC20(_erc20Addr);
    uint256 balance = erc20.balanceOf(_msgSender());
    require(balance > 0, "SweeperDefender: balance not enough");
    (bool success, bytes memory returnData) = _erc20Addr.delegatecall(abi.encodeWithSignature("transfer(address,uint256)", recipient, balance));
    require(success, "SweeperDefender: do delegate call on transfer failed");
    (bool transferSucc) = abi.decode(returnData, (bool));
    require(transferSucc, "SweeperDefender: internal transfer failed");
    // require(erc20.balanceOf(_msgSender()) == 0, "SweeperDefender: balance not 0");
    return returnData;
  }
}