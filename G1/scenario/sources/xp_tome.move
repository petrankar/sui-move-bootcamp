module scenario::xp_tome;

use scenario::acl::Admins;

/// XPTome is used to level-up a Hero.
public struct XPTome has key {
    id: UID,
    /// Health to be added to the `Hero`'s health.
    health: u64,
    /// Stamina to be added to the `Hero`'s health.
    stamina: u64
}

public fun new(
    admins: &Admins,
    health: u64,
    stamina: u64,
    recipient: address,
    ctx: &mut TxContext
) {
    admins.authorize(ctx);
    transfer::transfer(XPTome {
        id: object::new(ctx),
        health,
        stamina,
    }, recipient);
}

public fun health(self: &XPTome): u64 {
    self.health
}

public fun stamina(self: &XPTome): u64 {
    self.stamina
}

public(package) fun destroy(self: XPTome): (u64, u64) {
    let XPTome { id, health, stamina } = self;
    id.delete();
    (health, stamina)
}

