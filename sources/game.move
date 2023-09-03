module publisher::game
{
    use std::signer;
    use std::string::{String};

    // structs

    /// a struct representing an accounts user data
    struct User has key
    {
        /// the username of the user
        username: String,
        /// the score of the user
        score: u64,
        /// the index of the level the user is on
        level_index: u8
    }

    // error codes

    /// error code for when a user already exists for a given account address
    const EUserAlreadyExists: u64 = 0;

    /// error code for when a user does not exist for a given account address
    const EUserDoesNotExist: u64 = 1;

    // entry functions

    /// creates a user for the signing account with a given username
    /// * account - the signing account
    /// * username - the username to assign to the user
    public entry fun create_user(account: signer, username: String)
    {
        assert_user_does_not_exist(signer::address_of(&account));
        move_to(&account, User {
            username,
            score: 0,
            level_index: 0
        });
    }

    // view functions

    #[view]
    /// returns the user data for a given account address
    /// * account_address - the address of the account to get the user data for
    public fun get_user(account_address: address): (String, u64, u8)  acquires User
    {
        assert_user_exists(account_address);
        let user = borrow_global<User>(account_address);
        (user.username, user.score, user.level_index)
    }

    // assert statements

    /// asserts that a user does not exist for a given account address
    /// * account_address - the address of the account to check
    fun assert_user_does_not_exist(account_address: address)
    {
        assert!(!exists<User>(account_address), EUserAlreadyExists);
    }

    /// asserts that a user exists for a given account address
    /// * account_address - the address of the account to check
    fun assert_user_exists(account_address: address)
    {
        assert!(exists<User>(account_address), EUserDoesNotExist);
    }
}
