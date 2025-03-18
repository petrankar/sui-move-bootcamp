module scenario::hero;

use scenario::acl::Admins;
use scenario::xp_tome::XPTome;

public struct HERO() has drop;

/// Hero NFT
public struct Hero has key {
    id: UID,
    health: u64,
    stamina: u64,
}

/// Anyone can mint a hero.
/// Hero starts with 100 heath and 10 stamina.
public fun mint(
    admins: &Admins,
    health: u64,
    stamina: u64,
    recipient: address,
    ctx: &mut TxContext
) {
    admins.authorize(ctx);
    transfer::transfer(Hero {
        id: object::new(ctx),
        health,
        stamina
    }, recipient);
}

public fun health(self: &Hero): u64 {
    self.health
}

public fun stamina(self: &Hero): u64 {
    self.stamina
}

public fun level_up(self: &mut Hero, tome: XPTome) {
    let (health, stamina) = tome.destroy();
    self.health = self.health + health;
    self.stamina = self.stamina + stamina;
}
