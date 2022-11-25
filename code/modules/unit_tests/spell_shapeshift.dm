/**
 * Validates that all shapeshift type spells have a valid possible_shapes setup.
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

	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	dummy.mind_initialize()

	for(var/spell_type in subtypesof(/datum/action/cooldown/spell/shapeshift))
		// Test all shapeshifts as if they were on the mob's body
		var/datum/action/cooldown/spell/shapeshift/bodybound_shift = new spell_type(dummy)
		bodybound_shift.Grant(dummy)
		if(LAZYLEN(bodybound_shift.possible_shapes) > 1)
			for(var/forced_shape in bodybound_shift.possible_shapes)
				test_spell(dummy, bodybound_shift, forced_shape)

		else if(LAZYLEN(bodybound_shift.possible_shapes) == 1)
			test_spell(dummy, bodybound_shift)

		qdel(bodybound_shift)

		// And test all shapeshifts as if they were on the mob's mind
		var/datum/action/cooldown/spell/shapeshift/mindbound_shift = new spell_type(dummy.mind)
		mindbound_shift.Grant(dummy)
		if(LAZYLEN(mindbound_shift.possible_shapes) > 1)
			for(var/forced_shape in mindbound_shift.possible_shapes)
				test_spell(dummy, mindbound_shift, forced_shape)

		else if(LAZYLEN(bodybound_shift.possible_shapes) == 1)
			test_spell(dummy, mindbound_shift)

		qdel(mindbound_shift)

/datum/unit_test/shapeshift_spell/proc/test_spell(mob/living/carbon/human/dummy, datum/action/cooldown/spell/shapeshift/shift, forced_shape)
	if(forced_shape)
		shift.shapeshift_type = forced_shape

	shift.next_use_time = 0
	shift.Trigger()
	var/mob/expected_shape = shift.shapeshift_type
	if(!istype(dummy.loc, expected_shape))
		return TEST_FAIL("Shapeshift spell: [shift.name] failed to transform the dummy into the shape [initial(expected_shape.name)]. \
			([dummy] was located within [dummy.loc], which is a [dummy.loc?.type || "null"]).")

	var/mob/living/shape = dummy.loc
	if(!(shift in shape.actions))
		return TEST_FAIL("Shapeshift spell: [shift.name] failed to grant the spell to the dummy's shape.")

	shift.next_use_time = 0
	shift.Trigger()
	if(istype(dummy.loc, shift.shapeshift_type))
		return TEST_FAIL("Shapeshift spell: [shift.name] failed to transform the dummy back into a human.")


/**
 * Validates that shapeshifts function properly with holoparasites.
 */
/datum/unit_test/shapeshift_holoparasites

/datum/unit_test/shapeshift_holoparasites/Run()

	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	var/datum/action/cooldown/spell/shapeshift/wizard/shift = new(dummy)
	shift.shapeshift_type = shift.possible_shapes[1]
	shift.Grant(dummy)

	var/mob/living/simple_animal/hostile/guardian/test_stand = allocate(/mob/living/simple_animal/hostile/guardian)
	test_stand.set_summoner(dummy)

	// The stand's summoner is dummy.
	TEST_ASSERT_EQUAL(test_stand.summoner, dummy, "Holoparasite failed to set the summoner to the correct mob.")

	// Dummy casts shapeshift. The stand's summoner should become the shape the dummy is within.
	shift.Trigger()
	TEST_ASSERT(istype(dummy.loc, shift.shapeshift_type), "Shapeshift spell failed to transform the dummy into the shape [initial(shift.shapeshift_type.name)].")
	TEST_ASSERT_EQUAL(test_stand.summoner, dummy.loc, "Shapeshift spell failed to transfer the holoparasite to the dummy's shape.")

	// Dummy casts shapeshfit back, the stand's summoner should become the dummy again.
	shift.next_use_time = 0
	shift.Trigger()
	TEST_ASSERT(!istype(dummy.loc, shift.shapeshift_type), "Shapeshift spell failed to transform the dummy back into human form.")
	TEST_ASSERT_EQUAL(test_stand.summoner, dummy, "Shapeshift spell failed to transfer the holoparasite back to the dummy's human form.")

	qdel(shift)
