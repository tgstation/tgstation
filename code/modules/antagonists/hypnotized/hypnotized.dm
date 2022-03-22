/// Antag datum associated with the hypnosis brain trauma, used for displaying objectives and antag hud
/datum/antagonist/hypnotized
	name = "\improper Hypnotized Victim"
	job_rank = ROLE_HYPNOTIZED
	roundend_category = "hypnotized victims"
	antag_hud_name = "brainwashed"
	ui_name = "AntagInfoBrainwashed"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE

	silent = TRUE //not actually silent, because greet will be called by the trauma anyway.
	/// Brain trauma associated with this antag datum
	var/datum/brain_trauma/hypnosis/trauma

/datum/antagonist/hypnotized/Destroy()
	QDEL_NULL(trauma)
	return ..()
