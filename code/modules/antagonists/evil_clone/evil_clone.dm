/// Antag datum associated with the experimental cloner
/datum/antagonist/evil_clone
	name = "\improper Evil Clone"
	stinger_sound = 'sound/music/antag/hypnotized.ogg'
	job_rank = ROLE_EVIL_CLONE
	roundend_category = "evil clones"
	show_in_antagpanel = TRUE
	antagpanel_category = ANTAG_GROUP_CREW
	show_name_in_check_antagonists = TRUE
	count_against_dynamic_roll_chance = FALSE

/datum/antagonist/evil_clone/on_gain()
	if (owner.current)
		name = owner.current.real_name
	forge_objectives()
	return ..()

/datum/antagonist/evil_clone/greet()
	if(silent)
		return
	play_stinger()
	to_chat(owner.current, span_big("You are [src]."))
	to_chat(owner.current, span_hypnophrase("You are the <b>only</b> [src]."))
	to_chat(owner.current, span_boldwarning("Anyone else pretending to be [src] must be punished."))
	owner.announce_objectives()

/datum/antagonist/evil_clone/forge_objectives()
	var/datum/objective/accept_no_substitutes/objective = new
	objective.owner = owner
	objectives += objective

/// Kill everyone with the same name as you
/datum/objective/accept_no_substitutes
	name = "kill all clones"
	explanation_text = "Ensure that you are the only remaining person with your name."

/datum/objective/accept_no_substitutes/check_completion()
	if (!owner.current)
		return FALSE

	for (var/mob/living/someone as anything in GLOB.player_list) // We will generously not include people who logged out or ghosted
		if (!istype(someone))
			continue
		if (someone.stat == DEAD)
			continue
		if (someone == owner.current)
			continue
		if (someone.real_name == owner.current.real_name)
			return FALSE

	return TRUE

