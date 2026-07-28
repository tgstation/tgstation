/datum/unit_test/stacked_metabolization_effect_verify

/datum/unit_test/stacked_metabolization_effect_verify/Run()
	for(var/datum/stacked_metabolization_effect/effect as anything in valid_subtypesof(/datum/stacked_metabolization_effect))
		effect = new effect()

		if(!length(effect.requirements))
			TEST_FAIL("Effect [effect] does not have any requirments!")
			qdel(effect)
			continue

		for(var/datum/reagent/key as anything in effect.requirements)
			if(!ispath(key, /datum/reagent))
				TEST_FAIL("Effect [effect] has an non reagent key [key] as requirment")
				break

			var/count = effect.requirements[key]
			if(count < 1)
				TEST_FAIL("Effect [effect] has an invalid requirement count [count] for key [key] ")
				break

		qdel(effect)
