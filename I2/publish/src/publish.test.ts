import { getFullnodeUrl, SuiClient } from '@mysten/sui/client';
import { PublishSingleton } from './publish';

describe("Publish package", () => {
    let client: SuiClient;

    beforeAll(async () => {
        client = new SuiClient({url: getFullnodeUrl('localnet') });
        await PublishSingleton.publish(client);
    });

    it("Publishes package", () => {
        let resp = PublishSingleton.publishResponse();
        expect(resp.effects?.status.status).toBe('success');
    });

    it("Freezer has TreasuryCap", async () => {
        let packageId = PublishSingleton.packageId();
        let freezer = PublishSingleton.freezer();
        if (!freezer) {
            throw new Error("Expected Freezer object-change");
        }
        let tCap = PublishSingleton.treasuryCap();
        if (!freezer) {
            throw new Error("Expected TreasuryCap object-change");
        }
        let tCapAsDOF = await client.getDynamicFieldObject({
            name: {type: `${packageId}::silver::TreasuryCapKey`, value: {} },
            parentId: freezer.objectId
        });
        expect(tCap?.objectId).toBe(tCapAsDOF.data?.objectId)
    });

    it("Package is not upgradable", () => {
        let resp = PublishSingleton.publishResponse();
        let upgradeCap = resp.objectChanges?.find((chng) =>
            chng.type === 'created' && chng.objectType.endsWith('2::package::UpgradeCap')
        );
        expect(upgradeCap).toBeUndefined();
    });
});
