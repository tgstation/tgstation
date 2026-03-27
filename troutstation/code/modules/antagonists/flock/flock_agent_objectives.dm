/datum/objective/flock_agent
	abstract_type = /datum/objective/flock_agent

/datum/objective/flock_agent/proc/get_flock_agent_team()
	RETURN_TYPE(/datum/team/flock_agent)
	return team

/datum/objective/flock_agent/get_resources
	name = "Accumulate Resources"
	var/resources_required = 0

/datum/objective/flock_agent/get_resources/New(text)
	resources_required = rand(2,5) * 100
	update_explanation_text()

/datum/objective/flock_agent/get_resources/update_explanation_text()
	explanation_text = "We need you to acquire [resources_required] units worth of additional substrate mass."

/datum/objective/flock_agent/get_resources/check_completion()
	return get_flock_agent_team().total_consumed_resources >= resources_required

/datum/objective/flock_agent/consume_uniques
	abstract_type = /datum/objective/flock_agent/consume_uniques
	var/list/desired_types
	var/list/blacklisted_types = list() // always make these more specific than desired types
	var/num_uniques_required = 0
	var/thing_name = "code bug"
	var/thing_name_plural = "code bugs"
	var/prefix = "Your Lord wants the code to work."
	var/suffix = "Please, god, let it work."

/datum/objective/flock_agent/consume_uniques/New(text)
	update_explanation_text()

/datum/objective/flock_agent/consume_uniques/update_explanation_text()
	explanation_text = "[prefix] Process [num_uniques_required] unique [num_uniques_required == 1 ? thing_name : thing_name_plural] to appease them. [suffix]"

/datum/objective/flock_agent/consume_uniques/proc/get_total_num()
	var/count = 0
	var/team_consumed_types = get_flock_agent_team().consumed_types
	for(var/obj/item/consumed_type as anything in team_consumed_types)
		var/is_blacklisted = FALSE
		for(var/blacklisted_type in blacklisted_types)
			if(ispath(consumed_type, blacklisted_type))
				is_blacklisted = TRUE
				break
		if(!is_blacklisted)
			for(var/desired_type in desired_types)
				if(ispath(consumed_type, desired_type))
					count += 1
					break
	return count

/datum/objective/flock_agent/consume_uniques/proc/is_desired(obj/item/item)
	for(var/obj/item/blacklisted_type as anything in blacklisted_types)
		if(istype(item, blacklisted_type))
			return FLOCK_OBJECTIVE_CONSUME_DETESTED
	for(var/obj/item/desired_type as anything in desired_types)
		if(istype(item, desired_type))
			return FLOCK_OBJECTIVE_CONSUME_DESIRED
	return FLOCK_OBJECTIVE_CONSUME_IRRELEVANT

/datum/objective/flock_agent/consume_uniques/check_completion()
	return get_total_num() >= num_uniques_required

/datum/objective/flock_agent/consume_uniques/jumpsuits
	name = "Consume Unique Jumpsuits"
	desired_types = list(/obj/item/clothing/under)
	blacklisted_types = list(/obj/item/clothing/under/color, /obj/item/clothing/under/shorts)
	num_uniques_required = 7
	thing_name = "jumpsuit"
	thing_name_plural = "jumpsuits"
	prefix = "Your Lord wants more insight on humanoid design sensibilities."
	suffix = "They aren't interested in basic, single-colour jumpsuits, or shorts."

/datum/objective/flock_agent/consume_uniques/head_radios
	name = "Consume Unique Headheadsets" // c:
	desired_types = list(/obj/item/radio/headset/heads)
	num_uniques_required = 3
	thing_name = "command headset"
	thing_name_plural = "command headsets"
	prefix = "Your Lord needs to reattune to the local frequencies better."
	suffix = "They MUST be head of staff headsets."
