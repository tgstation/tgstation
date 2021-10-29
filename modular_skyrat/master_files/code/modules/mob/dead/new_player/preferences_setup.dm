/datum/preferences/proc/render_new_preview_appearance(mob/living/carbon/human/dummy/mannequin)
	var/datum/job/preview_job = get_highest_priority_job()
	mannequin.dna.mutant_bodyparts = list()

	// Set up the dummy for its photoshoot
	apply_prefs_to(mannequin, TRUE)

	switch(preview_pref)
		if(PREVIEW_PREF_JOB)
			mannequin.underwear_visibility = NONE
			if(preview_job) //SKYRAT EDIT CHANGE
				// Silicons only need a very basic preview since there is no customization for them.
				if (istype(preview_job,/datum/job/ai))
					return image('icons/mob/ai.dmi', icon_state = resolve_ai_icon(read_preference(/datum/preference/choiced/ai_core_display)), dir = SOUTH)
				if (istype(preview_job,/datum/job/cyborg))
					return image('icons/mob/robots.dmi', icon_state = "robot", dir = SOUTH)
				mannequin.job = preview_job.title
				mannequin.equip_outfit_and_loadout(preview_job.outfit, src, TRUE)
		if(PREVIEW_PREF_LOADOUT)
			mannequin.underwear_visibility = NONE
			var/default_outfit = new /datum/outfit()
			mannequin.equip_outfit_and_loadout(default_outfit, src, TRUE)
		if(PREVIEW_PREF_NAKED)
			mannequin.underwear_visibility = UNDERWEAR_HIDE_UNDIES | UNDERWEAR_HIDE_SHIRT | UNDERWEAR_HIDE_SOCKS
			for(var/organ_key in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_PENIS, ORGAN_SLOT_BREASTS, ORGAN_SLOT_ANUS))
				var/obj/item/organ/genital/gent = mannequin.getorganslot(organ_key)
				if(gent)
					gent.aroused = AROUSAL_NONE
					gent.update_sprite_suffix()
		if(PREVIEW_PREF_NAKED_AROUSED)
			mannequin.underwear_visibility = UNDERWEAR_HIDE_UNDIES | UNDERWEAR_HIDE_SHIRT | UNDERWEAR_HIDE_SOCKS
			for(var/organ_key in list(ORGAN_SLOT_VAGINA, ORGAN_SLOT_PENIS, ORGAN_SLOT_BREASTS, ORGAN_SLOT_ANUS))
				var/obj/item/organ/genital/gent = mannequin.getorganslot(organ_key)
				if(gent)
					gent.aroused = AROUSAL_FULL
					gent.update_sprite_suffix()
	mannequin.update_body()
	COMPILE_OVERLAYS(mannequin)
	return mannequin.appearance
