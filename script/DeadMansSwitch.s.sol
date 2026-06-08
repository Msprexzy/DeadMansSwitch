// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {DeadMansSwitch} from "../src/DeadMansSwitch.sol";

contract DeadMansSwitchScript is Script {
    function run() external {
        vm.startBroadcast();
        new DeadMansSwitch(payable(address(1)));
        vm.stopBroadcast();
    }
}
