module basic_move::basic_move;

// === Imports ===

use std::string::String;

#[test_only]
use sui::{ test_scenario, test_utils::destroy };

// === Structs ===

public struct Hero has key, store {
    id: UID,
    name: String,
}

public struct InsignificantWeapon has drop, store {
    power: u8,
}

public struct Weapon has store {
    power: u8,
}

// === Public Functions ===

public fun mint_hero(name: String, ctx: &mut TxContext): Hero {
    Hero {
        id: object::new(ctx),
        name,
    }
}

public fun create_insignificant_weapon(power: u8): InsignificantWeapon {
    InsignificantWeapon { power }
}

public fun create_weapon(power: u8): Weapon {
    Weapon { power }
}

// === Test Functions ===

#[test]
fun test_mint() {
    let mut scenario = test_scenario::begin(@0xCAFE);
    let hero = mint_hero(b"Osman".to_string(), scenario.ctx());

    assert!(hero.name == b"Osman".to_string(), 65);
    std::debug::print(&hero);
    
    let msg = b"Hello World".to_string();
    std::debug::print(&msg);

    destroy(hero);
    scenario.end();
}

#[test]
fun test_drop_semantics() {
    // let scenario = test_scenario::begin(@0xCAFE);
    let scenario = test_scenario::begin(@osman);

    // Has drop, no need to consume or destroy
    let _weapon1 = create_insignificant_weapon(69);

    // Has drop, we can reassign
    let mut _weapon2 = create_insignificant_weapon(42);
    _weapon2 = create_insignificant_weapon(43);

    // This has to be destroyed since it doesn't have drop
    let weapon3 = create_weapon(101);
    destroy(weapon3);

    scenario.end();
}
