//Shuttle equipment

/obj/machinery/shuttle_scrambler
	name = "Data Siphon"
	desc = "This heap of machinery steals credits and data from unprotected systems and locks down cargo shuttles."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	density = TRUE
	var/active = FALSE
	var/credits_stored = 0
	var/siphon_per_tick = 5

/obj/machinery/shuttle_scrambler/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/machinery/shuttle_scrambler/process()
	if(active)
		if(is_station_level(z))
			var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
			if(D)
				var/siphoned = min(D.account_balance,siphon_per_tick)
				D.adjust_money(-siphoned)
				credits_stored += siphoned
			interrupt_research()
		else
			return
	else
		STOP_PROCESSING(SSobj,src)

/obj/machinery/shuttle_scrambler/proc/toggle_on(mob/user)
	SSshuttle.registerTradeBlockade(src)
	AddComponent(/datum/component/gps, "Nautical Signal")
	active = TRUE
	to_chat(user,span_notice("You toggle [src] [active ? "on":"off"]."))
	to_chat(user,span_warning("The scrambling signal can be now tracked by GPS."))
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

//interrupt_research
/obj/machinery/shuttle_scrambler/proc/interrupt_research()
	for(var/obj/machinery/rnd/server/S as anything in SSresearch.science_tech.techweb_servers)
		if(S.machine_stat & (NOPOWER|BROKEN))
			continue
		S.emp_act()
		new /obj/effect/temp_visual/emp(get_turf(S))

/obj/machinery/shuttle_scrambler/proc/dump_loot(mob/user)
	if(credits_stored) // Prevents spamming empty holochips
		new /obj/item/holochip(drop_location(), credits_stored)
		to_chat(user,span_notice("You retrieve the siphoned credits!"))
		credits_stored = 0
	else
		to_chat(user,span_notice("There's nothing to withdraw."))

/obj/machinery/shuttle_scrambler/proc/send_notification()
	priority_announce("Data theft signal detected, source registered on local gps units.")

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

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/pirate
	name = "pirate shuttle navigation computer"
	desc = "Used to designate a precise transit location for the pirate shuttle."
	shuttleId = "pirate"
	lock_override = CAMERA_LOCK_STATION
	shuttlePortId = "pirate_custom"
	x_offset = 9
	y_offset = 0
	see_hidden = FALSE

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/pirate/psyker
	name = "psyker navigation warper"
	desc = "Used to designate a precise transit location for the psyker shuttle, using sent out brainwaves as detailed sight."
	icon_screen = "recharge_comp_on"
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_SET_MACHINE //blind friendly
	x_offset = 0
	y_offset = 11

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
	var/cooldown = 300
	var/next_use = 0

/obj/machinery/loot_locator/interact(mob/user)
	if(world.time <= next_use)
		to_chat(user,span_warning("[src] is recharging."))
		return
	next_use = world.time + cooldown
	var/atom/movable/AM = find_random_loot()
	if(!AM)
		say("No valuables located. Try again later.")
	else
		say("Located: [AM.name] at [get_area_name(AM)]")

/obj/machinery/loot_locator/proc/find_random_loot()
	if(!GLOB.exports_list.len)
		setupExports()
	var/list/possible_loot = list()
	for(var/datum/export/pirate/E in GLOB.exports_list)
		possible_loot += E
	var/datum/export/pirate/P
	var/atom/movable/AM
	while(!AM && possible_loot.len)
		P = pick_n_take(possible_loot)
		AM = P.find_loot()
	return AM

//Pad & Pad Terminal
/obj/machinery/piratepad
	name = "cargo hold pad"
	icon = 'icons/obj/telescience.dmi'
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
		to_chat(user, span_notice("You register [src] in [I]s buffer."))
		I.buffer = src
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

/obj/machinery/computer/piratepad_control/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/piratepad_control/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if (istype(I) && istype(I.buffer,/obj/machinery/piratepad))
		to_chat(user, span_notice("You link [src] with [I.buffer] in [I] buffer."))
		pad_ref = WEAKREF(I.buffer)
		return TRUE

/obj/machinery/computer/piratepad_control/LateInitialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/piratepad/P in GLOB.machines)
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

/obj/machinery/computer/piratepad_control/ui_act(action, params)
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
			. = TRUE
		if("stop")
			stop_sending()
			. = TRUE

/obj/machinery/computer/piratepad_control/proc/recalc()
	if(sending)
		return

	status_report = "Predicted value: "
	var/value = 0
	var/datum/export_report/ex = new
	var/obj/machinery/piratepad/pad = pad_ref?.resolve()
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		export_item_and_contents(AM, apply_elastic = FALSE, dry_run = TRUE, external_report = ex)

	for(var/datum/export/E in ex.total_amount)
		status_report += E.total_printout(ex,notes = FALSE)
		status_report += " "
		value += ex.total_value[E]

	if(!value)
		status_report += "0"

/obj/machinery/computer/piratepad_control/proc/send()
	if(!sending)
		return

	var/datum/export_report/ex = new
	var/obj/machinery/piratepad/pad = pad_ref?.resolve()

	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad)
			continue
		export_item_and_contents(AM, EXPORT_PIRATE | EXPORT_CARGO | EXPORT_CONTRABAND | EXPORT_EMAG, apply_elastic = FALSE, delete_unsold = FALSE, external_report = ex)

	status_report = "Sold: "
	var/value = 0
	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex,notes = FALSE) //Don't want nanotrasen messages, makes no sense here.
		if(!export_text)
			continue

		status_report += export_text
		status_report += " "
		value += ex.total_value[E]

	if(!total_report)
		total_report = ex
	else
		total_report.exported_atoms += ex.exported_atoms
		for(var/datum/export/E in ex.total_amount)
			total_report.total_amount[E] += ex.total_amount[E]
			total_report.total_value[E] += ex.total_value[E]
		playsound(loc, 'sound/machines/wewewew.ogg', 70, TRUE)

	points += value

	if(!value)
		status_report += "Nothing"

	pad.visible_message(span_notice("[pad] activates!"))
	flick(pad.sending_state,pad)
	pad.icon_state = pad.idle_state
	sending = FALSE

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

//Attempts to find the thing on station
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

/datum/export/pirate/ransom/get_cost(atom/movable/AM)
	var/mob/living/carbon/human/H = AM
	if(H.stat != CONSCIOUS || !H.mind) //mint condition only
		return 0
	else if(FACTION_PIRATE in H.faction) //can't ransom your fellow pirates to CentCom!
		return 0
	else if(H.mind.assigned_role.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
		return 3000
	else
		return 1000

/datum/export/pirate/parrot
	cost = 2000
	unit_name = "alive parrot"
	export_types = list(/mob/living/simple_animal/parrot)

/datum/export/pirate/parrot/find_loot()
	for(var/mob/living/simple_animal/parrot/P in GLOB.alive_mob_list)
		var/turf/T = get_turf(P)
		if(T && is_station_level(T.z))
			return P

/datum/export/pirate/cash
	cost = 1
	unit_name = "bills"
	export_types = list(/obj/item/stack/spacecash)

/datum/export/pirate/cash/get_amount(obj/O)
	var/obj/item/stack/spacecash/C = O
	return ..() * C.amount * C.value

/datum/export/pirate/holochip
	cost = 1
	unit_name = "holochip"
	export_types = list(/obj/item/holochip)

/datum/export/pirate/holochip/get_cost(atom/movable/AM)
	var/obj/item/holochip/H = AM
	return H.credits
