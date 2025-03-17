module package_upgrade::admin;

use sui::package::Publisher;

const EInvalidPublisher: u64 = 0;

public struct AdminCap has key, store {
    id: UID,
}

public fun new(publisher: &Publisher, ctx: &mut TxContext): AdminCap {
    assert!(publisher.from_package<AdminCap>(), EInvalidPublisher);
    AdminCap { id: object::new(ctx) }
}
