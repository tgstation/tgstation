//Shuttle equipment

/obj/machinery/shuttle_scrambler
	name = "Data Siphon"
	desc = "This heap of machinery steals credits and data from unprotected systems and locks down cargo shuttles."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = TRUE
	/// Is the machine siphoning right now
	var/active = FALSE
	/// The amount of money stored in the machine
	var/credits_stored = 0
	/// The amount of money removed per tick
	var/siphon_per_tick = 5

/obj/machinery/shuttle_scrambler/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/machinery/shuttle_scrambler/process()
	if(!active)
		return PROCESS_KILL

	if(!is_station_level(z))
		return

	var/datum/bank_account/account = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/siphoned = min(account.account_balance,siphon_per_tick)
	account.adjust_money(-siphoned)
	credits_stored += siphoned
	interrupt_research()

///Turns on the siphoning, and its various side effects
/obj/machinery/shuttle_scrambler/proc/toggle_on(mob/user)
	SSshuttle.registerTradeBlockade(src)
	AddComponent(/datum/component/gps, "Nautical Signal")
	active = TRUE
	to_chat(user,span_notice("You toggle [src] [active ? "on":"off"]."))
	to_chat(user,span_warning("The scrambling signal can now be tracked by GPS."))
	START_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/interact(mob/user)
	if(active)
		dump_loot(user)
		return
	var/scramble_response = tgui_alert(user, "Turning the scrambler on will make the shuttle trackable by GPS. Are you sure you want to do it?", "Scrambler", list("Yes", "Cancel"))
	if(scramble_response != "Yes")
		return
	if(active || !user.can_perform_action(src))
		return
	toggle_on(user)
	update_appearance()
	send_notification()

/// Handles interrupting research
/obj/machinery/shuttle_scrambler/proc/interrupt_research()
	var/datum/techweb/science_web = locate(/datum/techweb/science) in SSresearch.techwebs
	for(var/obj/machinery/rnd/server/research_server as anything in science_web.techweb_servers)
		if(research_server.machine_stat & (NOPOWER|BROKEN|EMPED))
			continue
		research_server.emp_act(EMP_LIGHT)
		new /obj/effect/temp_visual/emp(get_turf(research_server))

/// Handles expelling all the siphoned credits as holochips
/obj/machinery/shuttle_scrambler/proc/dump_loot(mob/user)
	if(credits_stored) // Prevents spamming empty holochips
		new /obj/item/holochip(drop_location(), credits_stored)
		to_chat(user,span_notice("You retrieve the siphoned credits!"))
		credits_stored = 0
	else
		to_chat(user,span_notice("There's nothing to withdraw."))

/// Alerts the crew about the siphon
/obj/machinery/shuttle_scrambler/proc/send_notification()
	priority_announce("Data theft signal detected; source registered on local GPS units.")

/// Switches off the siphon
/obj/machinery/shuttle_scrambler/proc/toggle_off(mob/user)
	SSshuttle.clearTradeBlockade(src)
	active = FALSE
	STOP_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/update_icon_state()
	icon_state = active ? "dominator-Blue" : "dominator"
	return ..()

/obj/machinery/shuttle_scrambler/Destroy()
	toggle_off()
	return ..()

/obj/machinery/computer/shuttle/pirate
	name = "pirate shuttle console"
	shuttleId = "pirate"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = COLOR_SOFT_RED
	possible_destinations = "pirate_away;pirate_home;pirate_custom"

/obj/machinery/computer/shuttle/pirate/drop_pod
	possible_destinations = "null"

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/pirate
	name = "pirate shuttle navigation computer"
	desc = "Used to designate a precise transit location for the pirate shuttle."
	shuttleId = "pirate"
	lock_override = CAMERA_LOCK_STATION
	shuttlePortId = "pirate_custom"
	x_offset = 9
	y_offset = 0
	see_hidden = FALSE

/obj/docking_port/mobile/pirate
	name = "pirate shuttle"
	shuttle_id = "pirate"
	rechargeTime = 3 MINUTES

/obj/machinery/suit_storage_unit/pirate
	suit_type = /obj/item/clothing/suit/space
	helmet_type = /obj/item/clothing/head/helmet/space
	mask_type = /obj/item/clothing/mask/breath
	storage_type = /obj/item/tank/internals/oxygen

/obj/machinery/loot_locator
	name = "Booty Locator"
	desc = "This sophisticated machine scans the nearby space for items of value."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	/// Cooldown on locating booty.
	COOLDOWN_DECLARE(locate_cooldown)

