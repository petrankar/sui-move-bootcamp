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
        target: `${PublishSingleton.packageId()}::registry::mint_swords`,
        arguments: [
            txb.object(PublishSingleton.armoryRegistryId()),
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

describe("Armory into registry", () => {
    let client: SuiClient;
    const admin = ADMIN_KEYPAIR;
    const swordsToMint = 800;

    beforeAll(async () => {
        client = new SuiClient({ url: getFullnodeUrl('localnet') });
        await PublishSingleton.publish(client, admin);

        const swordsPerMint = 400;
        for (let i = 0; i < swordsToMint / swordsPerMint + (swordsToMint % swordsPerMint === 0 ? 0 : 1); i++) {
            const swordResp = await mintSwordsInArmory({
                client,
                signer: admin,
                armoryId: PublishSingleton.armoryRegistryId(),
                nSwords: swordsPerMint,
                attack: 10,
            });
            if (swordResp.effects?.status.status !== 'success') {
                throw new Error(`Something went wrong creating sword:\n${JSON.stringify(swordResp, null, 2)}`)
            }
            // console.log(`Minted ${swordsPerMint} swords`);
        }
    }, 60000);


    it(`Transform Armory to Registry`, async () => {
        const txb = new Transaction();

        let table = txb.moveCall({
            target: `${PublishSingleton.packageId()}::registry::into_registry`,
            arguments: [txb.object(PublishSingleton.armoryRegistryId())]
        })

        txb.moveCall({
            target: "0x2::table::drop",
            arguments: [table],
            typeArguments: ["u64", "0x2::object::ID"]
        });

        // txb.setGasBudget(50_000_000_000n);
        const resp = await client.signAndExecuteTransaction({
            transaction: txb,
            signer: admin,
            options: {
                showEffects: true,
                showObjectChanges: true
            }
        });
        if (resp.effects?.status.status !== 'success') {
            throw new Error(`Something went transforming armory swords to registry:\n${JSON.stringify(resp, null, 2)}`)
        }


    }, 60000);
});

