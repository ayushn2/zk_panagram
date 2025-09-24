//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";

contract Panagram is ERC1155, Ownable {
    IVerifier public s_verifier;

    uint256 public constant MIN_DURATION = 10800;
    uint256 public s_roundStartTime;
    uint256 public s_currentRound;
    address public s_currentRoundWinner;
    bytes32 public s_answer;
    mapping (address => uint256) public s_lastCorrectGuessRound;


    // Events
    event PanagramVerifierUpdated(address newVerifier);
    event Panagram_NewRoundStarted(bytes32 answer);
    event Panagram_WinnerCrowned(address indexed winner, uint256 round);
    event Panagram_RunnerUpCrowned(address indexed runnerUp, uint256 indexed round);

    // Errors
    error Panagram_MinTimeNotPassed(uint256 required, uint256 actual);
    error Panagram_NoWinner();
    error Panagram__FirstPanagramNotSet();
    error Panagram__alreadyWon(uint256 round, address user);
    error Panagram__InvalidProof();

    constructor(IVerifier _verifier) ERC1155("ipfs://QmPlaceholderCID/{id}.json") Ownable(msg.sender){
        s_verifier = _verifier;
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
    function makeGuess(bytes memory _proof) external returns (bool) {
        // check whether the first round has been initialized
        if (s_currentRound == 0){
            revert Panagram__FirstPanagramNotSet();
        }
        // check if the user has laready won this round
        if (s_lastCorrectGuessRound[msg.sender] == s_currentRound){
            revert Panagram__alreadyWon(s_currentRound, msg.sender);
        }
        // check the proof and verify with verifier smart contract
        bytes32[] memory publicInputs = new bytes32[](1);
        publicInputs[0] = s_answer;
        bool proofResult = s_verifier.verify(_proof, publicInputs);
        if (!proofResult){
            revert Panagram__InvalidProof();
        }
        s_lastCorrectGuessRound[msg.sender] = s_currentRound;
        if (s_currentRoundWinner == address(0)){
            s_currentRoundWinner = msg.sender;
            _mint(msg.sender, 0, 1, "");
            emit Panagram_WinnerCrowned(msg.sender, s_currentRound);
        }else{
            _mint(msg.sender,1 ,1, "");
            emit Panagram_RunnerUpCrowned(msg.sender, s_currentRound);
        }
        return proofResult;
        // revert if incorrect
        // if correct, check if they are first, f they ar theb mint them NFT 0
        // if they are second, mint them NFT 1
    }

    // set a new verifier
    function setVerifier(IVerifier _verifier) external onlyOwner {
        s_verifier = _verifier;
        emit PanagramVerifierUpdated(address(_verifier));
    }
  }
