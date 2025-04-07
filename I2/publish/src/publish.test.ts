import { PublishSingleton } from './publish';

describe("Publish package", () => {

    beforeAll(async () => {
        await PublishSingleton.publish();
    });

    it("Publishes package", async () => {

        let resp = PublishSingleton.publishResponse();
        expect(resp.effects?.status.status).toBe('success');
    });

    it("Package is not upgradable", async() => {
        let resp = PublishSingleton.publishResponse();
        let upgradeCap = resp.objectChanges?.find((chng) => chng.type === 'created' && chng.objectType.endsWith('2::package::UpgradeCap'));
        expect(upgradeCap).toBeUndefined();
    });
});
