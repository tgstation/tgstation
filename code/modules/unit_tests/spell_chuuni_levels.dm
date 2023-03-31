/**
 * Validates that the chuunibyou has an invocation for each school of spell
 */
/datum/unit_test/spell_chuuni_levels

/datum/unit_test/spell_chuuni_levels/Run()

	var/mob/living/carbon/human/chuuni = allocate(/mob/living/carbon/human/consistent)
	var/datum/component/chuunibyou/chuuni_powers = chuuni.AddComponent(/datum/component/chuunibyou)

	var/list/spell_schools_tested = list()
	var/list/types_to_test = subtypesof(/datum/action/cooldown/spell)

	for(var/datum/action/cooldown/spell/spell_type as anything in types_to_test)
		var/spell_school = initial(spell_type.school)
		var/spell_name = initial(spell_type.name)
		if(spell_school in spell_schools_tested)
			continue
		spell_schools_tested |= spell_school
		var/chuuni_invocation = chuuni_powers.chuunibyou_invocations[spell_school]
		TEST_ASSERT(chuuni_invocation, "[spell_name] has a spell school, \"[spell_school]\", that doesn't have a chuuni invocation line!")
