module publisher::aptos_raiders_token
{
    use aptos_framework::fungible_asset::{Self, MintRef, TransferRef, BurnRef, Metadata, FungibleStore};
    use aptos_framework::object::{Self, Object};
    use aptos_framework::primary_fungible_store;
    use std::string::utf8;
    use std::option;

    const EINVALID_MINT: u64 = 1;
    const ASSET_SYMBOL: vector<u8> = b"APTRD";

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct ManagedFungibleAsset has key 
    {
        mint_ref: MintRef,
        transfer_ref: TransferRef,
        burn_ref: BurnRef,
    }

    fun init_module(admin: &signer) 
    {
        let constructor_ref = &object::create_named_object(admin, ASSET_SYMBOL);
        primary_fungible_store::create_primary_store_enabled_fungible_asset(
            constructor_ref,
            option::none(),
            utf8(b"Aptos Raiders Token"),
            utf8(ASSET_SYMBOL),
            0,
            utf8(b"https://bafkreia3ju7pg4a2wi2ieeempnrhfvwzokt6avbs5kcmliuzbpifg2zqa4.ipfs.dweb.link/"),
            utf8(b"https://github.com/IntoTheVerse/Aptos-Hackathon-Game")
        );

        let mint_ref = fungible_asset::generate_mint_ref(constructor_ref);
        let burn_ref = fungible_asset::generate_burn_ref(constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(constructor_ref);
        let metadata_object_signer = object::generate_signer(constructor_ref);
        move_to(
            &metadata_object_signer,
            ManagedFungibleAsset { mint_ref, transfer_ref, burn_ref }
        )
    }

    #[view]
    public fun get_metadata(): Object<Metadata> 
    {
        let asset_address = object::create_object_address(&@publisher, ASSET_SYMBOL);
        object::address_to_object<Metadata>(asset_address)
    }

    #[view]
    public fun get_balance<T: key>(account: address, metadata: Object<T>): u64 
    {
        if (fungible_asset::store_exists(primary_store_address(account, metadata))) 
        {
            fungible_asset::balance(primary_store(account, metadata))
        } 
        else 
        {
            0
        }
    }

    fun primary_store_address<T: key>(owner: address, metadata: Object<T>): address 
    {
        let metadata_addr = object::object_address(&metadata);
        object::create_user_derived_object_address(owner, metadata_addr)
    }

    fun primary_store<T: key>(owner: address, metadata: Object<T>): Object<FungibleStore> 
    {
        let store = primary_store_address(owner, metadata);
        object::address_to_object<FungibleStore>(store)
    }

    public entry fun get_tokens(to: address, amount: u64, chest_opened: u64) acquires ManagedFungibleAsset
    {
        assert!(amount == chest_opened * 4, EINVALID_MINT);
        mint(to, amount);
    }

    fun mint(to: address, amount: u64) acquires ManagedFungibleAsset 
    {
        let asset = get_metadata();
        let managed_fungible_asset = borrow_global<ManagedFungibleAsset>(object::object_address(&asset));
        let to_wallet = primary_fungible_store::ensure_primary_store_exists(to, asset);
        let fa = fungible_asset::mint(&managed_fungible_asset.mint_ref, amount);
        fungible_asset::deposit_with_ref(&managed_fungible_asset.transfer_ref, to_wallet, fa);
    }

    public entry fun burn(from: address, amount: u64) acquires ManagedFungibleAsset 
    {
        let asset = get_metadata();
        let burn_ref = &borrow_global<ManagedFungibleAsset>(object::object_address(&asset)).burn_ref;
        let from_wallet = primary_fungible_store::primary_store(from, asset);
        fungible_asset::burn_from(burn_ref, from_wallet, amount);
    }
}