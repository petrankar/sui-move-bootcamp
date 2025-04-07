/// Module: silver
module fixed_supply::silver;

use sui::coin::{Self, TreasuryCap, CoinMetadata};
use sui::url;

public struct SILVER() has drop;

const ETodo: u64 = 0;

const DECIMALS: u8 = 9;
const NAME: vector<u8> = b"Silver";
const SYMBOL: vector<u8> = b"SILVER";
const DESCRIPTION: vector<u8> = b"Silver, commonly used by heroes to purchase necessary adventure equipment";
const ICON_URL: vector<u8> = b"https://aggregator.walrus-testnet.walrus.space/v1/blobs/cWTbHE-yC4z3JLmEYWDXM6uhQ1nxu-R0GOLReRwQcH4";
const TOTAL_SUPPLY: u64 = 10_000_000_000_000_000_000;

public struct Freezer has key {
    id: UID
}

public struct TreasuryCapKey() has copy, drop, store;

fun init(otw: SILVER, ctx: &mut TxContext) {
    let (tcap, metadata) = create_silver_currency(otw, ctx);

    transfer::public_freeze_object(metadata);

    // Mint the total supply, and transfer it to sender.
    // Lock the treasury cap inside the freezer, so that it is unusable but
    // still easily indexable.
    // todo!<()>()
    transfer::public_transfer(tcap, ctx.sender())
}

fun create_silver_currency(
    otw: SILVER,
    ctx: &mut TxContext
): (TreasuryCap<SILVER>, CoinMetadata<SILVER>) {
    coin::create_currency<SILVER>(
        otw,
        DECIMALS,
        SYMBOL,
        NAME,
        DESCRIPTION,
        option::some(url::new_unsafe_from_bytes(ICON_URL)),
        ctx
    )
}

public macro fun todo<$T>(): $T {
    abort(ETodo)
}
