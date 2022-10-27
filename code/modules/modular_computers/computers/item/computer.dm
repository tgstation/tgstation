GLOBAL_LIST_EMPTY(TabletMessengers) // a list of all active messengers, similar to GLOB.PDAs (used primarily with ntmessenger.dm)

// This is the base type that does all the hardware stuff.
// Other types expand it - tablets and laptops are subtypes
// consoles use "procssor" item that is held inside it.
/obj/item/modular_computer
	name = "modular microcomputer"
	desc = "A small portable microcomputer."
	icon = 'icons/obj/computer.dmi'
	icon_state = "laptop-open"
	light_on = FALSE
	integrity_failure = 0.5
	max_integrity = 100
	armor = list(MELEE = 0, BULLET = 20, LASER = 20, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	light_system = MOVABLE_LIGHT_DIRECTIONAL

	///The disk in this PDA. If set, this will be inserted on Initialize.
	var/obj/item/computer_disk/inserted_disk

	///The amount of storage space the computer starts with.
	var/max_capacity = 128
	///The amount of storage space we've got filled
	var/used_capacity = 0
	///List of stored files on this drive. DO NOT MODIFY DIRECTLY!
	var/list/datum/computer_file/stored_files = list()

	///Non-static list of programs the computer should recieve on Initialize.
	var/list/datum/computer_file/starting_programs = list()
	///Static list of default programs that come with ALL computers, here so computers don't have to repeat this.
	var/static/list/datum/computer_file/default_programs = list(
		/datum/computer_file/program/computerconfig,
		/datum/computer_file/program/ntnetdownload,
		/datum/computer_file/program/filemanager,
	)

	///Flag of the type of device the modular computer is, deciding what types of apps it can run.
	var/hardware_flag = NONE
//	Options: PROGRAM_ALL | PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET

	///Whether the icon state should be bypassed entirely, used for PDAs.
	var/bypass_state = FALSE
	///The theme, used for the main menu, some hardware config, and file browser apps.
	var/device_theme = "ntos"

	///Bool on whether the computer is currently active or not.
	var/enabled = FALSE
	///If the screen is open, only used by laptops.
	var/screen_on = TRUE

	///Looping sound for when the computer is on.
	var/datum/looping_sound/computer/soundloop
	///Whether or not this modular computer uses the looping sound
	var/looping_sound = TRUE

	///If the computer has a flashlight/LED light built-in.
	var/has_light = FALSE
	/// How far the computer's light can reach, is not editable by players.
	var/comp_light_luminosity = 3
	/// The built-in light's color, editable by players.
	var/comp_light_color = "#FFFFFF"

	///The last recorded amount of power used.
	var/last_power_usage = 0
	///Power usage when the computer is open (screen is active) and can be interacted with. Remember hardware can use power too.
	var/base_active_power_usage = 50
	///Power usage when the computer is idle and screen is off (currently only applies to laptops)
	var/base_idle_power_usage = 5

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	var/icon_state_unpowered = null // Icon state when the computer is turned off.
	var/icon_state_powered = null // Icon state when the computer is turned on.
	var/icon_state_menu = "menu" // Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/display_overlays = TRUE // If FALSE, don't draw overlays on this device at all

	/// List of "connection ports" in this computer and the components with which they are plugged
	var/list/all_components = list()
	/// Lazy List of extra hardware slots that can be used modularly.
	var/list/expansion_bays
	/// Number of total expansion bays this computer has available.
	var/max_bays = 0
	///The w_class (size) hardware it can handle, laptops get extra, computers get more.
	var/max_hardware_size = 0

	///The full name of the stored ID card's identity. These vars should probably be on the PDA.
	var/saved_identification
	///The job title of the stored ID card
	var/saved_job

	///The program currently active on the tablet.
	var/datum/computer_file/program/active_program
	///Idle programs on background. They still receive process calls but can't be interacted with.
	var/list/idle_threads = list()
	/// Amount of programs that can be ran at once
	var/max_idle_programs = 2

	///The 'computer' itself, as an obj. Primarily used for Adjacent() and UI visibility checks, especially for computers.
	var/obj/physical
	///Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/steel_sheet_cost = 5

	///A pAI currently loaded into the modular computer.
	var/obj/item/pai_card/inserted_pai
	/// Allow people with chunky fingers to use?
	var/allow_chunky = FALSE

	///If hit by a Clown virus, remaining honks left until it stops.
	var/honkvirus_amount = 0
	///Whether the PDA can still use NTNet while out of NTNet's reach.
	var/long_ranged = FALSE

	///The amount of paper currently stored in the PDA
	var/stored_paper = 10
	///The max amount of paper that can be held at once.
	var/max_paper = 30

/obj/item/modular_computer/Initialize(mapload)
	. = ..()

	START_PROCESSING(SSobj, src)
	if(!physical)
		physical = src
	set_light_color(comp_light_color)
	set_light_range(comp_light_luminosity)
	if(looping_sound)
		soundloop = new(src, enabled)
	UpdateDisplay()
	if(has_light)
		add_item_action(/datum/action/item_action/toggle_computer_light)
	if(inserted_disk)
		inserted_disk = new inserted_disk(src)

	update_appearance()
	register_context()
	init_network_id(NETWORK_TABLETS)
	Add_Messenger()
	install_default_programs()

/obj/item/modular_computer/proc/install_default_programs()
	SHOULD_CALL_PARENT(FALSE)
	for(var/programs in default_programs + starting_programs)
		var/datum/computer_file/program/program_type = new programs
		store_file(program_type)

/obj/item/modular_computer/Destroy()
	STOP_PROCESSING(SSobj, src)
	wipe_program(forced = TRUE)
	for(var/datum/computer_file/program/idle as anything in idle_threads)
		idle.kill_program(TRUE)
	for(var/port in all_components)
		var/obj/item/computer_hardware/component = all_components[port]
		qdel(component)
	all_components?.Cut()
	//Some components will actually try and interact with this, so let's do it later
	QDEL_NULL(soundloop)
	QDEL_LIST(stored_files)
	Remove_Messenger()

	if(istype(inserted_disk))
		QDEL_NULL(inserted_disk)
	if(istype(inserted_pai))
		QDEL_NULL(inserted_pai)

	physical = null
	return ..()

/obj/item/modular_computer/pre_attack_secondary(atom/A, mob/living/user, params)
	if(active_program?.tap(A, user, params))
		user.do_attack_animation(A) //Emulate this animation since we kill the attack in three lines
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1) //Likewise for the tap sound
		addtimer(CALLBACK(src, .proc/play_ping), 0.5 SECONDS, TIMER_UNIQUE) //Slightly delayed ping to indicate success
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

