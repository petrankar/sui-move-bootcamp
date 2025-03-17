module package_upgrade::hero;

use sui::coin::Coin;
use sui::dynamic_field as df;
use sui::dynamic_object_field as dof;
use sui::package;
use sui::sui::SUI;

use package_upgrade::blacksmith::{Shield, Sword};
use package_upgrade::version::Version;

const PAYMENT_ADDRESS: address = @0x1111;
const HERO_PRICE: u64 = 5_000_000_000;

const EAlreadyEquipedShield: u64 = 0;
const EAlreadyEquipedSword: u64 = 1;
const EInvalidPaymentBalance: u64 = 2;
const EUseMintHeroV2Instead: u64 = 3;

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

/// @deprecated: `mint_hero` is deprecated. Use `mint_hero_v2` instead.
public fun mint_hero(_: &Version, _: &mut TxContext): Hero {
    abort(EUseMintHeroV2Instead)
}

/// Anyone can mint a hero, as long as they pay `HERO_PRICE` SUI.
/// New hero will have 100 health and 10 stamina.
public fun mint_hero_v2(version: &Version, payment: Coin<SUI>, ctx: &mut TxContext): Hero {
    version.check_is_valid();
    assert!(payment.value() == HERO_PRICE, EInvalidPaymentBalance);
    transfer::public_transfer(payment, PAYMENT_ADDRESS);
    Hero {
        id: object::new(ctx),
        health: 100,
        stamina: 10
    }
}

/// Hero can equip a single sword.
/// Equiping a sword increases the `Hero`'s power by its attack.
public fun equip_sword(self: &mut Hero, version: &Version, sword: Sword) {
    version.check_is_valid();
    if (df::exists_(&self.id, ShieldKey())) {
        abort(EAlreadyEquipedSword)
    };
    self.increase_power(sword.attack());
    self.add_dof(SwordKey(), sword)
}

/// Hero can equip a single shield.
/// Equiping a shield increases the `Hero`'s power by its defence.
public fun equip_shield(self: &mut Hero, version: &Version, shield: Shield) {
    version.check_is_valid();
    if (df::exists_(&self.id, ShieldKey())) {
        abort(EAlreadyEquipedShield)
    };
    self.increase_power(shield.defence());
    self.add_dof(ShieldKey(), shield)
}

/// Increases the power of a hero by value. If no `PowerKey` field exists under
/// the hero, it creates it.
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

/// Generic add dynamic object field to the hero.
fun add_dof<K: copy + drop + store, T: key + store>(self: &mut Hero, key_: K, value: T) {
    dof::add(&mut self.id, key_, value)
}

