/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin, show_job_clothes = TRUE)
	var/datum/job/no_job = SSjob.get_job_type(/datum/job/unassigned)
	var/datum/job/preview_job = get_highest_priority_job() || no_job

	// Set up the dummy for its photoshoot
	apply_prefs_to(mannequin, TRUE)

	switch(preview_pref)
		if(PREVIEW_PREF_JOB)
			mannequin.underwear_visibility = NONE
			// Silicons only need a very basic preview since there is no customization for them.
			if (istype(preview_job, /datum/job/ai))
				return image('icons/mob/silicon/ai.dmi', icon_state = resolve_ai_icon(read_preference(/datum/preference/choiced/ai_core_display)), dir = SOUTH)
			if (istype(preview_job, /datum/job/cyborg))
				return image('icons/mob/silicon/robots.dmi', icon_state = "robot", dir = SOUTH)

			mannequin.job = preview_job.title
			mannequin.dress_up_as_job(
				equipping = show_job_clothes ? preview_job : no_job,
				visual_only = TRUE,
				player_client = parent,
				consistent = TRUE,
			)

		if(PREVIEW_PREF_LOADOUT)
			mannequin.underwear_visibility = NONE
			var/default_outfit = new /datum/outfit()
			mannequin.equip_outfit_and_loadout(default_outfit, src, TRUE)

		if(PREVIEW_PREF_UNDERWEAR)
			mannequin.underwear_visibility = NONE

		if(PREVIEW_PREF_NAKED)
			mannequin.underwear_visibility = UNDERWEAR_HIDE_UNDIES | UNDERWEAR_HIDE_SHIRT | UNDERWEAR_HIDE_SOCKS | UNDERWEAR_HIDE_BRA

	// Apply visual quirks
	// Yes we do it every time because it needs to be done after job gear
	if(SSquirks?.initialized)
		// And yes we need to clean all the quirk datums every time
		mannequin.cleanse_quirk_datums()
		for(var/quirk_name as anything in all_quirks)
			var/datum/quirk/quirk_type = SSquirks.quirks[quirk_name]
			if(!(initial(quirk_type.quirk_flags) & QUIRK_CHANGES_APPEARANCE))
				continue
			mannequin.add_quirk(quirk_type, parent)

	mannequin.update_body()
	return mannequin.appearance
