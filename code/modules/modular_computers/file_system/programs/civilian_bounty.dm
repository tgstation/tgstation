///Everything within this file is an edited form from this file, stripping it of some various components because they are not needed for the PDA app: code/game/machinery/civilian_bounties.dm

///Percentage of a civilian bounty the civilian will make.
#define CIV_BOUNTY_SPLIT 30

/datum/computer_file/program/civilianbounties
	filename = "bountyapp"
	filedesc = "Civilian Bounties"
	downloader_category = PROGRAM_CATEGORY_SUPPLY
	program_open_overlay = "request"
	extended_desc = "Nanotrasen Civilian Bounty Requisition Network interface for displaying wanted items."
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	can_run_on_flags = PROGRAM_LAPTOP | PROGRAM_PDA
	size = 5
	tgui_id = "NtosCivCargoHoldTerminal"
	program_icon = FA_ICON_BOXES_STACKED
	var/status_report = "Ready for delivery."
	var/points = 0

/datum/computer_file/program/civilianbounties/ui_data(mob/user)
	var/list/data = list()
	data["points"] = points
	data["status_report"] = status_report
	data["id_inserted"] = computer.stored_id
	if(computer.stored_id?.registered_account)
		if(computer.stored_id.registered_account.civilian_bounty)
			data["id_bounty_info"] = computer.stored_id.registered_account.civilian_bounty.description
			data["id_bounty_num"] = computer.stored_id.registered_account.bounty_num()
			data["id_bounty_value"] = (computer.stored_id.registered_account.civilian_bounty.reward) * (CIV_BOUNTY_SPLIT/100)
		if(computer.stored_id.registered_account.bounties)
			data["picking"] = TRUE
			data["id_bounty_names"] = list(computer.stored_id.registered_account.bounties[1].name,
											computer.stored_id.registered_account.bounties[2].name,
											computer.stored_id.registered_account.bounties[3].name)
			data["id_bounty_infos"] = list(computer.stored_id.registered_account.bounties[1].description,
											computer.stored_id.registered_account.bounties[2].description,
											computer.stored_id.registered_account.bounties[3].description)
			data["id_bounty_values"] = list(computer.stored_id.registered_account.bounties[1].reward * (CIV_BOUNTY_SPLIT/100),
											computer.stored_id.registered_account.bounties[2].reward * (CIV_BOUNTY_SPLIT/100),
											computer.stored_id.registered_account.bounties[3].reward * (CIV_BOUNTY_SPLIT/100))
		else
			data["picking"] = FALSE

	return data

/datum/computer_file/program/civilianbounties/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	switch(action)
		if("pick")
			pick_bounty(params["value"])
		if("bounty")
			add_bounties(user, 0)

///Here is where cargo bounties are added to the player's bank accounts, then adjusted and scaled into a civilian bounty.
/datum/computer_file/program/civilianbounties/proc/add_bounties(mob/user, cooldown_reduction = 0)
	var/datum/bank_account/id_account = computer.stored_id?.registered_account
	if(!id_account)
		return
	if((id_account.civilian_bounty || id_account.bounties) && !COOLDOWN_FINISHED(id_account, bounty_timer))
		var/time_left = DisplayTimeText(COOLDOWN_TIMELEFT(id_account, bounty_timer), round_seconds_to = 1)
		computer.balloon_alert(user, "try again in [time_left]!")
		return FALSE
	if(!id_account.account_job)
		computer.say("Requesting ID card has no job assignment registered!")
		return FALSE

	var/list/datum/bounty/crumbs = generate_bounty_list(id_account.account_job.bounty_types)
	COOLDOWN_START(id_account, bounty_timer, (5 MINUTES) - cooldown_reduction)
	id_account.bounties = crumbs

/**
 * Proc that assigned a civilian bounty to an ID card, from the list of potential bounties that that bank account currently has available.
 * Available choices are assigned during add_bounties, and one is locked in here.
 *
 * @param choice The index of the bounty in the list of bounties that the player can choose from.
 */
/datum/computer_file/program/civilianbounties/proc/pick_bounty(datum/bounty/choice)
	var/datum/bank_account/id_account = computer.stored_id?.registered_account
	if(!id_account?.bounties?[choice])
		playsound(computer.loc, 'sound/machines/synth/synth_no.ogg', 40 , TRUE)
		return
	id_account.civilian_bounty = id_account.bounties[choice]
	id_account.bounties = null
	SSblackbox.record_feedback("tally", "bounties_assigned", 1, id_account.civilian_bounty.type)
	return id_account.civilian_bounty

/**
 * Generates a list of bounties for use with the civilian bounty pad, this is virtually identical to the stuff contained within: code/game/machinery/civilian_bounties.dm
 * @param bounty_types the define taken from a job for selection of a random_bounty() proc.
 * @param bounty_rolls the number of bounties to be selected from.
 * @param assistant_failsafe Do we guarentee one assistant bounty per generated list? Used for non-assistant jobs to give an easier alternative to that job's default bounties.
 */
/datum/computer_file/program/civilianbounties/proc/generate_bounty_list(bounty_types, bounty_rolls = 3, assistant_failsafe = TRUE)
	var/list/rolling_list = list()
	if(assistant_failsafe)
		rolling_list += random_bounty(CIV_JOB_BASIC)
	while(bounty_rolls > 1)
		var/datum/bounty/potential_bounty = random_bounty(bounty_types)
		var/repeats_bool = FALSE
		for(var/datum/iterator in rolling_list)
			if(iterator.type == potential_bounty.type)
				repeats_bool = TRUE
		if(repeats_bool)
			continue
		rolling_list += potential_bounty
		bounty_rolls -= 1
	return rolling_list

#undef CIV_BOUNTY_SPLIT
