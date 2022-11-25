/datum/component/modular_computer_host

	dupe_mode = COMPONENT_DUPE_UNIQUE
	dupe_type = /datum/component/modular_computer_host // TODO: planning on adding subtypes for pdas maybe

	///The ID currently stored in the computer.
	var/obj/item/card/id/computer_id_slot
	///The disk in this PDA. If set, this will be inserted on Initialize.
	var/obj/item/computer_disk/inserted_disk
	///The power cell the computer uses to run on.
	var/obj/item/stock_parts/cell/internal_cell = /obj/item/stock_parts/cell
	///A pAI currently loaded into the modular computer.
	var/obj/item/pai_card/inserted_pai

	///The amount of storage space the computer starts with.
	var/max_capacity = 128
	///The amount of storage space we've got filled
	var/used_capacity = 0
	///List of stored files on this drive. Use `store_file` and `remove_file` instead of modifying directly!
	var/list/datum/computer_file/stored_files = list()

	///Non-static list of programs the computer should recieve on Initialize.
	var/list/datum/computer_file/starting_programs = list()
	///Static list of default programs that come with ALL computers, here so computers don't have to repeat this.
	var/static/list/datum/computer_file/default_programs = list(
		/datum/computer_file/program/computerconfig,
		/datum/computer_file/program/ntnetdownload,
		/datum/computer_file/program/filemanager,
	)

	///The program currently active on the tablet.
	var/datum/computer_file/program/active_program
	///Idle programs on background. They still receive process calls but can't be interacted with.
	var/list/idle_threads = list()
	/// Amount of programs that can be ran at once
	var/max_idle_programs = 2

	///Flag of the type of device the modular computer is, deciding what types of apps it can run.
	var/hardware_flag = NONE
//	Options: PROGRAM_ALL | PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET

	///Whether the icon state should be bypassed entirely, used for PDAs.
	var/bypass_state = FALSE
	///The theme, used for the main menu and file browser apps.
	var/device_theme = "ntos"

	///Bool on whether the computer is currently active or not.
	var/powered_on = FALSE

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
	///Power usage when the computer is open (screen is active) and can be interacted with.
	var/base_active_power_usage = 75
	///Power usage when the computer is idle and screen is off (currently only applies to laptops)
	var/base_idle_power_usage = 5

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console & Tablet)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	///The full name of the stored ID card's identity. These vars should probably be on the PDA.
	var/saved_identification
	///The job title of the stored ID card
	var/saved_job

	///The 'computer' itself, as an obj. Primarily used for Adjacent() and UI visibility checks, especially for computers.
	var/atom/physical
	///Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/steel_sheet_cost = 5

	///If hit by a Clown virus, remaining honks left until it stops.
	var/honkvirus_amount = 0
	///Whether the PDA can still use NTNet while out of NTNet's reach.
	var/ntnet_bypass_rangelimit = FALSE

	///The amount of paper currently stored in the PDA
	var/stored_paper = 10
	///The max amount of paper that can be held at once.
	var/max_paper = 30

/datum/component/modular_computer_host/Initialize(...)
	. = ..()
	physical = holder

	if(inserted_disk)
		inserted_disk = new inserted_disk(src)
	if(internal_cell)
		internal_cell = new internal_cell(src)

	add_messenger()
	install_default_programs()
	register_signals(physical)

/datum/component/modular_computer_host/Destroy(force, ...)
	. = ..()
	wipe_program(forced = TRUE)
	for(var/datum/computer_file/program/idle as anything in idle_threads)
		idle.kill_program(TRUE)
	//Some components will actually try and interact with this, so let's do it later
	QDEL_NULL(soundloop)
	QDEL_LIST(stored_files)
	remove_messenger()

	if(istype(inserted_disk))
		QDEL_NULL(inserted_disk)
	if(istype(inserted_pai))
		QDEL_NULL(inserted_pai)
	if(computer_id_slot)
		QDEL_NULL(computer_id_slot)

// Process currently calls handle_power(), may be expanded in future if more things are added.
/datum/component/modular_computer_host/process(delta_time)
	if(!powered_on) // The computer is turned off
		last_power_usage = 0
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

/datum/component/modular_computer_host/proc/get_cell()
	return internal_cell

/datum/component/modular_computer_host/proc/install_default_programs()
	SHOULD_CALL_PARENT(FALSE)
	for(var/programs in default_programs + starting_programs)
		var/datum/computer_file/program/program_type = new programs
		store_file(program_type)

