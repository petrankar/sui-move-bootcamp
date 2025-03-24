
module abilities_events_params::abilities_events_params;

use std::string::{String};
use sui::event;


//Error Codes
const EMedalOfHonorNotAvailable:u64 = 111;


// Structs

public struct Hero has key {
    id: UID, // required
    name: String,
    medals: vector<Medal>
}

public struct HeroRegistry has key, store {
    id: UID,
    heroes: vector<ID>
}

public struct MedalStorage has key, store {
    id: UID,
    medals: vector<Medal>
}

public struct HeroMinted has copy, drop {
    hero: ID,
    owner: address
}

public struct Medal has key, store {
    id: UID,
    name: String,
}



fun init(ctx: &mut TxContext) {
    let registry = HeroRegistry {
        id: object::new(ctx),
        heroes: vector::empty()
    };
    transfer::share_object(registry);


    let mut medalStorage = MedalStorage {
        id: object::new(ctx),
        medals: vector::empty()
    };
    medalStorage.medals.push_back(Medal{
        id: object::new(ctx),
        name: b"Medal of Honor".to_string()
    });
    medalStorage.medals.push_back(Medal{
        id: object::new(ctx),
        name: b"Air Force Cross".to_string()
    });
    medalStorage.medals.push_back(Medal{
        id: object::new(ctx),
        name: b"Legion of Merit".to_string()
    });

    transfer::share_object(medalStorage);
}

public fun mint_hero(name: String, registry: &mut HeroRegistry, ctx: &mut TxContext): Hero {
    let freshHero = Hero {
        id: object::new(ctx), // creates a new UID
        name,
        medals: vector::empty()
    };
    registry.heroes.push_back(object::id(&freshHero));

    let minted = HeroMinted {
        hero: object::id(&freshHero),
        owner: ctx.sender()
    };

    event::emit(minted);
    freshHero
}

public fun mint_and_keep_hero(name:String, registry: &mut HeroRegistry, ctx: &mut TxContext) {
    let hero = mint_hero(name, registry, ctx);
    transfer::transfer(hero, ctx.sender());
}

public fun award_medal_of_honor(hero: &mut Hero, medalStorage: &mut MedalStorage) {
    award_medal(hero, medalStorage, b"Medal of Honor".to_string() );
}

public fun award_medal_of_merit(hero: &mut Hero, medalStorage: &mut MedalStorage) {
    award_medal(hero, medalStorage, b"Legion of Merit".to_string() );
}
public fun award_medal_of_cross(hero: &mut Hero, medalStorage: &mut MedalStorage) {
    award_medal(hero, medalStorage, b"Air Force Cross".to_string() );
}


///// Private Functions /////

fun award_medal(hero: &mut Hero, medalStorage: &mut MedalStorage, medalName: String) {
    let medalOption : Option<Medal> = get_medal(medalName, medalStorage);
    assert!(medalOption.is_some(), EMedalOfHonorNotAvailable);

    hero.medals.append(medalOption.to_vec());
}

fun get_medal(name: String, medalStorage: &mut MedalStorage): Option<Medal> {

    let mut i = 0;
    while (i < medalStorage.medals.length()) {
        if (medalStorage.medals[i].name == name) {
            return option::some(medalStorage.medals.remove(i))
        };
        i = i + 1;
    };
    option::none<Medal>()
}


/////// Tests ///////

#[test_only]
use sui::test_scenario as ts;
use sui::test_utils::{destroy,assert_eq};
#[test_only]
use sui::test_scenario::{take_shared, return_shared};


#[test]
fun test_hero_creation(){

    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);

    let mut registry = take_shared<HeroRegistry>(&test);
    let hero = mint_hero(b"Flash".to_string(), &mut registry, test.ctx());
    assert_eq(hero.name, b"Flash".to_string());

    assert_eq(registry.heroes.length(), 1);

    return_shared(registry);
    destroy(hero);
    test.end();
}

#[test]
fun test_event_thrown(){

    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);

    let mut registry = take_shared<HeroRegistry>(&test);
    let hero = mint_hero(b"Flash".to_string(), &mut registry, test.ctx());
    let hero2 = mint_hero(b"Flash".to_string(), &mut registry, test.ctx());
    assert_eq(hero.name, b"Flash".to_string());

    assert_eq(registry.heroes.length(), 2);

    let events : vector<HeroMinted> =  event::events_by_type<HeroMinted>();

    assert_eq(events.length(), 2);

    let mut i=0;
    while (i < events.length()) {
        assert!(events[i].owner == @USER, 661);
        i = i + 1;
    };

    return_shared(registry);
    destroy(hero);
    destroy(hero2);
    test.end();
}

#[test]
fun test_medal_award(){

    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);

    let mut registry = take_shared<HeroRegistry>(&test);

    let mut medalStorage = take_shared<MedalStorage>(&test);

    let mut hero = mint_hero(b"Superman".to_string(), &mut registry, test.ctx());

    award_medal_of_honor(&mut hero, &mut medalStorage);
    assert_eq(hero.medals.length(), 1);
    assert_eq(medalStorage.medals.length(), 2);

    award_medal_of_merit(&mut hero, &mut medalStorage);
    assert_eq(hero.medals.length(), 2);
    assert_eq(medalStorage.medals.length(), 1);

    award_medal_of_cross(&mut hero, &mut medalStorage);
    assert_eq(hero.medals.length(), 3);
    assert_eq(medalStorage.medals.length(), 0);

    return_shared(registry);
    return_shared(medalStorage);
    destroy(hero);
    test.end();
}


#[test, expected_failure(abort_code = EMedalOfHonorNotAvailable)]
fun test_medal_award_error(){

    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);

    let mut registry = take_shared<HeroRegistry>(&test);

    let mut medalStorage = take_shared<MedalStorage>(&test);

    let mut hero = mint_hero(b"Superman".to_string(), &mut registry, test.ctx());

    award_medal_of_honor(&mut hero, &mut medalStorage);
    assert_eq(hero.medals.length(), 1);
    assert_eq(medalStorage.medals.length(), 2);

    award_medal_of_honor(&mut hero, &mut medalStorage);

    return_shared(registry);
    return_shared(medalStorage);
    destroy(hero);
    test.end();
}
