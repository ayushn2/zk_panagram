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

    function _getProof(bytes32 guess, bytes32 correctAnswer, address sender) internal returns (bytes memory _proof){
        uint256 NUM_ARGS = 6;
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/generateProof.ts";
        inputs[3] = vm.toString(guess);
        inputs[4] = vm.toString(correctAnswer);
        inputs[5] = vm.toString(sender);

        bytes memory encodedProof = vm.ffi(inputs);
        _proof = abi.decode(encodedProof, (bytes));
        console.logBytes(_proof);
    }

    // test someone receives NFT 0 if they guess correctly first
    function testCorrectFirstGuess() public {
        vm.prank(PLAYER1);
        bytes memory proof = _getProof(ANSWER, ANSWER, PLAYER1);
        panagram.makeGuess(proof);
        vm.assertEq(panagram.balanceOf(PLAYER1, 0), 1);
        vm.assertEq(panagram.balanceOf(PLAYER1, 1), 0);

        vm.prank(PLAYER1);
        vm.expectRevert();
        panagram.makeGuess(proof);
    }

    // test someone receive s NFT 1 if they guess correctly second
    function testCorrectSecondGuess() public {
        vm.prank(PLAYER1);
        bytes memory proof = _getProof(ANSWER, ANSWER, PLAYER1);
        panagram.makeGuess(proof);
        vm.assertEq(panagram.balanceOf(PLAYER1, 0), 1);
        vm.assertEq(panagram.balanceOf(PLAYER1, 1), 0);

        address PLAYER2 = makeAddr("user2");
        vm.prank(PLAYER2);
        bytes memory proof2 = _getProof(ANSWER, ANSWER, PLAYER2);
        panagram.makeGuess(proof2);
        vm.assertEq(panagram.balanceOf(PLAYER2, 0), 0);
        vm.assertEq(panagram.balanceOf(PLAYER2, 1), 1);

    }

    // test we can start a new round after time has passed and there was a winner

    function testStartSecondRound() public{
        vm.prank(PLAYER1);
        bytes memory proof = _getProof(ANSWER, ANSWER, PLAYER1);
        panagram.makeGuess(proof);
        vm.assertEq(panagram.balanceOf(PLAYER1, 0), 1);
        vm.assertEq(panagram.balanceOf(PLAYER1, 1), 0);

        vm.warp(panagram.MIN_DURATION() + 1);
        bytes32 NEW_ANSWER = bytes32(uint256(keccak256("NEW_ANSWER")) % FIELD_MODULUS);
        panagram.newRound(NEW_ANSWER);

        vm.assertEq(panagram.s_currentRound(), 2);
        vm.assertEq(panagram.s_currentRoundWinner(), address(0));
        vm.assertEq(panagram.s_answer(), NEW_ANSWER);
    }

    function testIncorrectProof() public {
        vm.prank(PLAYER1);
        bytes memory proof = _getProof(bytes32(uint256(keccak256("outnumber")) % FIELD_MODULUS), bytes32(uint256(keccak256("outnumber")) % FIELD_MODULUS), PLAYER1);

        vm.expectRevert();
        panagram.makeGuess(proof);
        
    }

}