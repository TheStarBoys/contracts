// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDTMock is ERC20 {
  constructor() ERC20("USDT Mock", "USDT") {
    _mint(_msgSender(), 10000000*10**18);
  }
}