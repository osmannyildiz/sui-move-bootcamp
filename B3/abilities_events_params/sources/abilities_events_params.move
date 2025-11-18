module abilities_events_params::abilities_events_params;

// === Imports ===

use std::string::String;
use sui::event;

// === Errors ===

const EMedalOfHonorNotAvailable: u64 = 111;

// === Structs ===

public struct Hero has key {
    id: UID, // required
    name: String,
    medals: vector<Medal>, // Holds medals belonging to the hero
}

public struct HeroRegistry has key, store { // Here `store` is optional. It makes the objects independent from the contract
    id: UID,
    heroes: vector<ID>, // If we did `vector<Hero>`, users wouldn't be able to own the heroes, and we need to store the ID in the event anyway
}

public struct Medal has key, store {
    id: UID,
    name: String,
}

public struct MedalStorage has key, store { // Here `store` is optional. It makes the objects independent from the contract
    id: UID,
    medals: vector<Medal>, // Holds medals that belong to no hero yet
}

// === Events ===

public struct HeroMinted has copy, drop {
    hero_id: ID,
    owner: address,
}

// === Module Initializer ===

fun init(ctx: &mut TxContext) {
    let hero_registry = HeroRegistry { 
        id: object::new(ctx),
        heroes: vector::empty(),
    };
    transfer::share_object(hero_registry);

    let medal_storage = MedalStorage {
        id: object::new(ctx),
        medals: vector[],
    };
    transfer::share_object(medal_storage);
}

// === Public Functions ===

public fun mint_hero(name: String, hero_registry: &mut HeroRegistry, ctx: &mut TxContext): Hero {
    let freshHero = Hero {
        id: object::new(ctx), // creates a new UID
        name,
        medals: vector[],
    };

    // hero_registry.heroes.push_back(freshHero.id.to_inner());
    // vector::push_back(hero_registry.heroes, object::id(&freshHero)); // TODO Why does this error?
    hero_registry.heroes.push_back(object::id(&freshHero));

    event::emit(HeroMinted {
        hero_id: object::id(&freshHero),
        owner: ctx.sender(),
    });

    freshHero
}

public fun mint_and_keep_hero(name: String, hero_registry: &mut HeroRegistry, ctx: &mut TxContext) {
    let hero = mint_hero(name, hero_registry, ctx);
    transfer::transfer(hero, ctx.sender());
}

public fun create_medal(name: String, medal_storage: &mut MedalStorage, ctx: &mut TxContext) {
    let freshMedal = Medal {
        id: object::new(ctx),
        name,
    };
    medal_storage.medals.push_back(freshMedal);
}

// public fun award_medal(hero: &mut Hero, medal_storage: &mut MedalStorage, ctx: &mut TxContext) {
//     let medal = medal_storage.medals.pop_back();
//     hero.medals.push_back(medal);
// }

public fun award_medal(medal_name: String, hero: &mut Hero, medal_storage: &mut MedalStorage) {
    let medal = pop_medal_by_name(medal_name, medal_storage);
    assert!(medal.is_some(), EMedalOfHonorNotAvailable);
    // hero.medals.append(medal.to_vec());
    // let medal = medal.extract();
    let medal = medal.destroy_some();
    hero.medals.push_back(medal);
}

fun pop_medal_by_name(name: String, medal_storage: &mut MedalStorage): Option<Medal> {
    let mut i = 0;
    while (i < medal_storage.medals.length()) {
        if (medal_storage.medals[i].name == name) {
            let medal = vector::remove(&mut medal_storage.medals, i);
            return option::some(medal)
        };
        i = i + 1;
    };
    // option::none<Medal>()
    option::none()
}

// === Tests ===

#[test_only]
use sui::test_scenario as ts;
#[test_only]
use sui::test_scenario::{take_shared, return_shared};
#[test_only]
use sui::test_utils::{destroy};
#[test_only]
use std::unit_test::assert_eq;

