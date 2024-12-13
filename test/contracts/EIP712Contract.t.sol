pragma solidity ^0.8.20;

import "../../src/EIP712RC.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {Test, console} from "forge-std/Test.sol";

contract EIP712Contract is EIP712RC {
    struct Data {
        uint256 value;
        address user;
        uint256 nonce;
    }

    bytes32 private constant DATA_TYPEHASH = keccak256("Data(uint256 value,address user,uint256 nonce)");
    mapping(address => uint256) private messageMap;
    mapping(address => uint256) public nonces;

    constructor(string memory name, string memory version) EIP712RC(name, version) {}

    function buildDomainSeparator() public view returns (bytes32) {
        return _buildDomainSeparator();
    }

    function hashData(Data memory data) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(DATA_TYPEHASH, data.value, data.user, data.nonce));
        return _hashTypedDataV4(structHash);
    }

    function EIP712Name() public view returns (string memory) {
        return _EIP712Name();
    }

    function EIP712Version() public view returns (string memory) {
        return _EIP712Version();
    }

    function executeMethod(Data memory data, bytes memory signature) public {
        // Verify the signature
        bytes32 digest = hashData(data);
        address signer = ECDSA.recover(digest, signature);
        console.log("signer:", signer);
        console.log("user:", data.user);

        require(signer == data.user, "Invalid signature");
        require(nonces[data.user] == data.nonce, "Invalid nonce");

        // Update balances and nonce
        messageMap[data.user] = data.value;
        nonces[data.user] += 1;
    }

    function getMessage(address user) public returns (uint256) {
        return messageMap[user];
    }
}