// shameless copy of newscaster photo saving

/obj/item/modular_computer/proc/save_photo(icon/photo)
	var/photo_file = copytext_char(md5("\icon[photo]"), 1, 6)
	if(!fexists("[GLOB.log_directory]/photos/[photo_file].png"))
		//Clean up repeated frames
		var/icon/clean = new /icon()
		clean.Insert(photo, "", SOUTH, 1, 0)
		fcopy(clean, "[GLOB.log_directory]/photos/[photo_file].png")
	return photo_file

/**
 * Plays a ping sound.
 *
 * Timers runtime if you try to make them call playsound. Yep.
 */
/obj/item/modular_computer/proc/play_ping()
	playsound(loc, 'sound/machines/ping.ogg', get_clamped_volume(), FALSE, -1)

/obj/item/modular_computer/AltClick(mob/user)
	..()
	if(issilicon(user))
		return

	if(user.canUseTopic(src, be_close = TRUE))
		var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
		var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]

		if(istype(card_slot) && card_slot.stored_card && card_slot?.try_eject(user))
			return TRUE

		if(istype(card_slot2) && card_slot2?.stored_card && card_slot2?.try_eject(user))
			return TRUE

		if(istype(inserted_pai)) // Remove pAI
			user.put_in_hands(inserted_pai)
			balloon_alert(user, "removed pAI")
			inserted_pai = null
			return TRUE

		if(!istype(src, /obj/item/modular_computer/tablet))
			return FALSE

