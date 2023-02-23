use array::ArrayTrait;

#[contract]
mod ERC721 {
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::ContractAddressZeroable;
    use starknet::ContractAddressIntoFelt;
    use starknet::FeltTryIntoContractAddress;
    use traits::TryInto;
    use traits::Into;
    use option::OptionTrait;

    struct Storage {
        name: felt,
        symbol: felt,
        owners: LegacyMap::<u256, felt>,
        balances: LegacyMap::<ContractAddress, u256>,
        token_approvals: LegacyMap::<u256, felt>,
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
        owner.try_into().unwrap()
    }

    #[view]
    fn get_approved(token_id: u256) -> ContractAddress {
        let owner = owners::read(token_id);
        assert(!owner.is_zero(), 'ERC721: nonexistent token');
        token_approvals::read(token_id).try_into().unwrap()
    }

    #[view]
    fn is_approved_for_all(owner: ContractAddress, operator: ContractAddress) -> bool {
        operator_approvals::read((owner, operator, ))
    }

    #[view]
    fn token_uri(token_id: u256) -> Array::<felt> {
        ArrayTrait::new()
    }

    // setters

    #[external]
    fn approve(to: ContractAddress, token_id: u256) {
        let caller = get_caller_address();
        let owner = owners::read(token_id);
        let owner_as_contract: Option::<ContractAddress> = owner.try_into();
        if (caller.into() == owner | operator_approvals::read(
            (owner_as_contract.unwrap(), caller, )
        )) {
            let as_felt: felt = to.into();
            token_approvals::write(token_id, as_felt);
        } else {
            assert(false, 'ERC721: caller not allowed');
        }
    }
}
