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

    public fun create_user(wallet_address: signer, username: String): User acquires User
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

    #[test(admin = @0x43)]
    fun game_test(admin: signer) acquires User
    {
        // let user = get_user(admin);
        // std::debug::print(&user);
        // if(user.username == utf8(b""))
        // {
            let new_user = create_user(admin, utf8(b"Memxor"));
            std::debug::print(&new_user);
        //};
    }
}