/obj/machinery/loot_locator/interact(mob/user)
	if(!COOLDOWN_FINISHED(src, locate_cooldown))
		balloon_alert_to_viewers("locator recharging!", vision_distance = 3)
		return
	var/atom/movable/found_loot = find_random_loot()
	if(!found_loot)
		say("No valuables located. Try again later.")
	else
		say("Located: [found_loot.name] at [get_area_name(found_loot)]")

	COOLDOWN_START(src, locate_cooldown, 10 SECONDS)

/// Looks across the station for items that are pirate specific exports
/obj/machinery/loot_locator/proc/find_random_loot()
	if(!GLOB.exports_list.len)
		setupExports()
	var/list/possible_loot = list()
	for(var/datum/export/pirate/possible_export in GLOB.exports_list)
		possible_loot += possible_export
	var/datum/export/pirate/selected_export
	var/atom/movable/found_loot
	while(!found_loot && possible_loot.len)
		selected_export = pick_n_take(possible_loot)
		found_loot = selected_export.find_loot()
	return found_loot

/// Surgery disk for the space IRS (I don't know where to dump them anywhere else)
/obj/item/disk/surgery/irs
	name = "Advanced Surgery Disk"
	desc = "A disk that contains advanced surgery procedures, must be loaded into an Operating Console."
	surgeries = list(
		/datum/surgery/advanced/lobotomy,
		/datum/surgery/advanced/lobotomy/mechanic,
		/datum/surgery/advanced/bioware/vein_threading,
		/datum/surgery/advanced/bioware/vein_threading/mechanic,
		/datum/surgery/advanced/bioware/nerve_splicing,
		/datum/surgery/advanced/bioware/nerve_splicing/mechanic,
		/datum/surgery_step/heal/combo/upgraded,
		/datum/surgery_step/pacify,
		/datum/surgery_step/pacify/mechanic,
	)

//Pad & Pad Terminal
/obj/machinery/piratepad
	name = "cargo hold pad"
	icon = 'icons/obj/machines/telepad.dmi'
	icon_state = "lpad-idle-off"
	///This is the icon_state that this telepad uses when it's not in use.
	var/idle_state = "lpad-idle-off"
	///This is the icon_state that this telepad uses when it's warming up for goods teleportation.
	var/warmup_state = "lpad-idle"
	///This is the icon_state to flick when the goods are being sent off by the telepad.
	var/sending_state = "lpad-beam"
	///This is the cargo hold ID used by the piratepad_control. Match these two to link them together.
	var/cargo_hold_id

/obj/machinery/piratepad/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if (istype(I))
		I.set_buffer(src)
		balloon_alert(user, "saved to multitool buffer")
		return TRUE

/obj/machinery/piratepad/screwdriver_act_secondary(mob/living/user, obj/item/screwdriver/screw)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, "lpad-idle-open", "lpad-idle-off", screw)

/obj/machinery/piratepad/crowbar_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	default_deconstruction_crowbar(tool)
	return TRUE

/obj/machinery/computer/piratepad_control
	name = "cargo hold control terminal"
	///Message to display on the TGUI window.
	var/status_report = "Ready for delivery."
	///Reference to the specific pad that the control computer is linked up to.
	var/datum/weakref/pad_ref
	///How long does it take to warmup the pad to teleport?
	var/warmup_time = 100
	///Is the teleport pad/computer sending something right now? TRUE/FALSE
	var/sending = FALSE
	///For the purposes of space pirates, how many points does the control pad have collected.
	var/points = 0
	///Reference to the export report totaling all sent objects and mobs.
	var/datum/export_report/total_report
	///Callback holding the sending timer for sending the goods after a delay.
	var/sending_timer
	///This is the cargo hold ID used by the piratepad machine. Match these two to link them together.
	var/cargo_hold_id
	///Interface name for the ui_interact call for different subtypes.
	var/interface_type = "CargoHoldTerminal"
	///Typecache of things that shouldn't be sold and shouldn't have their contents sold.
	var/static/list/nosell_typecache

/obj/machinery/computer/piratepad_control/Initialize(mapload)
	..()
	if(isnull(nosell_typecache))
		nosell_typecache = typecacheof(/mob/living/silicon/robot)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/piratepad_control/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if (istype(I) && istype(I.buffer,/obj/machinery/piratepad))
		to_chat(user, span_notice("You link [src] with [I.buffer] in [I] buffer."))
		pad_ref = WEAKREF(I.buffer)
		return TRUE

/obj/machinery/computer/piratepad_control/post_machine_initialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/P as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/piratepad))
			if(P.cargo_hold_id == cargo_hold_id)
				pad_ref = WEAKREF(P)
				return
	else
		var/obj/machinery/piratepad/pad = locate() in range(4, src)
		pad_ref = WEAKREF(pad)

