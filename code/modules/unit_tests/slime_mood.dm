///Unit test that tests all types of moods for slimes, to make sure they all have proper icons.
/datum/unit_test/slime_mood

/datum/unit_test/slime_mood/Run()
	var/mob/living/simple_animal/slime/this_guy = allocate(/mob/living/simple_animal/slime)

	for(var/datum/emote/slime/mood/moods as anything in subtypesof(/datum/emote/slime/mood))
		TEST_ASSERT((moods.mood_key in icon_states(this_guy.icon)), "[moods] is set to give [this_guy] an emote, but has no Icon for it.")
