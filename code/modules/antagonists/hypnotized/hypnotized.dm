/datum/antagonist/hypnotized
	name = "Hypnotized Victim"
	job_rank = ROLE_HYPNOTIZED
	roundend_category = "hypnotized victims"
	show_in_antagpanel = TRUE
	antag_hud_type = ANTAG_HUD_BRAINWASHED
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	antag_hud_name = "brainwashed"
	silent = TRUE //not actually silent, because greet will be called by the trauma anyway.
	var/datum/brain_trauma/hypnosis/trauma

/datum/antagonist/hypnotized/Destroy()
	if(trauma)
		qdel(trauma)
	. = ..()

/datum/antagonist/hypnotized/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	add_antag_hud(antag_hud_type, antag_hud_name, M)

/datum/antagonist/hypnotized/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	remove_antag_hud(antag_hud_type, M)
