// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DeadMansSwitch {
    // Custom errors
    error NotOwner();
    error NotBeneficiary();
    error OwnerStillActive();
    error AlreadyWithdrawn();
    error NoFunds();
    error MustSendETH();

    address public owner;
    address payable public beneficiary;
    uint256 public lastCheckIn;
    uint256 public timeoutPeriod = 7 days;
    bool public triggered = false;

    event CheckedIn(address owner, uint256 time);
    event FundsDeposited(address owner, uint256 amount);
    event FundsWithdrawn(address beneficiary, uint256 amount);

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert NotBeneficiary();
        _;
    }

    constructor(address payable _beneficiary) {
        owner = msg.sender;
        beneficiary = _beneficiary;
        lastCheckIn = block.timestamp;
    }

    // Owner deposits ETH into the contract
    function deposit() external payable onlyOwner {
        if (msg.value == 0) revert MustSendETH();
        emit FundsDeposited(msg.sender, msg.value);
    }

    // Owner checks in to reset the timer
    function checkIn() external onlyOwner {
        lastCheckIn = block.timestamp;
        emit CheckedIn(msg.sender, block.timestamp);
    }

    // Beneficiary withdraws if owner hasn't checked in
    function withdraw() external onlyBeneficiary {
        if (block.timestamp < lastCheckIn + timeoutPeriod) 
            revert OwnerStillActive();
        if (triggered) revert AlreadyWithdrawn();
        if (address(this).balance == 0) revert NoFunds();

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
