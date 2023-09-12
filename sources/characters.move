module publisher::aptos_raiders_characters
{
    use aptos_token_objects::token;
    use aptos_framework::object;
    use std::option::{Self, Option};
    use std::vector;
    use std::string::{Self, String};
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_token_objects::collection;
    use aptos_std::string_utils;
    use publisher::aptos_raiders_token;
    use std::signer;

    const ECOLLECTION_ALREADY_INITIALIZED: u64 = 0;

    struct Collection has key 
    {
        soulbound: bool,
        mintable: bool,
        one_to_one_mapping: Option<SmartTable<address, address>>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Characters has key
    {
        characters: vector<Character>
    }

    struct Character has store, copy, drop, key
    {
        name: String,
        description: String,
        price: String,
        uri: String,
        we
    }

    fun init_module(admin: &signer) 
    {
        let characters: vector<Character> = 
        vector<Character>[
            Character
            {
                name: string::utf8(b"Tom"),
                description: string::utf8(b"The cheese-obsessed whirlwind, Tom, scampers with a tiny Swiss army knife, leaving a trail of cheddar-infused chaos in his wake"),
                price: string::utf8(b"0"),
                uri: string::utf8(b"https://bafkreiaw7lfkdfrxbd2e27r2p4bykuk7zyegss767mmzfkonqaz7bhmp5q.ipfs.dweb.link/"),
            },
            Character
            {
                name: string::utf8(b"Bob"),
                description: string::utf8(b"A lumberjack struck by disco fever, Bob slays trees with a neon chainsaw while busting funky moves that would make John Travolta proud"),
                price: string::utf8(b"12"),
                uri: string::utf8(b"https://bafkreieuzwuigcmhpqz3a2soo7qvmhzpcchzjo7hqqxlq2tzipu36gneuu.ipfs.dweb.link/"),
            },
            Character
            {
                name: string::utf8(b"Chris"),
                description: string::utf8(b"The peculiar digital sorcerer, Chris, weaves spells with emojis and memes, harnessing the internet's bizarre power to defeat foes in a realm where hashtags hold mystical significance"),
                price: string::utf8(b"20"),
                uri: string::utf8(b"https://bafkreiepfp3l3o2w5ndnpnvudzqz5kmo3kyet4s3rn5ycwae2lsts6ff44.ipfs.dweb.link/"),
            },
        ];

        move_to(admin, Characters { characters });
    }

    #[view]
    public fun get_all_metadata(): vector<Character>  acquires Characters
    {
        let characters = borrow_global<Characters>(@publisher).characters;
        characters
    }

    public fun create_collection(creator: &signer) 
    {
        let constructor_ref = collection::create_unlimited_collection(
            creator,
            string::utf8(b"The brave dungeon raiders."),
            string::utf8(b"Aptos Raider Characters"),
            option::none(),
            string::utf8(b"https://linktr.ee/intotheverse")
        );

        move_to(&object::generate_signer(&constructor_ref), Collection {
            soulbound: false,
            mintable: true,
            one_to_one_mapping: option::some(smart_table::new())
        });
    }

    public entry fun mint_character(creator: &signer, type: u64, price: u64) acquires Characters
    {
        let characters = borrow_global<Characters>(@publisher).characters;
        let character = vector::borrow(&characters, type);

        let constructor_ref = token::create_named_token(
            creator,
            string::utf8(b"Aptos Raider Characters"),
            character.description,
            character.name,
            option::none(),
            string_utils::format2(&b"{},{}", character.uri, character.price),
        );

        let token_signer = object::generate_signer(&constructor_ref);
        move_to(&token_signer, *character);

        if(price > 0)
        {
            aptos_raiders_token::burn(signer::address_of(creator), price);
        }
    }
}