use array::ArrayTrait;

#[contract]
mod ERC721 {
    use starknet::get_caller_address;

    struct Storage {
        name: felt,
        symbol: felt,
        owners: LegacyMap::<u256, felt>,
        balances: LegacyMap::<felt, u256>,
        token_approvals: LegacyMap::<u256, felt>,
        operator_approvals: LegacyMap::<(felt, felt), u256>,
    }

    #[event]
    fn Transfer(from: felt, to: felt, token_id: u256) {}

    #[event]
    fn Approval(owner: felt, approved: felt, token_id: u256) {}

    #[event]
    fn ApprovalForAll(owner: felt, operator: felt, approved: bool) {}

    #[constructor]
    fn constructor(name_: felt, symbol_: felt) {
        name::write(name_);
        symbol::write(symbol_);
    }

    #[view]
    fn get_name() -> felt {
        name::read()
    }

    #[view]
    fn get_symbol() -> felt {
        symbol::read()
    }

    #[view]
    fn balance_of(account: felt) -> u256 {
        assert(account != 0, 'ERC721: balance query for zero');
        balances::read(account)
    }

    #[view]
    fn owner_of(token_id: u256) -> felt {
        let owner = owners::read(token_id);
        assert(owner != 0, 'ERC721: nonexistent token');
        owner
    }

    #[view]
    fn get_approved(token_id: u256) -> felt {
        let owner = owners::read(token_id);
        assert(owner != 0, 'ERC721: nonexistent token');
        token_approvals::read(token_id)
    }

}

#[test]
#[available_gas(200000)]
fn get_name() {
    let mut retdata = ERC721::__external::get_name(ArrayTrait::new());
    pop_and_compare(ref retdata, 0, 'Wrong result');
    assert_empty(retdata);
}

// Utility functions

fn pop_and_compare(ref arr: Array::<felt>, value: felt, err: felt) {
    match arr.pop_front() {
        Option::Some(x) => {
            assert(x == value, err);
        },
        Option::None(_) => {
            panic(single_element_arr('Got empty result data'))
        },
    };
}

fn assert_empty(mut arr: Array::<felt>) {
    assert(arr.is_empty(), 'Array not empty');
}

fn single_element_arr(value: felt) -> Array::<felt> {
    let mut arr = ArrayTrait::new();
    arr.append(value);
    arr
}
