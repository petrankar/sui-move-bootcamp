import { SuiClient, SuiTransactionBlockResponse, getFullnodeUrl } from "@mysten/sui/client";
import { Keypair } from "@mysten/sui/cryptography";
import { Transaction } from "@mysten/sui/transactions";
import { PublishSingleton } from "./publish";
import { ADMIN_KEYPAIR } from "./consts";

export async function mintSwordsInArmory({ client, signer, nSwords, attack }: {
    client: SuiClient,
    signer: Keypair,
    armoryId: string,
    nSwords: number,
    attack: number,
}): Promise<SuiTransactionBlockResponse> {
    const txb = new Transaction();

    txb.moveCall({
        target: `${PublishSingleton.packageId()}::armory::mint_swords`,
        arguments: [
            txb.object(PublishSingleton.armoryId()),
            txb.pure.u64(nSwords),
            txb.pure.u64(attack),
        ]
    });

    const resp = await client.signAndExecuteTransaction({
        transaction: txb,
        signer,
        options: {
            showObjectChanges: true,
            showEffects: true,
        }
    });

    if (resp.effects?.status.status !== 'success') {
        throw new Error(`Failure during mass mint transaction:\n${JSON.stringify(resp, null, 2)}`);
    }
    await client.waitForTransaction({ digest: resp.digest });
    return resp;
}

describe("Mint Swords", () => {
    let client: SuiClient;
    const admin = ADMIN_KEYPAIR;
    const swordsToMint = 6000;

    beforeAll(async () => {
        client = new SuiClient({ url: getFullnodeUrl('localnet') });
        await PublishSingleton.publish(client, admin);
    }, 10000);


    it(`Mint ${swordsToMint} or more Swords`, async () => {

        // Task 1: Resolve max-new-objects per tx limit
        // Task 3: Resolve max cache objects (max dynamic field creations)
        const swordsPerMint = 500;
        for (let i = 0; i < swordsToMint / swordsPerMint + (swordsToMint%swordsPerMint===0 ? 0 : 1); i++) {
            const swordResp = await mintSwordsInArmory({
                client,
                signer: admin,
                armoryId: PublishSingleton.armoryId(),
                nSwords: swordsPerMint,
                attack: 10,
            });
            if (swordResp.effects?.status.status !== 'success') {
                throw new Error(`Something went wrong creating sword:\n${JSON.stringify(swordResp, null, 2)}`)
            }
            console.log(`Minted ${swordsPerMint} swords`);
        }
    }, 60000);
});
