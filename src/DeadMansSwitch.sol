// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DeadMansSwitch {
    address public owner;
    address payable public beneficiary;
    uint256 public lastCheckIn;
    uint256 public timeoutPeriod = 7 days;
    bool public triggered = false;

    event CheckedIn(address owner, uint256 time);
    event FundsDeposited(address owner, uint256 amount);
    event FundsWithdrawn(address beneficiary, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Not the beneficiary");
        _;
    }

    constructor(address payable _beneficiary) {
        owner = msg.sender;
        beneficiary = _beneficiary;
        lastCheckIn = block.timestamp;
    }

    // Owner deposits ETH into the contract
    function deposit() external payable onlyOwner {
        require(msg.value > 0, "Must send ETH");
        emit FundsDeposited(msg.sender, msg.value);
    }

    // Owner checks in to reset the timer
    function checkIn() external onlyOwner {
        lastCheckIn = block.timestamp;
        emit CheckedIn(msg.sender, block.timestamp);
    }

    // Beneficiary withdraws if owner hasn't checked in
    function withdraw() external onlyBeneficiary {
        require(
            block.timestamp >= lastCheckIn + timeoutPeriod,
            "Owner still active"
        );
        require(!triggered, "Already withdrawn");
        require(address(this).balance > 0, "No funds");

        triggered = true;
        uint256 amount = address(this).balance;
        beneficiary.transfer(amount);

        emit FundsWithdrawn(beneficiary, amount);
    }

    // Check contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Check time remaining before beneficiary can withdraw
    function timeRemaining() external view returns (uint256) {
        if (block.timestamp >= lastCheckIn + timeoutPeriod) return 0;
        return (lastCheckIn + timeoutPeriod) - block.timestamp;
    }

    // Owner can update beneficiary
    function updateBeneficiary(address payable _newBeneficiary) 
        external onlyOwner {
        beneficiary = _newBeneficiary;
    }

    // Owner can update timeout period
    function updateTimeoutPeriod(uint256 _days) external onlyOwner {
        timeoutPeriod = _days * 1 days;
    }
}
