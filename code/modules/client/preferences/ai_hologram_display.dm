/// What to show on the AI hologram
/datum/preference/choiced/ai_hologram_display
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "preferred_ai_hologram_display"
	should_generate_icons = TRUE

/datum/preference/choiced/ai_hologram_display/init_possible_values()
	var/list/values = list()

	values["Random"] = icon('icons/effects/random_spawners.dmi', "questionmark")

	//var/mob/living/carbon/human/dummy/ai_dummy = new
	//var/mutable_appearance/dummy_appearance = usr.client.prefs.render_new_preview_appearance(ai_dummy)
	//if(dummy_appearance)
	//	qdel(ai_dummy)
	//	values["Human"] = dummy_appearance

	values["Bear"] = icon('icons/mob/simple/animal.dmi', "bear")
	values["Carp"] = icon('icons/mob/simple/carp.dmi', "carp")
	values["Chicken"] = icon('icons/mob/simple/animal.dmi', "chicken_brown")
	values["Corgi"] = icon('icons/mob/simple/pets.dmi', "corgi")
	values["Cow"] = icon('icons/mob/simple/animal.dmi', "cow")
	values["Crab"] = icon('icons/mob/simple/animal.dmi', "crab")
	values["Fox"] = icon('icons/mob/simple/pets.dmi', "fox")
	values["Goat"] = icon('icons/mob/simple/animal.dmi', "goat")
	values["Cat"] = icon('icons/mob/simple/pets.dmi', "cat")
	values["Cat 2"] = icon('icons/mob/simple/pets.dmi', "cat2")
	values["Poly"] = icon('icons/mob/simple/animal.dmi', "parrot_fly")
	values["Pug"] = icon('icons/mob/simple/pets.dmi', "pug")
	values["Spider"] = icon('icons/mob/simple/animal.dmi', "guard")

	values["Default"] = icon('icons/mob/silicon/ai.dmi', "default")
	values["Floating Face"] = icon('icons/mob/silicon/ai.dmi', "floating face")
	values["Xeno Queen"] = icon('icons/mob/nonhuman-player/alien.dmi', "alienq")
	values["Horror"] = icon('icons/mob/silicon/ai.dmi', "horror")
	values["Clock"] = icon('icons/mob/silicon/ai.dmi', "clock")
	values["Default"] = icon('icons/mob/silicon/ai.dmi', "default")

	return values

/datum/preference/choiced/ai_hologram_display/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return istype(preferences.get_highest_priority_job(), /datum/job/ai)

/datum/preference/choiced/ai_hologram_display/apply_to_human(mob/living/carbon/human/target, value)
	return