// Gets IDs/access levels from card slot. Would be useful when/if PDAs would become modular PCs. //guess what
/obj/item/modular_computer/GetAccess()
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(card_slot)
		return card_slot.GetAccess()
	return ..()

/obj/item/modular_computer/GetID()
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]

	var/obj/item/card/id/first_id = card_slot?.GetID()
	var/obj/item/card/id/second_id = card_slot2?.GetID()

	// We have two IDs, pick the one with the most command accesses, preferring the primary slot.
	if(first_id && second_id)
		var/first_id_tally = SSid_access.tally_access(first_id, ACCESS_FLAG_COMMAND)
		var/second_id_tally = SSid_access.tally_access(second_id, ACCESS_FLAG_COMMAND)

		return (first_id_tally >= second_id_tally) ? first_id : second_id

	// If we don't have both ID slots filled, pick the one that is filled.
	if(first_id)
		return first_id
	if(second_id)
		return second_id

	// Otherwise, we have no ID at all.
	return ..()

/obj/item/modular_computer/get_id_examine_strings(mob/user)
	. = ..()

	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]

	var/obj/item/card/id/id_card1 = card_slot?.GetID()
	var/obj/item/card/id/id_card2 = card_slot2?.GetID()

	if(id_card1 || id_card2)
		if(id_card1 && id_card2)
			. += "\The [src] is displaying [id_card1] and [id_card2]."
			var/list/id_icons = list()
			id_icons += id_card1.get_id_examine_strings(user)
			id_icons += id_card2.get_id_examine_strings(user)
			. += id_icons.Join(" ")
		else if(id_card1)
			. += "\The [src] is displaying [id_card1]."
			. += id_card1.get_id_examine_strings(user)
		else
			. += "\The [src] is displaying [id_card2]."
			. += id_card2.get_id_examine_strings(user)

/obj/item/modular_computer/RemoveID()
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]

	var/removed_id = (card_slot2?.try_eject() || card_slot?.try_eject())
	if(removed_id)
		if(ishuman(loc))
			var/mob/living/carbon/human/human_wearer = loc
			if(human_wearer.wear_id == src)
				human_wearer.sec_hud_set_ID()
		update_slot_icon()
		update_appearance()

		return removed_id

	return ..()

/obj/item/modular_computer/proc/print_text(text_to_print, paper_title = "")
	if(!stored_paper)
		return FALSE

	var/obj/item/paper/printed_paper = new /obj/item/paper(drop_location())
	printed_paper.add_raw_text(text_to_print)
	if(paper_title)
		printed_paper.name = paper_title
	printed_paper.update_appearance()
	stored_paper--
	return TRUE

/obj/item/modular_computer/InsertID(obj/item/inserting_item)
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]

	if(!(card_slot || card_slot2))
		return FALSE

	var/obj/item/card/inserting_id = inserting_item.GetID()
	if(!inserting_id)
		return FALSE

	if((card_slot?.try_insert(inserting_id)) || (card_slot2?.try_insert(inserting_id)))
		if(ishuman(loc))
			var/mob/living/carbon/human/human_wearer = loc
			if(human_wearer.wear_id == src)
				human_wearer.sec_hud_set_ID()
		update_appearance()
		update_slot_icon()

	return TRUE

/obj/item/modular_computer/MouseDrop(obj/over_object, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /atom/movable/screen)) && usr.canUseTopic(src, be_close = TRUE))
		return attack_self(M)
	return ..()

/obj/item/modular_computer/attack_ai(mob/user)
	return attack_self(user)