/obj/machinery/computer/piratepad_control/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, interface_type, name)
		ui.open()

/obj/machinery/computer/piratepad_control/ui_data(mob/user)
	var/list/data = list()
	data["points"] = points
	data["pad"] = pad_ref?.resolve() ? TRUE : FALSE
	data["sending"] = sending
	data["status_report"] = status_report
	return data

/obj/machinery/computer/piratepad_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(!pad_ref?.resolve())
		return

	switch(action)
		if("recalc")
			recalc()
			. = TRUE
		if("send")
			start_sending()
			//We ensure that the holding facility is loaded in time in case we're selling mobs.
			//This isn't the prettiest place to put it, but 'start_sending()' is also used by civilian bounty computers
			//And we don't need them to also load the holding facility.
			SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_NINJA_HOLDING_FACILITY)
			. = TRUE
		if("stop")
			stop_sending()
			. = TRUE

/// Calculates the predicted value of the items on the pirate pad
/obj/machinery/computer/piratepad_control/proc/recalc()
	if(sending)
		return

	status_report = "Predicted value: "
	var/value = 0

	var/obj/machinery/piratepad/pad = pad_ref?.resolve()
	var/datum/export_report/report = pirate_export_loop(pad)

	for(var/datum/export/exported_datum in report.total_amount)
		status_report += exported_datum.total_printout(report,notes = FALSE)
		status_report += " "
		value += report.total_value[exported_datum]

	if(!value)
		status_report += "0"

/// Deletes and sells the item
/obj/machinery/computer/piratepad_control/proc/send()
	if(!sending)
		return

	var/obj/machinery/piratepad/pad = pad_ref?.resolve()
	var/datum/export_report/report = pirate_export_loop(pad, dry_run = FALSE)

	status_report = "Sold: "
	var/value = 0
	for(var/datum/export/exported_datum in report.total_amount)
		var/export_text = exported_datum.total_printout(report,notes = FALSE) //Don't want nanotrasen messages, makes no sense here.
		if(!export_text)
			continue

		status_report += export_text
		status_report += " "
		value += report.total_value[exported_datum]

	if(!total_report)
		total_report = report
	else
		total_report.exported_atoms += report.exported_atoms
		for(var/datum/export/exported_datum in report.total_amount)
			total_report.total_amount[exported_datum] += report.total_amount[exported_datum]
			total_report.total_value[exported_datum] += report.total_value[exported_datum]
		playsound(loc, 'sound/machines/wewewew.ogg', 70, TRUE)

	points += value

	if(!value)
		status_report += "Nothing"

	pad.visible_message(span_notice("[pad] activates!"))
	flick(pad.sending_state,pad)
	pad.icon_state = pad.idle_state
	sending = FALSE

///The loop that calculates the value of stuff on a pirate pad, or plain sell them if dry_run is FALSE.
/obj/machinery/computer/piratepad_control/proc/pirate_export_loop(obj/machinery/piratepad/pad, dry_run = TRUE)
	var/datum/export_report/report = new
	for(var/atom/movable/item_on_pad as anything in get_turf(pad))
		if(item_on_pad == pad)
			continue
		var/list/hidden_mobs = list()
		var/skip_movable = FALSE
		var/list/item_contents = item_on_pad.get_all_contents()
		for(var/atom/movable/thing in reverse_range(item_contents))
			///Don't destroy/sell stuff like the captain's laser gun, or borgs.
			if(thing.resistance_flags & INDESTRUCTIBLE || is_type_in_typecache(thing, nosell_typecache))
				skip_movable = TRUE
				break
			if(isliving(thing))
				hidden_mobs += thing
		if(skip_movable)
			continue
		for(var/mob/living/hidden as anything in hidden_mobs)
			///Sell mobs, but leave their contents intact.
			export_single_item(hidden, apply_elastic = FALSE, dry_run = dry_run, external_report = report)
		///there are still licing mobs inside that item. Stop, don't sell it ffs.
		if(locate(/mob/living) in item_on_pad.get_all_contents())
			continue
		export_item_and_contents(item_on_pad, apply_elastic = FALSE, dry_run = dry_run, delete_unsold = FALSE, external_report = report, ignore_typecache = nosell_typecache, export_market = EXPORT_MARKET_PIRACY)
	return report

