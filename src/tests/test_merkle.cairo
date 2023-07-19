use jedinft::merkle_proof::MerkleProof;

use core::serde::Serde;
use clone::Clone;
use starknet::testing;
use array::{ ArrayTrait, SpanTrait, SpanCopy, SpanSerde };
use traits::Into;
use zeroable::Zeroable;
use integer::u256_from_felt252;
use debug::PrintTrait;

#[test]
#[available_gas(10000000)]
fn test_verify() {
    let mut proof = ArrayTrait::<u256>::new();
    proof.append(0xa7c46294ffa3fad92dc8422b2e38b688ccf1b86172f5beaf864af9368d2844e5_u256);
    proof.append(0x5a8ead40cd9687835259cd89e45e2781d13c6ba02e8b0a08f1be6d3f47f69f74_u256);
    proof.append(0xc97e9e1eb896293c19f2649c796c9a276d997cfa58164c5f25d9a3f29b894cc9_u256);
    let leaf: u256 = 1.into();
    let root: u256 = 0x61067c4379bac00d29e8e8ddbc412848e77a47df1b73d5a5c7b904874018a180_u256;
    assert(MerkleProof::verify(proof, root, leaf) == true, 'verify failed');
}