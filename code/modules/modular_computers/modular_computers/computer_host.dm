/**
 * `/datum/modular_computer_host`, the brains and logic of NtOS
 *
 * Written similar to a component, except that you have to explicitly implement it in your `/obj`
 * Woe be upon ye, for there lie only shitcode beyond this point.
 *
 * If you decide to implement this on your datum,
 * THEN MAKE SURE THE SIGNALS THIS DATUM REGISTERS GET CALLED ON YOUR ATOM. I AM SERIOUS.
 * Else I will find you. Then I will kill you.
 * You think I am joking? Why not try me?
 */
/datum/modular_computer_host
	///Our object that holds us.
	var/atom/physical
	///The type this host is valid on. Really only used for error proofing.
	var/valid_on = null

	///The ID currently stored in the computer.
	var/obj/item/card/id/inserted_id
	///The disk in this PDA. If set, this will be inserted on Initialize.
	var/obj/item/computer_disk/inserted_disk
	///The power cell the computer uses to run on.
	var/obj/item/stock_parts/cell/internal_cell
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
	var/list/datum/computer_file/program/idle_threads = list()
	/// Amount of programs that can be ran at once
	var/max_idle_programs = 2

	///Flag of the type of device the modular computer is, deciding what types of apps it can run.
	var/hardware_flag = NONE
//	Options: PROGRAM_ALL | PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET

	///The theme, used for the main menu and file browser apps.
	var/device_theme = "ntos"

	///Bool on whether the computer is currently active or not.
	var/powered_on = FALSE
	///Is our object broken?
	var/nonfunctional

	///Looping sound for when the computer is on.
	var/datum/looping_sound/computer/soundloop
	///Whether or not this modular computer uses the looping sound
	var/looping_sound = FALSE

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
	var/atom_icon = null

	///The full name of the stored ID card's identity. These vars should probably be on the PDA.
	var/saved_identification
	///The job title of the stored ID card
	var/saved_job

	///If hit by a Clown virus, remaining honks left until it stops.
	var/honkvirus_amount = 0
	///Whether the PDA can still use NTNet while out of NTNet's reach.
	var/ntnet_bypass_rangelimit = FALSE

	///The amount of paper currently stored in the PDA
	var/stored_paper = 10
	///The max amount of paper that can be held at once.
	var/max_paper = 30

	var/allow_chunky = FALSE

/datum/modular_computer_host/New(atom/holder, cell_type = /obj/item/stock_parts/cell, disk_type = null)
	if(isnull(valid_on))
		stack_trace("Instantiated abstract modular computer; Type: [type]")
		qdel(src)
		return

	if(!istype(holder, valid_on))
		stack_trace("Invalid modular computer holder; Expected: [valid_on], Got: [holder.type]")
		qdel(src)
		return

	physical = holder

	atom_icon = physical.icon

	if(disk_type)
		inserted_disk = new disk_type(physical)
	if(cell_type)
		internal_cell = new cell_type(physical)

	install_default_programs()

	register_signals()

	START_PROCESSING(SSmodular_computers, src)

/datum/modular_computer_host/Destroy(force, ...)
	wipe_program(forced = TRUE)
	for(var/datum/computer_file/program/idle as anything in idle_threads)
		idle.kill_program(TRUE)

	//Some components will actually try and interact with this, so let's do it later
	QDEL_NULL(soundloop)
	QDEL_LIST(stored_files)

	var/droploc = physical.drop_location()
	if(!force && droploc) // our internal stuff gets a chance to live
		// refs get cleared in do_exited
		internal_cell?.forceMove(droploc)
		inserted_id?.forceMove(droploc)
		inserted_disk?.forceMove(droploc)
		inserted_pai?.forceMove(droploc)
	else
		if(istype(internal_cell))
			QDEL_NULL(internal_cell)
		if(istype(inserted_disk))
			QDEL_NULL(inserted_disk)
		if(istype(inserted_pai))
			QDEL_NULL(inserted_pai)
		if(istype(inserted_id))
			QDEL_NULL(inserted_id)

	unregister_signals()

	STOP_PROCESSING(SSmodular_computers, src)

	physical = null

	return ..()

/datum/modular_computer_host/proc/register_signals()
	RegisterSignal(physical, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(do_attack_ghost))
	RegisterSignal(physical, COMSIG_ATOM_BREAK, PROC_REF(do_integrity_failure))
	RegisterSignal(physical, COMSIG_ATOM_EMAG_ACT, PROC_REF(do_emag))
	RegisterSignal(physical, COMSIG_ATOM_EXITED, PROC_REF(do_exited))
	RegisterSignal(physical, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(do_add_context))
	RegisterSignal(physical, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(do_screwdriver_act))
	RegisterSignal(physical, COMSIG_ATOM_UI_INTERACT, PROC_REF(do_interact))
	RegisterSignal(physical, COMSIG_ITEM_ATTACK_SELF, PROC_REF(do_attack_self))
	RegisterSignal(physical, COMSIG_CLICK_ALT, PROC_REF(do_altclick))
	RegisterSignal(physical, COMSIG_CLICK_CTRL_SHIFT, PROC_REF(do_ctrlshiftclick))
	RegisterSignal(physical, COMSIG_PARENT_ATTACKBY, PROC_REF(do_attackby))
	RegisterSignal(physical, COMSIG_PARENT_EXAMINE, PROC_REF(do_examine))
	RegisterSignal(physical, COMSIG_PARENT_EXAMINE_MORE, PROC_REF(do_examine_more))

