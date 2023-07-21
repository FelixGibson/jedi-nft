import { merkle } from 'starknet';
import * as starkCurve from 'micro-starknet';

// array of  [address, token_id]
let list = [['0x0138EfE7c064c69140e715f58d1e29FC75E5594D342E568246a4D6a3131a5974', 1],
['0x0138EfE7c064c69140e715f58d1e29FC75E5594D342E568246a4D6a3131a5975', 2],
['0x0138EfE7c064c69140e715f58d1e29FC75E5594D342E568246a4D6a3131a5976', 3],
['0x0138EfE7c064c69140e715f58d1e29FC75E5594D342E568246a4D6a3131a5977', 4],
['0x0138EfE7c064c69140e715f58d1e29FC75E5594D342E568246a4D6a3131a597a', 5],
['0x0138EfE7c064c69140e715f58d1e29FC75E5594D342E568246a4D6a3131a597E', 6],
];


// convert to aim list, each item is hash of two elements
let aimList = list.map(item => {
    return starkCurve.pedersen(BigInt(item[0]),  BigInt(item[1]))
})
// print aimList
console.log("aimList: ", aimList)
const tree = new merkle.MerkleTree(aimList);

console.log(tree.root);

console.log(tree.getProof(aimList[0]))

// console.log(merkle.proofMerklePath(tree.root, '1', tree.getProof('1')))