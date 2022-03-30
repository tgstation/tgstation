/**
 * Tests that actions assigned to a mob's mind
 * are successfuly transferred when their mind is transferred to a new mob.
 */
/datum/unit_test/action_move_on_mind_transfer

/datum/unit_test/action_move_on_mind_transfer/Run()

	var/mob/living/carbon/human/wizard = allocate(/mob/living/carbon/human)
	var/mob/living/simple_animal/pet/dog/corgi/wizard_dog = allocate(/mob/living/simple_animal/pet/dog/corgi)
	wizard.mind_initialize()

	var/datum/action/cooldown/spell/pointed/projectile/fireball/fireball = new(wizard.mind)
	fireball.Grant(wizard)
	var/datum/action/cooldown/spell/aoe/magic_missile/missile = new(wizard.mind)
	missile.Grant(wizard)
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jaunt = new(wizard.mind)
	jaunt.Grant(wizard)

	var/datum/mind/wizard_mind = wizard.mind
	wizard_mind.transfer_to(wizard_dog)

	TEST_ASSERT_EQUAL(wizard_dog.mind, wizard_mind, "Mind transfer failed to occur, which invalidates the test.")

	for(var/datum/action/cooldown/spell/remaining_spell in wizard.actions)
		Fail("Spell: [remaining_spell] failed to transfer minds when a mind transfer occured.")

	qdel(fireball)
	qdel(missile)
	qdel(jaunt)

/**
 * Validates that all spells have a correct
 * invocation type and invocation setup.
 */
/datum/unit_test/spell_invocations

/datum/unit_test/spell_invocations/Run()

	var/list/types_to_test = subtypesof(/datum/action/cooldown/spell)

	for(var/datum/action/cooldown/spell/spell_type as anything in types_to_test)
		var/spell_name = initial(spell_type.name)
		var/invoke_type = initial(spell_type.invocation_type)
		switch(invoke_type)
			if(INVOCATION_EMOTE)
				if(isnull(initial(spell_type.invocation_self_message)))
					Fail("Spell: [spell_name] ([spell_type]) set emote invocation type but did not set a self message.")
				if(isnull(initial(spell_type.invocation)))
					Fail("Spell: [spell_name] ([spell_type]) set emote invocation type but did not set an invocation message.")

			if(INVOCATION_SHOUT, INVOCATION_WHISPER)
				if(isnull(initial(spell_type.invocation)))
					Fail("Spell: [spell_name] ([spell_type]) set a speaking invocation type but did not set an invocation message.")

			// INVOCATION_NONE doesn't really matter what they have set for invocation text
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
 * Validates that the mind swap spell
 * properly transfers minds between a caster and a target.
 *
 * Also checks that the mindswap spell itself was transferred over
 * to the new body on cast.
 */
/datum/unit_test/mind_swap_spell

/datum/unit_test/mind_swap_spell/Run()

	var/mob/living/carbon/human/swapper = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/to_swap = allocate(/mob/living/carbon/human)

	swapper.forceMove(run_loc_floor_bottom_left)
	to_swap.forceMove(locate((run_loc_floor_bottom_left.x + 1), run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	swapper.mind_initialize()
	to_swap.mind_initialize()

	var/datum/mind/swapper_mind = swapper.mind
	var/datum/mind/to_swap_mind = to_swap.mind

	var/datum/action/cooldown/spell/pointed/mind_transfer/mind_swap = new(swapper.mind)
	mind_swap.target_requires_key = FALSE
	mind_swap.Grant(swapper)

	// Perform a cast from the very base - mimics a click
	var/result = mind_swap.InterceptClickOn(swapper, null, to_swap)
	TEST_ASSERT(result, "[mind_swap] spell: Mind swap returned \"false\" from InterceptClickOn / cast, despite having valid conditions.")

	TEST_ASSERT_EQUAL(swapper.mind, to_swap_mind, "[mind_swap] spell: Despite returning \"true\" on cast, swap failed to relocate the minds of the caster and the target.")
	TEST_ASSERT_EQUAL(to_swap.mind, swapper_mind, "[mind_swap] spell: Despite returning \"true\" on cast, swap failed to relocate the minds of the target and the caster.")

	var/datum/action/cooldown/spell/pointed/mind_transfer/should_be_null = locate() in swapper.actions
	var/datum/action/cooldown/spell/pointed/mind_transfer/should_not_be_null = locate() in to_swap.actions

	TEST_ASSERT(!isnull(should_not_be_null), "[mind_swap] spell: The spell was not transferred to the caster's new body, despite successful mind reolcation.")
	TEST_ASSERT(isnull(should_be_null), "[mind_swap] spell: The spell remained on the caster's original body, despite successful mind relocation.")

	qdel(mind_swap)
