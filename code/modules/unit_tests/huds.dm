/// Tests huds are applied and removed correctly when relevant traits are added/removed
/datum/unit_test/huds

/datum/unit_test/huds/Run()
	var/datum/atom_hud/testhud = GLOB.huds[GLOB.trait_to_hud[TRAIT_SECURITY_HUD]]
	var/mob/living/carbon/human/consistent/dummy = allocate(__IMPLIED_TYPE__)

	ADD_TRAIT(dummy, TRAIT_SECURITY_HUD, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!!testhud.hud_users_all_z_levels[dummy], "HUD not applied when trait of HUD was added")

	ADD_TRAIT(dummy, TRAIT_BLOCK_SECHUD, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!testhud.hud_users_all_z_levels[dummy], "HUD not removed when trait blocking HUD was added")

	REMOVE_TRAIT(dummy, TRAIT_BLOCK_SECHUD, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!!testhud.hud_users_all_z_levels[dummy], "HUD not reapplied when trait blocking HUD was removed")

	REMOVE_TRAIT(dummy, TRAIT_SECURITY_HUD, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!testhud.hud_users_all_z_levels[dummy], "HUD not removed when trait of HUD was removed")
