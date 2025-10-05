/// Fully randomizes everything in the character.
/datum/preferences/proc/randomise_appearance_prefs(randomize_flags = ALL)
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.included_in_randomization_flags(randomize_flags))
			continue

		if (preference.is_randomizable())
			write_preference(preference, preference.create_random_value(src))

/// Randomizes the character according to preferences.
/datum/preferences/proc/apply_character_randomization_prefs(antag_override = FALSE)
	switch (read_preference(/datum/preference/choiced/random_body))
		if (RANDOM_ANTAG_ONLY)
			if (!antag_override)
				return

		if (RANDOM_DISABLED)
			return

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (should_randomize(preference, antag_override))
			write_preference(preference, preference.create_random_value(src))

///Setup the random hardcore quirks and give the character the new score prize.
/datum/preferences/proc/hardcore_random_setup(mob/living/carbon/human/character)
	var/next_hardcore_score = select_hardcore_quirks(character.dna.species.type)
	character.hardcore_survival_score = next_hardcore_score ** 1.2  //30 points would be about 60 score
	log_game("[character] started hardcore random with [english_list(all_quirks)], for a score of [next_hardcore_score].")

	//Add a sixpack because honestly
	var/obj/item/bodypart/chest/chest = character.get_bodypart(BODY_ZONE_CHEST)
	chest.add_bodypart_overlay(new /datum/bodypart_overlay/simple/sixpack() )

/**
 * Goes through all quirks that can be used in hardcore mode and select some based on a random budget.
 * Returns the new value to be gained with this setup, plus the previously earned score.
 **/
/datum/preferences/proc/select_hardcore_quirks(species)
	. = 0

	var/quirk_budget = rand(8, 35)

	all_quirks = list() //empty it out

	var/list/available_hardcore_quirks = SSquirks.hardcore_quirks.Copy()

	while(quirk_budget > 0)
		for(var/quirk in available_hardcore_quirks) //Remove from available quirks if its too expensive.
			var/datum/quirk/quirk_prototype = SSquirks.quirk_prototypes[quirk]
			if(available_hardcore_quirks[quirk] > quirk_budget || !quirk_prototype.is_species_appropriate(species))
				available_hardcore_quirks -= quirk

		if(!available_hardcore_quirks.len)
			break

		var/datum/quirk/picked_quirk = pick(available_hardcore_quirks)

		var/picked_quirk_blacklisted = FALSE
		for(var/bl in GLOB.quirk_blacklist) //Check if the quirk is blacklisted with our current quirks. quirk_blacklist is a list of lists.
			var/list/blacklist = bl
			if(!(picked_quirk in blacklist))
				continue
			for(var/quirk_name in all_quirks) //Go through all the quirks we've already selected to see if theres a blacklist match
				var/selected_quirk = SSquirks.quirks[quirk_name]
				if((selected_quirk in blacklist) && !(selected_quirk == picked_quirk)) //two quirks have lined up in the list of the list of quirks that conflict with each other, so return (see quirks.dm for more details)
					picked_quirk_blacklisted = TRUE
					break
			if(picked_quirk_blacklisted)
				break

		if(picked_quirk_blacklisted)
			available_hardcore_quirks -= picked_quirk
			continue

		if((initial(picked_quirk.quirk_flags) & QUIRK_MOODLET_BASED) && CONFIG_GET(flag/disable_human_mood)) //check for moodlet quirks
			available_hardcore_quirks -= picked_quirk
			continue

		all_quirks += initial(picked_quirk.name)
		quirk_budget -= available_hardcore_quirks[picked_quirk]
		. += available_hardcore_quirks[picked_quirk]
		available_hardcore_quirks -= picked_quirk

/// Returns what job is marked as highest
/datum/preferences/proc/get_highest_priority_job()
	var/datum/job/preview_job
	var/highest_pref = 0

	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			preview_job = SSjob.get_job(job)
			highest_pref = job_preferences[job]

	return preview_job

/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin, show_job_clothes = TRUE)
	var/datum/job/no_job = SSjob.get_job_type(/datum/job/unassigned)
	var/datum/job/preview_job = get_highest_priority_job() || no_job

	if(preview_job)
		// Silicons only need a very basic preview since there is no customization for them.
		if (istype(preview_job,/datum/job/ai))
			return image('icons/mob/silicon/ai.dmi', icon_state = resolve_ai_icon(read_preference(/datum/preference/choiced/ai_core_display)), dir = SOUTH)
		if (istype(preview_job,/datum/job/cyborg))
			return image('icons/mob/silicon/robots.dmi', icon_state = "robot", dir = SOUTH)

	// Set up the dummy for its photoshoot
	apply_prefs_to(mannequin, TRUE)

	mannequin.job = preview_job.title
	mannequin.dress_up_as_job(
		equipping = show_job_clothes ? preview_job : no_job,
		visual_only = TRUE,
		player_client = parent,
		consistent = TRUE,
	)

	// Apply visual quirks
	// Yes we do it every time because it needs to be done after job gear
	if(SSquirks?.initialized)
		// And yes we need to clean all the quirk datums every time
		mannequin.cleanse_quirk_datums()
		for(var/quirk_name in all_quirks)
			var/datum/quirk/quirk_type = SSquirks.quirks[quirk_name]
			if(!(initial(quirk_type.quirk_flags) & QUIRK_CHANGES_APPEARANCE))
				continue
			mannequin.add_quirk(quirk_type, parent, announce = FALSE)

	return mannequin.appearance
