///Percentage of a civilian bounty the civilian will make.
#define CIV_BOUNTY_SPLIT 30
#define HIGH_PRIORITY_BOUNTY_ODDS 20

///Pad for the Civilian Bounty Control.
/obj/machinery/piratepad/civilian
	name = "civilian bounty pad"
	desc = "A machine designed to send civilian bounty targets to centcom."
	layer = TABLE_LAYER
	resistance_flags = FIRE_PROOF
	circuit = /obj/item/circuitboard/machine/bountypad
	var/cooldown_reduction = 0

/obj/machinery/piratepad/civilian/RefreshParts()
	. = ..()
	var/T = -2
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		T += micro_laser.tier

	for(var/datum/stock_part/scanning_module/scanning_module in component_parts)
		T += scanning_module.tier

	cooldown_reduction = T * (30 SECONDS)

/obj/machinery/piratepad/civilian/proc/get_cooldown_reduction()
	return cooldown_reduction

///Computer for assigning new civilian bounties, and sending bounties for collection.
/obj/machinery/computer/piratepad_control/civilian
	name = "civilian bounty control terminal"
	desc = "A console for assigning civilian bounties to inserted ID cards, and for controlling the bounty pad for export."
	status_report = "Ready for delivery."
	icon_screen = "civ_bounty"
	icon_keyboard = "id_key"
	warmup_time = 3 SECONDS
	circuit = /obj/item/circuitboard/computer/bountypad
	interface_type = "CivCargoHoldTerminal"
	load_holding_facility = FALSE
	///Typecast of an inserted, scanned ID card inside the console, as bounties are held within the ID card.
	var/obj/item/card/id/inserted_scan_id
	///Cooldown for printing the bounty sheet, and not breaking people's eardrums.
	COOLDOWN_DECLARE(sheet_printer_cooldown)

/obj/machinery/computer/piratepad_control/civilian/attackby(obj/item/I, mob/living/user, list/modifiers, list/attack_modifiers)
	if(isidcard(I))
		if(id_insert(user, I, inserted_scan_id))
			inserted_scan_id = I
			return TRUE
	return ..()

/obj/machinery/computer/piratepad_control/multitool_act(mob/living/user, obj/item/multitool/I)
	if(istype(I) && istype(I.buffer,/obj/machinery/piratepad/civilian))
		to_chat(user, span_notice("You link [src] with [I.buffer] in [I] buffer."))
		pad_ref = WEAKREF(I.buffer)
		return TRUE

/obj/machinery/computer/piratepad_control/civilian/post_machine_initialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/civilian/C as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/piratepad/civilian))
			if(C.cargo_hold_id == cargo_hold_id)
				pad_ref = WEAKREF(C)
				return
	else
		var/obj/machinery/piratepad/civilian/pad = locate() in range(4,src)
		pad_ref = WEAKREF(pad)

/obj/machinery/computer/piratepad_control/civilian/recalc()
	if(sending)
		return FALSE
	if(!inserted_scan_id)
		status_report = "Please insert your ID first."
		playsound(loc, 'sound/machines/synth/synth_no.ogg', 30 , TRUE)
		return FALSE
	if(!inserted_scan_id.registered_account.civilian_bounty)
		status_report = "Please accept a new civilian bounty first."
		playsound(loc, 'sound/machines/synth/synth_no.ogg', 30 , TRUE)
		return FALSE
	status_report = "Civilian Bounty: "
	var/obj/machinery/piratepad/civilian/pad = pad_ref?.resolve()
	for(var/atom/movable/possible_shippable in get_turf(pad))
		if(possible_shippable == pad)
			continue
		if(possible_shippable.flags_1 & HOLOGRAM_1)
			continue
		if(isitem(possible_shippable))
			var/obj/item/possible_shippable_item = possible_shippable
			if(possible_shippable_item.item_flags & ABSTRACT)
				continue
		if(inserted_scan_id.registered_account.civilian_bounty.applies_to(possible_shippable))
			status_report += "Target Applicable."
			playsound(loc, 'sound/machines/synth/synth_yes.ogg', 30 , TRUE)
			return
	status_report += "Not Applicable."
	playsound(loc, 'sound/machines/synth/synth_no.ogg', 30 , TRUE)


