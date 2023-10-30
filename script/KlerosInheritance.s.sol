// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/KlerosInheritance.sol";

contract KlerosInheritanceScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address heir = address(1); // ADD HEIR ADDRESS HERE.

        KlerosInheritance klerosInheritance = new KlerosInheritance(address(0), heir);

        vm.stopBroadcast();
    }
}
