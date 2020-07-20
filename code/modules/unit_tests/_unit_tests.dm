//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#ifdef UNIT_TESTS
/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [a] to be equal to [b].[message ? " [message]" : ""]") }

#include "anchored_mobs.dm"
#include "bespoke_id.dm"
#include "card_mismatch.dm"
#include "chain_pull_through_space.dm"
#include "component_tests.dm"
#include "outfit_sanity.dm"
#include "plantgrowth_tests.dm"
#include "reagent_id_typos.dm"
#include "reagent_recipe_collisions.dm"
#include "siunit.dm"
#include "spawn_humans.dm"
#include "species_whitelists.dm"
#include "subsystem_init.dm"
#include "surgeries.dm"
#include "timer_sanity.dm"
#include "unit_test.dm"

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
