/**
 * Validates that the mind swap spell
 * properly transfers minds between a caster and a target.
 *
 * Also checks that the mindswap spell itself was transferred over
 * to the new body on cast.
 */
/datum/unit_test/mind_swap_spell

/datum/unit_test/mind_swap_spell/Run()

	var/mob/living/carbon/human/swapper = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/to_swap = allocate(/mob/living/carbon/human/consistent)
	swapper.real_name = "The Mindswapper"
	swapper.name = swapper.real_name
	to_swap.real_name = "The Guy Who Gets Mindswapped"
	to_swap.name = to_swap.real_name

	swapper.forceMove(run_loc_floor_bottom_left)
	to_swap.forceMove(locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

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
