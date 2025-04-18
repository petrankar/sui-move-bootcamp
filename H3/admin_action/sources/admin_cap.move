module admin_action::admin_cap;

public struct AdminCap has key, store {
    id: UID
}

/// Hero NFT
public struct Hero has key {
    id: UID,
    health: u64,
    stamina: u64,
}

fun init(otw: ACL, ctx: &mut TxContext) {
    package::claim_and_keep(otw,ctx);
    transfer::public_transfer(AdminCap {
        id: object::new(ctx),
    }, ctx.sender());
}

/// mint should be authorized
public fun mint(
    health: u64,
    stamina: u64,
    recipient: address,
    ctx: &mut TxContext
) {
    transfer::transfer(Hero {
        id: object::new(ctx),
        health,
        stamina
    }, recipient);
}
