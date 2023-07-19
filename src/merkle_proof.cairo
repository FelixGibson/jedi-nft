mod MerkleProof {
    use traits::{Into, TryInto, Felt252DictValue};
    use array::{SpanSerde, ArrayTrait};
    use clone::Clone;
    use array::SpanTrait;
    use ecdsa::check_ecdsa_signature;
    use zeroable::Zeroable;
    use debug::PrintTrait;


    fn verify(proof: Array<felt252>, root: felt252, leaf: felt252) -> bool {
        return process_proof(proof, leaf) == root;
    }

    fn process_proof(proof: Array<felt252>, leaf: felt252) -> felt252 {
        let mut proof_clone = proof.clone();
        let mut computed_hash = leaf;
        loop {
            match proof_clone.pop_front() {
                Option::Some(another_leaf) => {
                    computed_hash = _hash_pair(computed_hash, another_leaf);
                },
                Option::None(_) => {
                    break ();
                },
            };
        };
        return computed_hash;
    }

    fn _hash_pair(a: felt252, b: felt252) -> felt252 {
        let a_tmp: u256 = a.into();
        let b_tmp: u256 = b.into();
        if a_tmp < b_tmp {
            _efficient_hash(a, b)
        } else {
            _efficient_hash(b, a)
        }
    }

    fn _efficient_hash(a: felt252, b: felt252) -> felt252 {
        let ret = hash::pedersen(a, b);
        return ret.into();
    }
}
