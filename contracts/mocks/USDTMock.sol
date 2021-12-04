// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDTMock is ERC20 {
  address public transferMsgSender = address(1);
  
  constructor() ERC20("USDT Mock", "USDT") {
    _mint(_msgSender(), 10000000*10**18);
  }

  function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
    transferMsgSender = _msgSender();
    emit Transfer(_msgSender(), recipient, amount);
    return true;
  }
}