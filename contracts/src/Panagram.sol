//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IVerifier} from "./Verifier.sol";

contract Panagram is ERC1155 {
    IVerifier public immutable verifier;
  constructor(IVerifier _verifier) ERC1155("ipfs://QmPlaceholderCID/{id}.json"){

  }
}