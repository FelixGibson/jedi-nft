use jedinft::merkle_proof::MerkleProof;

use core::serde::Serde;
use clone::Clone;
use starknet::testing;
use array::{ArrayTrait, SpanTrait, SpanCopy, SpanSerde};
use traits::Into;
use zeroable::Zeroable;
use integer::u256_from_felt252;
use debug::PrintTrait;
use starknet::ContractAddress;
use core::result::ResultTrait;
use option::OptionTrait;
use starknet::class_hash::Felt252TryIntoClassHash;
use traits::TryInto;

use jedinft::jedi_nft::JediNFT;


#[test]
#[available_gas(10000000)]
fn test_verify() {
    let mut proof = ArrayTrait::<felt252>::new();
    proof.append(2);
    proof.append(0x262697b88544f733e5c6907c3e1763131e9f14c51ee7951258abbfb29415fbf);
    proof.append(0x5d768cbfb58b59a888e5ae9fe5d55d83b9b0c1d9365e28e3fe4849f8135ddc3);
    let leaf: felt252 = 1;
    let root: felt252 = 0x329d5b51e352537e8424bfd85b34d0f30b77d213e9b09e2976e6f6374ecb59;
    assert(MerkleProof::verify(proof, root, leaf) == true, 'verify failed');
}

fn URI() -> Span<felt252> {
    let mut uri = ArrayTrait::new();

    uri.append(111);
    uri.append(222);
    uri.append(333);

    uri.span()
}

fn setup_dispatcher(uri: Span<felt252>) -> ContractAddress {
    let mut calldata = ArrayTrait::new();

    'a'.serialize(ref output: calldata);
    'a'.serialize(ref output: calldata);
    uri.serialize(ref output: calldata);
    uri.serialize(ref output: calldata);

    let (address, _) = starknet::deploy_syscall(
        JediNFT::TEST_CLASS_HASH.try_into().unwrap(), 0, calldata.span(), false
    )
        .unwrap();

    address
}

#[test]
#[available_gas(20000000)]
fn test_constructor() {
    starknet::testing::set_caller_address(starknet::contract_address_const::<1>());
    let mut jedi_contract_address = setup_dispatcher(URI());
// let mut jedi_nft =   IInstaSwapPairDispatcher { contract_address: instaswap_pair_address };

}
