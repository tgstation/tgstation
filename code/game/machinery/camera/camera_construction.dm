/obj/machinery/camera/welder_act(mob/living/user, obj/item/tool)
	switch(camera_construction_state)
		if(CAMERA_STATE_WRENCHED, CAMERA_STATE_WELDED)
			if(!tool.tool_start_check(user, amount = 1))
				return ITEM_INTERACT_BLOCKING
			user.balloon_alert_to_viewers("[camera_construction_state == CAMERA_STATE_WELDED ? "un" : null]welding...")
			audible_message(span_hear("You hear welding."))
			if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
				user.balloon_alert_to_viewers("stopped [camera_construction_state == CAMERA_STATE_WELDED ? "un" : null]welding!")
				return
			camera_construction_state = ((camera_construction_state == CAMERA_STATE_WELDED) ? CAMERA_STATE_WRENCHED : CAMERA_STATE_WELDED)
			set_anchored(camera_construction_state == CAMERA_STATE_WELDED)
			user.balloon_alert_to_viewers(camera_construction_state == CAMERA_STATE_WELDED ? "welded" : "unwelded")
			return ITEM_INTERACT_SUCCESS
		if(CAMERA_STATE_FINISHED)
			if(!panel_open)
				return ITEM_INTERACT_BLOCKING
			if(!tool.tool_start_check(user, amount=2))
				return ITEM_INTERACT_BLOCKING
			audible_message(span_hear("You hear welding."))
			if(!tool.use_tool(src, user, 100, volume=50))
				return ITEM_INTERACT_BLOCKING
			user.visible_message(span_warning("[user] unwelds [src], leaving it as just a frame bolted to the wall."),
				span_warning("You unweld [src], leaving it as just a frame bolted to the wall"))
			deconstruct(TRUE)
			return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/camera/screwdriver_act(mob/user, obj/item/tool)
	switch(camera_construction_state)
		if(CAMERA_STATE_WIRED)
			tool.play_tool_sound(src)
			var/input = tgui_input_text(user, "Which networks would you like to connect this camera to? Separate networks with a comma. No Spaces!\nFor example: SS13,Security,Secret", "Set Network", "SS13", max_length = MAX_NAME_LEN)
			if(isnull(input))
				return ITEM_INTERACT_BLOCKING
			var/list/tempnetwork = splittext(input, ",")
			if(!length(tempnetwork))
				to_chat(user, span_warning("No network found, please hang up and try your call again!"))
				return ITEM_INTERACT_BLOCKING
			for(var/i in tempnetwork)
				tempnetwork -= i
				tempnetwork += LOWER_TEXT(i)
			camera_construction_state = CAMERA_STATE_FINISHED
			toggle_cam(user, displaymessage = FALSE)
			network = tempnetwork
			return ITEM_INTERACT_SUCCESS
		if(CAMERA_STATE_FINISHED)
			toggle_panel_open()
			to_chat(user, span_notice("You screw the camera's panel [panel_open ? "open" : "closed"]."))
			tool.play_tool_sound(src)
			update_appearance()
			return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/camera/wirecutter_act(mob/user, obj/item/tool)
	switch(camera_construction_state)
		if(CAMERA_STATE_WIRED)
			new /obj/item/stack/cable_coil(drop_location(), 2)
			tool.play_tool_sound(src)
			to_chat(user, span_notice("You cut the wires from the circuits."))
			camera_construction_state = CAMERA_STATE_WELDED
			return ITEM_INTERACT_SUCCESS
		if(CAMERA_STATE_FINISHED)
			if(!panel_open)
				return ITEM_INTERACT_BLOCKING
			toggle_cam(user, 1)
			atom_integrity = max_integrity //this is a pretty simplistic way to heal the camera, but there's no reason for this to be complex.
			set_machine_stat(machine_stat & ~BROKEN)
			tool.play_tool_sound(src)
			return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/camera/wrench_act(mob/user, obj/item/tool)
	if(camera_construction_state != CAMERA_STATE_WRENCHED)
		return NONE
	tool.play_tool_sound(src)
	to_chat(user, span_notice("You detach [src] from its place."))
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/camera/crowbar_act(mob/living/user, obj/item/tool)
	if(camera_construction_state != CAMERA_STATE_FINISHED || !panel_open)
		return NONE
	var/list/droppable_parts = list()
	if(xray_module)
		droppable_parts += xray_module
	if(emp_module)
		droppable_parts += emp_module
	if(proximity_monitor)
		droppable_parts += proximity_monitor
	if(!length(droppable_parts))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/choice = tgui_input_list(user, "Select a part to remove", "Part Removal", sort_names(droppable_parts))
	if(isnull(choice))
		return ITEM_INTERACT_BLOCKING
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You remove [choice] from [src]."))
	if(choice == xray_module)
		drop_upgrade(xray_module)
		removeXRay()
	if(choice == emp_module)
		drop_upgrade(emp_module)
		removeEmpProof()
	if(choice == proximity_monitor)
		drop_upgrade(proximity_monitor)
		removeMotion()
	tool.play_tool_sound(src)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/camera/multitool_act(mob/living/user, obj/item/tool)
	if(camera_construction_state != CAMERA_STATE_FINISHED || !panel_open)
		return NONE
	setViewRange((view_range == initial(view_range)) ? short_range : initial(view_range))
	to_chat(user, span_notice("You [(view_range == initial(view_range)) ? "restore" : "mess up"] the camera's focus."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/camera/proc/gas_analyzer_act(mob/living/user, obj/item/tool)
	if(camera_construction_state == CAMERA_STATE_FINISHED && !panel_open)
		return NONE
	if(isXRay(TRUE))
		to_chat(user, span_warning("[src] already has that upgrade!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.temporarilyRemoveItemFromInventory(tool, newloc = src))
		return ITEM_INTERACT_BLOCKING
	upgradeXRay(FALSE, TRUE)
	to_chat(user, span_notice("You attach [tool] into [src]'s inner circuits."))
	qdel(tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/camera/proc/plasma_act(mob/living/user, obj/item/tool)
	if(camera_construction_state == CAMERA_STATE_FINISHED && !panel_open)
		return NONE
	if(isEmpProof(TRUE))
		to_chat(user, span_warning("[src] already has that upgrade!"))
		return ITEM_INTERACT_BLOCKING
	if(!tool.use_tool(src, user, 0, amount = 1))
		return ITEM_INTERACT_BLOCKING
	upgradeEmpProof(FALSE, TRUE)
	to_chat(user, span_notice("You attach [tool] into [src]'s inner circuits."))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/camera/proc/prox_act(mob/living/user, obj/item/tool)
	if(camera_construction_state == CAMERA_STATE_FINISHED && !panel_open)
		return NONE
	if(isMotion())
		to_chat(user, span_warning("[src] already has that upgrade!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.temporarilyRemoveItemFromInventory(tool, newloc = src))
		return ITEM_INTERACT_BLOCKING
	upgradeMotion()
	to_chat(user, span_notice("You attach [tool] into [src]'s inner circuits."))
	qdel(tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/camera/proc/cable_act(mob/living/user, obj/item/tool)
	if(camera_construction_state != CAMERA_STATE_WELDED)
		return NONE
	if(!astype(tool, /obj/item/stack/cable_coil)?.use(2))
		to_chat(user, span_warning("You need two lengths of cable to wire [src]!"))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You add wires to [src]."))
	camera_construction_state = CAMERA_STATE_WIRED
	return ITEM_INTERACT_SUCCESS

/obj/machinery/camera/proc/computer_act(mob/living/user, obj/item/tool)
	if(camera_construction_state != CAMERA_STATE_FINISHED)
		return NONE
	var/obj/item/modular_computer/computer = tool
	var/note_name = sanitize(computer.name)
	var/datum/computer_file/program/notepad/notepad_app = locate() in computer.stored_files
	if(!notepad_app)
		return ITEM_INTERACT_BLOCKING
	var/note_text = sanitize(notepad_app.written_note)
	if(!note_text)
		return ITEM_INTERACT_BLOCKING
	display_note(user, note_name, note_text, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/camera/proc/paper_act(mob/living/user, obj/item/tool)
	if(camera_construction_state != CAMERA_STATE_FINISHED)
		return NONE
	var/obj/item/paper/paper = tool
	last_shown_paper = paper.copy(paper.type, null)
	var/note_name = sanitize(last_shown_paper.name)
	last_shown_paper.camera_holder = WEAKREF(src)
	display_note(user, note_name, null, FALSE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/camera/proc/display_note(mob/living/user, title, text, is_computer)
	to_chat(user, span_notice("You hold up \the [title] up to the camera..."))
	user.log_talk(title, LOG_GAME, "Pressed to camera", TRUE)
	user.changeNext_move(CLICK_CD_MELEE)

	// Iterate over all living mobs and check if anyone is elibile to view the paper.
	// This is backwards, but cameras don't store a list of people that are looking through them,
	// and we'll have to iterate this list anyway so we can use it to pull out AIs too.
	for(var/mob/potential_viewer as anything in GLOB.player_list)
		// All AIs view through cameras, so we need to check them regardless.
		if(isAI(potential_viewer))
			var/mob/living/silicon/ai/ai = potential_viewer
			if(ai.control_disabled || ai.stat == DEAD)
				continue

			ai.log_talk(title, LOG_VICTIM, "Pressed to camera from [key_name(user)]", FALSE)
			if(is_computer)
				ai.last_tablet_note_seen = "<HTML><HEAD><TITLE>[title]</TITLE></HEAD><BODY><TT>[text]</TT></BODY></HTML>"
			else
				log_paper("[key_name(user)] held [last_shown_paper] up to [src], requesting [key_name(ai)] read it.")

			var/href_string = is_computer ? "show_tablet_note=1" : "show_paper_note=[REF(last_shown_paper)]"
			if(user.name == "Unknown")
				to_chat(ai, "[span_name("[user]")] holds <a href='byond://?_src_=usr;[href_string];'>\a [title]</a> up to one of your cameras...")
			else
				to_chat(ai, "[span_name("<a href='byond://?src=[REF(ai)];track=[html_encode(user.name)]'>[user]</a>")] holds <a href='byond://?_src_=usr;[href_string];'>\a [title]</a> up to one of your cameras...")

		// If it's not an AI, eye if the client's eye is set to the camera. I wonder if this even works anymore with tgui camera apps and stuff?
		else if(potential_viewer.client?.eye == src)
			potential_viewer.log_talk(title, LOG_VICTIM, "Pressed to camera from [key_name(user)]", FALSE)
			if(!is_computer)
				log_paper("[key_name(user)] held [last_shown_paper] up to [src], and [key_name(potential_viewer)] may read it.")
				to_chat(potential_viewer, "[span_name("[user]")] holds <a href='byond://?_src_=usr;show_paper_note=[REF(last_shown_paper)];'>\a [title]</a> up to your camera...")
			else
				potential_viewer << browse("<HTML><HEAD><TITLE>[title]</TITLE></HEAD><BODY><TT>[text]</TT></BODY></HTML>", "window=[title]")

/obj/machinery/camera/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return ITEM_INTERACT_SKIP_TO_ATTACK
	if(istype(tool, /obj/item/stack/sheet/mineral/plasma))
		return plasma_act(user, tool)
	if(istype(tool, /obj/item/analyzer))
		return gas_analyzer_act(user, tool)
	if(isprox(tool))
		return prox_act(user, tool)
	if(istype(tool, /obj/item/stack/cable_coil))
		return cable_act(user, tool)
	if(istype(tool, /obj/item/modular_computer))
		return computer_act(user, tool)
	if(istype(tool, /obj/item/paper))
		return paper_act(user, tool)
	return NONE
