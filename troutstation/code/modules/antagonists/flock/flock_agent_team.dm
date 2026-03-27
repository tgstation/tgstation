/datum/team/flock_agent
	name = "\improper Flock Agents"
	member_name = "flock agent"

	var/static/list/possible_objective_types = list(
		/datum/objective/flock_agent/get_resources,
		/datum/objective/flock_agent/consume_uniques/jumpsuits,
		/datum/objective/flock_agent/consume_uniques/head_radios,
	)

	var/list/consumed_types = list()
	var/total_consumed_resources = 0


/datum/team/flock_agent/New(starting_members)
	. = ..()
	// TODO: randomise what objectives are given
	for (var/objective_type in possible_objective_types)
		objectives += new objective_type()

	for (var/datum/objective/objective as anything in objectives)
		objective.team = src

/datum/team/flock_agent/add_member(datum/mind/member)
	. = ..()
	register_member_mob(member.current)
	RegisterSignal(member, COMSIG_MIND_TRANSFERRED, PROC_REF(on_mind_transferred))

/datum/team/flock_agent/remove_member(datum/mind/member)
	UnregisterSignal(member, COMSIG_MIND_TRANSFERRED)
	unregister_member_mob(member.current)
	return ..()

// how likely is it that flock agent minds are going to swap? oh well, support is in
/datum/team/flock_agent/proc/on_mind_transferred(datum/mind/member, mob/previous_body)
	SIGNAL_HANDLER
	unregister_member_mob(previous_body)
	register_member_mob(member.current)

/datum/team/flock_agent/proc/register_member_mob(mob/member_mob)
	if (!member_mob)
		return
	RegisterSignal(member_mob, COMSIG_FLOCK_ITEM_CONSUMED, PROC_REF(on_flock_item_consumed))
	RegisterSignal(member_mob, COMSIG_FLOCK_RESOURCES_CHANGED, PROC_REF(on_flock_resources_changed))

/datum/team/flock_agent/proc/unregister_member_mob(mob/member_mob)
	if (!member_mob)
		return
	UnregisterSignal(member_mob, list(COMSIG_FLOCK_ITEM_CONSUMED, COMSIG_FLOCK_RESOURCES_CHANGED))

/datum/team/flock_agent/proc/on_flock_item_consumed(mob/living/agent, obj/item/consumed, total_resources)
	SIGNAL_HANDLER
	if(consumed.type in consumed_types)
		return
	consumed_types |= consumed.type
	// todo: this is hacky. try something less hacky. space ninja code is NOT a good example to read from
	var/datum/objective/flock_agent/consume_uniques/objective = locate() in objectives
	if(objective)
		if(objective.get_total_num() > objective.num_uniques_required)
			return
		var/desired = objective.is_desired(consumed)
		switch(desired)
			if(FLOCK_OBJECTIVE_CONSUME_IRRELEVANT)
				pass()
			if(FLOCK_OBJECTIVE_CONSUME_DESIRED)
				if(objective.get_total_num() == objective.num_uniques_required)
					to_chat(agent, span_nicegreen("<b>That's the [objective.num_uniques_required == 1 ? "" : "last"] [objective.thing_name] you needed!!</b>"))
				else
					to_chat(agent, span_nicegreen("This is definitely a [objective.thing_name] you need!"))
			if(FLOCK_OBJECTIVE_CONSUME_DETESTED)
				to_chat(agent, span_warning("Your Lord doesn't want this specific kind of [objective.thing_name]."))

/datum/team/flock_agent/proc/on_flock_resources_changed(mob/living/agent, new_total_resources, resources_added)
	SIGNAL_HANDLER
	total_consumed_resources += resources_added

/datum/team/flock_agent/roundend_report()
	var/list/report = list()
	report += span_header("\The [name]:")
	report += printplayerlist(members)

	if (length(objectives))
		report += span_header("Their goals:")
		report += print_objective_list()

	report += did_we_win() ? span_greentext("The [name] were successful! GLORY TO THE LORDS!!") : span_redtext("The so-called '[name]' were never present on your station and we disavow all knowledge.")
	return "<div class='panel redborder'>[report.Join("<br>")]</div>"

/datum/team/flock_agent/proc/print_objective_list()
	. = list()
	for (var/i in 1 to length(objectives))
		var/datum/objective/objective = objectives[i]
		. += "<B>Objective #[i]</B>: [objective.explanation_text] [objective.get_roundend_success_suffix()]"

/datum/team/flock_agent/proc/did_we_win()
	for (var/datum/objective/objective as anything in objectives)
		if (!objective.check_completion())
			return FALSE
	return TRUE
