/// Antag datum associated with the hypnosis brain trauma, used for displaying objectives and antag hud
/datum/antagonist/hypnotized
	name = "\improper Hypnotized Victim"
	stinger_sound = 'sound/music/antag/hypnotized.ogg'
	pref_flag = ROLE_HYPNOTIZED
	roundend_category = "Загипнотизированные"
	antag_hud_name = "brainwashed"
	ui_name = "AntagInfoBrainwashed"
	show_in_antagpanel = TRUE
	antagpanel_category = ANTAG_GROUP_CREW
	show_name_in_check_antagonists = TRUE
	antag_flags = ANTAG_FAKE|ANTAG_SKIP_GLOBAL_LIST

	/// Brain trauma associated with this antag datum
	var/datum/brain_trauma/hypnosis/trauma

/datum/antagonist/hypnotized/Destroy()
	QDEL_NULL(trauma)
	return ..()
