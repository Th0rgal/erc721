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
fn test_approval() {
    ERC721::constructor('Bored Apes', 'BA');
    let nft_id: u256 = integer::u256_from_felt(1);
    ERC721::owners::write(nft_id, 123);

    let me = starknet::contract_address_const::<123>();
    let friend = starknet::contract_address_const::<456>();
    starknet_testing::set_caller_address(me);
    ERC721::approve(friend, nft_id);
    ERC721::transfer_from(friend, starknet::contract_address_const::<789>(), nft_id);
}
