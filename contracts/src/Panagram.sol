//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";

contract Panagram is ERC1155, Ownable {
    IVerifier public immutable verifier;

    uint256 public constant MIN_DURATION = 10800;
    uint256 public s_roundStartTime;
    uint256 public s_currentRound;
    address public s_currentRoundWinner;
    bytes32 public s_answer;


    // Events
    event PanagramVerifierUpdated(address newVerifier);
    event Panagram_NewRoundStarted(bytes32 answer);

    // Errors
    error Panagram_MinTimeNotPassed(uint256 required, uint256 actual);
    error Panagram_NoWinner();

    constructor(IVerifier _verifier) ERC1155("ipfs://QmPlaceholderCID/{id}.json") Ownable(msg.sender){
        verifier = _verifier;
    }
    // function to create a round
    function newRound(bytes32 _answer) external onlyOwner {
        if (s_roundStartTime == 0){
            s_roundStartTime = block.timestamp;
            s_answer = _answer;
        }
        else{
            if (block.timestamp < s_roundStartTime + MIN_DURATION){
                revert Panagram_MinTimeNotPassed(MIN_DURATION, block.timestamp - s_roundStartTime);
            }
            if (s_currentRoundWinner == address(0)){
                // no winner, round is void
                revert Panagram_NoWinner();
            }
            // Reset the round
            s_roundStartTime = block.timestamp;
            s_currentRoundWinner = address(0);
            s_answer = _answer;
        }
        s_currentRound++;
       emit Panagram_NewRoundStarted(_answer);
    }

    // function to allow users to submit a guess

    // set a new verifier
    function setVerifier(IVerifier _verifier) external onlyOwner {
        emit PanagramVerifierUpdated(address(_verifier));
    }
  }