/datum/modular_computer_host/proc/unregister_signals()
	UnregisterSignal(physical, list(
		COMSIG_ATOM_ATTACK_GHOST,
		COMSIG_ATOM_BREAK,
		COMSIG_ATOM_EMAG_ACT,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
		COMSIG_ATOM_UI_INTERACT,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_CLICK_ALT,
		COMSIG_CLICK_CTRL_SHIFT,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_PARENT_EXAMINE,
	))

// Process currently calls handle_power(), may be expanded in future if more things are added.
/datum/modular_computer_host/process(delta_time)
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

///Returns the reference to our internal cell, if we are allowed to have one in our context
/datum/modular_computer_host/proc/get_cell()
	return internal_cell

///Finds how hard it is to send a virus to this tablet, checking all programs downloaded.
/datum/modular_computer_host/proc/get_detomatix_difficulty()
	var/detomatix_difficulty

	for(var/datum/computer_file/program/downloaded_apps in stored_files)
		detomatix_difficulty += downloaded_apps.detomatix_resistance

	return detomatix_difficulty

///Sets up all our default starting programs, but not your starting programs. Install those manually.
/datum/modular_computer_host/proc/install_default_programs()
	SHOULD_CALL_PARENT(FALSE)
	for(var/programs in default_programs)
		var/datum/computer_file/program/program_type = new programs
		store_file(program_type)

/datum/modular_computer_host/proc/interact(mob/user)
	if(powered_on)
		ui_interact(user)
	else
		turn_on(user)

/datum/modular_computer_host/proc/do_emag(datum/source, mob/user, obj/item/card/emag/card)
	SIGNAL_HANDLER
	var/newemag = FALSE
	for(var/datum/computer_file/program/app in stored_files)
		if(app.run_emag())
			newemag = TRUE
	if(newemag)
		to_chat(user, span_notice("You swipe \the [physical]. A console window momentarily fills the screen, with white text rapidly scrolling past."))
		return
	to_chat(user, span_notice("You swipe \the [physical]. A console window fills the screen, but it quickly closes itself after only a few lines are written to it."))

/datum/modular_computer_host/proc/do_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER
	// Check for ID first
	if(isidcard(attacking_item) && insert_card(attacking_item, user))
		return COMPONENT_NO_AFTERATTACK

	// Check for cash next
	if(inserted_id && iscash(attacking_item))
		INVOKE_ASYNC(inserted_id, TYPE_PROC_REF(/atom, attackby), attacking_item, user) // If we do, try and put that attacking object in (cant sleep, so call asynchronously)
		return COMPONENT_NO_AFTERATTACK

	// Inserting a pAI
	if(istype(attacking_item, /obj/item/pai_card) && !inserted_pai)
		if(!user.transferItemToLoc(attacking_item, physical))
			return
		inserted_pai = attacking_item
		physical.balloon_alert(user, "inserted pai")
		return COMPONENT_NO_AFTERATTACK

	if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(ismachinery(physical))
			return
		if(internal_cell)
			to_chat(user, span_warning("You try to connect \the [attacking_item] to \the [physical], but its connectors are occupied."))
			return
		if(user && !user.transferItemToLoc(attacking_item, physical))
			return
		internal_cell = attacking_item
		to_chat(user, span_notice("You plug \the [attacking_item] to \the [physical]."))
		return

	// Check if any Applications need it
	for(var/datum/computer_file/item_holding_app as anything in stored_files)
		if(item_holding_app.application_attackby(attacking_item, user))
			return COMPONENT_NO_AFTERATTACK

	if(istype(attacking_item, /obj/item/paper))
		if(stored_paper >= max_paper)
			physical.balloon_alert(user, "no more room!")
			return COMPONENT_NO_AFTERATTACK
		if(!user.temporarilyRemoveItemFromInventory(attacking_item))
			return
		physical.balloon_alert(user, "inserted paper")
		qdel(attacking_item)
		stored_paper++
		return COMPONENT_NO_AFTERATTACK
	if(istype(attacking_item, /obj/item/paper_bin))
		var/obj/item/paper_bin/bin = attacking_item
		if(bin.total_paper <= 0)
			physical.balloon_alert(user, "empty bin!")
			return COMPONENT_NO_AFTERATTACK
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
		return COMPONENT_NO_AFTERATTACK

	// Insert a data disk
	if(istype(attacking_item, /obj/item/computer_disk))
		INVOKE_ASYNC(src, PROC_REF(insert_disk), user, attacking_item)
		return COMPONENT_NO_AFTERATTACK

// On-click handling. Turns on the computer if it's off and opens the GUI.
/datum/modular_computer_host/proc/do_interact(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(interact), user)

