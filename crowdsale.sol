pragma solidity ^0.4.8;


contract token {function transfer(address receiver, uint amount){ }}



contract Crowdsale {
    mapping(address => uint256) public balance;
    address public benefAddress;
    uint public tokenPrice; uint public tokensForSale; uint public soldTokensCounter; uint public raisedAmount; uint public deadline;
    token public tokenRew;
    event GoalReached(address benefAddress, uint raisedAmount);
    event FundTransfer(address backer, uint amount, bool isContribution);

    
    function Crowdsale(
        address amountRaisedAddress,
        uint crowdsaleDuration,
        uint totalTokensForSale,
        uint etherTokenPrice,
        token tokenAddress
    ) {
        benefAddress = amountRaisedAddress;
        deadline = now + crowdsaleDuration * 1 minutes;
        tokensForSale = totalTokensForSale;
        tokenPrice = etherTokenPrice * 1 ether;
        tokenRew = token(tokenAddress);
    }

    function () payable {
        if (soldTokensCounter >= tokensForSale || (tokensForSale - soldTokensCounter) * tokenPrice < msg.value || msg.value % tokenPrice != 0) throw;
        uint amount = msg.value;
        balance[msg.sender] += amount;
        raisedAmount += amount;
        uint soldTokens = amount / tokenPrice;
        soldTokensCounter += soldTokens;
        tokenRew.transfer(msg.sender, soldTokens);
        FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() {if (now >= deadline) _;}
    function safeWithdrawal() afterDeadline {
        if (benefAddress == msg.sender) {
            if (benefAddress.send(raisedAmount)) {
                FundTransfer(benefAddress, raisedAmount, false);
            } 
        }
    }
}