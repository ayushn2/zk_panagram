// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Panagram} from "../src/Panagram.sol";
import {HonkVerifier} from "../src/Verifier.sol";

contract PanagramTest is Test{
   
   HonkVerifier public verifier;
   Panagram public panagram;
    
    function setUp() public{
        // deploy the verifier
        verifier = new HonkVerifier();

        // deploy the panagram contract
        panagram = new Panagram(verifier);

        // create the answer
        // start a new round

        
    }

    // test someone receives NFT 0 if they guess correctly first
    // test someone receive s NFT 1 if they guess correctly second
    // test we can start a new round after time has passed and there was a winner

}