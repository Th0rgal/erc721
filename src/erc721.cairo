#[contract]
mod ERC721 {
    use zeroable::Zeroable;
    use starknet::get_caller_address;
    use starknet::ContractAddressZeroable;
    use starknet::ContractAddressIntoFelt;
    use starknet::FeltTryIntoContractAddress;
    use starknet::contract_address_try_from_felt;
    use traits::Into;
    use traits::TryInto;
    use array::ArrayTrait;
    use option::OptionTrait;
    use erc721::interfaces::IERC721ReceiverDispatcher;
    use erc721::interfaces::IERC165Dispatcher;

    struct Storage {
        name: felt,
        symbol: felt,
        owners: LegacyMap::<u256, felt>,
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
        let owner_as_contract: ContractAddress = owner.try_into().unwrap();
        if is_approved_or_owner(
            caller, token_id
        ) {
            let as_felt: felt = to.into();
            token_approvals::write(token_id, as_felt);
            Approval(owner_as_contract, to, token_id);
        } else {
            assert(false, 'ERC721: caller not allowed');
        }
    }


    #[external]
    fn set_approval_for_all(operator: ContractAddress, approved: bool) {
        let caller = get_caller_address();
        operator_approvals::write((caller, operator), approved);
        ApprovalForAll(caller, operator, approved);
    }

    #[external]
    fn transfer_from(from: ContractAddress, to: ContractAddress, token_id: u256) {
        let caller = get_caller_address();
        assert(is_approved_or_owner(caller, token_id), 'ERC721: not approved');
        _transfer(from, to, token_id);
    }

    const IERC721_RECEIVER_ID: felt = 0x150b7a02;
    const IACCOUNT_ID: felt = 0xa66bd575;

    #[external]
    fn safe_transfer_from(
        from: ContractAddress, to: ContractAddress, token_id: u256, data: Array::<felt>
    ) {
        let caller = get_caller_address();
        assert(is_approved_or_owner(caller, token_id), 'ERC721: not approved');

        if IERC165Dispatcher::supports_interface(
            to, IERC721_RECEIVER_ID
        ) {
            let selector = IERC721ReceiverDispatcher::on_erc721_received(
                to, caller, from, token_id, data
            );
            assert(selector == IERC721_RECEIVER_ID, 'ERC721: not ERC721Receiver');
        } else {
            assert(
                IERC165Dispatcher::supports_interface(to, IACCOUNT_ID), 'ERC721: wrong interface'
            );
        }
        _transfer(from, to, token_id);
    }

    // utils

    fn is_approved_or_owner(address: ContractAddress, token_id: u256) -> bool {
        let owner = owners::read(token_id);
        let owner_as_contract: ContractAddress = owner.try_into().unwrap();
        address.into() == owner | operator_approvals::read((owner_as_contract, address, ))
    }

    fn _transfer(from: ContractAddress, to: ContractAddress, token_id: u256) {
        owners::write(token_id, to.into());
        Transfer(from, to, token_id);
    }
}
