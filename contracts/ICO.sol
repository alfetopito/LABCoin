pragma solidity ^0.5.0;

import "canonical-weth/contracts/WETH9.sol";
import './LABC.sol';

contract ICO {

    address public owner;
    uint256 public maxWeth = 1000e18;
    uint256 public totalDeposited = 0;
    uint256 public rate = 10;
    bool public finished = false;
    uint public timeFinished;
    WETH9 Weth;
    LABC Labc;
    mapping (address => uint256) public deposits;
    mapping (address => uint256) public pendingWithdraw;

    event Deposit(address who, uint256 amount);
    event Finished(uint time);
    event Withdraw(address who, uint256 amount);

    constructor(address tokenAddress, address payable wethAddress) public {
        Weth = WETH9(wethAddress);
        Labc = LABC(tokenAddress);
        owner = msg.sender;
    }

    function calculateAllowedAmount(uint256 amount) public view returns (uint256 allowedAmount) {
        if (totalDeposited + amount > maxWeth) {
            allowedAmount = maxWeth - totalDeposited;
        } else {
            allowedAmount = amount;
        }
        return allowedAmount;
    }

    function deposit(uint256 amount) public returns (bool success) {
        require(!finished, 'ICO is completed');
        require(totalDeposited < maxWeth, 'No longer accepting deposits');

        uint256 allowedAmount = calculateAllowedAmount(amount);

        require(Weth.transferFrom(msg.sender, address(this), allowedAmount), 
                'Not allowed to transfer enough funds');
        
        deposits[msg.sender] += allowedAmount;
        pendingWithdraw[msg.sender] += allowedAmount * rate;
        totalDeposited += allowedAmount;

        emit Deposit(msg.sender, allowedAmount);

        if (totalDeposited >= maxWeth) {
            finished = true;
            timeFinished = now;

            emit Finished(timeFinished);
        }

        return true;
    }

    function withdraw() public returns (bool success) {
        require(timeFinished < now + 2 minutes, 'Not time for whitdraw yet');
        require(pendingWithdraw[msg.sender] > 0, 'Nothing available to withdraw');

        uint256 amount = pendingWithdraw[msg.sender];
        pendingWithdraw[msg.sender] = 0;
        Labc.transfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount);

        return true;
    }
}