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

const adminPrivKey = process.env.ADMIN_PRIVATE_KEY!;
const adminParsed = decodeSuiPrivateKey(adminPrivKey);
export const ADMIN_KEYPAIR: Keypair = getKeypair(adminParsed);
const buyerPrivKey = process.env.BUYER_PRIVATE_KEY!;
const buyerParsed = decodeSuiPrivateKey(buyerPrivKey);
export const BUYER_KEYPAIR: Keypair = getKeypair(buyerParsed);
