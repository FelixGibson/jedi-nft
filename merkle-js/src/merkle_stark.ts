import { merkle } from 'starknet';
const tree = new merkle.MerkleTree(['1', '2']);

console.log(tree.root);