/obj/item/modular_computer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(enabled)
		ui_interact(user)
	else if(isAdminGhostAI(user))
		var/response = tgui_alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", list("Yes", "No"))
		if(response == "Yes")
			turn_on(user)

/obj/item/modular_computer/emag_act(mob/user)
	if(!enabled)
		to_chat(user, span_warning("You'd need to turn the [src] on first."))
		return FALSE
	obj_flags |= EMAGGED //Mostly for consistancy purposes; the programs will do their own emag handling
	var/newemag = FALSE
	for(var/datum/computer_file/program/app in stored_files)
		if(!istype(app))
			continue
		if(app.run_emag())
			newemag = TRUE
	if(newemag)
		to_chat(user, span_notice("You swipe \the [src]. A console window momentarily fills the screen, with white text rapidly scrolling past."))
		return TRUE
	to_chat(user, span_notice("You swipe \the [src]. A console window fills the screen, but it quickly closes itself after only a few lines are written to it."))
	return FALSE

/obj/item/modular_computer/examine(mob/user)
	. = ..()
	var/healthpercent = round((atom_integrity/max_integrity) * 100, 1)
	switch(healthpercent)
		if(50 to 99)
			. += span_info("It looks slightly damaged.")
		if(25 to 50)
			. += span_info("It appears heavily damaged.")
		if(0 to 25)
			. += span_warning("It's falling apart!")

	if(long_ranged)
		. += "It is upgraded with an experimental long-ranged network capabilities, picking up NTNet frequencies while further away."
	. += span_notice("It has [max_capacity] GQ of storage capacity.")

	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]
	var/multiple_slots = istype(card_slot) && istype(card_slot2)
	if(card_slot)
		if(card_slot.stored_card || card_slot2?.stored_card)
			var/obj/item/card/id/first_ID = card_slot?.stored_card
			var/obj/item/card/id/second_ID = card_slot2?.stored_card
			var/multiple_cards = (first_ID && second_ID)
			if(Adjacent(user))
				. += "It has [multiple_slots ? "two slots" : "a slot"] for identification cards installed[multiple_cards ? " which contain [first_ID] and [second_ID]" : ", one of which contains [first_ID || second_ID]"]."
			else
				. += "It has [multiple_slots ? "two slots" : "a slot"] for identification cards installed, [multiple_cards ? "both of which appear" : "and one of them appears"] to be occupied."
			. += span_info("Alt-click [src] to eject the identification card[multiple_cards ? "s":""].")
		else
			. += "It has [multiple_slots ? "two slots" : "a slot"] installed for identification cards."

/obj/item/modular_computer/examine_more(mob/user)
	. = ..()
	. += "Storage capacity: [used_capacity]/[max_capacity]GQ"

	for(var/datum/computer_file/app_examine as anything in stored_files)
		if(app_examine.on_examine(src, user))
			. += app_examine.on_examine(src, user)

	if(Adjacent(user))
		. += span_notice("Paper level: [stored_paper] / [max_paper].")

/obj/item/modular_computer/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	var/obj/item/computer_hardware/card_slot/card_slot2 = all_components[MC_CARD2]

	if(card_slot?.stored_card || card_slot2?.stored_card) // IDs get removed first before pAIs
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove ID"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(inserted_pai)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove pAI"
		. = CONTEXTUAL_SCREENTIP_SET

	if(inserted_disk)
		context[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB] = "Remove SSD"
		. = CONTEXTUAL_SCREENTIP_SET

	return . || NONE

/obj/item/modular_computer/update_icon_state()
	if(!bypass_state)
		icon_state = enabled ? icon_state_powered : icon_state_unpowered
	return ..()

/obj/item/modular_computer/update_overlays()
	. = ..()
	var/init_icon = initial(icon)

	if(!init_icon)
		return
	if(!display_overlays)
		return

	if(enabled)
		. += active_program ? mutable_appearance(init_icon, active_program.program_icon_state) : mutable_appearance(init_icon, icon_state_menu)
	if(atom_integrity <= integrity_failure * max_integrity)
		. += mutable_appearance(init_icon, "bsod")
		. += mutable_appearance(init_icon, "broken")


// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/item/modular_computer/interact(mob/user)
	if(enabled)
		ui_interact(user)
	else
		turn_on(user)

/obj/item/modular_computer/CtrlShiftClick(mob/user)
	. = ..()
	if(.)
		return
	if(!inserted_disk)
		return
	user.put_in_hands(inserted_disk)
	inserted_disk = null
	playsound(src, 'sound/machines/card_slide.ogg', 50)

/obj/item/modular_computer/proc/turn_on(mob/user, open_ui = TRUE)
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(atom_integrity <= integrity_failure * max_integrity)
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [src], but it responds with an error code. It must be damaged."))
		else
			to_chat(user, span_warning("You press the power button, but the computer fails to boot up, displaying variety of errors before shutting down again."))
		return FALSE

	if(use_power()) // use_power() checks if the PC is powered
		if(issynth)
			to_chat(user, span_notice("You send an activation signal to \the [src], turning it on."))
		else
			to_chat(user, span_notice("You press the power button and start up \the [src]."))
		if(looping_sound)
			soundloop.start()
		enabled = TRUE
		update_appearance()
		if(open_ui)
			ui_interact(user)
		return TRUE
	else // Unpowered
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [src] but it does not respond."))
		else
			to_chat(user, span_warning("You press the power button but \the [src] does not respond."))
		return FALSE

// Process currently calls handle_power(), may be expanded in future if more things are added.
/obj/item/modular_computer/process(delta_time)
	if(!enabled) // The computer is turned off
		last_power_usage = 0
		return

	if(atom_integrity <= integrity_failure * max_integrity)
		shutdown_computer()
		return

	if(active_program && active_program.requires_ntnet && !get_ntnet_status(active_program.requires_ntnet_feature))
		active_program.event_networkfailure(FALSE) // Active program requires NTNet to run but we've just lost connection. Crash.

	for(var/datum/computer_file/program/idle_programs as anything in idle_threads)
		if(idle_programs.program_state == PROGRAM_STATE_KILLED)
			idle_threads.Remove(idle_programs)
			continue
		idle_programs.process_tick(delta_time)
		idle_programs.ntnet_status = get_ntnet_status(idle_programs.requires_ntnet_feature)
		if(idle_programs.requires_ntnet && !idle_programs.ntnet_status)
			idle_programs.event_networkfailure(TRUE)

	if(active_program)
		if(active_program.program_state == PROGRAM_STATE_KILLED)
			active_program = null
		else
			active_program.process_tick(delta_time)
			active_program.ntnet_status = get_ntnet_status()

	handle_power(delta_time) // Handles all computer power interaction
	//check_update_ui_need()

/**
 * Displays notification text alongside a soundbeep when requested to by a program.
 *
 * After checking that the requesting program is allowed to send an alert, creates
 * a visible message of the requested text alongside a soundbeep. This proc adds
 * text to indicate that the message is coming from this device and the program
 * on it, so the supplied text should be the exact message and ending punctuation.
 *
 * Arguments:
 * The program calling this proc.
 * The message that the program wishes to display.
 */
/obj/item/modular_computer/proc/alert_call(datum/computer_file/program/caller, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!caller || !caller.alert_able || caller.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return FALSE
	playsound(src, sound, 50, TRUE)
	visible_message(span_notice("[icon2html(src)] [span_notice("The [src] displays a [caller.filedesc] notification: [alerttext]")]"))

/obj/item/modular_computer/proc/ring(ringtone) // bring bring
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		playsound(src, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, TRUE)
	else
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
	visible_message("*[ringtone]*")

/obj/item/modular_computer/proc/send_sound()
	playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)

