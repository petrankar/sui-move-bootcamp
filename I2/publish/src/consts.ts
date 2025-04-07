import dotenv from 'dotenv';
import { decodeSuiPrivateKey, Keypair, ParsedKeypair } from '@mysten/sui/cryptography';
import {Ed25519Keypair} from '@mysten/sui/keypairs/ed25519';
import {Secp256k1Keypair} from '@mysten/sui/keypairs/secp256k1';
import {Secp256r1Keypair} from '@mysten/sui/keypairs/secp256r1';

function getKeypair(parsed: ParsedKeypair) {
    switch (parsed.schema) {
        case 'ED25519': { return Ed25519Keypair.fromSecretKey(parsed.secretKey);}
        case 'Secp256k1': { return Secp256k1Keypair.fromSecretKey(parsed.secretKey);}
        case 'Secp256r1': { return Secp256r1Keypair.fromSecretKey(parsed.secretKey);}
        default:
            throw new Error(`Key scheme ${parsed.schema} not supported`);
    }
}
dotenv.config();

export const RECIPIENT="0x69628f2cf992e5749022060a25feb471d96b97e2a518243136e6f4b0b121bc9a";

const privKey = process.env.ADMIN_PRIVATE_KEY!;
const parsed = decodeSuiPrivateKey(privKey);
export const ADMIN_KEYPAIR: Keypair = getKeypair(parsed);
