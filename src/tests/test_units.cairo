use erc721::ERC721;
use traits::Into;
use traits::TryInto;
use starknet::contract_address_try_from_felt;
use starknet::FeltTryIntoContractAddress;

#[test]
#[available_gas(2000000)]
fn test_get_name() {
    ERC721::constructor('Bored Apes', 'BA');

    assert(ERC721::get_name() == 'Bored Apes', 'wrong name');
}

#[test]
#[available_gas(2000000)]
fn test_get_symbol() {
    ERC721::constructor('Bored Apes', 'BA');

    assert(ERC721::get_symbol() == 'BA', 'wrong name');
}

#[test]
#[available_gas(2000000)]
fn test_owner_of() {
    ERC721::constructor('Bored Apes', 'BA');
    let nft_id: u256 = integer::u256_from_felt(1);
    ERC721::owners::write(nft_id, 123);

    let owner = ERC721::owner_of(nft_id);
    assert(owner.into() == 123, 'wrong owner');
}

#[test]
#[available_gas(2000000)]
fn test_approved() {
    ERC721::constructor('Bored Apes', 'BA');
    let nft_id: u256 = integer::u256_from_felt(1);
    ERC721::owners::write(nft_id, 123);

    let me = starknet::contract_address_const::<123>();
    let friend = starknet::contract_address_const::<456>();
    starknet_testing::set_caller_address(me);
    ERC721::approve(friend, nft_id);
    ERC721::transfer_from(friend, starknet::contract_address_const::<789>(), nft_id);
}

#[test]
#[available_gas(2000000)]
fn test_approved_for_all() {
    ERC721::constructor('Bored Apes', 'BA');
    let nft_id: u256 = integer::u256_from_felt(1);
    ERC721::owners::write(nft_id, 123);

    let me = starknet::contract_address_const::<123>();
    let friend = starknet::contract_address_const::<456>();
    starknet_testing::set_caller_address(me);
    ERC721::set_approval_for_all(friend, true);
    ERC721::transfer_from(friend, starknet::contract_address_const::<789>(), nft_id);
}

#[test]
#[available_gas(2000000)]
#[should_panic(expected = ('ERC721: caller not allowed', ))]
fn test_not_approved() {
    ERC721::constructor('Bored Apes', 'BA');
    let nft_id: u256 = integer::u256_from_felt(1);
    ERC721::owners::write(nft_id, 123);

    let me = starknet::contract_address_const::<123>();
    let friend = starknet::contract_address_const::<456>();
    // random caller address
    starknet_testing::set_caller_address(starknet::contract_address_const::<36378278>());
    ERC721::approve(friend, nft_id);
    ERC721::transfer_from(friend, starknet::contract_address_const::<789>(), nft_id);
}

#[test]
#[available_gas(2000000)]
fn test_transfer() {
    ERC721::constructor('Bored Apes', 'BA');
    let nft_id: u256 = integer::u256_from_felt(1);
    ERC721::owners::write(nft_id, 123);

    let me = starknet::contract_address_const::<123>();
    let friend = starknet::contract_address_const::<456>();
    starknet_testing::set_caller_address(me);
    ERC721::transfer_from(me, friend, nft_id);

    let new_owner = ERC721::owners::read(nft_id);
    assert(new_owner == 456, 'wrong new owner');
}
