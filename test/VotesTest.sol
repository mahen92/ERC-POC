// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../test/contracts/VotesContract.t.sol";
import "../src/CheckpointsRC.sol";

contract VotesTest is Test {
    VotesContract vc;
    address alice = makeAddr("alice");

    function setUp() public {
        vc = new VotesContract("VC", "1");
    }

    function test_maxSupply() public{
         console.log(vc.maxSupply());
    }

    function test_getVotingUnits() public{
        vm.startPrank(alice);
        vc.mint(20);
        vm.stopPrank();
        console.log("voting units:",vc.getVotingUnits(alice));
    }

   function test_getCheckPoint() public{
        vm.startPrank(alice);
        vc.mint(20);
        vm.stopPrank();
        console.log("voting units:",vc.getVotingUnits(alice));
        CheckpointsRC.Checkpoint208 memory checkPoint=vc.checkpoints(alice,0);
        console.log("key:",checkPoint._key);
        console.log("value:",checkPoint._value);
    }

}
