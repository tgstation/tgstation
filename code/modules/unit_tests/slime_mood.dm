///Unit test that tests all types of moods for slimes, to make sure they all have proper icons.
/datum/unit_test/slime_mood

/datum/unit_test/slime_mood/Run()
	var/mob/living/simple_animal/slime/this_guy = allocate(/mob/living/simple_animal/slime)

	for(var/key in GLOB.emote_list)
		for(var/datum/emote/slime/mood/slime_mood in GLOB.emote_list[key])
			//intentionally does not have a mood key.
			if(!slime_mood.mood_key)
				continue
			TEST_ASSERT((slime_mood.mood_key in icon_states(this_guy.icon)), "[slime_mood] is set to give [this_guy] an emote, but has no Icon for it.")