/// Prepares to sell the items on the pad
/obj/machinery/computer/piratepad_control/proc/start_sending()
	var/obj/machinery/piratepad/pad = pad_ref?.resolve()
	if(!pad)
		status_report = "No pad detected. Build or link a pad."
		pad.audible_message(span_notice("[pad] beeps."))
		return
	if(pad?.panel_open)
		status_report = "Please screwdrive pad closed to send. "
		pad.audible_message(span_notice("[pad] beeps."))
		return
	if(sending)
		return
	sending = TRUE
	status_report = "Sending... "
	pad.visible_message(span_notice("[pad] starts charging up."))
	pad.icon_state = pad.warmup_state
	sending_timer = addtimer(CALLBACK(src, PROC_REF(send)),warmup_time, TIMER_STOPPABLE)

/// Finishes the sending state of the pad
/obj/machinery/computer/piratepad_control/proc/stop_sending(custom_report)
	if(!sending)
		return
	sending = FALSE
	status_report = "Ready for delivery."
	if(custom_report)
		status_report = custom_report
	var/obj/machinery/piratepad/pad = pad_ref?.resolve()
	pad.icon_state = pad.idle_state
	deltimer(sending_timer)

/datum/export/pirate
	sales_market = EXPORT_MARKET_PIRACY

/// Attempts to find the thing on station
/datum/export/pirate/proc/find_loot()
	return

/datum/export/pirate/ransom
	cost = 3000
	unit_name = "hostage"
	export_types = list(/mob/living/carbon/human)

/datum/export/pirate/ransom/find_loot()
	var/list/head_minds = SSjob.get_living_heads()
	var/list/head_mobs = list()
	for(var/datum/mind/M as anything in head_minds)
		head_mobs += M.current
	if(head_mobs.len)
		return pick(head_mobs)

/datum/export/pirate/ransom/get_cost(atom/movable/exported_item)
	var/mob/living/carbon/human/ransomee = exported_item
	if(ransomee.stat != CONSCIOUS || !ransomee.mind || HAS_TRAIT(ransomee.mind, TRAIT_HAS_BEEN_KIDNAPPED)) //mint condition only
		return 0
	else if(FACTION_PIRATE in ransomee.faction) //can't ransom your fellow pirates to CentCom!
		return 0
	else if(HAS_TRAIT(ransomee, TRAIT_HIGH_VALUE_RANSOM))
		return 3000
	else
		return 1000

/datum/export/pirate/ransom/sell_object(mob/living/carbon/human/sold_item, datum/export_report/report, dry_run = TRUE, apply_elastic = TRUE)
	. = ..()
	if(. == EXPORT_NOT_SOLD || dry_run)
		return
	var/turf/picked_turf = pick(GLOB.holdingfacility)
	sold_item.forceMove(picked_turf)
	var/mob_cost = get_cost(sold_item)
	sold_item.process_capture(mob_cost, mob_cost * 1.2)
	do_sparks(8, FALSE, sold_item)
	playsound(picked_turf, 'sound/items/weapons/emitter2.ogg', 25, TRUE)
	sold_item.flash_act()
	sold_item.adjust_confusion(10 SECONDS)
	sold_item.adjust_dizzy(10 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(send_back_to_station), sold_item), COME_BACK_FROM_CAPTURE_TIME)
	to_chat(sold_item, span_hypnophrase("A million voices echo in your head... <i>\"Yaarrr, thanks for the booty, landlubber. \
		You will be ransomed back to your station, so it's only a matter of time before we ship you back...</i>"))

	return EXPORT_SOLD_DONT_DELETE

///Send them back to the station after a while.
/datum/export/pirate/ransom/proc/send_back_to_station(mob/living/prisoner)
	///Deleted or already bailed out of the place.
	if(QDELETED(prisoner) || !istype(get_area(prisoner), /area/centcom/central_command_areas/holding))
		return
	var/obj/structure/closet/supplypod/back_to_station/return_pod = new()
	return_pod.return_from_capture(prisoner)

/datum/export/pirate/parrot
	cost = 2000
	unit_name = "alive parrot"
	export_types = list(/mob/living/basic/parrot)

/datum/export/pirate/parrot/find_loot()
	for(var/mob/living/basic/parrot/current_parrot in GLOB.alive_mob_list)
		var/turf/parrot_turf = get_turf(current_parrot)
		if(parrot_turf && is_station_level(parrot_turf.z))
			return current_parrot

/datum/export/pirate/cash
	cost = 1
	unit_name = "bill"
	export_types = list(/obj/item/stack/spacecash)

/datum/export/pirate/cash/get_cost(obj/exported_item)
	var/obj/item/stack/spacecash/cash = exported_item
	return cash.value * cash.amount

/datum/export/pirate/holochip
	cost = 1
	unit_name = "holochip"
	export_types = list(/obj/item/holochip)

/datum/export/pirate/holochip/get_cost(atom/movable/exported_item)
	var/obj/item/holochip/chip = exported_item
	return chip.credits
