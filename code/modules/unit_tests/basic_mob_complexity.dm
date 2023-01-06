/// Tests that all basic mobs created have not forgotten the many complexities in a mob.
/// I'm doing this because it is a very easy pattern to fall into where you make variables for components and conditionally add them.
/datum/unit_test/basic_mob_complexity

/datum/unit_test/basic_mob_complexity/Run()
	var/list/bmob_paths = subtypesof(/mob/living/basic)

	for(var/bmob_path as anything in bmob_paths)
		var/mob/living/basic/bmob = allocate(bmob_path)

		//consider atmos
		var/no_atmos_flag = bmob.basic_mob_flags & NO_ATMOS_REQUIREMENTS
		var/has_atmos_requirements = HAS_TRAIT(bmob, TRAIT_UNIT_TESTS(/datum/element/atmos_requirements))
		if(no_atmos_flag)
			if(has_atmos_requirements)
				TEST_FAIL("basic mob \"[bmob_path]\" flags that it has no atmos, yet it has atmos requirements.")
		else
			if(!has_atmos_requirements)
				TEST_FAIL("basic mob \"[bmob_path]\" has atmos requirements despite being flagged otherwise.")

		//consider temperature
		var/no_temperature_flagged = bmob.basic_mob_flags & NO_TEMP_SENSITIVITY
		var/has_temperature_sensitivity = HAS_TRAIT(bmob, TRAIT_UNIT_TESTS(/datum/element/basic_body_temp_sensitive))
		if(no_temperature_flagged)
			if(has_temperature_sensitivity)
				TEST_FAIL("basic mob \"[bmob_path]\" flags that it has no temp sensitivity, yet it has temp sensitivity.")
		else
			if(!has_temperature_sensitivity)
				TEST_FAIL("basic mob \"[bmob_path]\" has temp sensitivity despite being flagged otherwise.")

		//consider sentient potion
		var/no_sentience_flagged = bmob.basic_mob_flags & NO_SENTIENCE_POSSIBILITY
		var/has_sentience_possibility = HAS_TRAIT(bmob, TRAIT_UNIT_TESTS(/datum/element/sentience_possible))
		if(no_sentience_flagged)
			if(has_sentience_possibility)
				TEST_FAIL("basic mob \"[bmob_path]\" flags that it has no sentience possibility, yet it has sentience possibility.")
		else
			if(!has_sentience_possibility)
				TEST_FAIL("basic mob \"[bmob_path]\" has sentience possibility despite being flagged otherwise.")
