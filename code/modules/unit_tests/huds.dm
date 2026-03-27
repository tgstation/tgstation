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

///We're gonna give every HUD type to a mob to see if they are missing action intent/health doll.
///This destroys the HUD of the mob we're using (but it doesn't matter cause it's a test)
/datum/unit_test/verify_basic_huds
	focus = TRUE

/datum/unit_test/verify_basic_huds/Run()
	for(var/mob/living/basic/mobs as anything in subtypesof(/mob/living/basic))
		if(mobs::abstract_type == mobs)
			continue
		var/mob/living/basic/dummy = allocate(mobs)
		var/mob_hud = mobs::hud_type
		var/datum/hud/initialized_hud = new mob_hud(dummy)
		//mobs that don't use combat mode don't need it.
		if(!HAS_TRAIT(dummy, TRAIT_COMBAT_MODE_LOCK) && isnull(initialized_hud.action_intent))
			TEST_FAIL("[dummy] using [initialized_hud.type] does not have an Action Intent.")
		//Mobs that need a health indicator should have at least a healthdoll or healths.
		if(initialized_hud.needs_health_indicator && isnull(initialized_hud.healthdoll) && isnull(initialized_hud.healths))
			TEST_FAIL("[dummy] using [initialized_hud.type] does not have a Health Doll.")
