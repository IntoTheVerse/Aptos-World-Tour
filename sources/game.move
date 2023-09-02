module publisher::game
{
    use std::signer;
    use std::string::{String,utf8};

    struct User has key, store, copy, drop
    {
        username: String,
        score: u64,
        level_index: u8
    }

    // This needs to be a view function
    public fun get_user(wallet_address: signer): User acquires User
    {
        let addr = signer::address_of(&wallet_address);
        if(!exists<User>(addr))
        {
            return User {
                username: utf8(b""),
                score: 0,
                level_index: 0
            }
        };
        return *borrow_global<User>(addr)
    }

    public entry fun create_user(wallet_address: signer, username: String): User acquires User
    {
        let addr = signer::address_of(&wallet_address);
        if(!exists<User>(addr))
        {
            move_to(&wallet_address, User {
                username: username,
                score: 0,
                level_index: 0
            });
        };
        return *borrow_global<User>(addr)
    }
}
