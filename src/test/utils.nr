use dep::aztec::{
    protocol_types::address::AztecAddress, test::helpers::test_environment::TestEnvironment,
};

pub unconstrained fn setup() -> (TestEnvironment, AztecAddress, AztecAddress) {
    let mut env = TestEnvironment::new();

    (env)
}
