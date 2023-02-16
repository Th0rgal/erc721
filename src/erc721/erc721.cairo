use array::ArrayTrait;

#[contract]
mod ERC721 {
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::ContractAddressZeroable;

    struct Storage {
        name: felt,
        symbol: felt,
        owners: LegacyMap::<u256, ContractAddress>,
        balances: LegacyMap::<ContractAddress, u256>,
        token_approvals: LegacyMap::<u256, ContractAddress>,
        operator_approvals: LegacyMap::<(ContractAddress, ContractAddress), bool>,
    }

    // events

    #[event]
    fn Transfer(from: ContractAddress, to: ContractAddress, token_id: u256) {}

    #[event]
    fn Approval(owner: ContractAddress, approved: ContractAddress, token_id: u256) {}

    #[event]
    fn ApprovalForAll(owner: ContractAddress, operator: ContractAddress, approved: bool) {}

    #[constructor]
    fn constructor(name_: felt, symbol_: felt) {
        name::write(name_);
        symbol::write(symbol_);
    }

    // getters

    #[view]
    fn get_name() -> felt {
        name::read()
    }

    #[view]
    fn get_symbol() -> felt {
        symbol::read()
    }

    #[view]
    fn balance_of(account: ContractAddress) -> u256 {
        assert(!account.is_zero(), 'ERC721: balance query for zero');
        balances::read(account)
    }

    #[view]
    fn owner_of(token_id: u256) -> ContractAddress {
        let owner = owners::read(token_id);
        assert(!owner.is_zero(), 'ERC721: nonexistent token');
        owner
    }

    #[view]
    fn get_approved(token_id: u256) -> ContractAddress {
        let owner = owners::read(token_id);
        assert(!owner.is_zero(), 'ERC721: nonexistent token');
        token_approvals::read(token_id)
    }

    #[view]
    fn is_approved_for_all(owner: ContractAddress, operator: ContractAddress) -> bool {
        operator_approvals::read((owner, operator, ))
    }

    #[view]
    fn token_uri(token_id: u256) -> Array::<ContractAddress> {
        ArrayTrait::new()
    }

    // setters

    #[external]
    fn approve(to: ContractAddress, token_id: u256) {
        let caller = get_caller_address();
        let owner = owners::read(token_id);
        if (caller == owner | operator_approvals::read(
            (owner, caller, )
        )) {
            token_approvals::write(token_id, to);
        } else {
            assert(false, 'ERC721: caller not allowed');
        }
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
