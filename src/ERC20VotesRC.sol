pragma solidity ^0.8.20;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {VotesRC} from "./VotesRC.sol";
import {CheckpointsRC} from "./CheckpointsRC.sol";
import {Test, console} from "forge-std/Test.sol";


abstract contract ERC20VotesRC is ERC20, VotesRC {
        
    error ERC20ExceededSafeSupply(uint256 increasedSupply, uint256 cap);

    function _maxSupply() internal view virtual returns (uint256) {
        return type(uint208).max;
    }

    function _update(address from,address to,uint256 value) internal virtual override{
        console.log("ERC20VotesRC:_update()");
        super._update(from,to,value);
        if (from == address(0)) {
            uint256 supply = totalSupply();
            uint256 cap = _maxSupply();

            if (supply > cap) {
                revert ERC20ExceededSafeSupply(supply, cap);
            }

            _transferVotingUnits(from, to, value);
        }
    }

    function _getVotingUnits(address account) internal view virtual override returns (uint256) {
        return balanceOf(account);
    }

    function numCheckpoints(address account) public view virtual returns (uint32) {
        return _numCheckpoints(account);
    }

    function checkpoints(address account, uint32 pos) public view virtual returns (CheckpointsRC.Checkpoint208 memory) {
        return _checkpoints(account, pos);
    }

}

