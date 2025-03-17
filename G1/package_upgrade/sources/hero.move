module package_upgrade::hero;

use sui::dynamic_field as df;
use sui::dynamic_object_field as dof;
use sui::package;

use package_upgrade::blacksmith::{Shield, Sword};
use package_upgrade::version::Version;

const EAlreadyEquipedShield: u64 = 0;
const EAlreadyEquipedSword: u64 = 1;

public struct HERO() has drop;

/// Hero NFT
public struct Hero has key, store {
    id: UID,
    health: u64,
    stamina: u64,
}

public struct SwordKey() has copy, drop, store;
public struct ShieldKey() has copy, drop, store;

public struct PowerKey() has copy, drop, store;

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
        health: 100,
        stamina: 10,
    }
}

public fun add_sword(self: &mut Hero, version: &Version, sword: Sword) {
    version.check_is_valid();
    if (df::exists_(&self.id, ShieldKey())) {
        abort(EAlreadyEquipedSword)
    };
    self.increase_power(sword.attack());
    self.add_dof(SwordKey(), sword)
}

public fun equip_shield(self: &mut Hero, version: &Version, shield: Shield) {
    version.check_is_valid();
    if (df::exists_(&self.id, ShieldKey())) {
        abort(EAlreadyEquipedShield)
    };
    self.increase_power(shield.defence());
    self.add_dof(ShieldKey(), shield)
}

fun increase_power(self: &mut Hero, value: u64) {
    if (!df::exists_(&self.id, PowerKey())) {
        df::add(&mut self.id, PowerKey(), 0);
    };
    let power = df::borrow_mut(&mut self.id, PowerKey());
    *power = *power + value;
}

public fun health(self: &Hero): u64 {
    self.health
}

public fun stamina(self: &Hero): u64 {
    self.stamina
}

fun add_dof<K: copy + drop + store, T: key + store>(self: &mut Hero, key_: K, value: T) {
    dof::add(&mut self.id, key_, value)
}

