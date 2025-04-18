import dotenv from 'dotenv';
import { decodeSuiPrivateKey } from '@mysten/sui/cryptography';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { blake2b } from 'blakejs';

dotenv.config();
const keypair = Ed25519Keypair.fromSecretKey(decodeSuiPrivateKey(process.env.ADMIN_PRIVATE_KEY!).secretKey);

const message = new TextEncoder().encode(
    "Mint Hero for: 0x0000000000000000000000000000000000000000000000000000000000011111;health=10;stamina=10"
);
const digest = blake2b(message, undefined, 32); // 32 bytes = 256-bit digest
console.log(Buffer.from(digest).toString('hex'));
keypair.sign(digest).then((signature: Uint8Array) => {
    console.log("Public Key: ", Buffer.from(keypair.getPublicKey().toRawBytes()).toString('hex'));
    console.log("Signature: ", Buffer.from(signature).toString('hex'));
});



