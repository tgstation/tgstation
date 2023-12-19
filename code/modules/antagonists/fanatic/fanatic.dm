/datum/antagonist/fanatic
	name = "Fanatic"
	antagpanel_category = "Other"
	job_rank = ROLE_FANATIC
	show_name_in_check_antagonists = TRUE
	preview_outfit = /datum/outfit/tiger_fanatic
	antag_moodlet = /datum/mood_event/focused
	suicide_cry = "FOR THE HIVE!!"
	hardcore_random_bonus = TRUE
	ui_name = "AntagInfoFanatic"
	var/blessings = 0

/datum/antagonist/fanatic/ui_data(mob/user)
	var/list/data = list()
	data["key"] = MODE_KEY_CHANGELING
	data["objectives"] = get_objectives()
	return data

/datum/antagonist/fanatic/on_gain()
	owner.special_role = ROLE_FANATIC
	SEND_SOUND(owner.current, sound('sound/effects/tiger_greeting.ogg'))
	forge_objectives()
	. = ..()

/datum/antagonist/fanatic/forge_objectives()
	var/datum/objective/be_absorbed/absorbed_escape/absorbed = new
	var/datum/objective/changeling_blessed/blessed = new
	absorbed.owner = owner
	blessed.owner = owner
	objectives += absorbed
	objectives += blessed
	. = ..()

/datum/objective/be_absorbed
	name = "be absorbed"
	explanation_text = "Be absorbed by a changeling so you may ascend to a higher level of being!"
	martyr_compatible = TRUE
	admin_grantable = TRUE
	var/player_absorbed = FALSE

/datum/objective/be_absorbed/check_completion()
	if(player_absorbed)
		return TRUE
	return FALSE


/datum/objective/be_absorbed/absorbed_escape
	name = "be absorbed"
	explanation_text = "Ascend by being absorbed by a changeling, or escape on the shuttle or an escape pod alive and without being in custody."
	martyr_compatible = TRUE
	admin_grantable = TRUE


/datum/objective/be_absorbed/absorbed_escape/check_completion()
	if(player_absorbed || considered_escaped(owner))
		return TRUE
	return FALSE

/datum/antagonist/fanatic/proc/receive_blessing()
	blessings += 1
	if(iscarbon(owner.current))
		var/mob/living/carbon/blessed_one = owner.current
		blessed_one.add_mood_event("tiger fanatic", /datum/mood_event/changeling_enjoyer)

/datum/objective/changeling_blessed
	name = "be blessed by a changeling"
	explanation_text = "Have a changeling use their powers on you 3 times."
	martyr_compatible = TRUE
	admin_grantable = TRUE
	completed = FALSE
	var/blessings_required = 3

/datum/objective/changeling_blessed/check_completion()
	var/datum/antagonist/fanatic/fanatic = owner.has_antag_datum(/datum/antagonist/fanatic)
	if(isnull(fanatic))
		return FALSE
	if(fanatic.blessings >= blessings_required)
		return TRUE
	return FALSE
