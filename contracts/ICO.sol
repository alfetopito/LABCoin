pragma solidity ^0.5.0;

import "canonical-weth/contracts/WETH9.sol";
import './LABC.sol';

contract ICO {

    address public owner;
    uint32 public maxWeth = 1000;
    uint32 public totalDeposited = 0;
    uint32 public rate = 10;
    bool public finished = false;
    uint public timeFinished;
    WETH9 Weth;
    LABC Labc;
    mapping (address => uint32) public deposits;
    mapping (address => uint32) public pendingWithdraw;

    event Deposit(address who, uint32 amount);
    event Finished(uint time);
    event Withdraw(address who, uint32 amount);

    constructor(address tokenAddress, address payable wethAddress) public {
        Weth = WETH9(wethAddress);
        Labc = LABC(tokenAddress);
        owner = msg.sender;

        // Labc owner must be == msg.sender;
        Labc.mint(owner, maxWeth * rate * 10 ^ Labc.decimals());
    }

    function calculateAllowedAmount(uint32 amount) public view returns (uint32 allowedAmount) {
        // uint32 allowedAmount = 0;
        if (totalDeposited + amount > maxWeth ^ 18) {
            allowedAmount = maxWeth ^ 18 - totalDeposited;
        } else {
            allowedAmount = amount;
        }
        return allowedAmount;
    }

    function deposit(uint32 amount) public returns (bool success) {
        require(!finished, 'ICO is completed');
        require(totalDeposited < maxWeth ^ 18, 'No longer accepting deposits');

        uint32 allowedAmount = calculateAllowedAmount(amount);

        Weth.transferFrom(msg.sender, address(this), allowedAmount);
        
        deposits[msg.sender] += allowedAmount;
        pendingWithdraw[msg.sender] += allowedAmount * rate;
        totalDeposited += allowedAmount;

        emit Deposit(msg.sender, allowedAmount);

        if (totalDeposited >= maxWeth ^ 18) {
            finished = true;
            timeFinished = now;

            emit Finished(timeFinished);
        }

        return true;
    }

    function withdraw() public returns (bool success) {
        require(timeFinished < now + 2 minutes, 'Not time for whitdraw yet');
        require(pendingWithdraw[msg.sender] > 0, 'Nothing available to withdraw');

        uint32 amount = pendingWithdraw[msg.sender];
        pendingWithdraw[msg.sender] = 0;
        Labc.transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);

        return true;
    }
}