/**
 * This fully rewrites base behavior in order to only check for bounty objects, and no other types of objects like pirate-pads do.
 */
/obj/machinery/computer/piratepad_control/civilian/send(check_global = FALSE, mob/user)
	status_report = ""
	playsound(loc, 'sound/machines/wewewew.ogg', 70, TRUE)
	if(!sending)
		return FALSE
	var/datum/bank_account/id_account = inserted_scan_id?.registered_account

	// To account for check_global, we're going to construct a list of all bounties we want to check.
	var/list/datum/bounty/bounty_stack = list()

	if(check_global)
		bounty_stack = GLOB.shared_crew_bounties.Copy()
	else
		bounty_stack += id_account?.civilian_bounty

	if(!length(bounty_stack))
		stop_sending()
		return FALSE
	var/active_count = 0
	var/obj/machinery/piratepad/civilian/pad = pad_ref?.resolve()
	for(var/atom/movable/possible_shippable in get_turf(pad))
		if(possible_shippable == pad)
			continue
		if(possible_shippable.flags_1 & HOLOGRAM_1)
			continue
		if(isitem(possible_shippable))
			var/obj/item/possible_shippable_item = possible_shippable
			if(possible_shippable_item.item_flags & ABSTRACT)
				continue

		for(var/datum/bounty/stack_item in bounty_stack)
			if(stack_item.applies_to(possible_shippable))
				active_count++
				LAZYADDASSOC(stack_item.contribution, id_account, stack_item.contribution_amount(possible_shippable))
				if(stack_item.contribution[id_account] <= 0 || !stack_item.contribution[id_account])
					stack_item.contribution[id_account] = stack_item.contribution_amount(possible_shippable)
				stack_item.ship(possible_shippable)
				qdel(possible_shippable)

	if(active_count >= 1)
		status_report += "Bounty Target[active_count > 1 ? "s" : ""] Found x[active_count]. "

		SStgui.update_uis(src)	//update Ui data to display how much of the bounty remains
	else
		status_report = "No applicable target found. Aborting. "
		stop_sending()

	active_count = 0 // We'll just re-use this for the second message setter.
	for(var/datum/bounty/stack_item in bounty_stack)
		if(stack_item.can_claim())
			active_count++
			//Pay for the bounty with the ID's department funds.
			SSblackbox.record_feedback("tally", "bounties_completed", 1, stack_item.type)
			stack_item.claimed = TRUE
			stack_item.on_claimed(inserted_scan_id)
			// Unique case: A global bounty is completed, and you have the same bounty as a personal bounty,
			// it will complete your personal one as well. It will however only increment the tracker by one.
			if(check_global)
				SSeconomy.civ_bounty_tracker++ //This is the tracker for adding more global bounties, not for logging purposes.
				for(var/datum/bank_account/helper in stack_item.contribution)
					if(istype(helper?.civilian_bounty, stack_item.type))
						helper.reset_bounty(inserted_scan_id)
						helper.bank_card_talk("Your [stack_item.name] bounty has been completed for matching the completed station bounty!")
			else
				id_account.reset_bounty(inserted_scan_id)

			var/obj/item/bounty_cube/reward = new /obj/item/bounty_cube(drop_location())
			reward.set_up(stack_item, inserted_scan_id)
	if(active_count >= 1)
		status_report += "x[active_count] Bount[active_count > 1 ? "ies" : "y"] completed! \
			Please give your bounty cube[active_count > 1 ? "s" : ""] to cargo for your automated payout shortly. "

	if(check_global)
		update_global_bounty_list(round(CIV_BOUNTY_BASELINE + (SSeconomy.civ_bounty_tracker / 3)), FALSE)

	pad.visible_message(span_notice("[pad] activates!"))
	flick(pad.sending_state,pad)
	pad.icon_state = pad.idle_state
	playsound(loc, 'sound/machines/synth/synth_yes.ogg', 30 , TRUE)
	sending = FALSE
	return TRUE

