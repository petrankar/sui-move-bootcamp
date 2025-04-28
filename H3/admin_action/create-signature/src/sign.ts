import dotenv from 'dotenv';
import { decodeSuiPrivateKey } from '@mysten/sui/cryptography';
import { Ed25519Keypair } from '@mysten/sui/keypairs/ed25519';
import { blake2b } from 'blakejs';
import { bcs } from '@mysten/sui/bcs';

dotenv.config();
const keypair = Ed25519Keypair.fromSecretKey(decodeSuiPrivateKey(process.env.ADMIN_PRIVATE_KEY!).secretKey);

const message = new TextEncoder().encode(
    "Mint Hero for: 0x0000000000000000000000000000000000000000000000000000000000011111;health=10;stamina=10;counter_bcs="
);

const counterBcs = bcs.struct("0x0::signature::Counter", {
    id: bcs.struct("0x2::object::UID", {
        id: bcs.struct("0x2::object::ID", {
            bytes: bcs.Address
        })
    }),
    value: bcs.u64(),
}).serialize({
    id: {
        id: {
            bytes: "0x34401905bebdf8c04f3cd5f04f442a39372c8dc321c29edfb4f9cb30b23ab96"
        }
    },
    value: 0
}).toBytes();
const merged = new Uint8Array(message.length + counterBcs.length);
merged.set(message, 0);
merged.set(counterBcs, message.length);

const digest = blake2b(merged, undefined, 32); // 32 bytes = 256-bit digest
console.log(Buffer.from(digest).toString('hex'));
keypair.sign(digest).then((signature: Uint8Array) => {
    console.log("Public Key: ", Buffer.from(keypair.getPublicKey().toRawBytes()).toString('hex'));
    console.log("Signature: ", Buffer.from(signature).toString('hex'));
});

