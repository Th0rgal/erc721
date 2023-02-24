use starknet_serde::ContractAddressSerde;

#[abi]
trait IERC721Receiver {
    fn on_erc721_received(
        operator: ContractAddress, from_: ContractAddress, tokenId: u256, data: Array::<felt>
    ) -> felt;
}

#[abi]
trait IERC165 {
    fn supports_interface(interface_id: felt) -> bool;
}