//--------------------------------------------------------------
//  Test 1: Hero Creation
//--------------------------------------------------------------
//  Objective: Verify the correct creation of a Hero object.
//  Tasks:
//      1. Complete the test by calling the `mint_hero` function with a hero name.
//      2. Assert that the created Hero's name matches the provided name.
//      3. Properly clean up the created Hero object using `destroy`.
//--------------------------------------------------------------
#[test]
fun test_hero_creation() {
    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);

    // Get hero registry
    let mut hero_registry = take_shared<HeroRegistry>(&test);

    let hero = mint_hero(b"Flash".to_string(), &mut hero_registry, test.ctx());
    assert_eq!(hero.name, b"Flash".to_string());
    assert_eq!(hero_registry.heroes.length(), 1);

    return_shared(hero_registry);
    destroy(hero);
    test.end();
}

//--------------------------------------------------------------
//  Test 2: Event Emission
//--------------------------------------------------------------
//  Objective: Implement event emission during hero creation and verify its correctness.
//  Tasks:
//      1. Define a `HeroMinted` event struct with appropriate fields (e.g., hero ID, owner address).  Remember to add `copy, drop` abilities!
//      2. Emit the `HeroMinted` event within the `mint_hero` function after creating the Hero.
//      3. In this test, capture emitted events using `event::events_by_type<HeroMinted>()`.
//      4. Assert that the number of emitted `HeroMinted` events is 1.
//      5. Assert that the `owner` field of the emitted event matches the expected address (e.g., @USER).
//--------------------------------------------------------------
#[test]
fun test_event_thrown() {
    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);

    let mut hero_registry = take_shared<HeroRegistry>(&test);

    let hero1 = mint_hero(b"Ali".to_string(), &mut hero_registry, test.ctx());
    let hero2 = mint_hero(b"Dio".to_string(), &mut hero_registry, test.ctx());

    let events = event::events_by_type<HeroMinted>();
    assert_eq!(events.length(), 2);

    return_shared(hero_registry);
    // let Hero { id, name: _, medals: _ } = hero1;
    // let Hero { id, .. } = hero1;
    // object::delete(id);
    // id.delete();
    destroy(hero1);
    destroy(hero2);
    test.end();
}

//--------------------------------------------------------------
//  Test 3: Medal Awarding
//--------------------------------------------------------------
//  Objective: Implement medal awarding functionality to heroes and verify its effects.
//  Tasks:
//      1. Define a `Medal` struct with appropriate fields (e.g., medal ID, medal name). Remember to add `key, store` abilities!
//      2. Add a `medals: vector<Medal>` field to the `Hero` struct to store the medals a hero has earned.
//      3. Create functions to award medals to heroes, e.g., `award_medal_of_honor(hero: &mut Hero)`.
//      4. In this test, mint a hero.
//      5. Award a specific medal (e.g., Medal of Honor) to the hero using your `award_medal_of_honor` function.
//      6. Assert that the hero's `medals` vector now contains the awarded medal.
//      7. Consider creating a shared `MedalStorage` object to manage the available medals.
//--------------------------------------------------------------
#[test]
fun test_medal_award() {
    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);

    let mut hero_registry = take_shared<HeroRegistry>(&test);
    let mut medal_storage = take_shared<MedalStorage>(&test);

    let mut hero = mint_hero(b"Lofi the Yeti".to_string(), &mut hero_registry, test.ctx());

    create_medal(b"Sui Move Bootcamp Ankara".to_string(), &mut medal_storage, test.ctx());
    assert_eq!(medal_storage.medals.length(), 1);

    award_medal(b"Sui Move Bootcamp Ankara".to_string(), &mut hero, &mut medal_storage);
    assert_eq!(hero.medals.length(), 1);
    assert_eq!(medal_storage.medals.length(), 0);

    return_shared(hero_registry);
    return_shared(medal_storage);
    destroy(hero);
    test.end();
}
