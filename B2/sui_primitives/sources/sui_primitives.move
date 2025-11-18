module sui_primitives::sui_primitives;

// === Imports ===

#[test_only]
use sui::dynamic_field;
#[test_only]
use sui::dynamic_object_field;
#[test_only]
use sui::test_scenario;

// === Errors ===

const EInvalidNumber: u64 = 607;
const EIncorrectFactorial: u64 = 608;

// === Test Functions ===

#[test]
fun test_numbers() {
    let a = 50;
    let b = 50;
    assert!(a == b, 601);

    let c = a + b;
    assert!(c == 100, 602);
}

#[test, expected_failure]
fun test_overflow() {
    let a = 255;
    let b = 1u8;

    assert!(a + b == 0, 604);
}

#[test]
fun test_mutability() {
    let mut a = 10;
    a = a + 10;
}

#[test]
fun test_boolean() {
    let a = 69;
    let b = 42;
    let a_greater_than_b = a > b;
    assert!(a_greater_than_b, EInvalidNumber);
}

#[test]
fun test_loop() {
    let mut acc = 1;
    let mut i = 5;
    while (i > 1) {
        acc = acc * i;
        i = i - 1;
    };
    std::debug::print(&acc);
    assert!(acc == 120, EIncorrectFactorial);
}

#[test]
fun test_vector() {
    let mut myVec: vector<u8> = vector[10, 20, 30];

    assert!(myVec.length() == 3, 609);
    assert!(!myVec.is_empty() == true, 610);

    // let mut i = 0;
    // while (i < myVec.length()) { // This doesn't work since the condition will be re-evaluated
    //     myVec.pop_back();
    //     i = i + 1;
    // };
    while (myVec.length() > 0) {
        myVec.pop_back();
    };
    assert!(myVec.length() == 0, 611);
    assert!(myVec.is_empty(), 612);
}

#[test]
fun test_string() {
    let myStringArr: vector<u8> = b"Hello, World!";
    assert!(myStringArr[2] == 108, 613);
}

#[test]
fun test_string2() {
    let myStringArr = b"Hello, World!";

    // TODO What if there was no 'W' in myStringArr?
    let mut i = 0;
    while (i < myStringArr.length()) {
        if (myStringArr[i] == 87) { // W = 87
            break
        };
        i = i + 1;
    };
    std::debug::print(&b"Index of 'W':".to_string());
    std::debug::print(&i.to_string());
    assert!(i == 7, 614);
}

public struct Container has key {
    id: UID,
}

public struct Item has key, store {
    id: UID,
    value: u64,
}

public struct Item2 has key, store {
    id: UID,
    value2: u64,
}

public struct ScoreKey has copy, drop, store {}
public struct TimeKey has copy, drop, store {}
public struct FaulKey has copy, drop, store {}
public struct ItemKey has copy, drop, store {}
public struct Item2Key has copy, drop, store {}

#[test]
fun test_dynamic_fields() {
    let mut test_scenario = test_scenario::begin(@0xCAFE);
    let mut container = Container {
        id: object::new(test_scenario.ctx()),
    };

    // PART 1: Dynamic Fields

    dynamic_field::add(&mut container.id, ScoreKey {}, 100u64);
    // dynamic_field::add(&mut container.id, TimeKey {}, test_scenario.ctx().epoch_timestamp_ms());
    dynamic_field::add(&mut container.id, TimeKey {}, 90 * 60);
    dynamic_field::add(&mut container.id, FaulKey {}, 3u8);
    
    let score = dynamic_field::borrow(&container.id, ScoreKey {});
    let time = dynamic_field::borrow(&container.id, TimeKey {});
    let faul = dynamic_field::borrow(&container.id, FaulKey {});
    
    assert!(score == 100, 123);
    assert!(time == 90 * 60, 124);
    assert!(faul == 3u8, 125); // `faul` is inferred as &u8
    // assert!(faul == 3, 125); // `faul` is inferred as &u64. This errors while running the test
    
    dynamic_field::remove<ScoreKey, u64>(&mut container.id, ScoreKey {});
    dynamic_field::remove<TimeKey, u64>(&mut container.id, TimeKey {});
    dynamic_field::remove<FaulKey, u8>(&mut container.id, FaulKey {});
    
    assert!(!dynamic_field::exists_(&container.id, ScoreKey {}), 126);
    assert!(!dynamic_field::exists_(&container.id, TimeKey {}), 127);
    assert!(!dynamic_field::exists_(&container.id, FaulKey {}), 128);

    // PART 2: Dynamic Object Fields

    let item = Item {
        id: object::new(test_scenario.ctx()),
        value: 500,
    };
    let item2 = Item2 {
        id: object::new(test_scenario.ctx()),
        value2: 69,
    };
    
    dynamic_object_field::add(&mut container.id, ItemKey {}, item);
    dynamic_object_field::add(&mut container.id, Item2Key {}, item2);
    
    let item_ref = dynamic_object_field::borrow<ItemKey, Item>(&container.id, ItemKey {});
    let item2_ref = dynamic_object_field::borrow<Item2Key, Item2>(&container.id, Item2Key {});
    
    assert!(item_ref.value == 500, 129);
    assert!(item2_ref.value2 == 69, 130);

    let item = dynamic_object_field::remove<ItemKey, Item>(&mut container.id, ItemKey {});
    let item2 = dynamic_object_field::remove<Item2Key, Item2>(&mut container.id, Item2Key {});
    
    assert!(!dynamic_object_field::exists_(&container.id, ItemKey {}), 131);
    assert!(!dynamic_object_field::exists_(&container.id, Item2Key {}), 132);
    
    let Item { id, value: _ } = item;
    object::delete(id);
    let Item2 { id, .. } = item2;
    object::delete(id);

    // Clean up
    let Container {
        id,
    } = container;
    object::delete(id);
    test_scenario.end();
}
