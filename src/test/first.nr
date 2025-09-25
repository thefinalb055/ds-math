use crate::test::utils;

#[test]
unconstrained fn test_basic_setup() {
    utils::setup();
    assert(true);
}
