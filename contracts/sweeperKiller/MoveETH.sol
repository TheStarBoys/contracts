// SPDX-License-Identifier: GPL3.0
pragma solidity ^0.8.0;

contract MoveETH {
  constructor(address sendToAddress) payable {
    address payable addr = payable(address(sendToAddress));
    selfdestruct(addr);
  }
}
