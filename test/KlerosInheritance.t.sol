// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/KlerosInheritance.sol";

contract KlerosInheritanceTest is Test {
    KlerosInheritance public klerosInheritance;
    address public owner;
    address public heir;
    address public newHeir;
    address public attacker;
    uint256 lastActivity;

    function setUp() public {
        owner = makeAddr("owner");
        heir = makeAddr("heir");
        newHeir = makeAddr("newHeir");
        attacker = makeAddr("attacker");

        vm.prank(owner);
        klerosInheritance = new KlerosInheritance(address(0), heir);

        lastActivity = block.timestamp;
    }

    function testNormalStateAfterDeployment() public {
        assertEq(klerosInheritance.owner(), owner);
        assertEq(klerosInheritance.lastActivity(), lastActivity);
        assertEq(klerosInheritance.heir(), heir);
    }

    function testTransferETH(uint256 _amount) public {
        vm.assume(_amount != 0 && _amount != type(uint256).max);
        address alice = makeAddr("alice");
        vm.deal(alice, _amount);

        uint256 aliceBalanceBefore = alice.balance;
        uint256 contractBalanceBefore = address(klerosInheritance).balance;

        vm.prank(alice);
        (bool status,) = address(klerosInheritance).call{value: _amount}("");
        assert(status);

        uint256 aliceBalanceAfter = alice.balance;
        uint256 contractBalanceAfter = address(klerosInheritance).balance;

        assertEq(aliceBalanceBefore - _amount, aliceBalanceAfter);
        assertEq(contractBalanceBefore + _amount, contractBalanceAfter);
    }

    function testFuzzOwnerActivity(uint256 _timeToSkip) public {
        vm.assume(_timeToSkip != 0);
        uint256 timeToSkip = _timeToSkip % 2 ** 100;

        vm.prank(owner);
        klerosInheritance.ownerActive();

        lastActivity = block.timestamp;

        skip(timeToSkip);

        vm.prank(owner);
        klerosInheritance.ownerActive();

        assertEq(lastActivity + timeToSkip, klerosInheritance.lastActivity());
    }

    function testHeirTakeControlAfterTimelock() public {
        lastActivity = klerosInheritance.lastActivity();
        skip(klerosInheritance.timeLock() + 1);

        vm.prank(heir);
        klerosInheritance.takeControl(newHeir);

        assertEq(klerosInheritance.owner(), heir);
        assertEq(klerosInheritance.lastActivity(), block.timestamp);
        assertEq(klerosInheritance.heir(), newHeir);
    }

    function testHeirTakeControlBeforeTimelock() public {
        vm.prank(owner);
        klerosInheritance.ownerActive();

        vm.prank(heir);
        vm.expectRevert();
        klerosInheritance.takeControl(newHeir);
    }

    function testFuzzAttackerTakeControl(address _attacker) public {
        vm.assume(_attacker != owner);

        vm.prank(_attacker);
        vm.expectRevert();
        klerosInheritance.takeControl(newHeir);
    }

    function testFuzzCallWithdrawByOwner(uint256 _balance, uint256 _toWithdraw) public {
        vm.assume(_toWithdraw != 0);
        vm.deal(address(klerosInheritance), _balance);

        if (_balance >= _toWithdraw) {
            uint256 ownerBalanceBefore = address(owner).balance;
            uint256 contractBalanceBefore = address(klerosInheritance).balance;

            vm.prank(owner);
            klerosInheritance.withdraw(_toWithdraw);

            uint256 ownerBalanceAfter = address(owner).balance;
            uint256 contractBalanceAfter = address(klerosInheritance).balance;

            assertEq(ownerBalanceBefore + _toWithdraw, ownerBalanceAfter);
            assertEq(contractBalanceBefore - _toWithdraw, contractBalanceAfter);
        } else {
            vm.prank(owner);
            vm.expectRevert();
            klerosInheritance.withdraw(_toWithdraw);
        }
    }

    function testFuzzCallWithdrawByAnyoneOtherThanOwner(address _attacker, uint256 _amount) public {
        vm.assume(_attacker != owner);
        vm.assume(_amount != 0 && _amount < type(uint256).max);

        vm.deal(address(klerosInheritance), type(uint256).max);

        vm.prank(_attacker);
        vm.expectRevert();
        klerosInheritance.withdraw(_amount);
    }
}
