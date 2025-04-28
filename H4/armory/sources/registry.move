module armory::registry;

use sui::table::{Self, Table};
use sui::linked_table::{Self, LinkedTable};

public struct Sword has key, store {
    id: UID,
    attack: u64
}

public struct Armory has key {
    id: UID,
    swords: LinkedTable<ID, Sword>
}

public fun new_armory(ctx: &mut TxContext): Armory {
    Armory {
        id: object::new(ctx),
        swords: linked_table::new(ctx),
    }
}

public fun share(self: Armory) {
    transfer::share_object(self)
}

public fun mint_swords(self: &mut Armory, n_swords: u64, attack: u64, ctx: &mut TxContext) {
    n_swords.do!(|_i| {
        let sword = Sword {
            id: object::new(ctx),
            attack
        };
        self.swords.push_back(object::id(&sword), sword);
    });
}

public fun into_registry(self: &Armory, ctx: &mut TxContext): Table<u64, ID> {
    let mut table = table::new<u64, ID>(ctx);
    let mut next = self.swords.front();
    let mut i = 0;
    while (next.is_some()) {
        let key_ = *next.borrow();
        table.add(i, key_);
        next = self.swords.next(key_);
        i = i + 1;
    };
    table
}