/datum/modular_computer_host/proc/do_altclick(datum/source, mob/user)
	SIGNAL_HANDLER
	if(issilicon(user))
		return

	if(!user.canUseTopic(physical, be_close = TRUE))
		return

	if(inserted_id)
		INVOKE_ASYNC(src, PROC_REF(remove_card), user)
		return COMPONENT_CANCEL_CLICK_ALT

	if(istype(inserted_pai)) // Remove pAI
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), inserted_pai)
		physical.balloon_alert(user, "removed pAI")
		inserted_pai = null
		return COMPONENT_CANCEL_CLICK_ALT

/datum/modular_computer_host/proc/do_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(isidcard(arrived))
		if(!isnull(inserted_id))
			CRASH("Attempted to insert card in occupied slot!")
		inserted_id = arrived
	else if(istype(arrived, /obj/item/computer_disk))
		if(!isnull(inserted_disk))
			CRASH("Attempted to insert disk in occupied slot!")
		inserted_disk = arrived
	else if(ispAI(arrived))
		if(!isnull(inserted_pai))
			CRASH("Attempted to insert pAI in occupied slot!")
		inserted_pai = arrived
	else if(istype(arrived, /obj/item/stock_parts/cell))
		if(!isnull(internal_cell))
			CRASH("Attempted to insert cell in occupied slot!")
		internal_cell = arrived

	relay_appearance_update(UPDATE_ICON)

/datum/modular_computer_host/proc/do_exited(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(internal_cell == gone)
		internal_cell = null
		if(powered_on && !use_power())
			turn_off()
	if(inserted_id == gone)
		inserted_id = null
		var/mob/living/carbon/human/human_wearer = get(physical, /mob/living/carbon/human)
		if(istype(human_wearer))
			human_wearer.sec_hud_set_ID()
	if(inserted_pai == gone)
		inserted_pai = null
	if(inserted_disk == gone)
		inserted_disk = null

	relay_appearance_update(UPDATE_ICON)

/datum/modular_computer_host/proc/do_examine(datum/source, mob/user, list/examines)
	SIGNAL_HANDLER
	if(ntnet_bypass_rangelimit)
		examines += "It is upgraded with an experimental long-ranged network capabilities, picking up NTNet frequencies while further away."
	examines += span_notice("It has [max_capacity] GQ of storage capacity.")

	if(inserted_id)
		if(physical.Adjacent(user))
			examines += "It has \the [inserted_id] card installed in its card slot."
		else
			examines += "Its identification card slot is currently occupied."
		examines += span_info("Alt-click [physical] to eject the identification card.")

/datum/modular_computer_host/proc/do_examine_more(datum/source, mob/user, list/examines)
	SIGNAL_HANDLER
	examines += "Storage capacity: [used_capacity]/[max_capacity]GQ"

	for(var/datum/computer_file/app_examine as anything in stored_files)
		var/examine = app_examine.on_examine(physical, user)
		if(examine)
			examines += examine

	if(physical.Adjacent(user))
		examines += span_notice("Paper level: [stored_paper] / [max_paper].")

/datum/modular_computer_host/proc/do_ctrlshiftclick(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!inserted_disk)
		return
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), inserted_disk)
	playsound(physical, 'sound/machines/card_slide.ogg', 50)

/datum/modular_computer_host/proc/do_attack_ghost(datum/source, mob/dead/observer/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(interact_ghost), user)

/datum/modular_computer_host/proc/interact_ghost(datum/source, mob/dead/observer/user)
	if(powered_on)
		ui_interact(user)
	else if(isAdminGhostAI(user))
		var/response = tgui_alert(user, "This computer is turned off. Would you like to turn it on?", "Admin Override", list("Yes", "No"))
		if(response == "Yes")
			turn_on(user)
			ui_interact(user)

/datum/modular_computer_host/proc/do_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(interact), user)

/datum/modular_computer_host/proc/do_add_context(atom/source, list/ctx, obj/item/item, mob/user)
	SIGNAL_HANDLER
	if(inserted_id) // ID get removed first before pAIs
		ctx[SCREENTIP_CONTEXT_ALT_LMB] += "Remove ID"
		. = CONTEXTUAL_SCREENTIP_SET
	else if(inserted_pai)
		ctx[SCREENTIP_CONTEXT_ALT_LMB] += "Remove pAI"
		. = CONTEXTUAL_SCREENTIP_SET
	if(inserted_disk)
		ctx[SCREENTIP_CONTEXT_CTRL_SHIFT_LMB] += "Remove SSD"
		. = CONTEXTUAL_SCREENTIP_SET

	return . || NONE

/datum/modular_computer_host/proc/do_integrity_failure(datum/source)
	SIGNAL_HANDLER
	turn_off()

/datum/modular_computer_host/proc/do_screwdriver_act(atom/source, mob/living/user, obj/item/tool, list/recipes)
	SIGNAL_HANDLER
	if(internal_cell)
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), internal_cell)
		return

/datum/modular_computer_host/proc/do_update_overlays(atom/source, list/new_overlays)
	SIGNAL_HANDLER
	if(powered_on && active_program)
		. += mutable_appearance(atom_icon, active_program.program_icon_state)
