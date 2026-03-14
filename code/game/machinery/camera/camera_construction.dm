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
	if(camera_construction_state == CAMERA_STATE_WRENCHED)
		tool.play_tool_sound(src)
		to_chat(user, span_notice("You detach [src] from its place."))
		deconstruct(TRUE)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/camera/crowbar_act(mob/living/user, obj/item/tool)
	if(camera_construction_state == CAMERA_STATE_FINISHED)
		if(!panel_open)
			return ITEM_INTERACT_BLOCKING
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
	return ..()

/obj/machinery/camera/multitool_act(mob/living/user, obj/item/tool)
	if(camera_construction_state == CAMERA_STATE_FINISHED)
		if(!panel_open)
			return ITEM_INTERACT_BLOCKING
		setViewRange((view_range == initial(view_range)) ? short_range : initial(view_range))
		to_chat(user, span_notice("You [(view_range == initial(view_range)) ? "restore" : "mess up"] the camera's focus."))
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/machinery/camera/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(camera_construction_state != CAMERA_STATE_FINISHED || panel_open)
		if(attacking_item.tool_behaviour == TOOL_ANALYZER)
			if(!isXRay(TRUE)) //don't reveal it was already upgraded if was done via MALF AI Upgrade Camera Network ability
				if(!user.temporarilyRemoveItemFromInventory(attacking_item, newloc = src))
					return
				upgradeXRay(FALSE, TRUE)
				to_chat(user, span_notice("You attach [attacking_item] into [name]'s inner circuits."))
				qdel(attacking_item)
			else
				to_chat(user, span_warning("[src] already has that upgrade!"))
			return
		else if(istype(attacking_item, /obj/item/stack/sheet/mineral/plasma))
			if(!isEmpProof(TRUE)) //don't reveal it was already upgraded if was done via MALF AI Upgrade Camera Network ability
				if(attacking_item.use_tool(src, user, 0, amount=1))
					upgradeEmpProof(FALSE, TRUE)
					to_chat(user, span_notice("You attach [attacking_item] into [name]'s inner circuits."))
			else
				to_chat(user, span_warning("[src] already has that upgrade!"))
			return
		else if(isprox(attacking_item))
			if(!isMotion())
				if(!user.temporarilyRemoveItemFromInventory(attacking_item, newloc = src))
					return
				upgradeMotion()
				to_chat(user, span_notice("You attach [attacking_item] into [name]'s inner circuits."))
				qdel(attacking_item)
			else
				to_chat(user, span_warning("[src] already has that upgrade!"))
			return
	switch(camera_construction_state)
		if(CAMERA_STATE_WELDED)
			if(istype(attacking_item, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/attacking_cable = attacking_item
				if(attacking_cable.use(2))
					to_chat(user, span_notice("You add wires to [src]."))
					camera_construction_state = CAMERA_STATE_WIRED
				else
					to_chat(user, span_warning("You need two lengths of cable to wire a camera!"))
				return
		if(CAMERA_STATE_FINISHED)
			if(istype(attacking_item, /obj/item/modular_computer))
				var/itemname = ""
				var/info = ""

				var/obj/item/modular_computer/computer = attacking_item
				for(var/datum/computer_file/program/notepad/notepad_app in computer.stored_files)
					info = notepad_app.written_note
					break

				if(!info)
					return

				itemname = computer.name
				itemname = sanitize(itemname)
				info = sanitize(info)
				to_chat(user, span_notice("You hold \the [itemname] up to the camera..."))
				user.log_talk(itemname, LOG_GAME, log_globally=TRUE, tag="Pressed to camera")
				user.changeNext_move(CLICK_CD_MELEE)

				for(var/mob/potential_viewer as anything in GLOB.player_list)
					if(isAI(potential_viewer))
						var/mob/living/silicon/ai/ai = potential_viewer
						if(ai.control_disabled || (ai.stat == DEAD))
							continue

						ai.log_talk(itemname, LOG_VICTIM, tag="Pressed to camera from [key_name(user)]", log_globally=FALSE)
						ai.last_tablet_note_seen = "<HTML><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>"

						if(user.name == "Unknown")
							to_chat(ai, "[span_name(user)] holds <a href='byond://?_src_=usr;show_tablet_note=1;'>\a [itemname]</a> up to one of your cameras ...")
						else
							to_chat(ai, "<b><a href='byond://?src=[REF(ai)];track=[html_encode(user.name)]'>[user]</a></b> holds <a href='byond://?_src_=usr;show_tablet_note=1;'>\a [itemname]</a> up to one of your cameras ...")
						continue

					if (potential_viewer.client?.eye == src)
						to_chat(potential_viewer, "[span_name("[user]")] holds \a [itemname] up to one of the cameras ...")
						potential_viewer.log_talk(itemname, LOG_VICTIM, tag="Pressed to camera from [key_name(user)]", log_globally=FALSE)
						potential_viewer << browse("<HTML><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>", "window=[itemname]")
				return

			if(istype(attacking_item, /obj/item/paper))
				// Grab the paper, sanitise the name as we're about to just throw it into chat wrapped in HTML tags.
				var/obj/item/paper/paper = attacking_item

				// Make a complete copy of the paper, store a ref to it locally on the camera.
				last_shown_paper = paper.copy(paper.type, null)

				// Then sanitise the name because we're putting it directly in chat later.
				var/item_name = sanitize(last_shown_paper.name)

				// Start the process of holding it up to the camera.
				to_chat(user, span_notice("You hold \the [item_name] up to the camera..."))
				user.log_talk(item_name, LOG_GAME, log_globally=TRUE, tag="Pressed to camera")
				user.changeNext_move(CLICK_CD_MELEE)

				// And make a weakref we can throw around to all potential viewers.
				last_shown_paper.camera_holder = WEAKREF(src)

				// Iterate over all living mobs and check if anyone is elibile to view the paper.
				// This is backwards, but cameras don't store a list of people that are looking through them,
				// and we'll have to iterate this list anyway so we can use it to pull out AIs too.
				for(var/mob/potential_viewer in GLOB.player_list)
					// All AIs view through cameras, so we need to check them regardless.
					if(isAI(potential_viewer))
						var/mob/living/silicon/ai/ai = potential_viewer
						if(ai.control_disabled || (ai.stat == DEAD))
							continue

						ai.log_talk(item_name, LOG_VICTIM, tag="Pressed to camera from [key_name(user)]", log_globally=FALSE)
						log_paper("[key_name(user)] held [last_shown_paper] up to [src], requesting [key_name(ai)] read it.")

						if(user.name == "Unknown")
							to_chat(ai, "[span_name(user.name)] holds <a href='byond://?_src_=usr;show_paper_note=[REF(last_shown_paper)];'>\a [item_name]</a> up to one of your cameras ...")
						else
							to_chat(ai, "<b><a href='byond://?src=[REF(ai)];track=[html_encode(user.name)]'>[user]</a></b> holds <a href='byond://?_src_=usr;show_paper_note=[REF(last_shown_paper)];'>\a [item_name]</a> up to one of your cameras ...")
						continue

					// If it's not an AI, eye if the client's eye is set to the camera. I wonder if this even works anymore with tgui camera apps and stuff?
					if (potential_viewer.client?.eye == src)
						log_paper("[key_name(user)] held [last_shown_paper] up to [src], and [key_name(potential_viewer)] may read it.")
						potential_viewer.log_talk(item_name, LOG_VICTIM, tag="Pressed to camera from [key_name(user)]", log_globally=FALSE)
						to_chat(potential_viewer, "[span_name(user)] holds <a href='byond://?_src_=usr;show_paper_note=[REF(last_shown_paper)];'>\a [item_name]</a> up to your camera...")
				return

	return ..()
