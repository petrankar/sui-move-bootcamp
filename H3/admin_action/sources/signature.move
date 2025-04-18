module admin_action::signature;

use sui::{ed25519, hash, package};

const ECouldNotMintFirst: u64 = 0;
const ECouldNotMintSecond: u64 = 1;

// TODO: Change with your public key
const BE_PUBLIC_KEY: vector<u8> = x"ccfce9e209216138d29318da27f6c1b42ec863962ab7d9b56d9f6e22ccb31b86";

public struct SIGNATURE() has drop;

public struct Counter has key {
    id: UID,
    value: u64,
}

/// Hero NFT
public struct Hero has key {
    id: UID,
    health: u64,
    stamina: u64,
}

fun init(otw: SIGNATURE, ctx: &mut TxContext) {
    package::claim_and_keep(otw,ctx);
    transfer::share_object(Counter {
        id: object::new(ctx),
        value: 0
    });
}
/// mint should be authorized
#[allow(implicit_const_copy)]
public fun mint(
    sig: vector<u8>,
    health: u64,
    stamina: u64,
    ctx: &mut TxContext
): bool {
    let mut msg = b"Mint Hero for: 0x".to_string();
        msg.append(ctx.sender().to_string());
        msg.append_utf8(b";health=");
        msg.append(health.to_string());
        msg.append_utf8(b";stamina=");
        msg.append(stamina.to_string());
    let digest = hash::blake2b256(msg.as_bytes());
    // std::debug::print(&digest);
    // Here we would abort but for testing purposes we do not.
    if (!ed25519::ed25519_verify(&sig, &BE_PUBLIC_KEY, &digest)) {
        return false
    };

    transfer::transfer(Hero {
        id: object::new(ctx),
        health,
        stamina
    }, ctx.sender());
    return true
}

#[test]
#[expected_failure(abort_code=ECouldNotMintSecond)]
fun test_replay() {
    // TODO: Change with your signature
    let sig = x"5dadee914391b3be7c9587952005c079f33bd26d6a4a1fbe208ed05929b828c468cfdd7e68226168a15143b91e63189614d95e621f3d2388aa523b866e3bdc0c";
    assert!(mint(
        sig,
        10,
        10,
        &mut tx_context::new_from_hint(@0x11111, 0, 0, 0, 0)
    ), ECouldNotMintFirst);

    assert!(mint(
        sig,
        10,
        10,
        &mut tx_context::new_from_hint(@0x11111, 0, 0, 0, 0)
    ), ECouldNotMintSecond);
}

