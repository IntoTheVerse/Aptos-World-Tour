module publisher::raiders_weapons
{
    use aptos_token_objects::token;
    use aptos_framework::object;
    use std::option::{Self, Option};
    use std::vector;
    use std::string::{Self, String};
    use aptos_std::smart_table::{Self, SmartTable};
    use aptos_token_objects::collection;
    use aptos_std::string_utils;

    const ECOLLECTION_ALREADY_INITIALIZED: u64 = 0;

    struct Collection has key 
    {
        soulbound: bool,
        mintable: bool,
        one_to_one_mapping: Option<SmartTable<address, address>>
    }

    #[resource_group_member(group = aptos_framework::object::ObjectGroup)]
    struct Weapons has key
    {
        weapons: vector<Weapon>
    }

    struct Weapon has store, copy, drop, key
    {
        name: String,
        description: String,
        price: vector<u8>,
        uri: vector<u8>
    }

    fun init_module(admin: &signer) 
    {
        let weapons: vector<Weapon> =
        vector<Weapon>[
            Weapon
            {
                name: string::utf8(b"Pistol"),
                description: string::utf8(b"The quirky sidearm with a big personality, this pistol delivers a punch that'll make you smile while keeping enemies at bay"),
                price: b"0",
                uri:b"https://bafkreido4s6mxcpr32ofnfa3on7r7llvldn3vz6tvr7tkkgl65ydfvi2zu.ipfs.dweb.link/",
            },
            Weapon
            {
                name: string::utf8(b"Revolver"),
                description: string::utf8(b"With a dramatic flair, this eccentric six-shooter spins chambers like a showman, bringing justice with a stylish bang"),
                price: b"4",
                uri:b"https://bafkreifwdtlpnw2dudcakwxgyx2c2sqpvsyplhqtm2hknwblakicjgooza.ipfs.dweb.link/",
            },
            Weapon
            {
                name: string::utf8(b"Plasma Blaster"),
                description: string::utf8(b"A futuristic weapon harnessing intergalactic energy, it fires neon plasma bolts that electrify enemies and light up the battlefield"),
                price: b"8",
                uri:b"https://bafkreifohicxw7de4ioav7jk4pwicjgpicq6esk6t7htzi22dwemgy2stu.ipfs.dweb.link/",
            },
            Weapon
            {
                name: string::utf8(b"Shotgun"),
                description: string::utf8(b"The scatterbrained friend you'll want by your side, this shotgun spreads pellets with wild abandon, turning foes into confetti"),
                price: b"8",
                uri:b"https://bafkreif3f6dxcozlwwmbskayylz45cszw6srfg22snf6w62lrzql24b2za.ipfs.dweb.link/",
            },
            Weapon
            {
                name: string::utf8(b"MP7"),
                description: string::utf8(b"Small but spirited, this submachine gun rattles with gusto, unleashing a hailstorm of bullets that demand attention"),
                price: b"12",
                uri:b"https://bafkreiffq5r6gmiomepa2zfzkjxickclj7zr3naxb4h2w3e5zaedj2cari.ipfs.dweb.link/",
            },
            Weapon
            {
                name: string::utf8(b"GM6 Lynx Sniper"),
                description: string::utf8(b"The eccentric sharpshooter's tool of choice, this high-powered rifle comes with a built-in monocle and a stylish edge"),
                price: b"16",
                uri:b"https://bafkreienor4dykkgtdei3vv5nprraxrlx2vwwatsuritv6wz5jrkypgyh4.ipfs.dweb.link/",
            },
            Weapon
            {
                name: string::utf8(b"N22 Laser Blaster"),
                description: string::utf8(b"Straight out of retro sci-fi, this blaster shoots dazzling lasers with flashy sound effects, invoking nostalgia for space adventures"),
                price: b"16",
                uri:b"https://bafkreihh4mufscyiwreiskcysibhcis6fw4ppuxm5xsn7e2rocobjkif34.ipfs.dweb.link/",
            },
            Weapon
            {
                name: string::utf8(b"QBZ95 SMG"),
                description: string::utf8(b"Armed with an unconventional design and playful charm, this SMG sprays bullets with a funky rhythm, turning firefights into spontaneous dance parties"),
                price: b"20",
                uri:b"https://bafkreiflkuyvzoeoozkjnxw7kbq6vmti6d2k23aglpycta3rg23ngkc72u.ipfs.dweb.link/",
            },
            Weapon
            {
                name: string::utf8(b"Rocket Launcher"),
                description: string::utf8(b"The explosive showstopper, this launcher sends foes flying with thunderous blasts and dazzling fireworks, transforming the battlefield into a chaotic spectacle"),
                price: b"24",
                uri:b"https://bafkreihasi6uoegmxpcbcrel4x5wuqaacyt7edgjr2eghzlmzgsflyahje.ipfs.dweb.link/",
            },
        ];

        move_to(admin, Weapons { weapons });
    }

    public fun create_collection(creator: &signer) 
    {
        let constructor_ref = collection::create_unlimited_collection(
            creator,
            string::utf8(b"The cutting edge swords."),
            string::utf8(b"Raider Weapons"),
            option::none(),
            string::utf8(b"https://linktr.ee/intotheverse")
        );

        move_to(&object::generate_signer(&constructor_ref), Collection {
            soulbound: false,
            mintable: true,
            one_to_one_mapping: option::some(smart_table::new())
        });
    }

    public entry fun mint_weapon(creator: &signer, type: u64) acquires Weapons
    {
        let weapons = borrow_global<Weapons>(@publisher).weapons;
        let weapon = vector::borrow(&weapons, type);

        let constructor_ref = token::create_named_token(
            creator,
            string::utf8(b"Raider Weapons"),
            weapon.description,
            weapon.name,
            option::none(),
            string_utils::format2(&b"{\"uri\": \"{}\", \"price\": \"{}\"}", weapon.uri, weapon.price),
        );

        let token_signer = object::generate_signer(&constructor_ref);
        move_to(&token_signer, *weapon);
    }
}