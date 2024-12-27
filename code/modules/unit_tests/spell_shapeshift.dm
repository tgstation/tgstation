/**
 * Validates that all shapeshift type spells have a valid possible_shapes setup.
 */
/datum/unit_test/shapeshift_spell_validity

/datum/unit_test/shapeshift_spell_validity/Run()

	var/list/types_to_test = subtypesof(/datum/action/cooldown/spell/shapeshift)

	for(var/spell_type in types_to_test)
		var/datum/action/cooldown/spell/shapeshift/shift = new spell_type()
		if(!LAZYLEN(shift.possible_shapes))
			TEST_FAIL("Shapeshift spell: [shift] ([spell_type]) did not have any possible shapeshift options.")

		for(var/shift_type in shift.possible_shapes)
			if(!ispath(shift_type, /mob/living))
				TEST_FAIL("Shapeshift spell: [shift] had an invalid / non-living shift type ([shift_type]) in their possible shapes list.")

		qdel(shift)

#define TRIGGER_RESET_COOLDOWN(spell) spell.next_use_time = 0; spell.Trigger();

/**
 * Validates that shapeshift spells put the mob in another mob, as they should.
 */
/datum/unit_test/shapeshift_spell

/datum/unit_test/shapeshift_spell/Run()

	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
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

	TRIGGER_RESET_COOLDOWN(shift)
	var/mob/expected_shape = shift.shapeshift_type
	if(!istype(dummy.loc, expected_shape))
		return TEST_FAIL("Shapeshift spell: [shift.name] failed to transform the dummy into the shape [initial(expected_shape.name)]. \
			([dummy] was located within [dummy.loc], which is a [dummy.loc?.type || "null"]).")

	var/mob/living/shape = dummy.loc
	if(!(shift in shape.actions))
		return TEST_FAIL("Shapeshift spell: [shift.name] failed to grant the spell to the dummy's shape.")

	TRIGGER_RESET_COOLDOWN(shift)
	if(istype(dummy.loc, shift.shapeshift_type))
		return TEST_FAIL("Shapeshift spell: [shift.name] failed to transform the dummy back into a human.")


/**
 * Validates that shapeshifts function properly with holoparasites.
 */
/datum/unit_test/shapeshift_holoparasites

/datum/unit_test/shapeshift_holoparasites/Run()

	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)

	var/datum/action/cooldown/spell/shapeshift/wizard/shift = new(dummy)
	shift.shapeshift_type = shift.possible_shapes[1]
	shift.Grant(dummy)

	var/mob/living/basic/guardian/test_stand = allocate(/mob/living/basic/guardian)
	test_stand.set_summoner(dummy)

	// The stand's summoner is dummy.
	TEST_ASSERT_EQUAL(test_stand.summoner, dummy, "Holoparasite failed to set the summoner to the correct mob.")

	// Dummy casts shapeshift. The stand's summoner should become the shape the dummy is within.
	shift.Trigger()
	TEST_ASSERT(istype(dummy.loc, shift.shapeshift_type), "Shapeshift spell failed to transform the dummy into the shape [initial(shift.shapeshift_type.name)].")
	TEST_ASSERT_EQUAL(test_stand.summoner, dummy.loc, "Shapeshift spell failed to transfer the holoparasite to the dummy's shape.")

	// Dummy casts shapeshfit back, the stand's summoner should become the dummy again.
	TRIGGER_RESET_COOLDOWN(shift)
	TEST_ASSERT(!istype(dummy.loc, shift.shapeshift_type), "Shapeshift spell failed to transform the dummy back into human form.")
	TEST_ASSERT_EQUAL(test_stand.summoner, dummy, "Shapeshift spell failed to transfer the holoparasite back to the dummy's human form.")

	qdel(shift)

#define EXPECTED_HEALTH_RATIO 0.5

/// Validates that shapeshifting carries health or death between forms properly, if it is supposed to
/datum/unit_test/shapeshift_health

/datum/unit_test/shapeshift_health/Run()
	for(var/spell_type in subtypesof(/datum/action/cooldown/spell/shapeshift))
		var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)
		var/datum/action/cooldown/spell/shapeshift/shift_spell = new spell_type(dummy)
		shift_spell.Grant(dummy)
		shift_spell.shapeshift_type = shift_spell.possible_shapes[1]

		if (istype(shift_spell, /datum/action/cooldown/spell/shapeshift/polymorph_belt))
			var/datum/action/cooldown/spell/shapeshift/polymorph_belt/belt_spell = shift_spell
			belt_spell.channel_time = 0 SECONDS // No do-afters

		if (shift_spell.convert_damage)
			shift_spell.Trigger()
			TEST_ASSERT(istype(dummy.loc, shift_spell.shapeshift_type), "Failed to transform into [shift_spell.shapeshift_type]using [shift_spell.name].")
			var/mob/living/shifted_mob = dummy.loc
			shifted_mob.apply_damage(shifted_mob.maxHealth * EXPECTED_HEALTH_RATIO, BRUTE, forced = TRUE)
			TRIGGER_RESET_COOLDOWN(shift_spell)
			TEST_ASSERT(!istype(dummy.loc, shift_spell.shapeshift_type), "Failed to unfransform from [shift_spell.shapeshift_type] using [shift_spell.name].")
			TEST_ASSERT_EQUAL(dummy.get_total_damage(), dummy.maxHealth * EXPECTED_HEALTH_RATIO, "Failed to transfer damage from [shift_spell.shapeshift_type] to original form using [shift_spell.name].")
			TRIGGER_RESET_COOLDOWN(shift_spell)
			TEST_ASSERT(istype(dummy.loc, shift_spell.shapeshift_type), "Failed to transform into [shift_spell.shapeshift_type] after taking damage using [shift_spell.name].")
			shifted_mob = dummy.loc
			TEST_ASSERT_EQUAL(shifted_mob.get_total_damage(), shifted_mob.maxHealth * EXPECTED_HEALTH_RATIO, "Failed to transfer damage from original form to [shift_spell.shapeshift_type] using [shift_spell.name].")
			TRIGGER_RESET_COOLDOWN(shift_spell)

		if (shift_spell.die_with_shapeshifted_form)
			TRIGGER_RESET_COOLDOWN(shift_spell)
			TEST_ASSERT(istype(dummy.loc, shift_spell.shapeshift_type), "Failed to transform into [shift_spell.shapeshift_type]")
			var/mob/living/shifted_mob = dummy.loc
			shifted_mob.health = 0 // Fucking megafauna
			shifted_mob.death()
			if (shift_spell.revert_on_death)
				TEST_ASSERT(!istype(dummy.loc, shift_spell.shapeshift_type), "Failed to untransform after death using [shift_spell.name].")
			TEST_ASSERT_EQUAL(dummy.stat, DEAD, "Failed to kill original mob when transformed mob died using [shift_spell.name].")

		qdel(shift_spell)

#undef EXPECTED_HEALTH_RATIO
#undef TRIGGER_RESET_COOLDOWN
