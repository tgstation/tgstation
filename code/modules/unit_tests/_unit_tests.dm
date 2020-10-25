//include unit test files in this module in this ifdef
//Keep this sorted alphabetically

#ifdef UNIT_TESTS

/// Asserts that a condition is true
/// If the condition is not true, fails the test
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Asserts that the two parameters passed are equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// Asserts that the two parameters passed are not equal, fails otherwise
/// Optionally allows an additional message in the case of a failure
#define TEST_ASSERT_NOTEQUAL(a, b, message) if ((a) == (b)) { return Fail("Expected [isnull(a) ? "null" : a] to not be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// *Only* run the test provided within the parentheses
/// This is useful for debugging when you want to reduce noise, but should never be pushed
/// Intended to be used in the manner of `TEST_FOCUS(/datum/unit_test/math)`
#define TEST_FOCUS(test_path) ##test_path { focus = TRUE; }

#include "anchored_mobs.dm"
#include "bespoke_id.dm"
#include "binary_insert.dm"
#include "card_mismatch.dm"
#include "chain_pull_through_space.dm"
#include "component_tests.dm"
#include "confusion.dm"
#include "emoting.dm"
#include "keybinding_init.dm"
#include "machine_disassembly.dm"
#include "medical_wounds.dm"
#include "metabolizing.dm"
#include "outfit_sanity.dm"
#include "pills.dm"
#include "plantgrowth_tests.dm"
#include "quick_swap_sanity.dm"
#include "reagent_id_typos.dm"
#include "reagent_mod_expose.dm"
#include "reagent_mod_procs.dm"
#include "reagent_recipe_collisions.dm"
#include "resist.dm"
#include "say.dm"
#include "serving_tray.dm"
#include "siunit.dm"
#include "spawn_humans.dm"
#include "species_whitelists.dm"
#include "stomach.dm"
#include "subsystem_init.dm"
#include "surgeries.dm"
#include "teleporters.dm"
#include "timer_sanity.dm"
#include "unit_test.dm"

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#undef TEST_ASSERT_NOTEQUAL
#undef TEST_FOCUS
#endif
