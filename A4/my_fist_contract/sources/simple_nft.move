module my_fist_contract::simple_nft;

// === Structs ===

/// An object that contains an arbitrary string
public struct Hero has key, store {
    id: UID,
}

// === Public Functions ===

#[lint_allow(self_transfer)]
public fun mint(ctx: &mut TxContext) {
    let object = Hero {
        id: object::new(ctx)
    };
    transfer::public_transfer(object, ctx.sender());
}
