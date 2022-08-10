/**
 * Validates that all shapeshift type spells
 * have a valid possible_shapes setup.
 */
/datum/unit_test/shapeshift_spell_validity

/datum/unit_test/shapeshift_spell_validity/Run()

	var/list/types_to_test = subtypesof(/datum/action/cooldown/spell/shapeshift)

	for(var/spell_type in types_to_test)
		var/datum/action/cooldown/spell/shapeshift/shift = new spell_type()
		if(!LAZYLEN(shift.possible_shapes))
			Fail("Shapeshift spell: [shift] ([spell_type]) did not have any possible shapeshift options.")

		for(var/shift_type in shift.possible_shapes)
			if(!ispath(shift_type, /mob/living))
				Fail("Shapeshift spell: [shift] had an invalid / non-living shift type ([shift_type]) in their possible shapes list.")

		qdel(shift)

/**
 * Validates that shapeshift spells put the mob in another mob, as they should.
 */
/datum/unit_test/shapeshift_spell

/datum/unit_test/shapeshift_spell/Run()

	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)
	dummy.mind_initialize()

	for(var/spell_type in subtypesof(/datum/action/cooldown/spell/shapeshift))
		// Test all shapeshifts as if they were on the mob's body
		var/datum/action/cooldown/spell/shapeshift/bodybound_shift = new spell_type(dummy)
		if(LAZYLEN(bodybound_shift.possible_shapes) > 1)
			for(var/forced_shape in bodybound_shift.possible_shapes)
				test_spell(dummy, bodybound_shift, forced_shape)

		else if(LAZYLEN(bodybound_shift.possible_shapes) == 1)
			test_spell(dummy, bodybound_shift)

		qdel(bodybound_shift)

		// And test all shapeshifts as if they were on the mob's mind
		var/datum/action/cooldown/spell/shapeshift/mindbound_shift = new spell_type(dummy.mind)
		if(LAZYLEN(mindbound_shift.possible_shapes) > 1)
			for(var/forced_shape in mindbound_shift.possible_shapes)
				test_spell(dummy, mindbound_shift, forced_shape)

		else if(LAZYLEN(bodybound_shift.mindbound_shift) == 1)
			test_spell(dummy, mindbound_shift)

		qdel(mindbound_shift)

/datum/unit_test/shapeshift_spell/proc/test_spell(mob/living/carbon/human/dummy, datum/action/cooldown/spell/shapeshift/shift, forced_type)
	if(forced_type)
		shift.shapeshift_type = forced_shape

	shift.Trigger()
	if(!istype(dummy.loc, shift.shapeshift_type))
		return TEST_FAIL("Shapeshift spell: [shift.name] failed to transform the dummy into the shape [initial(shift.shapeshift_type.name)].")

	var/mob/living/shape = dummy.loc
	if(!(shift in shape.actions))
		return TEST_FAIL("Shapeshift spell: [shift.name] failed to grant the spell to the dummy's shape.")

	shift.next_use_time = 0
	shift.Trigger()
	if(istype(dummy.loc, shift.shapeshift_type))
		return TEST_FAIL("Shapeshift spell: [shift.name] failed to transform the dummy back into a human.")
