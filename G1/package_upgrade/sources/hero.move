module package_upgrade::hero;

use sui::dynamic_object_field as dof;
use sui::package;

use package_upgrade::blacksmith::{Shield, Sword};
use package_upgrade::knowledge_tome::KnowledgeTome;
use package_upgrade::version::Version;

public struct HERO() has drop;

/// Hero NFT
public struct Hero has key, store {
    id: UID,
    level: u64,
    health: u64,
    stamina: u64,
    power: u64,
}

public struct SwordKey() has copy, drop, store;
public struct ShieldKey() has copy, drop, store;

fun init(otw: HERO, ctx: &mut TxContext) {
    package::claim_and_keep(otw, ctx);
}

// DEMO: Invalidate function.
// DEMO: Existing public function signatures cannot change.
/// Lvl-1 Hero is freely mintable.
/// We want to require a payment of 5 SUI in the next version.
public fun mint_hero(version: &Version, ctx: &mut TxContext): Hero {
    version.check_is_valid();
    Hero {
        id: object::new(ctx),
        level: 1,
        health: 100,
        stamina: 10,
        power: 10,
    }
}

public fun add_sword(self: &mut Hero, version: &Version, sword: Sword) {
    version.check_is_valid();
    self.add_dof(SwordKey(), sword)
}

public fun add_shield(self: &mut Hero, version: &Version, shield: Shield) {
    version.check_is_valid();
    self.add_dof(ShieldKey(), shield)
}

fun add_dof<K: copy + drop + store, T: key + store>(self: &mut Hero, key_: K, value: T) {
    dof::add(&mut self.id, key_, value)
}

// DEMO: Change function implementation.
/// Each tome brings one level to the hero.
/// We want tomes to add a dynamic number of levels to the hero.
public fun level_up(self: &mut Hero, version: &Version, tome: KnowledgeTome) {
    version.check_is_valid();
    tome.delete();
    self.level = self.level + 1;
}