// Function used by NanoUI's to obtain data for header. All relevant entries begin with "PC_"
/obj/item/modular_computer/proc/get_header_data()
	var/list/data = list()

	data["PC_device_theme"] = device_theme

	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]

	data["PC_showbatteryicon"] = !!battery_module
	if(battery_module && battery_module.battery)
		switch(battery_module.battery.percent())
			if(80 to 200) // 100 should be maximal but just in case..
				data["PC_batteryicon"] = "batt_100.gif"
			if(60 to 80)
				data["PC_batteryicon"] = "batt_80.gif"
			if(40 to 60)
				data["PC_batteryicon"] = "batt_60.gif"
			if(20 to 40)
				data["PC_batteryicon"] = "batt_40.gif"
			if(5 to 20)
				data["PC_batteryicon"] = "batt_20.gif"
			else
				data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "[round(battery_module.battery.percent())]%"
	else
		data["PC_batteryicon"] = "batt_5.gif"
		data["PC_batterypercent"] = "N/C"

	switch(get_ntnet_status())
		if(NTNET_NO_SIGNAL)
			data["PC_ntneticon"] = "sig_none.gif"
		if(NTNET_LOW_SIGNAL)
			data["PC_ntneticon"] = "sig_low.gif"
		if(NTNET_GOOD_SIGNAL)
			data["PC_ntneticon"] = "sig_high.gif"
		if(NTNET_ETHERNET_SIGNAL)
			data["PC_ntneticon"] = "sig_lan.gif"

	if(length(idle_threads))
		var/list/program_headers = list()
		for(var/datum/computer_file/program/idle_programs as anything in idle_threads)
			if(!idle_programs.ui_header)
				continue
			program_headers.Add(list(list("icon" = idle_programs.ui_header)))

		data["PC_programheaders"] = program_headers

	data["PC_stationtime"] = station_time_timestamp()
	data["PC_stationdate"] = "[time2text(world.realtime, "DDD, Month DD")], [GLOB.year_integer+540]"
	data["PC_showexitprogram"] = !!active_program // Hides "Exit Program" button on mainscreen
	return data

///Wipes the computer's current program. Doesn't handle any of the niceties around doing this
/obj/item/modular_computer/proc/wipe_program(forced)
	if(!active_program)
		return
	active_program.kill_program(forced)
	active_program = null

// Relays kill program request to currently active program. Use this to quit current program.
/obj/item/modular_computer/proc/kill_program(forced = FALSE)
	wipe_program(forced)
	var/mob/user = usr
	if(user && istype(user))
		//Here to prevent programs sleeping in destroy
		INVOKE_ASYNC(src, /datum/proc/ui_interact, user) // Re-open the UI on this computer. It should show the main screen now.
	update_appearance()

/obj/item/modular_computer/proc/open_program(mob/user, datum/computer_file/program/program)
	if(program.computer != src)
		CRASH("tried to open program that does not belong to this computer")

	if(!program || !istype(program)) // Program not found or it's not executable program.
		to_chat(user, span_danger("\The [src]'s screen shows \"I/O ERROR - Unable to run program\" warning."))
		return FALSE

	// The program is already running. Resume it.
	if(program in idle_threads)
		program.program_state = PROGRAM_STATE_ACTIVE
		active_program = program
		program.alert_pending = FALSE
		idle_threads.Remove(program)
		update_appearance()
		updateUsrDialog()
		return TRUE

	if(!program.is_supported_by_hardware(hardware_flag, 1, user))
		return FALSE

	if(idle_threads.len > max_idle_programs)
		to_chat(user, span_danger("\The [src] displays a \"Maximal CPU load reached. Unable to run another program.\" error."))
		return FALSE

	if(program.requires_ntnet && !get_ntnet_status(program.requires_ntnet_feature)) // The program requires NTNet connection, but we are not connected to NTNet.
		to_chat(user, span_danger("\The [src]'s screen shows \"Unable to connect to NTNet. Please retry. If problem persists contact your system administrator.\" warning."))
		return FALSE

	if(!program.on_start(user))
		return FALSE

	active_program = program
	program.alert_pending = FALSE
	update_appearance()
	updateUsrDialog()
	return TRUE

// Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/obj/item/modular_computer/proc/get_ntnet_status(specific_action = 0)
	if(!SSnetworks.station_network || !SSnetworks.station_network.check_function(specific_action)) // NTNet is down and we are not connected via wired connection. No signal.
		return NTNET_NO_SIGNAL

	// computers are connected through ethernet
	if(hardware_flag & PROGRAM_CONSOLE)
		return NTNET_ETHERNET_SIGNAL

	var/turf/current_turf = get_turf(src)
	if(!current_turf || !istype(current_turf))
		return NTNET_NO_SIGNAL
	if(is_station_level(current_turf.z))
		if(hardware_flag & PROGRAM_LAPTOP) //laptops can connect to ethernet but they have to be on station for that
			return NTNET_ETHERNET_SIGNAL
		return NTNET_GOOD_SIGNAL
	else if(is_mining_level(current_turf.z))
		return NTNET_LOW_SIGNAL
	else if(long_ranged)
		return NTNET_LOW_SIGNAL
	return NTNET_NO_SIGNAL

/obj/item/modular_computer/proc/add_log(text)
	if(!get_ntnet_status())
		return FALSE

	return SSnetworks.add_log(text, network_id)

/obj/item/modular_computer/proc/shutdown_computer(loud = 1)
	kill_program(forced = TRUE)
	for(var/datum/computer_file/program/P in idle_threads)
		P.kill_program(forced = TRUE)
	if(looping_sound)
		soundloop.stop()
	if(physical && loud)
		physical.visible_message(span_notice("\The [src] shuts down."))
	enabled = FALSE
	update_appearance()

/obj/item/modular_computer/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_computer_light))
		toggle_flashlight()
		return

	return ..()

/**
 * Toggles the computer's flashlight, if it has one.
 *
 * Called from ui_act(), does as the name implies.
 * It is separated from ui_act() to be overwritten as needed.
*/
/obj/item/modular_computer/proc/toggle_flashlight()
	if(!has_light)
		return FALSE
	set_light_on(!light_on)
	update_appearance()
	update_action_buttons(force = TRUE) //force it because we added an overlay, not changed its icon
	return TRUE

/**
 * Sets the computer's light color, if it has a light.
 *
 * Called from ui_act(), this proc takes a color string and applies it.
 * It is separated from ui_act() to be overwritten as needed.
 * Arguments:
 ** color is the string that holds the color value that we should use. Proc auto-fails if this is null.
*/
/obj/item/modular_computer/proc/set_flashlight_color(color)
	if(!has_light || !color)
		return FALSE
	comp_light_color = color
	set_light_color(color)
	return TRUE

/obj/item/modular_computer/proc/UpdateDisplay()
	if(!saved_identification && !saved_job)
		name = initial(name)
		return
	name = "[saved_identification] ([saved_job])"

