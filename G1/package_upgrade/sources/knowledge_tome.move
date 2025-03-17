module package_upgrade::knowledge_tome;

use package_upgrade::admin::AdminCap;

// REVIEW: Should we prefer using ACLs for these cases?
/// Can create tomes.
public struct TomeKeeper has key, store {
    id: UID,
}

// DEMO: Not being able to change existing struct.
// Note to self: Solutions: either a new struct, or DFs.
public struct KnowledgeTome has key, store {
    id: UID,
}

public fun new_keeper(_: &AdminCap, ctx: &mut TxContext): TomeKeeper {
    TomeKeeper { id: object::new(ctx) }
}

public fun new_tome(_: &TomeKeeper, ctx: &mut TxContext): KnowledgeTome {
    // DEMO: In case of DFs, changing function implementation.
    KnowledgeTome { id: object::new(ctx) }
}

// DEMO: renaming public(package) function
public(package) fun delete(self: KnowledgeTome) {
    let KnowledgeTome { id } = self;
    id.delete()
}

