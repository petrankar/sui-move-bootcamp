import { SuiClient, SuiTransactionBlockResponse } from '@mysten/sui/client';
import { Transaction } from '@mysten/sui/transactions';
import { Keypair } from '@mysten/sui/cryptography';
import { PublishSingleton } from './publish';

export async function createSword({ client, signer, recipient, name, damage, effects }: {
    client: SuiClient, signer: Keypair, recipient?: string, name: string, damage: number, effects: string[]
}): Promise<SuiTransactionBlockResponse> {
    recipient = recipient ?? signer.toSuiAddress();
    const transaction = new Transaction();
    const packageId = PublishSingleton.packageId();
    const publisherObjectId = PublishSingleton.publisherObjectId();
    const sword = transaction.moveCall({
        target: `${packageId}::sword::new`,
        arguments: [
            transaction.object(publisherObjectId),
            transaction.pure.string(name),
            transaction.pure.u32(damage),
            transaction.pure.vector('string', effects)
        ]
    });
    transaction.transferObjects([sword], recipient);

    const resp = await client.signAndExecuteTransaction({
        transaction,
        signer,
        options: {
            showEffects: true,
            showObjectChanges: true
        }
    });
    if (resp.effects?.status.status !== 'success') {
        throw new Error(`Something went wrong creating sword:\n${JSON.stringify(resp, null, 2)}`)
    }
    await client.waitForTransaction({digest: resp.digest});
    return resp;
}
