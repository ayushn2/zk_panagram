import { Noir } from "@noir-lang/noir_js";
import { ethers } from "ethers";
import {UltraHonkBackend} from "@aztec/bb.js";

// get the circuit file with the bytecode
// initialize noir with the circuit
// initialize the backend using the circuit bytecode
// create th inputs
// Execute the circuit with the inputs to create the witness
// Generate the proof (using the backend) with the witness
// return the proof