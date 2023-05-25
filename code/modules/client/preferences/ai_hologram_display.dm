/// What to show on the AI hologram
/datum/preference/choiced/ai_hologram_display
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "preferred_ai_hologram_display"
	should_generate_icons = TRUE

/datum/preference/choiced/ai_hologram_display/init_possible_values()
	var/list/values = list()

	values["Random"] = icon('icons/mob/silicon/ai.dmi', "ai-empty")

	for (var/screen in GLOB.ai_hologram_display_screens - "Portrait" - "Random")
		values[screen] = icon('icons/mob/silicon/ai.dmi', resolve_ai_icon_sync(screen))



	var/mob/living/carbon/human/dummy/ai_dummy = new
	var/mutable_appearance/dummy_appearance = usr.client.prefs.render_new_preview_appearance(ai_dummy)
	if(dummy_appearance)
		qdel(ai_dummy)
		hologram_appearance = dummy_appearance


	values["Bear"] = icon('icons/mob/simple/animal.dmi', "bear")


	if("Animal")
		var/list/icon_list = list(
		"bear" = 'icons/mob/simple/animal.dmi',
		"carp" = 'icons/mob/simple/carp.dmi',
		"chicken" = 'icons/mob/simple/animal.dmi',
		"corgi" = 'icons/mob/simple/pets.dmi',
		"cow" = 'icons/mob/simple/animal.dmi',
		"crab" = 'icons/mob/simple/animal.dmi',
		"fox" = 'icons/mob/simple/pets.dmi',
		"goat" = 'icons/mob/simple/animal.dmi',
		"cat" = 'icons/mob/simple/pets.dmi',
		"cat2" = 'icons/mob/simple/pets.dmi',
		"poly" = 'icons/mob/simple/animal.dmi',
		"pug" = 'icons/mob/simple/pets.dmi',
		"spider" = 'icons/mob/simple/animal.dmi'
		)


		if("poly")
			working_state = "parrot_fly"
		if("chicken")
			working_state = "chicken_brown"
		if("spider")
			working_state = "guard"
		else
			working_state = input
		hologram_appearance = mutable_appearance(icon_list[input], working_state)

		var/list/icon_list = list(
			"default" = 'icons/mob/silicon/ai.dmi',
			"floating face" = 'icons/mob/silicon/ai.dmi',
			"xeno queen" = 'icons/mob/nonhuman-player/alien.dmi',
			"horror" = 'icons/mob/silicon/ai.dmi',
			"clock" = 'icons/mob/silicon/ai.dmi'
			)

		if("xeno queen")
			working_state = "alienq"

		hologram_appearance = mutable_appearance(icon_list[input], working_state)









	return values

/datum/preference/choiced/ai_hologram_display/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return istype(preferences.get_highest_priority_job(), /datum/job/ai)

/datum/preference/choiced/ai_hologram_display/apply_to_human(mob/living/carbon/human/target, value)
	return