// Returns 0 for No Signal, 1 for Low Signal and 2 for Good Signal. 3 is for wired connection (always-on)
/datum/component/modular_computer_host/proc/get_ntnet_status(specific_action = 0)
	if(!SSnetworks.station_network || !SSnetworks.station_network.check_function(specific_action)) // NTNet is down and we are not connected via wired connection. No signal.
		return NTNET_NO_SIGNAL

	// computers are connected through ethernet
	if(hardware_flag & PROGRAM_CONSOLE)
		return NTNET_ETHERNET_SIGNAL

	var/turf/current_turf = get_turf(physical)
	if(!current_turf || !istype(current_turf))
		return NTNET_NO_SIGNAL
	if(is_station_level(current_turf.z))
		if(hardware_flag & PROGRAM_LAPTOP) //laptops can connect to ethernet but they have to be on station for that
			return NTNET_ETHERNET_SIGNAL
		return NTNET_GOOD_SIGNAL
	else if(is_mining_level(current_turf.z))
		return NTNET_LOW_SIGNAL
	else if(ntnet_bypass_rangelimit)
		return NTNET_LOW_SIGNAL
	return NTNET_NO_SIGNAL

///Wipes the computer's current program. Doesn't handle any of the niceties around doing this
/datum/component/modular_computer_host/proc/wipe_program(forced)
	if(!active_program)
		return
	active_program.kill_program(forced)
	active_program = null

// Relays kill program request to currently active program. Use this to quit current program.
/datum/component/modular_computer_host/proc/kill_program(forced = FALSE)
	wipe_program(forced)
	var/mob/user = usr
	if(user && istype(user))
		//Here to prevent programs sleeping in destroy
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user) // Re-open the UI on this computer. It should show the main screen now.

/datum/component/modular_computer_host/proc/open_program(mob/user, datum/computer_file/program/program)
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

	return TRUE

/datum/component/modular_computer_host/proc/nonfunctional()
	return physical.atom_integrity <= physical.integrity_failure * physical.max_integrity

/datum/component/modular_computer_host/proc/turn_on(mob/user, open_ui = TRUE)
	var/issynth = issilicon(user) // Robots and AIs get different activation messages.
	if(nonfunctional())
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
		powered_on = TRUE
		if(open_ui)
			ui_interact(user)
		return TRUE
	else // Unpowered
		if(issynth)
			to_chat(user, span_warning("You send an activation signal to \the [src] but it does not respond."))
		else
			to_chat(user, span_warning("You press the power button but \the [src] does not respond."))
		return FALSE

/datum/component/modular_computer_host/proc/shutdown_computer(loud = 1)
	kill_program(forced = TRUE)
	for(var/datum/computer_file/program/P in idle_threads)
		P.kill_program(forced = TRUE)
	if(looping_sound)
		soundloop.stop()
	if(physical && loud)
		physical.visible_message(span_notice("\The [src] shuts down."))
	powered_on = FALSE

/datum/component/modular_computer_host/proc/register_signals(atom/holder)
	RegisterSignal(holder, COMSIG_ATOM_EMAG_ACT, PROC_REF(do_emag))
	RegisterSignal(holder, COMSIG_ATOM_BREAK, PROC_REF(do_integrity_failure))
	RegisterSignal(holder, COMSIG_PARENT_ATTACKBY, PROC_REF(do_attackby))

/datum/component/modular_computer_host/proc/add_messenger()
	GLOB.TabletMessengers += src

/datum/component/modular_computer_host/proc/remove_messenger()
	GLOB.TabletMessengers -= src

