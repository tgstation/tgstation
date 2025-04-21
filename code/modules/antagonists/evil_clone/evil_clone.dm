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
		name = "[owner.current.real_name] Prime"
	forge_objectives()
	return ..()

/datum/antagonist/evil_clone/greet()
	if(silent)
		return
	play_stinger()
	var/mob/living/current_mob = owner.current
	if (current_mob)
		to_chat(current_mob, span_big("You are [current_mob.real_name]."))
		to_chat(current_mob, span_hypnophrase("You are the <b>only</b> [current_mob.real_name]."))
		to_chat(current_mob, span_boldwarning("Anyone else pretending to be [current_mob.real_name] must be punished."))
	owner.announce_objectives()

/datum/antagonist/evil_clone/forge_objectives()
	var/datum/objective/accept_no_substitutes/objective = new
	objective.owner = owner
	objective.set_target_name(owner.current?.real_name)
	objectives += objective

/// Kill everyone with the same name as you
/datum/objective/accept_no_substitutes
	name = "kill all clones"
	explanation_text = "Ensure that nobody with a particular name that you don't remember remains alive."
	admin_grantable = TRUE
	/// What name do we want to expunge?
	var/target_name

/// Set the name to check for
/datum/objective/accept_no_substitutes/proc/set_target_name(new_name)
	target_name = new_name
	explanation_text = "Ensure that nobody with the name [target_name] remains alive."

/datum/objective/accept_no_substitutes/check_completion()
	if (!target_name)
		return FALSE // Well we forgot to check for a name

	for (var/mob/living/someone as anything in GLOB.player_list) // We will generously not include people who logged out or ghosted
		if (!istype(someone))
			continue
		if (someone.stat == DEAD)
			continue
		if (someone == owner.current)
			continue
		if (someone.real_name == target_name)
			return FALSE

	return TRUE

/datum/objective/accept_no_substitutes/admin_edit(mob/admin)
	admin_simple_target_pick(admin)
	if (target.current)
		set_target_name(target.current.real_name)
