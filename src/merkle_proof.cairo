mod MerkleProof {
    use traits::{Into, TryInto, Felt252DictValue};
    use array::{SpanSerde, ArrayTrait};
    use clone::Clone;
    use array::SpanTrait;
    use ecdsa::check_ecdsa_signature;
    use zeroable::Zeroable;
    use debug::PrintTrait;


    fn verify(proof: Array<u256>, root: u256, leaf: u256) -> bool {
        return process_proof(proof, leaf) == root;
    }

    fn process_proof(proof: Array<u256>, leaf: u256) -> u256 {
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

    fn _hash_pair(a: u256, b: u256) -> u256 {
        if a < b {
            _efficient_hash(a, b)
        } else {
            _efficient_hash(b, a)
        }
    }

    fn _efficient_hash(a: u256, b: u256) -> u256 {
        let hash1 = hash::pedersen(a.low.into(), a.high.into());
        let hash2 = hash::pedersen(b.low.into(), b.high.into());
        let ret = hash::pedersen(hash1, hash2);
        return ret.into();
    }
}
