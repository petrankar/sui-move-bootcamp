module scenario::acl;

use sui::package;
use sui::vec_set::{Self, VecSet};

const ENotAuthorized: u64 = 0;

public struct ACL() has drop;

/// In charge of adding/removing admins.
public struct AdminCap has key, store {
    id: UID,
}

/// Admins can mint Heroes and XPTomes
public struct Admins has key {
    id: UID,
    inner: VecSet<address>
}

fun init(otw: ACL, ctx: &mut TxContext) {
    package::claim_and_keep(otw, ctx);
    transfer::public_transfer(AdminCap { id: object::new(ctx) }, ctx.sender());
    transfer::share_object(Admins {
        id: object::new(ctx),
        inner: vec_set::singleton(ctx.sender())
    });
}

public fun add_admin(self: &mut Admins, _cap: &AdminCap, new_admin: address) {
    self.inner.insert(new_admin);
}

public fun remove_admin(self: &mut Admins, _cap: &AdminCap, old_admin: address) {
    self.inner.remove(&old_admin);
}

public(package) fun authorize(self: &Admins, ctx: &TxContext) {
    assert!(self.inner.contains(&ctx.sender()), ENotAuthorized);
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ACL(), ctx);
}

