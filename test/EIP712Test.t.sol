// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../test/contracts/EIP712Contract.t.sol";

contract EIP712Test is Test {
    EIP712Contract eip712RC;
    address alice = makeAddr("alice");

    function setUp() public {
        eip712RC = new EIP712Contract("EIP", "1");
    }

    function test_buildDomainSeparator() public {
        console.log("buildDomainSeparator()");
        console.logBytes32(eip712RC.buildDomainSeparator());
    }

    /*function test_hashTypedDataV4() public {
        EIP712Contract.Data memory data = EIP712Contract.Data({
            message:"test",
            value:1
        });
        bytes32 hash=eip712RC.hashData(data);
        console.log("hashTypedDataV4");
        console.logBytes32(hash);
    }*/

    function test_EIP712Name() public {
        console.log("name", eip712RC.EIP712Name());
    }

    function test_EIP712Version() public {
        console.log("version", eip712RC.EIP712Version());
    }

    function test_executeMethod() public {
        address signer = vm.addr(1);
        console.log("Signer address:", signer);

        EIP712Contract.Data memory data = EIP712Contract.Data({value: 5, user: signer, nonce: 0});

        // Hash the message to sign
        bytes32 hash = eip712RC.hashData(data);
        console.logBytes32(hash);

        // Sign the message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);

        vm.stopPrank();
        bytes memory signature = abi.encodePacked(r, s, v);
        eip712RC.executeMethod(data, signature);
        console.log(eip712RC.getMessage(signer));
    }
}
