pragma solidity ^0.4.8;


contract token {function transfer(address receiver, uint amount){ }}

contract Crowdsale {
    address public beneficiary;
    uint public minimumTarget; uint public maximumTarget; uint public amountRaised; uint public deadline; uint public price = 0.0016 ether;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool public minimumTargetReached = false;
    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    bool crowdsaleClosed = false;

    /* data structure to hold information about campaign contributors */

    /*  at initialization, setup the owner */
    function Crowdsale(
        address ifSuccessfulSendTo,
        uint minimumTargetInEthers,
        uint maximumTargetInEthers,
        uint durationInMinutes,
        //uint etherCostOfEachToken,
        token addressOfTokenUsedAsReward
    ) {
        beneficiary = ifSuccessfulSendTo;
        minimumTarget = minimumTargetInEthers * price;
        maximumTarget = maximumTargetInEthers * price;
        deadline = now + durationInMinutes * 1 minutes;
        //price = etherCostOfEachToken * 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    // the function without name is the default function that is called whenever anyone sends funds to a contract
    function () payable {
        if (crowdsaleClosed || msg.value % price != 0 || (maximumTarget - amountRaised) < msg.value) throw;

        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);

        if (amountRaised >= minimumTarget && !minimumTargetReached) {
            minimumTargetReached = true;
        }

        if (minimumTargetReached) {
            if (beneficiary.send(amount)){
                FundTransfer(beneficiary, amount, false);
            }
        }
    }

    function devWithdrawal(uint num, uint den) {
        if (!minimumTargetReached || !(beneficiary == msg.sender)) throw;
        uint wAmount = num / den;
        if (beneficiary.send(wAmount)) {
            FundTransfer(beneficiary, wAmount, false);
        }
    }

    function closeCrowdsale(bool closeType) {
         if (beneficiary == msg.sender) {
            crowdsaleClosed = closeType;
         }
    }

    function returnTokens(uint tokensAmount) {
        if (!crowdsaleClosed) throw;
        if (beneficiary == msg.sender){
            tokenReward.transfer(beneficiary, tokensAmount);
        }
    }


    modifier afterDeadline() { if (now >= deadline) _; }

    // checks if the goal or time limit has been reached and ends the campaign
    function checkTargetReached() {
        if (amountRaised >= minimumTarget){
            minimumTargetReached = true;
        }
    }

    function safeWithdrawal() {
        if (!minimumTargetReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
    }
}