use erc721::ERC721;

#[test]
#[available_gas(2000000)]
fn test_get_name() {
    let name = ERC721::get_name();
}