/datum/component/modular_computer_host/proc/do_integrity_failure()
	shutdown_computer()

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
/datum/component/modular_computer_host/proc/alert_call(datum/computer_file/program/caller, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!caller || !caller.alert_able || caller.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return FALSE
	playsound(src, sound, 50, TRUE)
	visible_message(span_notice("[icon2html(src)] [span_notice("The [src] displays a [caller.filedesc] notification: [alerttext]")]"))

/datum/component/modular_computer_host/proc/ring(ringtone) // bring bring
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		playsound(src, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 50, TRUE)
	else
		playsound(src, 'sound/machines/twobeep_high.ogg', 50, TRUE)
	visible_message("*[ringtone]*")

/datum/component/modular_computer_host/proc/send_sound()
	playsound(src, 'sound/machines/terminal_success.ogg', 15, TRUE)

/datum/component/modular_computer_host/proc/set_flashlight_color(color)
	if(!has_light || !color)
		return FALSE
	comp_light_color = color
	set_light_color(color)
	return TRUE

/**
 * InsertID
 * Attempt to insert the ID in either card slot.
 * Args:
 * inserting_id - the ID being inserted
 * user - The person inserting the ID
 */
/datum/component/modular_computer_host/InsertID(obj/item/card/inserting_id, mob/user)
	//all slots taken
	if(cpu.computer_id_slot)
		return FALSE

	cpu.computer_id_slot = inserting_id
	if(user)
		if(!user.transferItemToLoc(inserting_id, src))
			return FALSE
		to_chat(user, span_notice("You insert \the [inserting_id] into the card slot."))
	else
		inserting_id.forceMove(src)

	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		if(human_wearer.wear_id == src)
			human_wearer.sec_hud_set_ID()
	update_appearance()
	update_slot_icon()
	return TRUE

/**
 * Removes the ID card from the computer, and puts it in loc's hand if it's a mob
 * Args:
 * user - The mob trying to remove the ID, if there is one
 */
/datum/component/modular_computer_host/RemoveID(mob/user)
	if(!computer_id_slot)
		return ..()

	if(user)
		if(!issilicon(user) && in_range(src, user))
			user.put_in_hands(computer_id_slot)
		balloon_alert(user, "removed ID")
		to_chat(user, span_notice("You remove the card from the card slot."))
	else
		computer_id_slot.forceMove(drop_location())

	computer_id_slot = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

	if(ishuman(loc))
		var/mob/living/carbon/human/human_wearer = loc
		if(human_wearer.wear_id == src)
			human_wearer.sec_hud_set_ID()
	update_slot_icon()
	update_appearance()
	return TRUE

/datum/component/modular_computer_host/proc/do_emag(mob/user, obj/item/card/emag/card)
	var/newemag = FALSE
	for(var/datum/computer_file/program/app in stored_files)
		if(!istype(app))
			continue
		if(app.run_emag())
			newemag = TRUE
	if(newemag)
		to_chat(user, span_notice("You swipe \the [src]. A console window momentarily fills the screen, with white text rapidly scrolling past."))
		return
	to_chat(user, span_notice("You swipe \the [src]. A console window fills the screen, but it quickly closes itself after only a few lines are written to it."))

/datum/component/modular_computer_host/proc/do_attackby(obj/item/attacking_item, mob/user, params)
	// Check for ID first
	if(isidcard(attacking_item) && InsertID(attacking_item, user))
		return

	// Check for cash next
	if(computer_id_slot && iscash(attacking_item))
		var/obj/item/card/id/inserted_id = computer_id_slot.GetID()
		if(inserted_id)
			inserted_id.attackby(attacking_item, user) // If we do, try and put that attacking object in
			return

	// Inserting a pAI
	if(istype(attacking_item, /obj/item/pai_card) && !inserted_pai)
		if(!user.transferItemToLoc(attacking_item, src))
			return
		inserted_pai = attacking_item
		physical.balloon_alert(user, "inserted pai")
		return

	if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(ismachinery(physical))
			return
		if(internal_cell)
			to_chat(user, span_warning("You try to connect \the [attacking_item] to \the [src], but its connectors are occupied."))
			return
		if(user && !user.transferItemToLoc(attacking_item, physical))
			return
		internal_cell = attacking_item
		to_chat(user, span_notice("You plug \the [attacking_item] to \the [src]."))
		return

	// Check if any Applications need it
	for(var/datum/computer_file/item_holding_app as anything in stored_files)
		if(item_holding_app.application_attackby(attacking_item, user))
			return

	if(istype(attacking_item, /obj/item/paper))
		if(stored_paper >= max_paper)
			physical.balloon_alert(user, "no more room!")
			return
		if(!user.temporarilyRemoveItemFromInventory(attacking_item))
			return FALSE
		physical.balloon_alert(user, "inserted paper")
		qdel(attacking_item)
		stored_paper++
		return
	if(istype(attacking_item, /obj/item/paper_bin))
		var/obj/item/paper_bin/bin = attacking_item
		if(bin.total_paper <= 0)
			physical.balloon_alert(user, "empty bin!")
			return
		var/papers_added //just to keep track
		while((bin.total_paper > 0) && (stored_paper < max_paper))
			papers_added++
			stored_paper++
			bin.remove_paper()
		if(!papers_added)
			return
		physical.balloon_alert(user, "inserted paper")
		to_chat(user, span_notice("Added in [papers_added] new sheets. You now have [stored_paper] / [max_paper] printing paper stored."))
		bin.update_appearance()
		return

	// Insert a data disk
	if(istype(attacking_item, /obj/item/computer_disk))
		if(!user.transferItemToLoc(attacking_item, src))
			return
		inserted_disk = attacking_item
		playsound(src, 'sound/machines/card_slide.ogg', 50)
		return

/datum/component/modular_computer_host/proc/do_preattack_secondary()
	if(active_program?.tap(A, user, params))
		user.do_attack_animation(A) //Emulate this animation since we kill the attack in three lines
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1) //Likewise for the tap sound
		addtimer(CALLBACK(src, PROC_REF(play_ping)), 0.5 SECONDS, TIMER_UNIQUE) //Slightly delayed ping to indicate success
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return SECONDARY_ATTACK_CONTINUE_CHAIN

// On-click handling. Turns on the computer if it's off and opens the GUI.
/datum/component/modular_computer_host/proc/do_interact(mob/user)
	if(powered_on)
		ui_interact(user)
	else
		turn_on(user)
