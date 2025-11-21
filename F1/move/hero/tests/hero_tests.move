#[test_only]
module hero::hero_tests;

use hero::hero::{Self, HeroRegistry};
use std::string::utf8;
use sui::test_scenario;
use sui::test_utils;

#[test]
fun test_init() {
    let sender = @0xCAFE;

    // Initialize the hero module.
    let mut scenario = test_scenario::begin(sender);
    hero::init_for_testing(scenario.ctx());

    // Test that the registry is created and is empty.
    scenario.next_tx(sender);
    let registry = scenario.take_shared<HeroRegistry>();
    test_utils::assert_eq(hero::hero_registry_counter(&registry), 0);
    test_scenario::return_shared(registry);

    scenario.end();
}

#[test]
fun test_new_hero() {
    let sender = @0xCAFE;

    // Initialize the hero module.
    let mut scenario = test_scenario::begin(sender);
    hero::init_for_testing(scenario.ctx());

    // Mint a new hero and check its fields.
    scenario.next_tx(sender);
    let mut registry = scenario.take_shared<HeroRegistry>();
    let hero = hero::new_hero(
        utf8(b"Batman"),
        100,
        &mut registry,
        scenario.ctx(),
    );
    test_utils::assert_eq(hero::hero_name(&hero), utf8(b"Batman"));
    test_utils::assert_eq(hero::hero_stamina(&hero), 100);
    assert!(option::is_none(hero::hero_weapon(&hero)), 1);
    test_scenario::return_shared(registry);

    // Check that the registry has one hero.
    scenario.next_tx(sender);
    let registry = scenario.take_shared<HeroRegistry>();
    test_utils::assert_eq(hero::hero_registry_counter(&registry), 1);
    test_utils::assert_eq(*hero::hero_registry_ids(&registry).borrow(0), object::id(&hero));
    test_scenario::return_shared(registry);

    // End the scenario.
    test_utils::destroy(hero);
    scenario.end();
}

#[test]
fun test_new_weapon() {
    let ctx = &mut tx_context::dummy();
    let weapon = hero::new_weapon(
        utf8(b"Batmobile"),
        100,
        ctx,
    );
    test_utils::assert_eq(hero::weapon_name(&weapon), utf8(b"Batmobile"));
    test_utils::assert_eq(hero::weapon_attack(&weapon), 100);
    test_utils::destroy(weapon);
}

#[test]
fun test_equip_weapon() {
    let sender = @0xCAFE;

    // Initialize the hero module.
    let mut scenario = test_scenario::begin(sender);
    hero::init_for_testing(scenario.ctx());

    // Mint a new hero and a weapon.
    scenario.next_tx(sender);
    let mut registry = scenario.take_shared<HeroRegistry>();
    let mut hero = hero::new_hero(
        utf8(b"Batman"),
        100,
        &mut registry,
        scenario.ctx(),
    );
    let weapon = hero::new_weapon(
        utf8(b"Batmobile"),
        100,
        scenario.ctx(),
    );
    test_scenario::return_shared(registry);

    // Equip the weapon and check that the hero has it.
    hero::equip_weapon(&mut hero, weapon);
    assert!(option::is_some(hero::hero_weapon(&hero)), 1);

    // End the scenario.
    test_utils::destroy(hero);
    scenario.end();
}

#[test]
fun test_unequip_weapon() {
    let sender = @0xCAFE;

    // Initialize the hero module.
    let mut scenario = test_scenario::begin(sender);
    hero::init_for_testing(scenario.ctx());

    // Mint a new hero, and a weapon.
    scenario.next_tx(sender);
    let mut registry = scenario.take_shared<HeroRegistry>();
    let mut hero = hero::new_hero(
        utf8(b"Batman"),
        100,
        &mut registry,
        scenario.ctx(),
    );
    let weapon = hero::new_weapon(
        utf8(b"Batmobile"),
        100,
        scenario.ctx(),
    );
    test_scenario::return_shared(registry);

    // Equip and then unequip the weapon.
    hero::equip_weapon(&mut hero, weapon);
    let weapon = hero::unequip_weapon(&mut hero);

    // Check that the hero no longer has a weapon.
    assert!(option::is_none(hero::hero_weapon(&hero)), 1);

    // End the scenario.
    test_utils::destroy(weapon);
    test_utils::destroy(hero);
    scenario.end();
}

#[test, expected_failure(abort_code = ::hero::hero::EAlreadyEquipedWeapon)]
fun test_equip_weapon_already_equiped() {
    let sender = @0xCAFE;

    // Initialize the hero module.
    let mut scenario = test_scenario::begin(sender);
    hero::init_for_testing(scenario.ctx());

    // Mint a new hero, and two weapons.
    scenario.next_tx(sender);
    let mut registry = scenario.take_shared<HeroRegistry>();
    let mut hero = hero::new_hero(
        utf8(b"Batman"),
        100,
        &mut registry,
        scenario.ctx(),
    );
    let weapon1 = hero::new_weapon(
        utf8(b"Batmobile"),
        100,
        scenario.ctx(),
    );
    let weapon2 = hero::new_weapon(
        utf8(b"Batmobile2"),
        100,
        scenario.ctx(),
    );
    test_scenario::return_shared(registry);

    // Try equipping both of the weapons.
    hero::equip_weapon(&mut hero, weapon1);
    hero::equip_weapon(&mut hero, weapon2);

    // End the scenario.
    test_utils::destroy(hero);
    scenario.end();
}

#[test, expected_failure(abort_code = ::hero::hero::ENotEquipedWeapon)]
fun test_unequip_weapon_not_equiped() {
    let sender = @0xCAFE;

    // Initialize the hero module.
    let mut scenario = test_scenario::begin(sender);
    hero::init_for_testing(scenario.ctx());

    // Mint a new hero.
    scenario.next_tx(sender);
    let mut registry = scenario.take_shared<HeroRegistry>();
    let mut hero = hero::new_hero(
        utf8(b"Batman"),
        100,
        &mut registry,
        scenario.ctx(),
    );
    test_scenario::return_shared(registry);

    // Try unequipping a weapon when the hero has none.
    let weapon = hero::unequip_weapon(&mut hero);

    // End the scenario.
    test_utils::destroy(weapon);
    test_utils::destroy(hero);
    scenario.end();
}
