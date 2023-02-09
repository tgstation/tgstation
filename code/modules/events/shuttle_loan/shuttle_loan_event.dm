
/datum/round_event_control/shuttle_loan
	name = "Shuttle Loan"
	typepath = /datum/round_event/shuttle_loan
	max_occurrences = 3
	earliest_start = 7 MINUTES
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "If cargo accepts the offer, fills the shuttle with loot and/or enemies."
	///The types of loan events already run (and to be excluded if the event triggers).
	admin_setup = /datum/event_admin_setup/listed_options/shuttle_loan
	var/list/run_situations = list()

/datum/round_event_control/shuttle_loan/can_spawn_event(players_amt)
	. = ..()
	for(var/datum/round_event/running_event in SSevents.running)
		if(istype(running_event, /datum/round_event/shuttle_loan)) //Make sure two of these don't happen at once.
			return FALSE

/datum/round_event/shuttle_loan
	announce_when = 1
	end_when = 500
	/// what type of shuttle loan situation the station faces.
	var/datum/shuttle_loan_situation/situation
	/// Whether the station has let Centcom commandeer the shuttle yet.
	var/dispatched = FALSE

/datum/round_event/shuttle_loan/setup()
	var/datum/round_event_control/shuttle_loan/loan_control = control
	//by this point if situation is admin picked, it is a type, not an instance.
	if(!situation)
		var/list/valid_situations = subtypesof(/datum/shuttle_loan_situation) - loan_control.run_situations
		if(!valid_situations.len)
			//If we somehow run out of loans (fking campbell), they all become available again
			loan_control.run_situations.Cut()
			valid_situations = subtypesof(/datum/shuttle_loan_situation)
		situation = pick(valid_situations)

	loan_control.run_situations.Add(situation)
	situation = new situation()

/datum/round_event/shuttle_loan/announce(fake)
	priority_announce("Cargo: [situation.announcement_text]", situation.sender)
	SSshuttle.shuttle_loan = src

/datum/round_event/shuttle_loan/proc/loan_shuttle()
	priority_announce(situation.thanks_msg, "Cargo shuttle commandeered by CentCom.")

	dispatched = TRUE
	var/datum/bank_account/dep_account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	dep_account?.adjust_money(situation.bonus_points)
	end_when = activeFor + 1

	SSshuttle.supply.mode = SHUTTLE_CALL
	SSshuttle.supply.destination = SSshuttle.getDock("cargo_home")
	SSshuttle.supply.setTimer(3000)
	SSshuttle.centcom_message += situation.shuttle_transit_text

	log_game("Shuttle loan event firing with type '[situation.logging_desc]'.")

/datum/round_event/shuttle_loan/tick()
	if(dispatched)
		if(SSshuttle.supply.mode != SHUTTLE_IDLE)
			end_when = activeFor
		else
			end_when = activeFor + 1

/datum/round_event/shuttle_loan/end()
	if(!SSshuttle.shuttle_loan || !SSshuttle.shuttle_loan.dispatched)
		return
	//make sure the shuttle was dispatched in time
	SSshuttle.shuttle_loan = null

	//get empty turfs
	var/list/empty_shuttle_turfs = list()
	var/list/area/shuttle/shuttle_areas = SSshuttle.supply.shuttle_areas
	for(var/area/shuttle/shuttle_area as anything in shuttle_areas)
		for(var/turf/open/floor/shuttle_turf in shuttle_area)
			if(shuttle_turf.is_blocked_turf())
				continue
			empty_shuttle_turfs += shuttle_turf
	if(!empty_shuttle_turfs.len)
		return

	//let the situation spawn its items
	var/list/spawn_list = list()
	situation.spawn_items(spawn_list, empty_shuttle_turfs)

	var/false_positive = 0
	while(spawn_list.len && empty_shuttle_turfs.len)
		var/turf/spawn_turf = pick_n_take(empty_shuttle_turfs)
		if(spawn_turf.contents.len && false_positive < 5)
			false_positive++
			continue
		var/spawn_type = pick_n_take(spawn_list)
		new spawn_type(spawn_turf)

/datum/event_admin_setup/listed_options/shuttle_loan
	input_text = "Select a loan offer?"

/datum/event_admin_setup/listed_options/shuttle_loan/get_list()
	var/datum/round_event_control/shuttle_loan/loan_event = event_control
	var/list/valid_situations = subtypesof(/datum/shuttle_loan_situation) - loan_event.run_situations
	return valid_situations

/datum/event_admin_setup/listed_options/shuttle_loan/apply_to_event(datum/round_event/shuttle_loan/event)
	event.situation = chosen
