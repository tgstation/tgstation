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

/**
 * Used for registering typepaths of item to be tracked as a "required map item"
 * This is used to ensure that that all station maps have certain items mapped in that they should have
 * Or that people aren't mapping in an excess of items that they shouldn't be
 * (For example, all map should only ever have 1 Pun Pun)
 *
 * Min is inclusive, Max is inclusive (so 1, 1 means min of 1, max of 1, or only 1 allowed)
 *
 * This should only be used in Initialize(). And don't forget to update the unit test with the type itself!
 */
#ifdef UNIT_TESTS
#define REGISTER_REQUIRED_MAP_ITEM(min, max) \
	do { \
		if(mapload) { \
			var/turf/spawn_turf = get_turf(src); \
			if(is_station_level(spawn_turf?.z || 0)) { \
				var/datum/required_item/existing_value = GLOB.required_map_items[type]; \
				if(isnull(existing_value)) { \
					var/datum/required_item/new_value = new(type, min, max); \
					GLOB.required_map_items[type] = new_value; \
				} else { \
					existing_value.total_amount += 1; \
				}; \
			}; \
		}; \
	} while (FALSE)
#else
#define REGISTER_REQUIRED_MAP_ITEM(min, max)
#endif
