/**
 * Security Level Unit Test
 *
 * This test is here to ensure there are no security levels with the same name or number level. Having the same name or number level will cause problems.
 */
/datum/unit_test/security_levels

/datum/unit_test/security_levels/Run()
	var/list/comparison = subtypesof(/datum/security_level)

	for(var/datum/security_level/iterating_level in comparison)
		for(var/datum/security_level/iterating_level_check in comparison)
			if(iterating_level == iterating_level_check) // If they are the same type, don't check
				continue
			TEST_ASSERT_NOTEQUAL(iterating_level.name, iterating_level_check.name, "Security level [iterating_level] has the same name as [iterating_level_check]!")
			TEST_ASSERT_NOTEQUAL(iterating_level.number_level, iterating_level_check.number_level, "Security level [iterating_level] has the same level number as [iterating_level_check]!")
