module basic_move::basic_move;

use std::string::String;

//Errors
const EAlreadyCarryingWeapon: u64 = 1;

public struct Hero has key, store {
    id: UID,
    name: String,
    stamina: Option<u64>,
    category: Option<Category>,
    weapon: Option<Weapon>,
}

public struct Category has drop, store {
    name: String,
}

public struct Weapon has key, store {
    id: UID,
    name: String,
    destruction_power: u64,
}

public fun mint_hero(name_param: String, ctx: &mut TxContext): Hero {
    let aHero = Hero {
        id: object::new(ctx),
        name: name_param,
        //adding initial weapon
        weapon: option::none(),
        stamina: option::none(),
        category: option::none(),
    };
    aHero
}

public fun create_weapon(
    name_param: String,
    destruction_power_param: u64,
    ctx: &mut TxContext,
): Weapon {
    let aWeapon = Weapon {
        id: object::new(ctx),
        name: name_param,
        destruction_power: destruction_power_param,
    };
    aWeapon
}

public fun equip_hero(hero: &mut Hero, weapon: Weapon) {
    assert!(hero.weapon.is_none(), EAlreadyCarryingWeapon);
    hero.weapon.fill(weapon);
}

public fun set_stamina(hero: &mut Hero, stamina: u64) {
    hero.stamina.fill(stamina);
}

public fun set_class(hero: &mut Hero, class: Category) {
    hero.category.fill(class);
}

#[test]
fun test_mint() {
    let mut test = test_scenario::begin(@0xCAFE);
    let hero = mint_hero(b"superman".to_string(), test.ctx());
    assert!(hero.name == b"superman".to_string(), 612);
    destroy_for_testing(hero);
    test.end();
}

#[test]
fun test_stamina() {
    let mut test = test_scenario::begin(@0xCAFE);
    let mut hero = mint_hero(b"superman".to_string(), test.ctx());
    assert!(hero.stamina.is_none(), 611);

    hero.set_stamina(100);
    assert!(hero.stamina.is_some(), 613);

    destroy_for_testing(hero);
    test.end();
}

#[test]
fun test_class() {
    let mut test = test_scenario::begin(@0xCAFE);
    let mut hero = mint_hero(b"Gandalf".to_string(), test.ctx());
    assert!(hero.stamina.is_none(), 621);
    assert!(hero.category.is_none(), 622);

    let class = Category { name: b"wizard".to_string() };
    hero.set_class(class);

    assert!(hero.category.is_some(), 623);
    assert!(hero.category.borrow().name == b"wizard".to_string(), 624);

    destroy_for_testing(hero);
    test.end();
}

#[test]
fun test_equip() {
    let mut test = test_scenario::begin(@0xCAFE);
    let mut hero = mint_hero(b"batman".to_string(), test.ctx());
    assert!(hero.name == b"batman".to_string(), 666);

    assert!(hero.weapon.is_none(), 667);

    let weapon = create_weapon(b"batmobile".to_string(), 67, test.ctx());

    equip_hero(&mut hero, weapon);

    destroy_for_testing(hero);
    test.end();
}

#[test_only]
fun destroy_for_testing(hero: Hero) {
    let Hero {
        id,
        name: _,
        stamina: _s,
        category: _c, //implicitly dropped
        weapon: _w,
    } = hero;
    object::delete(id);

    if (_s.is_some()) {
        _s.destroy_some();
    } else {
        _s.destroy_none();
    };

    if (_w.is_some()) {
        let Weapon { id: wid, name: _, destruction_power: _ } = _w.destroy_some();
        object::delete(wid);
    } else {
        _w.destroy_none();
    }
}
