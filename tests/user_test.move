// #[test_only]
// module publisher::user_tests
// {
//     use std::signer;
//     use std::unit_test;
//     use std::vector;

//     fun get_account(): signer
//     {
//         vector::pop_back(&mut unit_test::create_signers_for_testing(1))
//     }

//     #[test]
//     public entry fun test_if_it_init()
//     {
//         let addr = signer::address_of(&get_account());
//         aptos_framework::account::create_account_for_test(addr);
//         publisher::game::get_user(account, Memxor);
//     }
// }