/obj/item/modular_computer/attackby(obj/item/attacking_item, mob/user, params)
	// Check for ID first
	if(isidcard(attacking_item) && InsertID(attacking_item))
		return

	// Check for cash next
	var/obj/item/computer_hardware/card_slot/card_slot = all_components[MC_CARD]
	if(card_slot && iscash(attacking_item))
		var/obj/item/card/id/inserted_id = card_slot.GetID()
		if(inserted_id)
			inserted_id.attackby(attacking_item, user) // If we do, try and put that attacking object in
			return

	// Inserting a pAI
	if(istype(attacking_item, /obj/item/pai_card) && !inserted_pai)
		if(!user.transferItemToLoc(attacking_item, src))
			return
		inserted_pai = attacking_item
		balloon_alert(user, "inserted pai")
		return

	// Check if any Applications need it
	for(var/datum/computer_file/item_holding_app as anything in stored_files)
		if(item_holding_app.try_insert(attacking_item, user))
			return

	if(istype(attacking_item, /obj/item/paper))
		if(stored_paper >= max_paper)
			balloon_alert(user, "no more room!")
			return
		if(!user.temporarilyRemoveItemFromInventory(attacking_item))
			return FALSE
		balloon_alert(user, "inserted paper")
		qdel(attacking_item)
		stored_paper++
		return
	if(istype(attacking_item, /obj/item/paper_bin))
		var/obj/item/paper_bin/bin = attacking_item
		if(bin.total_paper <= 0)
			balloon_alert(user, "empty bin!")
			return
		var/papers_added //just to keep track
		while((bin.total_paper > 0) && (stored_paper < max_paper))
			papers_added++
			stored_paper++
			bin.remove_paper()
		if(!papers_added)
			return
		balloon_alert(user, "inserted paper")
		to_chat(user, span_notice("Added in [papers_added] new sheets. You now have [stored_paper] / [max_paper] printing paper stored."))
		bin.update_appearance()
		return


	// Insert items into the components
	for(var/h in all_components)
		var/obj/item/computer_hardware/H = all_components[h]
		if(H.try_insert(attacking_item, user))
			return

	// Insert a data disk
	if(istype(attacking_item, /obj/item/computer_disk))
		if(!user.transferItemToLoc(attacking_item, src))
			return
		inserted_disk = attacking_item
		playsound(src, 'sound/machines/card_slide.ogg', 50)
		return

	// Insert new hardware
	if(istype(attacking_item, /obj/item/computer_hardware))
		if(install_component(attacking_item, user))
			playsound(src, 'sound/machines/card_slide.ogg', 50)
			return

	return ..()

/obj/item/modular_computer/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	if((resistance_flags & INDESTRUCTIBLE) || (flags_1 & NODECONSTRUCT_1))
		return
	if(!length(all_components))
		balloon_alert(user, "no components installed!")
		return
	var/list/component_names = list()
	for(var/h in all_components)
		var/obj/item/computer_hardware/H = all_components[h]
		component_names.Add(H.name)

	var/choice = tgui_input_list(user, "Component to uninstall", "Computer maintenance", sort_list(component_names))
	if(isnull(choice))
		return
	if(!Adjacent(user))
		return

	var/obj/item/computer_hardware/H = find_hardware_by_name(choice)
	if(!H)
		return TOOL_ACT_TOOLTYPE_SUCCESS

	tool.play_tool_sound(src, user, 20, volume=20)
	uninstall_component(H, user)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/modular_computer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(length(all_components))
		balloon_alert(user, "remove the other components!")
		return TOOL_ACT_TOOLTYPE_SUCCESS
	tool.play_tool_sound(src, user, 20, volume=20)
	new /obj/item/stack/sheet/iron(get_turf(loc), steel_sheet_cost)
	user.balloon_alert(user, "disassembled")
	relay_qdel()
	qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS


/obj/item/modular_computer/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(atom_integrity == max_integrity)
		to_chat(user, span_warning("\The [src] does not require repairs."))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	if(!tool.tool_start_check(user, amount=1))
		return TOOL_ACT_TOOLTYPE_SUCCESS

	to_chat(user, span_notice("You begin repairing damage to \the [src]..."))
	if(!tool.use_tool(src, user, 20, volume=50, amount=1))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	atom_integrity = max_integrity
	to_chat(user, span_notice("You repair \the [src]."))
	update_appearance()
	return TOOL_ACT_TOOLTYPE_SUCCESS


// Used by processor to relay qdel() to machinery type.
/obj/item/modular_computer/proc/relay_qdel()
	return

// Perform adjacency checks on our physical counterpart, if any.
/obj/item/modular_computer/Adjacent(atom/neighbor)
	if(physical && physical != src)
		return physical.Adjacent(neighbor)
	return ..()

/obj/item/modular_computer/proc/Add_Messenger()
	GLOB.TabletMessengers += src

/obj/item/modular_computer/proc/Remove_Messenger()
	GLOB.TabletMessengers -= src
