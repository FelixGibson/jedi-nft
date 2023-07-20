use core::clone::Clone;
use core::traits::TryInto;
#[starknet::contract]
mod JediNFT {
    use traits::{Into, TryInto, Default, Felt252DictValue};
    use array::{SpanSerde, ArrayTrait};
    use clone::Clone;
    use array::SpanTrait;
    use ecdsa::check_ecdsa_signature;
    use hash::LegacyHash;
    use zeroable::Zeroable;
    use rules_erc721::erc721::erc721;
    use rules_erc721::erc721::erc721::ERC721;
    use rules_erc721::erc721::erc721::ERC721::{HelperTrait as ERC721HelperTrait};
    use rules_erc721::erc721::interface::IERC721;
    use kass::access::ownable;
    use kass::access::ownable::{Ownable, IOwnable};
    use kass::access::ownable::Ownable::{
        HelperTrait as OwnableHelperTrait, ModifierTrait as OwnableModifierTrait
    };
    use rules_erc721::introspection::erc165::{IERC165 as rules_erc721_IERC165};
    use starknet::ContractAddress;
    use rules_utils::utils::storage::Felt252SpanStorageAccess;
    use jedinft::merkle_proof::MerkleProof;

    #[storage]
    struct Storage {
        _is_minted: LegacyMap::<ContractAddress, bool>,
        _merkle_root: felt252,
        _uri: Span<felt252>,
        _contract_uri: Span<felt252>,
    }

    //
    // Constructor
    //

    #[constructor]
    fn constructor(
        ref self: ContractState,
        name_: felt252,
        symbol_: felt252,
        uri_: Span<felt252>,
        contract_uri: Span<felt252>
    ) {
        self._uri.write(uri_);
        let mut erc721_self = ERC721::unsafe_new_contract_state();
        // ERC721 init
        erc721_self.initializer(:name_, :symbol_);
        self._contract_uri.write(contract_uri);
    }


    #[generate_trait]
    #[external(v0)]
    impl JediNFTImpl of IJediNFT {
        fn tokenURI(self: @ContractState, token_id: u256) -> Span<felt252> {
            let base_uri = self._uri.read();
            let new_base_uri: Array<felt252> = base_uri.snapshot.clone();
            return append_number_ascii(new_base_uri, token_id).span();
        }

        fn contractURI(self: @ContractState) -> Span<felt252> {
            return self._contract_uri.read();
        }

        fn is_minted(self: @ContractState, address: ContractAddress) -> bool {
            return self._is_minted.read(address);
        }

        fn set_merkle_root(ref self: ContractState, merkle_root: felt252) {
            // TODO owner check

            self._merkle_root.write(merkle_root);
        }

        fn get_merkle_root(self: @ContractState) -> felt252 {
            return self._merkle_root.read();
        }

        fn mint_whitelist(ref self: ContractState, token_id: u128, proof: Array<felt252>) {
            let caller = starknet::get_caller_address();
            // TODO verify
            let merkle_root = self._merkle_root.read();
            let leaf = hash::pedersen(caller.into(), token_id.into());
            assert(MerkleProof::verify(proof, merkle_root, leaf) == true, 'verify failed');


            let is_minted = self._is_minted.read(caller);
            assert(!is_minted, 'ALREADY_MINTED');
            self._is_minted.write(caller, true);
            let mut erc721_self = ERC721::unsafe_new_contract_state();
            erc721_self._mint(to: caller, token_id:token_id.into());
        }
    }


    //
    // ERC721 ABI impl
    //

    #[external(v0)]
    impl IERC721Impl of erc721::ERC721ABI<ContractState> {
        // IERC721

        fn name(self: @ContractState) -> felt252 {
            let erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.name()
        }

        fn symbol(self: @ContractState) -> felt252 {
            let erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.symbol()
        }

        fn token_uri(self: @ContractState, token_id: u256) -> felt252 {
            let erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.token_uri(:token_id)
        }

        fn balance_of(self: @ContractState, account: starknet::ContractAddress) -> u256 {
            let erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.balance_of(:account)
        }

        fn owner_of(self: @ContractState, token_id: u256) -> starknet::ContractAddress {
            let erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.owner_of(:token_id)
        }

        fn get_approved(self: @ContractState, token_id: u256) -> starknet::ContractAddress {
            let erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.get_approved(:token_id)
        }

        fn is_approved_for_all(
            self: @ContractState,
            owner: starknet::ContractAddress,
            operator: starknet::ContractAddress
        ) -> bool {
            let erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.is_approved_for_all(:owner, :operator)
        }

        fn approve(ref self: ContractState, to: starknet::ContractAddress, token_id: u256) {
            let mut erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.approve(:to, :token_id);
        }

        fn transfer_from(
            ref self: ContractState,
            from: starknet::ContractAddress,
            to: starknet::ContractAddress,
            token_id: u256
        ) {
            let mut erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.transfer_from(:from, :to, :token_id);
        }

        fn safe_transfer_from(
            ref self: ContractState,
            from: starknet::ContractAddress,
            to: starknet::ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            let mut erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.safe_transfer_from(:from, :to, :token_id, :data);
        }

        fn set_approval_for_all(
            ref self: ContractState, operator: starknet::ContractAddress, approved: bool
        ) {
            let mut erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.set_approval_for_all(:operator, :approved);
        }

        // IERC165

        fn supports_interface(self: @ContractState, interface_id: u32) -> bool {
            // let erc721_self = ERC721::unsafe_new_contract_state();

            // erc721_self.supports_interface(:interface_id)
            // TODO
            false
        }
    }

    fn append_number_ascii(mut uri: Array<felt252>, mut number: u256) -> Array<felt252> {
        loop {
            if number == 0 {
                break;
            }
            let digit: u256 = number % 10;
            number /= 10;
            uri.append(digit.low.into() + 48);
        };
        return uri;
    }
}