///Here is where cargo bounties are added to the player's bank accounts, then adjusted and scaled into a civilian bounty.
/obj/machinery/computer/piratepad_control/civilian/proc/add_bounties(mob/user, cooldown_reduction = 0)
	var/datum/bank_account/id_account = inserted_scan_id?.registered_account
	if(!id_account)
		return FALSE
	if((id_account.civilian_bounty || id_account.bounties) && !COOLDOWN_FINISHED(id_account, bounty_timer))
		var/time_left = DisplayTimeText(COOLDOWN_TIMELEFT(id_account, bounty_timer), round_seconds_to = 1)
		balloon_alert(user, "try again in [time_left]!")
		return FALSE
	if(!inserted_scan_id.trim)
		say("Requesting ID card has no job assignment registered!")
		return FALSE

	var/list/datum/bounty/crumbs = inserted_scan_id.trim.generate_bounty_list()
	COOLDOWN_START(id_account, bounty_timer, (5 MINUTES) - cooldown_reduction)
	id_account.bounties = crumbs
	return TRUE


/**
 * Proc that assigned a civilian bounty to an ID card, from the list of potential bounties that that bank account currently has available.
 * Available choices are assigned during add_bounties, and one is locked in here.
 *
 * @param choice The index of the bounty in the list of bounties that the player can choose from.
 */
/obj/machinery/computer/piratepad_control/civilian/proc/pick_bounty(datum/bounty/choice)
	var/datum/bank_account/id_account = inserted_scan_id?.registered_account
	if(!id_account?.bounties?[choice])
		playsound(loc, 'sound/machines/synth/synth_no.ogg', 40 , TRUE)
		return
	id_account.set_bounty(id_account.bounties[choice], inserted_scan_id)
	id_account.bounties = null
	SSblackbox.record_feedback("tally", "bounties_assigned", 1, id_account.civilian_bounty.type)
	return id_account.civilian_bounty

/obj/machinery/computer/piratepad_control/civilian/click_alt(mob/user)
	id_eject(user, inserted_scan_id)
	return CLICK_ACTION_SUCCESS

/obj/machinery/computer/piratepad_control/civilian/ui_data(mob/user)
	var/list/data = list()
	data["points"] = points
	data["pad"] = pad_ref?.resolve() ? TRUE : FALSE
	data["sending"] = sending
	data["status_report"] = status_report
	data["id_inserted"] = inserted_scan_id
	data["claimed_bounties"] = SSeconomy.civ_bounty_tracker

// Personal bounty data:
	if(inserted_scan_id?.registered_account)
		if(inserted_scan_id.registered_account.civilian_bounty)
			data["id_bounty_info"] = inserted_scan_id.registered_account.civilian_bounty.description
			data["id_bounty_num"] = inserted_scan_id.registered_account.bounty_num()
			data["id_bounty_value"] = (inserted_scan_id.registered_account.civilian_bounty.get_bounty_reward()) * (CIV_BOUNTY_SPLIT / 100)
		if(inserted_scan_id.registered_account.bounties)
			data["picking"] = TRUE
			data["id_bounty_names"] = list()
			data["id_bounty_infos"] = list()
			data["id_bounty_values"] = list()
			for(var/datum/bounty/bounty as anything in inserted_scan_id.registered_account.bounties)
				data["id_bounty_names"] += bounty.name
				data["id_bounty_infos"] += bounty.description
				data["id_bounty_values"] += bounty.get_bounty_reward() * (CIV_BOUNTY_SPLIT / 100)

		else
			data["picking"] = FALSE

// Global bounty data:
	data["listBounty"] = list()
	for(var/datum/bounty/global_bounty as anything in GLOB.shared_crew_bounties)

		var/ship_max = global_bounty.get_max()
		var/ship_total = global_bounty.get_total() //Present value as a percentage, we'll handle 0 and 100 as constants

		if(data["listBounty"]["name"] == global_bounty.name)
			continue
		data["listBounty"] += list(list(
			"name" = global_bounty.name,
			"description" = global_bounty.description,
			"reward" = global_bounty.get_bounty_reward(),
			"claimed" = global_bounty.claimed,
			"shipped" = ship_total,
			"maximum" = ship_max,
			"priority" = global_bounty.high_priority,
			"unique" = global_bounty.unique
		))

	return data

