/// Are tests enabled with no focus?
/// Use this when performing test assertions outside of a unit test,
/// since a focused test means that you're trying to run a test quickly.
/// If a parameter is provided, will check if the focus is on that test name.
/// For example, PERFORM_ALL_TESTS(log_mapping) will only run if either
/// no test is focused, or the focus is log_mapping.
#ifdef UNIT_TESTS
// Bit of a trick here, if focus isn't passed in then it'll check for /datum/unit_test/, which is never the case.
#define PERFORM_ALL_TESTS(focus...) (isnull(GLOB.focused_tests) || (/datum/unit_test/##focus in GLOB.focused_tests))
#else
// UNLINT necessary here so that if (PERFORM_ALL_TESTS()) works
#define PERFORM_ALL_TESTS(...) UNLINT(FALSE)
#endif

/// ASSERT(), but it only actually does anything during unit tests
#ifdef UNIT_TESTS
#define TEST_ONLY_ASSERT(test, explanation) if(!(test)) {CRASH(explanation)}
#else
#define TEST_ONLY_ASSERT(test, explanation)
#endif
