import { merkle } from 'starknet';
const tree = new merkle.MerkleTree(['1', '2', '3', '4', '5', '6']);

console.log(tree.root);

console.log(tree.getProof('1'))

console.log(merkle.proofMerklePath(tree.root, '1', tree.getProof('1')))