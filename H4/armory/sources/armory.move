/// Module: armory
module armory::armory;

public struct Sword has key, store {
    id: UID,
    attack: u64
}

public struct Armory has key {
    id: UID,
    swords: vector<Sword>,
    sword_idx: u64,
}

public fun new_armory(ctx: &mut TxContext): Armory {
    Armory {
        id: object::new(ctx),
        swords: vector[],
        sword_idx: 0
    }
}

public fun share(self: Armory) {
    transfer::share_object(self)
}

public fun mint_swords(self: &mut Armory, n_swords: u64, attack: u64, ctx: &mut TxContext) {
    n_swords.do!(|_i|
        self.swords.push_back(Sword {
            id: object::new(ctx),
            attack
        })
    );
    self.sword_idx = self.sword_idx + n_swords;
}
