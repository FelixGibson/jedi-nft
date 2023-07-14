use core::clone::Clone;
use core::traits::TryInto;
#[starknet::contract]
mod JediNFT {
    use traits::{Into, TryInto, Default, Felt252DictValue};
    use array::{SpanSerde, ArrayTrait};
    use clone::Clone;
    use zeroable::Zeroable;
    use rules_erc721::erc721::erc721;
    use rules_erc721::erc721::erc721::ERC721;
    use rules_erc721::erc721::erc721::ERC721::{HelperTrait as ERC721HelperTrait};
    use rules_erc721::erc721::interface::IERC721;
    use rules_erc721::introspection::erc165::{IERC165 as rules_erc721_IERC165};

    #[storage]
    struct Storage {
        _completed_tasks: LegacyMap::<(u256, u256), bool>,
        _starkpath_public_key: felt252,
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
        starkpath_public_key: felt252,
        contract_uri: Span<felt252>
    ) {
        self._uri.write(uri_);
        let mut erc721_self = ERC721::unsafe_new_contract_state();
        // ERC721 init
        erc721_self.initializer(:name_, :symbol_);
        self._starkpath_public_key.write(starkpath_public_key);
        self._contract_uri.write(contract_uri);
    }


    #[external(v0)]
    fn tokenURI(self: @ContractState, token_id: u256) -> Span<felt252> {
        let base_uri = self._uri.read();
        let new_base_uri: Array<felt252> = base_uri.snapshot.clone();
        return append_number_ascii(new_base_uri, token_id).span();
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
            let erc721_self = ERC721::unsafe_new_contract_state();

            erc721_self.supports_interface(:interface_id)
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


    #[generate_trait]
    impl HelperImpl of HelperTrait {

    }
}
