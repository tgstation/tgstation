///Unit test that tests all types of moods for slimes, to make sure they all have proper icons, excluding moods that intentionally don't have an icon.
/datum/unit_test/slime_mood

/datum/unit_test/slime_mood/Run()
	var/mob/living/basic/slime/emoting_slime = allocate(/mob/living/basic/slime)

	for(var/key in GLOB.emote_list)
		for(var/datum/emote/slime/mood/slime_mood in GLOB.emote_list[key])
			var/list/states = icon_states(emoting_slime.icon)
			if(!slime_mood.mood_key)
				continue
			TEST_ASSERT(("aslime-[slime_mood.mood_key]" in states), "[slime_mood] is set to give [emoting_slime] the [slime_mood.mood_key] emote, but the icon state can't be found in [emoting_slime.icon].")
