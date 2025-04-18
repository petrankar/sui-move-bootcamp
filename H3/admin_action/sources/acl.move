module admin_action::acl;

use sui::package;

public struct ACL() has drop;

public struct AccessControlList has key {
    id: UID,
    admins: vector<address>
}

/// Hero NFT
public struct Hero has key {
    id: UID,
    health: u64,
    stamina: u64,
}

fun init(otw: ACL, ctx: &mut TxContext) {
    package::claim_and_keep(otw,ctx);
    transfer::share_object(AccessControlList {
        id: object::new(ctx),
        admins: vector[ctx.sender()]
    });
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
