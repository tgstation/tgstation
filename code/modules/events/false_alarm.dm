/datum/round_event_control/falsealarm
	name = "False Alarm"
	typepath = /datum/round_event/falsealarm
	weight = 20
	max_occurrences = 5
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "Fakes an event announcement."
	admin_setup = list(/datum/event_admin_setup/listed_options/false_alarm)

/datum/round_event_control/falsealarm/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	if(!length(get_potential_false_alarm()))
		return FALSE
	return TRUE

/datum/round_event/falsealarm
	announce_when = 0
	end_when = 1
	fakeable = FALSE
	/// Admin's pick of fake event (wow! you picked blob!! you're so creative and smart!)
	var/forced_type

/datum/round_event/falsealarm/announce(fake)
	if(fake) //What are you doing
		return

	var/players_amt = get_active_player_count(alive_check = TRUE, afk_check = TRUE, human_check = TRUE)
	var/picked_trigger = forced_type
	if(ispath(forced_type, /datum/dynamic_ruleset/midround))
		picked_trigger = new forced_type()

	var/list/event_pool = get_potential_false_alarm()

	while(length(event_pool) && isnull(picked_trigger))
		var/potential_trigger = pick_n_take(event_pool)
		if(istype(potential_trigger, /datum/round_event_control))
			var/datum/round_event_control/event_control = potential_trigger
			if(event_control.can_spawn_event(players_amt))
				picked_trigger = event_control
				break

		else if(ispath(potential_trigger, /datum/dynamic_ruleset/midround))
			var/datum/dynamic_ruleset/midround/ruleset = new potential_trigger(SSdynamic.get_config())
			if(ruleset.can_be_selected(players_amt))
				picked_trigger = ruleset
				break
			qdel(ruleset)

		else
			stack_trace("Unknown false alarm candidate type: [potential_trigger || "null"]")

	if(istype(picked_trigger, /datum/round_event_control))
		var/datum/round_event_control/event_control = picked_trigger
		var/datum/round_event/fake_event = new event_control.typepath()
		message_admins("False Alarm: [fake_event]")
		fake_event.kill() //do not process this event - no starts, no ticks, no ends
		fake_event.announce(TRUE) //just announce it like it's happening

	else if(istype(picked_trigger, /datum/dynamic_ruleset/midround))
		var/datum/dynamic_ruleset/midround/ruleset = picked_trigger
		message_admins("False Alarm: [ruleset]")
		ruleset.false_alarm()
		qdel(ruleset)

/proc/get_potential_false_alarm()
	. = list()
	for(var/datum/round_event_control/controller as anything in SSevents.control)
		if(istype(controller, /datum/round_event_control/falsealarm))
			continue
		var/datum/round_event/event = controller.typepath
		if(!initial(event.fakeable))
			continue
		. += controller

	for(var/datum/dynamic_ruleset/midround/midround as anything in subtypesof(/datum/dynamic_ruleset/midround))
		if(!initial(midround.false_alarm_able))
			continue
		. += midround

/datum/event_admin_setup/listed_options/false_alarm
	normal_run_option = "Random Fake Event"

/datum/event_admin_setup/listed_options/false_alarm/get_list()
	return get_potential_false_alarm()

/datum/event_admin_setup/listed_options/false_alarm/apply_to_event(datum/round_event/falsealarm/event)
	event.forced_type = chosen
