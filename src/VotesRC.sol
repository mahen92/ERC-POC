pragma solidity ^0.8.20;

import {IERC5805} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC5805.sol";
import {Context} from "../lib/openzeppelin-contracts/contracts/utils/Context.sol";
import {NoncesRC} from "./NoncesRC.sol";
import {EIP712RC} from "./EIP712RC.sol";
import {CheckpointsRC} from "./CheckpointsRC.sol";
import {SafeCast} from "../lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol";
import {ECDSA} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {Time} from "../lib/openzeppelin-contracts/contracts/utils/types/Time.sol";
import {Test, console} from "forge-std/Test.sol";



abstract contract VotesRC is Context, EIP712RC, NoncesRC, IERC5805 {
    using CheckpointsRC for CheckpointsRC.Trace208;

    bytes32 private constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    mapping(address account => address) private _delegatee;
    mapping(address delegatee => CheckpointsRC.Trace208) private _delegateCheckpoints;
    CheckpointsRC.Trace208 private _totalCheckpoints;

    error ERC6372InconsistentClock();
    error ERC5805FutureLookup(uint256 timepoint, uint48 clock);

    function clock() public view virtual returns (uint48) {
        return Time.blockNumber();
    }

    function CLOCK_MODE() public view virtual returns (string memory) {
        if (clock() != Time.blockNumber()) {
            revert ERC6372InconsistentClock();
        }
        return "mode=blocknumber&from=default";
    }

    function getVotes(address account) public view virtual returns (uint256) {
        return _delegateCheckpoints[account].latest();
    }

    function getPastVotes(address account, uint256 timepoint) public view virtual returns (uint256) {
        uint48 currentTimepoint = clock();
        if (timepoint >= currentTimepoint) {
            revert ERC5805FutureLookup(timepoint, currentTimepoint);
        }
        return _delegateCheckpoints[account].upperLookupRecent(SafeCast.toUint48(timepoint));
    }

    function getPastTotalSupply(uint256 timepoint) public view virtual returns (uint256) {
        uint48 currentTimepoint = clock();
        if (timepoint >= currentTimepoint) {
            revert ERC5805FutureLookup(timepoint, currentTimepoint);
        }

        return _totalCheckpoints.upperLookupRecent(SafeCast.toUint48(timepoint));
    }

    function _getTotalSupply() internal view virtual returns (uint256) {
        return _totalCheckpoints.latest();
    }

    function delegates(address account) public view virtual returns (address) {
        return _delegatee[account];
    }

    function delegate(address delegatee) public virtual {
        address account = _msgSender();
        _delegate(account, delegatee);
    }

    function _delegate(address account, address delegatee) internal virtual {
        address oldDelegate = delegates(account);
        _delegatee[account] = delegatee;
        _moveDelegateVotes(oldDelegate, delegatee, _getVotingUnits(account));
    }

    function _transferVotingUnits(address from, address to, uint256 amount) internal virtual {
        console.log("VotesRC:transferVotingRights()");
        if (from == address(0)) {
            _push(_totalCheckpoints, _add, SafeCast.toUint208(amount));
            console.log("key:",_totalCheckpoints._checkpoints[0]._key);
            console.log("value:",_totalCheckpoints._checkpoints[0]._value);

        }
        if (to == address(0)) {
            _push(_totalCheckpoints, _subtract, SafeCast.toUint208(amount));
        }
        _moveDelegateVotes(delegates(from), delegates(to), amount);
    }

    function _moveDelegateVotes(address from, address to, uint256 amount) internal virtual {
        console.log("VotesRC:_moveDelegateVotes()");

        if (from != to && amount > 0) {
            if (from != address(0)) {
                (uint256 oldValue, uint256 newValue) =
                    _push(_delegateCheckpoints[from], _subtract, SafeCast.toUint208(amount));
                emit DelegateVotesChanged(from, oldValue, newValue);
            }
            if (to != address(0)) {
                (uint256 oldValue, uint256 newValue) = _push(_delegateCheckpoints[to], _add, SafeCast.toUint208(amount));
                emit DelegateVotesChanged(to, oldValue, newValue);
            }
        }
    }

    function _numCheckpoints(address account) internal view virtual returns (uint32) {
        return SafeCast.toUint32(_delegateCheckpoints[account].length());
    }

    function _push(
        CheckpointsRC.Trace208 storage store,
        function(uint208, uint208) view returns (uint208) op,
        uint208 delta
    ) private returns (uint208 oldValue, uint208 newValue) {
        return store.push(clock(), op(store.latest(), delta));
    }

    function _subtract(uint208 a, uint208 b) private pure returns (uint208) {
        return a - b;
    }

    function _add(uint208 a, uint208 b) private pure returns (uint208) {
        return a + b;
    }

    function _getVotingUnits(address) internal view virtual returns (uint256);

    function _checkpoints(address account, uint32 pos)
        internal
        view
        virtual
        returns (CheckpointsRC.Checkpoint208 memory)
    {
        return _delegateCheckpoints[account].at(pos);
    }
}
