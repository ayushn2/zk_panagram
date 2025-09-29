import { Noir } from "@noir-lang/noir_js";
import { ethers } from "ethers";
import {UltraHonkBackend} from "@aztec/bb.js";
import { fileURLToPath } from "url";
import path from "path";
import fs from "fs";

// get the circuit file with the bytecode
path.dirname(fileURLToPath(import.meta.url)) //gives the path of the current file
"../circuits/target/panagram.circuit.json" //gives the path of the circuit file

const circuitPath = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../circuits/target/zk_panagram.json"
);

const circuit = JSON.parse(fs.readFileSync(circuitPath, "utf-8"))

export default async function generateProof() {
    const inputsArray = process.argv.slice(2);

    try {
        
        // initialize noir with the circuit
        const noir = new Noir(circuit);
        // initialize the backend using the circuit bytecode
        const backend = new UltraHonkBackend(circuit.bytecode, {threads: 1});

        // Convert hex string to decimal string
        function hexToDecimalString(hex: string): string {
            return BigInt(hex).toString(); // converts 0x... to decimal
        }
        // get the inputs from command line arguments
        const guessHash = hexToDecimalString(process.argv[2]);
        const answerHash = hexToDecimalString(process.argv[3]);
        const address = hexToDecimalString(process.argv[4]);


        // create the inputs
        const inputs = {
        guess_hash: guessHash,
        answer_hash: answerHash,
        address: address,
    };
        // Execute the circuit with the inputs to create the witness
        const {witness} = await noir.execute(inputs)
        // Generate the proof (using the backend) with the witness
        const originalLog = console.log;
        console.log = () => {}; // disable logging
        const { proof } = await backend.generateProof(witness, {keccak: true});
        console.log = originalLog; // enable logging
        // abi encode the proof
        const abiEncodedProof = ethers.AbiCoder.defaultAbiCoder().encode(
            ["bytes"],
            [proof]
        )
        
        return abiEncodedProof;
        // return the proof

    } catch (error) {
        console.error("Error generating proof:", error);
        throw error;
    }
    
}

// run the function
(
    async () => {
        await generateProof().then((proof)=> {
            process.stdout.write(proof)
            process.exit(0);
        }).catch((err) => {
            console.error(err);
            process.exit(1);
        })
    }
)()
