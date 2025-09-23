// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Panagram} from "../src/Panagram.sol";
import {HonkVerifier} from "../src/Verifier.sol";

contract PanagramTest is Test{
   
   HonkVerifier public verifier;
   Panagram public panagram;
   address public constant PLAYER1 = address(0x1);
   uint256 constant FIELD_MODULUS  = 21888242871839275222246405745257275088548364400416034343698204186575808495617; //prime field order
   bytes32 ANSWER;
    
    function setUp() public{
        // deploy the verifier
        verifier = new HonkVerifier();

        // deploy the panagram contract
        panagram = new Panagram(verifier);


        // create the answer
        ANSWER = bytes32(uint256(keccak256("ANSWER")) % FIELD_MODULUS);

        // start a new round
        panagram.newRound(ANSWER);
        
    }

    function _getProof(bytes32 guess, bytes32 correctAnswer) internal returns (bytes memory _proof){
        uint256 NUM_ARGS = 5;
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/generate-proof.js";
        inputs[3] = vm.toString(guess);
        inputs[4] = vm.toString(correctAnswer);

        bytes memory encodedProof = vm.ffi(inputs);
        _proof = abi.decode(encodedProof, (bytes));
        console.logBytes(_proof);
    }

    // test someone receives NFT 0 if they guess correctly first
    function testCorrectFirstGuess() public {
        vm.prank(PLAYER1);
        bytes memory proof = _getProof(ANSWER, ANSWER);
        panagram.makeGuess(proof);
    }

    // test someone receive s NFT 1 if they guess correctly second
    // test we can start a new round after time has passed and there was a winner

}