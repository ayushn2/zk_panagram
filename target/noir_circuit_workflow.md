# Noir Circuit Workflow

This document explains the standard steps involved in compiling a Noir circuit, generating verification keys, and creating a Solidity verifier using **nargo** (Noir’s CLI) and **barretenberg** (`bb`).

---

## 1. Compile the Circuit

```bash
nargo compile
```

What it does:

- Compiles the Noir circuit written in .nr files.
- Produces an intermediate representation of the circuit in JSON format inside the ./target directory.
- This JSON file contains the arithmetic constraints that define the circuit and will be used to generate proving and verification keys.

---

### 2. Generate Verification Key

```bash
bb write_vk --oracle_hash keccak -b ./target/<circuit_name>.json -o ./target
```

What it does:

- Converts the compiled circuit into a Verification Key (VK).
- The VK is required for verifying zero-knowledge proofs produced by the circuit.
- Flags:
- --oracle_hash keccak → specifies Keccak as the oracle hash function (default used in many blockchain settings).
- -b → path to the compiled circuit JSON.
- -o → directory where the verification key will be saved.

Output:

- A file named vk in the target directory.

---

## 3. Generate Solidity Verifier

```bash
bb write_solidity_verifier -k ./target/vk -o ./target/Verifier.sol
```

What it does:

- Generates a Solidity smart contract verifier that can be deployed on Ethereum or other EVM-compatible blockchains.
- This contract uses the verification key to check if a submitted proof is valid.
- Flags:
- -k → path to the verification key file.
- -o → output file path for the Solidity verifier.

Output:

- A Solidity contract file, typically named Verifier.sol.