/obj/machinery/computer/piratepad_control/civilian/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/obj/machinery/piratepad/civilian/pad = pad_ref?.resolve()
	if(!pad)
		return
	var/mob/user = ui.user
	if(!user.can_perform_action(src) || (machine_stat & (NOPOWER|BROKEN)))
		return
	switch(action) //several ui_acts are handled on parent by piratepad
		if("pick")
			pick_bounty(params["value"])
			return TRUE
		if("bounty")
			add_bounties(user, pad.get_cooldown_reduction())
			return TRUE
		if("eject")
			id_eject(user, inserted_scan_id)
			inserted_scan_id = null
			return TRUE
		if("update_list")
			playsound(src, 'sound/machines/data_transmission.ogg', 50) // Should only need to play once per round due to the list auto-updating afterwards.

			var/bonus_bounties = clamp(round(length(GLOB.player_list) / 8), 0, 5) // The number of bounties to be generated is 5 + 1-per every 8 players on the server, up to a max of 10 total.
			looped_global_update(1, CIV_BOUNTY_BASELINE + bonus_bounties, first_time = TRUE) // Just for visual flair
			return TRUE
		if("print")
			print_sheet(user)

/// Self explanitory, holds the ID card in the console for bounty payout and manipulation.
/obj/machinery/computer/piratepad_control/civilian/proc/id_insert(mob/user, obj/item/inserting_item, obj/item/target)
	var/obj/item/card/id/card_to_insert = inserting_item
	var/holder_item = FALSE

	if(!isidcard(card_to_insert))
		card_to_insert = inserting_item.remove_id()
		holder_item = TRUE

	if(!card_to_insert || !user.transferItemToLoc(card_to_insert, src))
		return FALSE

	if(target)
		if(holder_item && inserting_item.insert_id(target))
			playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 50, FALSE)
		else
			id_eject(user, target)

	user.visible_message(span_notice("[user] inserts \the [card_to_insert] into \the [src]."),
						span_notice("You insert \the [card_to_insert] into \the [src]."))
	playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 50, FALSE)
	ui_interact(user)
	return TRUE

///Removes A stored ID card.
/obj/machinery/computer/piratepad_control/civilian/proc/id_eject(mob/user, obj/item/target)
	if(!target)
		to_chat(user, span_warning("That slot is empty!"))
		return FALSE
	else
		try_put_in_hand(target, user)
		user.visible_message(span_notice("[user] gets \the [target] from \the [src]."), \
							span_notice("You get \the [target] from \the [src]."))
		playsound(src, 'sound/machines/terminal/terminal_insert_disc.ogg', 50, FALSE)
		inserted_scan_id = null
		return TRUE

/**
 * Updates the global bounty list: First by sorting through all completed bounties on the list and deleting them.
 * Then, adds new bounties up to the limit, defined by the update_up_to argument.
 * The bounties to be added should not share duplicates between job subtypes.
 * @param update_up_to How many new bounties to add to the list, up to the maximum defined by MAXIMUM_BOUNTY_JOBS.
 * @param enable_high_priority If enabled, means that past a prob(HIGH_PRIORITY_BOUNTY_ODDS), the created bounty will have a 1.5x value multiplier and be labeled in the UI.
 * @param running_jobs A list we generate when making multiple bounties at once, this stores the job define to prevent double dipping on the same job type.
 */
