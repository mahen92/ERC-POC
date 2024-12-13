pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "../../src/ERC20VotesRC.sol";
import "../../src/EIP712RC.sol";

contract VotesContract is ERC20VotesRC {
    constructor(string memory name, string memory version) EIP712RC(name,version)ERC20(name,version){}

    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s)
        external
        override
    {}

    


    function maxSupply() public view virtual returns (uint256) {
        return _maxSupply();
    }

    function mint(uint256 amt) public{
        console.log("VotesContract mint()");
        _mint(msg.sender,amt);
       // _update(address(0),msg.sender,amt);
    }

    function getVotingUnits(address account) public view virtual returns (uint256) {
        return _getVotingUnits(account);
    }
}