/obj/machinery/computer/piratepad_control/civilian/proc/update_global_bounty_list(update_up_to = CIV_BOUNTY_BASELINE, enable_high_priority = FALSE, list/running_jobs)
	//First, clear out completed bounties.
	for(var/datum/bounty/complete_or_unique in GLOB.shared_crew_bounties)
		if(complete_or_unique.claimed)
			GLOB.shared_crew_bounties -= complete_or_unique
		if(complete_or_unique.unique)
			update_up_to++ // We're doing this to ignore the quantity of unique bounties in the global list.

	//Then, add new bounties up to the limit.
	var/list/jobs_picked = running_jobs || list()
	while(length(GLOB.shared_crew_bounties) < update_up_to)
		var/job_code = rand(CIV_JOB_BASIC, CIV_JOB_BITRUN) //CIV_JOB_ defines taken from _DEFINES/economy.dm. If new job bounty classes are added, swap out our maximum.
		if(job_code in jobs_picked)
			continue
		jobs_picked += job_code

		var/datum/bounty/new_bounty = random_bounty(job_code)
		if(new_bounty.global_exempt)
			continue

		GLOB.shared_crew_bounties.Insert(0, new_bounty)

		if(enable_high_priority && prob(HIGH_PRIORITY_BOUNTY_ODDS))
			new_bounty.high_priority = TRUE
			new_bounty.description += "</br>\
				This bounty is marked as <b>high priority</b>, and will reward <b>1.5x</b> the normal payout!"
	return jobs_picked

/// Performs several global bounty updates in a row on a callback loop, adding one each time.
/obj/machinery/computer/piratepad_control/civilian/proc/looped_global_update(current_count, update_to, inherited_list, first_time = FALSE)
	var/jobs_picked = update_global_bounty_list(current_count, enable_high_priority = TRUE, running_jobs = inherited_list)

	if(current_count == update_to)
		if(first_time)
			setup_special_procs()
		return TRUE
	current_count++
	addtimer(CALLBACK(src, PROC_REF(looped_global_update), current_count, update_to, jobs_picked, first_time), 0.8 SECONDS)
	return FALSE

/// Spawns the roundstart "special" bounties.
/obj/machinery/computer/piratepad_control/civilian/proc/setup_special_procs()
	for(var/selected_special in subtypesof(/datum/bounty/item/special))
		GLOB.shared_crew_bounties += new selected_special

/**
 * Handles cooldowns and creation of a new cargo bounty sheet.
 */
/obj/machinery/computer/piratepad_control/civilian/proc/print_sheet(mob/living/user)
	if(!COOLDOWN_FINISHED(src, sheet_printer_cooldown))
		balloon_alert(user, "printer spooling!")
		return FALSE

	var/obj/item/paper/paper = new(loc)
	paper.name = "paper - Bounties"

	var/list/printout_text = list()
	printout_text += "<h2>Nanotrasen Cargo Bounties</h2></br>"

	for(var/datum/bounty/current_bounty in GLOB.shared_crew_bounties)
		if(current_bounty.claimed)
			continue
		printout_text += {"<h3>[current_bounty.name]</h3>
			<ul>
			<li>Quantity requested: <i>[current_bounty.print_required()]</i>
			<li>Reward: <b>[current_bounty.get_bounty_reward()]</b> cr.</li>
			<li>Cut: <b>[round(BOUNTY_CUT_STANDARD * current_bounty.get_bounty_reward())]</b> cr.</li>
			</ul>"}
	paper.add_raw_text(printout_text.Join("<br />"))
	paper.update_appearance()

	playsound(src, 'sound/machines/printer.ogg', 100, TRUE)
	COOLDOWN_START(src, sheet_printer_cooldown, 4 SECONDS)
	return TRUE

///Beacon to launch a new bounty setup when activated.
/obj/item/civ_bounty_beacon
	name = "civilian bounty beacon"
	desc = "N.T. approved civilian bounty beacon, toss it down and you will have a bounty pad and computer delivered to you."
	icon = 'icons/obj/machines/floor.dmi'
	icon_state = "floor_beacon"
	var/uses = 2

/obj/item/civ_bounty_beacon/attack_self()
	loc.visible_message(span_warning("\The [src] begins to beep loudly!"))
	addtimer(CALLBACK(src, PROC_REF(launch_payload)), 1 SECONDS)

/obj/item/civ_bounty_beacon/proc/launch_payload()
	playsound(src, SFX_SPARKS, 80, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	switch(uses)
		if(2)
			new /obj/machinery/piratepad/civilian(drop_location())
		if(1)
			new /obj/machinery/computer/piratepad_control/civilian(drop_location())
			qdel(src)
	uses--


#undef CIV_BOUNTY_SPLIT
#undef HIGH_PRIORITY_BOUNTY_ODDS
