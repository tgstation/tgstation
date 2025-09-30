// Status display

#define MAX_STATIC_WIDTH 22
#define FONT_STYLE "12pt 'TinyUnicode'"
#define SCROLL_RATE (0.04 SECONDS) // time per pixel
#define SCROLL_PADDING 2 // how many pixels we chop to make a smooth loop
#define LINE1_X 1
#define LINE1_Y -4
#define LINE2_X 1
#define LINE2_Y -11
GLOBAL_DATUM_INIT(status_font, /datum/font, new /datum/font/tiny_unicode/size_12pt())

/// Status display which can show images and scrolling text.
/obj/machinery/status_display
	name = "status display"
	desc = null
	icon = 'icons/obj/machines/status_display.dmi'
	icon_state = "frame"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	density = FALSE
	layer = ABOVE_WINDOW_LAYER

	// We store overlays as keys, so multiple displays can use the same object safely
	/// String key we use to index the first effect overlay displayed on us
	var/message_key_1
	/// String key we use to index the second effect overlay displayed on us
	var/message_key_2
	var/current_picture = ""
	var/current_mode = SD_BLANK
	var/message1 = ""
	var/message2 = ""

	/// Normal text color
	var/text_color = COLOR_DISPLAY_BLUE
	/// Color for headers, eg. "- ETA -"
	var/header_text_color = COLOR_DISPLAY_PURPLE

	/// Used in greenscreen mode: the display currently being displayed (via vis_contents)
	VAR_PRIVATE/list/obj/effect/abstract/greenscreen_display/active_displays
	/// Lazy-inited radio in greenscreen mode to receive speech from the display
	VAR_PRIVATE/obj/item/radio/entertainment/speakers/speakers

/obj/item/wallframe/status_display
	name = "status display frame"
	desc = "Used to build status displays, just secure to the wall."
	icon_state = "unanchoredstatusdisplay"
	custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT * 7)
	result_path = /obj/machinery/status_display/evac
	pixel_shift = 32

//makes it go on the wall when built
/obj/machinery/status_display/Initialize(mapload, ndir, building)
	. = ..()
	update_appearance()

/obj/machinery/status_display/wrench_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	balloon_alert(user, "[anchored ? "un" : ""]securing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		balloon_alert(user, "[anchored ? "un" : ""]secured")
		deconstruct()
		return TRUE

/obj/machinery/status_display/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return
	if(atom_integrity >= max_integrity)
		balloon_alert(user, "it doesn't need repairs!")
		return TRUE
	user.balloon_alert_to_viewers("repairing display...", "repairing...")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume=50))
		return TRUE
	balloon_alert(user, "repaired")
	atom_integrity = max_integrity
	set_machine_stat(machine_stat & ~BROKEN)
	update_appearance()
	return TRUE

/obj/machinery/status_display/on_deconstruction(disassembled)
	if(!disassembled)
		new /obj/item/stack/sheet/iron(drop_location(), 2)
		new /obj/item/shard(drop_location())
		new /obj/item/shard(drop_location())
	else
		new /obj/item/wallframe/status_display(drop_location())

/// Immediately change the display to the given picture.
/obj/machinery/status_display/proc/set_picture(state)
	if(state != current_picture)
		current_picture = state

	update_appearance()

/// Immediately change the display to the given two lines.
/obj/machinery/status_display/proc/set_messages(line1, line2)
	line1 = uppertext(line1)
	line2 = uppertext(line2)

	var/message_changed = FALSE
	if(line1 != message1)
		message1 = line1
		message_changed = TRUE

	if(line2 != message2)
		message2 = line2
		message_changed = TRUE

	if(message_changed)
		update_appearance()

/**
 * Remove both message objs and null the fields.
 * Don't call this in subclasses.
 */
/obj/machinery/status_display/proc/clear_display()
	PRIVATE_PROC(TRUE)
	clear_text()
	clear_green_screen()

/// Clears text off the display.
/obj/machinery/status_display/proc/clear_text()
	PRIVATE_PROC(TRUE)
	var/obj/effect/overlay/status_display_text/overlay_1 = get_status_text(message_key_1)
	message_key_1 = null
	overlay_1?.disown(src)
	var/obj/effect/overlay/status_display_text/overlay_2 = get_status_text(message_key_2)
	message_key_2 = null
	overlay_2?.disown(src)

/// Clears the green screen display.
/obj/machinery/status_display/proc/clear_green_screen()
	PRIVATE_PROC(TRUE)
	speakers?.set_listening(FALSE)
	if(LAZYLEN(active_displays))
		vis_contents -= active_displays
		LAZYNULL(active_displays)

// List in the form key -> status display that shows said key
GLOBAL_LIST_EMPTY(key_to_status_display)

/proc/generate_status_text(line_y, message, x_offset, text_color, header_text_color, line_pair)
	var/key = "[line_y]-[message]-[x_offset]-[text_color]-[header_text_color]-[line_pair]"
	var/obj/effect/overlay/status_display_text/new_overlay = GLOB.key_to_status_display[key]
	if(!new_overlay)
		new_overlay = new(null, line_y, message, text_color, header_text_color, x_offset, line_pair, key)
		GLOB.key_to_status_display[key] = new_overlay
	return new_overlay

/proc/get_status_text(key)
	return GLOB.key_to_status_display[key]

/**
 * Create/update message overlay.
 * They must be handled as real objects for the animation to run.
 * Don't call this in subclasses.
 * Arguments:
 * * overlay - the current /obj/effect/overlay/status_display_text instance
 * * line_y - The Y offset to render the text.
 * * x_offset - Used to offset the text on the X coordinates, not usually needed.
 * * message - the new message text.
 * Returns new /obj/effect/overlay/status_display_text or null if unchanged.
 */
/obj/machinery/status_display/proc/update_message(current_key, line_y, message, x_offset, line_pair)
	var/obj/effect/overlay/status_display_text/current_overlay = get_status_text(current_key)
	var/obj/effect/overlay/status_display_text/new_overlay = generate_status_text(line_y, message, x_offset, text_color, header_text_color, line_pair)

	if(current_overlay == new_overlay)
		return current_key

	current_overlay?.disown(src)
	new_overlay.own(src)
	return new_overlay.status_key

/obj/machinery/status_display/update_appearance(updates=ALL)
	. = ..()
	if( \
		(machine_stat & (NOPOWER|BROKEN)) || \
		(current_mode == SD_BLANK) || \
		(current_mode != SD_PICTURE && message1 == "" && message2 == "") \
	)
		set_light(0)
		return
	set_light(1.5, 0.7, LIGHT_COLOR_FAINT_CYAN) // blue light

/obj/machinery/status_display/update_overlays(updates)
	. = ..()

	if(machine_stat & (NOPOWER|BROKEN))
		clear_display()
		return

	switch(current_mode)
		if(SD_BLANK)
			clear_display()
			// Turn off backlight.
			return
		if(SD_PICTURE)
			clear_display()
			. += mutable_appearance(icon, current_picture)
			if(current_picture == AI_DISPLAY_DONT_GLOW) // If the thing's off, don't display the emissive yeah?
				return
		if(SD_GREENSCREEN)
			clear_text()
			if(LAZYLEN(active_displays))
				vis_contents |= active_displays
				speakers?.set_listening(TRUE)
		else
			clear_green_screen()
			var/line1_metric
			var/line2_metric
			var/line_pair
			line1_metric = GLOB.status_font.get_metrics(message1)
			line2_metric = GLOB.status_font.get_metrics(message2)
			line_pair = (line1_metric > line2_metric ? line1_metric : line2_metric)

			message_key_1 = update_message(message_key_1, LINE1_Y, message1, LINE1_X, line_pair)
			message_key_2 = update_message(message_key_2, LINE2_Y, message2, LINE2_X, line_pair)

			// Turn off backlight if message is blank
			if(message1 == "" && message2 == "")
				return

	. += emissive_appearance(icon, "outline", src, alpha = src.alpha)

// Timed process - performs nothing in the base class
/obj/machinery/status_display/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		update_appearance()

	return PROCESS_KILL

/// Updates the display and starts it processing again if needed
/obj/machinery/status_display/proc/update()
	if (process(SSMACHINES_DT) != PROCESS_KILL)
		START_PROCESSING(SSmachines, src)

/obj/machinery/status_display/power_change()
	. = ..()
	update()

/obj/machinery/status_display/emp_act(severity)
	. = ..()
	if((machine_stat & (NOPOWER|BROKEN)) || (. & EMP_PROTECT_SELF))
		return
	current_mode = SD_PICTURE
	set_picture("ai_bsod")

/obj/machinery/status_display/examine(mob/user)
	. = ..()
	if(LAZYLEN(active_displays))
		. += span_notice("<hr>It's currently broadcasting. You can see...")
		var/has_any = FALSE
		for(var/obj/effect/abstract/greenscreen_display/display as anything in active_displays)
			for(var/atom/movable/thing as anything in display.displaying)
				. += span_notice("&bull; \A [thing.name]")
				has_any = TRUE
		if(!has_any)
			. += span_notice("&bull; Nothing.")

	var/obj/effect/overlay/status_display_text/message1_overlay = get_status_text(message_key_1)
	var/obj/effect/overlay/status_display_text/message2_overlay = get_status_text(message_key_2)
	if (message1_overlay || message2_overlay)
		. += "<hr>The display says:"
		if (message1_overlay.message)
			. += "\t<tt>[html_encode(message1_overlay.message)]</tt>"
		if (message2_overlay.message)
			. += "\t<tt>[html_encode(message2_overlay.message)]</tt>"

// Helper procs for child display types.
/obj/machinery/status_display/proc/display_shuttle_status(obj/docking_port/mobile/shuttle)
	if(!shuttle)
		// the shuttle is missing - no processing
		set_messages("shutl","not in service")
		return PROCESS_KILL
	else if(shuttle.timer)
		var/line1 = shuttle.getModeStr()
		var/line2 = shuttle.getTimerStr()

		set_messages(line1, line2)
	else
		// don't kill processing, the timer might turn back on
		set_messages("", "")

/obj/machinery/status_display/Destroy()
	clear_display()
	QDEL_NULL(speakers)
	return ..()

/**
 * Nice overlay to make text smoothly scroll with no client updates after setup.
 */
/obj/effect/overlay/status_display_text
	icon = 'icons/obj/machines/status_display.dmi'
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID
	// physically shift down to render correctly
	pixel_y = -32
	pixel_z = 32

	/// The message this overlay is displaying.
	var/message
	/// Amount of usage this overlay is getting
	var/use_count = 0
	/// The status key we represent
	var/status_key

	// If the line is short enough to not marquee, and it matches this, it's a header.
	var/static/regex/header_regex = regex("^-.*-$")

/obj/effect/overlay/status_display_text/Initialize(mapload, maptext_y, message, text_color, header_text_color, xoffset = 0, line_pair, status_key)
	. = ..()

	src.maptext_y = maptext_y
	src.message = message
	src.status_key = status_key

	var/line_width = GLOB.status_font.get_metrics(message)

	if(line_width > MAX_STATIC_WIDTH)
		// Marquee text
		var/marquee_message = "[message]    [message]    [message]"

		// Width of full content. Must of these is never revealed unless the user inputted a single character.
		var/full_marquee_width = GLOB.status_font.get_metrics("[marquee_message]    ")
		// We loop after only this much has passed.
		var/looping_marquee_width = (GLOB.status_font.get_metrics("[message]    ]") - SCROLL_PADDING)

		maptext = generate_text(marquee_message, center = FALSE, text_color = text_color)
		maptext_width = full_marquee_width
		maptext_x = 0

		// Mask off to fit in screen.
		add_filter("mask", 1, alpha_mask_filter(icon = icon(icon, "outline")))

		// Scroll.
		var/time = line_pair * SCROLL_RATE
		animate(src, maptext_x = (-looping_marquee_width) + MAX_STATIC_WIDTH, time = time, loop = -1)
		animate(maptext_x = MAX_STATIC_WIDTH, time = 0)
	else
		// Centered text
		var/color = header_regex.Find(message) ? header_text_color : text_color
		maptext = generate_text(message, center = TRUE, text_color = color)
		maptext_x = xoffset //Defaults to 0, this would be centered unless overided

/obj/effect/overlay/status_display_text/Destroy(force)
	GLOB.key_to_status_display -= status_key
	return ..()

/// Status displays are static, shared by everyone who needs them
/// This marks us as being used by one more guy
/obj/effect/overlay/status_display_text/proc/own(atom/movable/owned_by)
	owned_by.vis_contents += src
	use_count += 1

/// Status displays are static, shared by everyone who needs them
/// This marks us as no longer being used by a guy
/obj/effect/overlay/status_display_text/proc/disown(atom/movable/disowned_by)
	disowned_by.vis_contents -= src
	use_count -= 1
	if(use_count <= 0)
		qdel(src)

/**
 * Generate the actual maptext.
 * Arguments:
 * * text - the text to display
 * * center - center the text if TRUE, otherwise right-align (the direction the text is coming from)
 * * text_color - the text color
 */
/obj/effect/overlay/status_display_text/proc/generate_text(text, center, text_color)
	return {"<div style="color:[text_color];font:[FONT_STYLE][center ? ";text-align:center" : "text-align:right"]" valign="top">[text]</div>"}

/// Evac display which shows shuttle timer or message set by Command.
/obj/machinery/status_display/evac
	current_mode = SD_PICTURE
	current_picture = "default"  // Show the logo when we start round
	var/frequency = FREQ_STATUS_DISPLAYS
	var/friendc = FALSE      // track if Friend Computer mode
	var/last_picture  // For when Friend Computer mode is undone
	/// What mode we should go back to when the alert timer runs out
	var/revert_mode = SD_PICTURE
	/// What picture we should show when reverting back
	var/revert_picture = "default"
	/// Timer for switching back to normal after showing alerts
	var/alert_display_timer
	/// How important our current display is (bigger number = more important)
	var/current_priority = DISPLAY_PRIORITY_LOGO
	/// What priority level we should go back to after alerts
	var/revert_priority = DISPLAY_PRIORITY_LOGO
	/// Keeps track of what someone manually set so we can go back to it later
	var/list/manual_display_state
	/// List of active emergency types - tracks what emergencies are currently happening
	var/list/active_emergencies = list()

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/evac, 32)

/obj/machinery/status_display/evac/Initialize(mapload)
	. = ..()
	// register for radio system
	SSradio.add_object(src, frequency)
	// Circuit USB
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/status_display,
	))
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, PROC_REF(on_sec_level_change))
	find_and_hang_on_wall()

/obj/machinery/status_display/evac/Destroy()
	SSradio.remove_object(src,frequency)
	UnregisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED)
	// Clean up our timer so we don't have ghost timers floating around
	if(alert_display_timer)
		deltimer(alert_display_timer)
		alert_display_timer = null
	return ..()

/obj/machinery/status_display/evac/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	if(friendc) //Makes all status displays except supply shuttle timer display the eye -- Urist
		current_mode = SD_PICTURE
		set_picture("ai_friend")
		return PROCESS_KILL

	// Figure out what we should be showing right now
	var/list/target_display = get_highest_priority_display()
	var/target_priority = target_display["priority"]

	// Don't mess with more important stuff that's already showing
	if(target_priority <= current_priority)
		// Keep the shuttle timer updating if that's what we're showing
		if(current_mode == SD_EMERGENCY)
			return display_shuttle_status(SSshuttle.emergency)
		return PROCESS_KILL

	// Switch to whatever should have priority right now
	switch(target_display["mode"])
		if(SD_EMERGENCY)
			set_display_with_priority(SD_EMERGENCY, target_priority)
			return display_shuttle_status(SSshuttle.emergency)
		if(SD_PICTURE)
			set_display_with_priority(SD_PICTURE, target_priority, picture_state = target_display["picture"])
			return PROCESS_KILL
		else
			return PROCESS_KILL

/// Figures out what we should be showing based on what's happening on the station
/// Returns a list with the mode, priority, and other details
/obj/machinery/status_display/evac/proc/get_highest_priority_display()
	// Shuttle stuff gets top priority - but only when it's actually doing something
	if(SSshuttle?.emergency)
		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_CALL, SHUTTLE_DOCKED, SHUTTLE_ESCAPE)
				return list("mode" = SD_EMERGENCY, "priority" = DISPLAY_PRIORITY_SHUTTLE)
			// Don't bother showing shuttle status when it's just sitting there

	// Check if someone manually set something from the bridge
	if(manual_display_state && manual_display_state["priority"] >= DISPLAY_PRIORITY_MESSAGE)
		return manual_display_state.Copy()

	// Nothing special happening, just show the logo
	return list("mode" = SD_PICTURE, "priority" = DISPLAY_PRIORITY_LOGO, "picture" = "default")

/// Tries to change what the display is showing, but respects priority levels
/// Returns TRUE if we actually changed it, FALSE if something more important was already showing
/obj/machinery/status_display/evac/proc/set_display_with_priority(new_mode, priority, picture_state = null, message1 = null, message2 = null, force_override = FALSE)
	// Allow manual overrides to always work (except when temporary alerts are showing)
	if(!force_override && priority < current_priority && current_priority != DISPLAY_PRIORITY_ALERT_TEMP)
		return FALSE

	// Cancel alert timer if we're changing to a different display type
	if(alert_display_timer && priority != DISPLAY_PRIORITY_ALERT_TEMP)
		deltimer(alert_display_timer)
		alert_display_timer = null

	current_mode = new_mode
	current_priority = priority

	// Store manually set displays (not temporary alerts, automated shuttle, or logo defaults)
	// Logo selections shouldn't be treated as manual overrides since logo is the default anyway
	var/is_logo_default = (new_mode == SD_PICTURE && (picture_state == "default" || picture_state == null))
	if(priority >= DISPLAY_PRIORITY_MESSAGE && priority != DISPLAY_PRIORITY_ALERT_TEMP && priority != DISPLAY_PRIORITY_SHUTTLE && !is_logo_default)
		manual_display_state = list(
			"mode" = new_mode,
			"priority" = priority,
			"picture" = picture_state,
			"message1" = message1,
			"message2" = message2
		)
	else if(is_logo_default)
		// Clear manual display state when logo is selected
		manual_display_state = null

	switch(new_mode)
		if(SD_BLANK)
			update_appearance()
		if(SD_EMERGENCY)
			set_messages("", "")
		if(SD_MESSAGE)
			set_messages(message1 || "", message2 || "")
		if(SD_PICTURE)
			last_picture = picture_state
			set_picture(picture_state)
		if(SD_GREENSCREEN)
			update_appearance()

	// Start processing to watch for higher priority displays (like shuttle calls)
	update()

	return TRUE

/obj/machinery/status_display/evac/receive_signal(datum/signal/signal)
	switch(signal.data["command"])
		if("blank")
			set_display_with_priority(SD_BLANK, DISPLAY_PRIORITY_MESSAGE, force_override = TRUE)
		if("shuttle")
			set_display_with_priority(SD_EMERGENCY, DISPLAY_PRIORITY_SHUTTLE, force_override = TRUE)
			// Start processing to keep shuttle timer updated and handle priority changes
			update()
		if("message")
			set_display_with_priority(SD_MESSAGE, DISPLAY_PRIORITY_MESSAGE, message1 = signal.data["top_text"], message2 = signal.data["bottom_text"], force_override = TRUE)
		if("alert")
			var/picture_state = signal.data["picture_state"]
			var/priority = DISPLAY_PRIORITY_MESSAGE
			var/is_emergency = signal.data["emergency_override"]
			var/emergency_type = signal.data["emergency_type"]

			// Check if this is just setting the logo back to default
			if(picture_state == "default")
				// Clear any manual display state and reset to logo priority
				manual_display_state = null
				set_display_with_priority(SD_PICTURE, DISPLAY_PRIORITY_LOGO, picture_state = picture_state, force_override = TRUE)
			// Automated emergency alerts use temporary high priority to interrupt even shuttle displays
			else if(is_emergency)
				// Track this emergency type
				if(emergency_type && !(emergency_type in active_emergencies))
					active_emergencies |= emergency_type
				show_temporary_display(SD_PICTURE, DISPLAY_PRIORITY_EMERGENCY_TEMP, picture_state = picture_state)
			else
				// Manual alerts can override existing displays
				set_display_with_priority(SD_PICTURE, priority, picture_state = picture_state, force_override = TRUE)
		if("clear_emergency")
			var/emergency_type = signal.data["emergency_type"]

			// Clear specific emergency type or all if no type specified
			if(emergency_type)
				active_emergencies -= emergency_type
			else
				active_emergencies.Cut()  // Clear all emergencies

			// Only revert display if no more emergencies are active
			if(!length(active_emergencies))
				// Clear emergency displays - if we're showing a temporary emergency, just cancel the timer
				if(current_priority == DISPLAY_PRIORITY_EMERGENCY_TEMP && alert_display_timer)
					deltimer(alert_display_timer)
					alert_display_timer = null
					revert_from_alert_display()
				// Otherwise clear persistent emergency displays by reverting to highest priority
				else if(current_priority >= DISPLAY_PRIORITY_EMERGENCY)
					var/list/target_display = get_highest_priority_display()
					current_mode = target_display["mode"]
					current_priority = target_display["priority"]

					switch(current_mode)
						if(SD_EMERGENCY)
							set_messages("", "")
						if(SD_PICTURE)
							set_picture(target_display["picture"])
						if(SD_MESSAGE)
							set_messages(target_display["message1"] || "", target_display["message2"] || "")
						else
							update_appearance()
		if("greenscreen")
			var/datum/weakref/display_ref = signal.data["display"]
			var/obj/effect/abstract/greenscreen_display/new_display = display_ref?.resolve()
			if(istype(new_display))
				if(isnull(speakers))
					speakers = new(src)
					// not seen, primarily for VV
					speakers.name = "[name] speakers"
					// to allow centcom cameras to reach the station
					speakers.special_channels |= RADIO_SPECIAL_CENTCOM
					speakers.set_frequency(FREQ_STATUS_DISPLAYS)
				LAZYOR(active_displays, new_display)
			set_display_with_priority(SD_GREENSCREEN, DISPLAY_PRIORITY_MESSAGE, force_override = TRUE)
		if("friendcomputer")
			friendc = !friendc
	update()

/obj/machinery/status_display/evac/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, current_mode))
		update_appearance()
		update()

/// Gets called when security changes the alert level - shows it for 30 seconds then goes back to normal
/obj/machinery/status_display/evac/proc/on_sec_level_change(datum/source, new_level)
	SIGNAL_HANDLER

	// Get the alert level icon
	var/datum/security_level/alert_level = SSsecurity_level.available_levels[SSsecurity_level.number_level_to_text(new_level)]

	// Show as temporary alert (can be overridden by emergency temps)
	show_temporary_display(SD_PICTURE, DISPLAY_PRIORITY_ALERT_TEMP, picture_state = alert_level.status_display_icon_state)

/// Shows a temporary display for 30 seconds then reverts to previous display
/// Can interrupt lower priority displays but respects higher priority temporary displays
/obj/machinery/status_display/evac/proc/show_temporary_display(temp_mode, temp_priority, picture_state = null, message1 = null, message2 = null)
	// Don't interrupt higher priority temporary displays
	if(alert_display_timer && current_priority >= temp_priority)
		return

	// Remember what we were showing before (unless we're already doing a lower priority alert)
	if(!alert_display_timer || current_priority < temp_priority)
		revert_mode = current_mode
		revert_picture = current_picture
		revert_priority = current_priority

	// Cancel any existing timer
	if(alert_display_timer)
		deltimer(alert_display_timer)
		alert_display_timer = null

	// Show the temporary display
	current_mode = temp_mode
	current_priority = temp_priority

	switch(temp_mode)
		if(SD_PICTURE)
			set_picture(picture_state)
		if(SD_MESSAGE)
			set_messages(message1 || "", message2 || "")
		else
			update_appearance()

	// Go back to what we were showing after 30 seconds
	alert_display_timer = addtimer(CALLBACK(src, PROC_REF(revert_from_alert_display)), 30 SECONDS, TIMER_STOPPABLE)

/// Goes back to showing whatever we were displaying before the alert level interrupt
/obj/machinery/status_display/evac/proc/revert_from_alert_display()
	alert_display_timer = null

	// Figure out what we should be showing now
	var/list/target_display = get_highest_priority_display()
	current_mode = target_display["mode"]
	current_priority = target_display["priority"]

	switch(current_mode)
		if(SD_EMERGENCY)
			set_messages("", "")
		if(SD_PICTURE)
			set_picture(target_display["picture"])
		if(SD_MESSAGE)
			set_messages(target_display["message1"] || "", target_display["message2"] || "")
		else
			update_appearance()

/// Supply display which shows the status of the supply shuttle.
/obj/machinery/status_display/supply
	name = "supply display"
	current_mode = SD_MESSAGE
	text_color = COLOR_DISPLAY_ORANGE
	header_text_color = COLOR_DISPLAY_YELLOW

/obj/machinery/status_display/supply/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	var/line1
	var/line2
	if(!SSshuttle.supply)
		// Might be missing in our first update on initialize before shuttles
		// have loaded. Cross our fingers that it will soon return.
		line1 = "shutl"
		line2 = "not in service"
	else if(SSshuttle.supply.mode == SHUTTLE_IDLE)
		if(is_station_level(SSshuttle.supply.z))
			line1 = "CARGO"
			line2 = "Docked"
		else
			line1 = ""
			line2 = ""
	else
		line1 = SSshuttle.supply.getModeStr()
		line2 = SSshuttle.supply.getTimerStr()
	set_messages(line1, line2)


/// General-purpose shuttle status display.
/obj/machinery/status_display/shuttle
	name = "shuttle display"
	current_mode = SD_MESSAGE
	var/shuttle_id

	text_color = COLOR_DISPLAY_GREEN
	header_text_color = COLOR_DISPLAY_CYAN

/obj/machinery/status_display/shuttle/process()
	if(!shuttle_id || (machine_stat & NOPOWER))
		// No power, no processing.
		update_appearance()
		return PROCESS_KILL

	return display_shuttle_status(SSshuttle.getShuttle(shuttle_id))

/obj/machinery/status_display/shuttle/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	switch(var_name)
		if(NAMEOF(src, shuttle_id))
			update()

/obj/machinery/status_display/shuttle/connect_to_shuttle(mapload, obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	if(port)
		shuttle_id = port.shuttle_id
	update()


/// Pictograph display which the AI can use to emote.
/obj/machinery/status_display/ai
	name = "\improper AI display"
	desc = "A small screen which the AI can use to present itself."
	current_mode = SD_PICTURE
	var/emotion = AI_DISPLAY_DONT_GLOW

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ai, 32)

/obj/machinery/status_display/ai/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	var/list/choices = list()
	for(var/emotion_const in GLOB.ai_status_display_emotes)
		var/icon_state = GLOB.ai_status_display_emotes[emotion_const]
		choices[emotion_const] = image(icon = 'icons/obj/machines/status_display.dmi', icon_state = icon_state)

	var/emotion_result = show_radial_menu(user, src, choices, tooltips = TRUE)
	for(var/_emote in typesof(/datum/emote/ai/emotion_display))
		var/datum/emote/ai/emotion_display/emote = _emote
		if(initial(emote.emotion) == emotion_result)
			user.emote(initial(emote.key))
			break

/obj/machinery/status_display/ai/process()
	if(machine_stat & NOPOWER)
		update_appearance()
		return PROCESS_KILL

	set_picture(GLOB.ai_status_display_emotes[emotion])
	return PROCESS_KILL

/obj/item/circuit_component/status_display
	display_name = "Status Display"
	desc = "Output text and pictures to a status display."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/option/command
	var/datum/port/input/option/picture
	var/datum/port/input/message1
	var/datum/port/input/message2

	var/obj/machinery/status_display/connected_display

	var/list/command_map
	var/list/picture_map

/obj/item/circuit_component/status_display/populate_ports()
	message1 = add_input_port("Message 1", PORT_TYPE_STRING)
	message2 = add_input_port("Message 2", PORT_TYPE_STRING)

/obj/item/circuit_component/status_display/populate_options()
	var/static/list/command_options = list(
		"Blank" = "blank",
		"Shuttle" = "shuttle",
		"Message" = "message",
		"Alert" = "alert"
	)

	var/static/list/picture_options = list(
		"Default" = "default",
		"Delta Alert" = "deltaalert",
		"Red Alert" = "redalert",
		"Blue Alert" = "bluealert",
		"Green Alert" = "greenalert",
		"Biohazard" = "biohazard",
		"Lockdown" = "lockdown",
		"Radiation" = "radiation",
		"Happy" = "ai_happy",
		"Neutral" = "ai_neutral",
		"Very Happy" = "ai_veryhappy",
		"Sad" = "ai_sad",
		"Unsure" = "ai_unsure",
		"Confused" = "ai_confused",
		"Surprised" = "ai_surprised",
		"BSOD" = "ai_bsod"
	)

	command = add_option_port("Command", command_options)
	command_map = command_options

	picture = add_option_port("Picture", picture_options)
	picture_map = picture_options

/obj/item/circuit_component/status_display/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/status_display))
		connected_display = shell

/obj/item/circuit_component/status_display/unregister_usb_parent(atom/movable/parent)
	connected_display = null
	return ..()

/obj/item/circuit_component/status_display/input_received(datum/port/input/port)
	// Just use command handling built into status display.
	// The option inputs thankfully sanitize command and picture for us.

	if(!connected_display)
		return

	var/command_value = command_map[command.value]
	var/datum/signal/status_signal = new(list("command" = command_value))
	switch(command_value)
		if("message")
			status_signal.data["top_text"] = message1.value
			status_signal.data["bottom_text"] = message2.value
		if("alert")
			status_signal.data["picture_state"] = picture_map[picture.value]

	connected_display.receive_signal(status_signal)

/obj/machinery/status_display/random_message
	current_mode = SD_MESSAGE
	/// list to pick the first line from
	var/list/firstline_to_secondline = list()

/obj/machinery/status_display/random_message/Initialize(mapload, ndir, building)
	if(firstline_to_secondline?.len)
		message1 = pick(firstline_to_secondline)
		message2 = firstline_to_secondline[message1]
	return ..() // status displays call update appearance on init so i suppose we should set the messages before calling parent as to not call it twice

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/random_message, 32)

#undef MAX_STATIC_WIDTH
#undef FONT_STYLE
#undef SCROLL_RATE
#undef LINE1_X
#undef LINE1_Y
#undef LINE2_X
#undef LINE2_Y
#undef SCROLL_PADDING

/// Tracks all active greenscreen displays
GLOBAL_LIST_EMPTY_TYPED(greenscreen_displays, /obj/effect/abstract/greenscreen_display)

/// Used to indicate where the greenscreen is recording
/obj/effect/abstract/greenscreen_location_indicator
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "blank_semi_transparent"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = BELOW_OPEN_DOOR_LAYER

/obj/effect/abstract/greenscreen_location_indicator/Initialize(mapload)
	. = ..()
	add_filter("greenscreen_indicator", 1, outline_filter(1.5, COLOR_YELLOW))
	animate(get_filter("greenscreen_indicator"), alpha = 0, time = 2.5 SECONDS, loop = -1)
	animate(alpha = 200, time = 1 SECONDS)

/// Basically exists to hold an appearance that we can slot into vis_contents
/obj/effect/abstract/greenscreen_appearance_holder
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/abstract/greenscreen_appearance_holder/Initialize(mapload, atom/movable/to_copy)
	. = ..()
	if(istype(to_copy))
		copy_appearance(to_copy)

/obj/effect/abstract/greenscreen_appearance_holder/proc/copy_appearance(atom/movable/from)
	var/mutable_appearance/copy = copy_appearance_filter_overlays(from.appearance)
	// if they have keep apart overlays we NEED to manually propogate the mask
	for(var/mutable_appearance/subcopy as anything in list() + copy.underlays + copy.overlays)
		if(subcopy.appearance_flags & KEEP_APART)
			subcopy.filters |= loc.filters // where loc = the display
	appearance = copy
	var/display_dir = ISDIAGONALDIR(loc.dir) ? EWCOMPONENT(loc.dir) : loc.dir
	var/from_dir = ISDIAGONALDIR(from.dir) ? EWCOMPONENT(from.dir) : from.dir
	switch(display_dir)
		if(NORTH)
			pass() // it just works
		if(EAST)
			dir = turn(from_dir, 90)
		if(SOUTH)
			dir = turn(from_dir, 180)
		if(WEST)
			dir = turn(from_dir, 270)
	// appearance copies these so we need to manually set them
	vis_flags |= VIS_INHERIT_PLANE|VIS_INHERIT_LAYER|VIS_INHERIT_ID // is vis_inherit recursive?

/// Basically exists to compile a list of appearances to display to all status displays
/obj/effect/abstract/greenscreen_display
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = -8
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER
	vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_LAYER
	/// Tracks who we're displaying
	VAR_FINAL/list/atom/movable/displaying = list()

/obj/effect/abstract/greenscreen_display/Initialize(mapload)
	. = ..()
	GLOB.greenscreen_displays += src
	// crops out the bits that don't fit the screen
	add_filter("display_mask", 1, alpha_mask_filter(x = -1 * pixel_x, y = -1 * pixel_y, icon = icon('icons/obj/machines/status_display.dmi', "outline")))
	// adds some pizzazz (copied from records)
	underlays += mutable_appearance('icons/effects/effects.dmi', "static_base", alpha = 20)
	add_overlay(mutable_appearance(generate_icon_alpha_mask('icons/effects/effects.dmi', "scanline"), alpha = 20))

/obj/effect/abstract/greenscreen_display/Destroy()
	for(var/thing in displaying)
		remove_from_display(thing)
	GLOB.greenscreen_displays -= src
	return ..()

/obj/effect/abstract/greenscreen_display/proc/add_to_display(atom/movable/thing)
	if(displaying[thing])
		return

	displaying[thing] = new /obj/effect/abstract/greenscreen_appearance_holder(src, thing)
	RegisterSignals(thing, list(
		COMSIG_ATOM_POST_DIR_CHANGE,
		COMSIG_ATOM_UPDATED_ICON,
		COMSIG_CARBON_APPLY_OVERLAY,
		COMSIG_CARBON_REMOVE_OVERLAY,
		COMSIG_LIVING_POST_UPDATE_TRANSFORM,
	), PROC_REF(thing_changed))
	RegisterSignal(thing, COMSIG_QDELETING, PROC_REF(remove_from_display))
	vis_contents += displaying[thing]

/obj/effect/abstract/greenscreen_display/proc/remove_from_display(atom/movable/thing)
	SIGNAL_HANDLER

	if(!displaying[thing])
		return

	UnregisterSignal(thing, list(
		COMSIG_ATOM_POST_DIR_CHANGE,
		COMSIG_ATOM_UPDATED_ICON,
		COMSIG_CARBON_APPLY_OVERLAY,
		COMSIG_CARBON_REMOVE_OVERLAY,
		COMSIG_LIVING_POST_UPDATE_TRANSFORM,
		COMSIG_QDELETING,
	))
	vis_contents -= displaying[thing]
	qdel(displaying[thing])
	displaying -= thing

/obj/effect/abstract/greenscreen_display/proc/thing_changed(atom/movable/source)
	SIGNAL_HANDLER

	var/obj/effect/abstract/greenscreen_appearance_holder/holder = displaying[source]
	holder.copy_appearance(source)

/// A stationary object which "records" anyone who is in front of it and broadcasts them to all status displays
/obj/machinery/greenscreen_camera
	name = "captain-caster"
	desc = "A camera that can be used to display whomever is in front of it across all status displays. \
		Pair with a greenscreen for best results."
	density = FALSE
	icon = 'icons/obj/machines/stationary_camera.dmi'
	icon_state = "camera"
	interaction_flags_atom = INTERACT_ATOM_REQUIRES_ANCHORED|INTERACT_ATOM_ATTACK_HAND|INTERACT_ATOM_ATTACK_PAW
	interaction_flags_machine = INTERACT_MACHINE_ALLOW_SILICON
	processing_flags = NONE
	use_power = IDLE_POWER_USE
	idle_power_usage = 0
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.1
	mouse_over_pointer = MOUSE_HAND_POINTER

	/// Tracks the turf we are recording
	VAR_PRIVATE/turf/greenscreen_turf
	/// The actual atom we hold the appearance on, held in nullspace
	VAR_PRIVATE/obj/effect/abstract/greenscreen_display/display
	/// Lazy-inited microphone to relay speech over the displays
	VAR_PRIVATE/obj/item/radio/entertainment/microphone/mic

/obj/machinery/greenscreen_camera/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_IGNORE_ANCHORED)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/greenscreen_camera/Destroy()
	deactivate_feed()
	return ..()

/obj/machinery/greenscreen_camera/examine(mob/user)
	. = ..()
	. += span_notice("It's currently [isnull(display) ? "not " : ""]broadcasting. <i>Click it to change that.</i>")

/obj/machinery/greenscreen_camera/interact(mob/user)
	. = ..()
	if(.)
		return TRUE

	toggle_feed()
	return TRUE

/obj/machinery/greenscreen_camera/proc/toggle_feed()
	if(isnull(display))
		if(!is_operational)
			return
		activate_feed()
		if(isnull(display))
			playsound(src, 'sound/machines/terminal/terminal_on.ogg', 33, TRUE, frequency = 0.5)
			balloon_alert_to_viewers("no backdrop, can't broadcast!")
			return
		playsound(src, 'sound/machines/terminal/terminal_on.ogg', 33, FALSE)
		use_power = ACTIVE_POWER_USE
	else
		deactivate_feed()
		playsound(src, 'sound/machines/terminal/terminal_off.ogg', 33, FALSE)
		use_power = IDLE_POWER_USE
	balloon_alert_to_viewers("feed [isnull(display) ? "de" : ""]activated")

/obj/machinery/greenscreen_camera/proc/activate_feed()
	greenscreen_turf = find_displayed_turf()
	if(isnull(greenscreen_turf))
		return

	new /obj/effect/abstract/greenscreen_location_indicator(greenscreen_turf)
	mic = new(src)
	// not seen, primarily for VV
	mic.name = "[name] microphone"
	// allows centcom cameras to reach the station + keeps transmission active even if comms are out
	mic.special_channels |= RADIO_SPECIAL_CENTCOM
	mic.set_frequency(FREQ_STATUS_DISPLAYS)
	display = new()
	display.dir = dir
	RegisterSignal(greenscreen_turf, COMSIG_ATOM_ENTERED, PROC_REF(turf_entered))
	RegisterSignal(greenscreen_turf, COMSIG_ATOM_EXITED, PROC_REF(turf_exited))

	for(var/mob/living/existing in greenscreen_turf)
		turf_entered(greenscreen_turf, existing)

	become_hearing_sensitive("active")

	INVOKE_ASYNC(src, PROC_REF(update_status_displays), list("command" = "greenscreen", "display" = WEAKREF(display)))
	update_appearance(UPDATE_OVERLAYS)

/// Sends a signal to all relevant status displays to update their greenscreen
/obj/machinery/greenscreen_camera/proc/update_status_displays(list/signal_args)
	// update the display on all status displays
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	frequency?.post_signal(src, new /datum/signal(signal_args))

/obj/machinery/greenscreen_camera/proc/deactivate_feed()
	if(!isnull(greenscreen_turf))
		for(var/obj/effect/abstract/greenscreen_location_indicator/indicator in greenscreen_turf)
			qdel(indicator)
		UnregisterSignal(greenscreen_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED))
		greenscreen_turf = null
	QDEL_NULL(mic)
	QDEL_NULL(display)

	lose_hearing_sensitivity("active")

	// there's another green screen to broadcast from, switch to it - otherwise, blank
	INVOKE_ASYNC(src, PROC_REF(update_status_displays), list("command" = (length(GLOB.greenscreen_displays) ? "greenscreen" : "shuttle")))
	update_appearance(UPDATE_OVERLAYS)

/// Check if the passed atom can be shown on the display
/obj/machinery/greenscreen_camera/proc/can_broadcast(atom/movable/thing)
	// blacklist underfloor, just in case
	// i would also blacklist invisible, but i figure it might be funny to see a ghost
	if(HAS_TRAIT(thing, TRAIT_UNDERFLOOR))
		return FALSE
	// always show any mobs
	if(isliving(thing))
		return TRUE
	// show things like wheelchairs, but not beds which are low
	if(thing.can_buckle && (thing.buckle_lying == NO_BUCKLE_LYING || thing.buckle_lying == 0))
		return TRUE
	return FALSE

/obj/machinery/greenscreen_camera/proc/turf_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	if(can_broadcast(entered))
		display.add_to_display(entered)

/obj/machinery/greenscreen_camera/proc/turf_exited(datum/source, atom/movable/exited)
	SIGNAL_HANDLER
	display.remove_from_display(exited)

/obj/machinery/greenscreen_camera/proc/find_displayed_turf()
	var/list/turf/line = get_line(src, get_ranged_target_turf(src, dir, 5))
	for(var/i in 1 to length(line))
		var/turf/current = line[i]
		// found a greenscreen turf
		if(istype(current, /turf/open/floor/greenscreen))
			return current
		// found any wall, or something we can't see through
		if(i != 1)
			if(current.opacity)
				return line[i - 1]
			for(var/atom/movable/thing in current)
				if(thing.opacity)
					return line[i - 1]
		// found a greenscreen poster
		var/obj/structure/sign/poster/greenscreen = locate() in current
		if(isnull(greenscreen))
			continue
		// the poster is wallmounted, so return this turf
		if(isProbablyWallMounted(greenscreen))
			return current
		// the poster is clipped into a wall, so return the last turf
		if(i != 1)
			return line[i - 1]

	return null

/obj/machinery/greenscreen_camera/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(isnull(display))
		return
	// stop the feed if we're moved
	deactivate_feed()

/obj/machinery/greenscreen_camera/setDir(newdir)
	var/old_dir
	. = ..()
	if(dir == old_dir || isnull(display))
		return
	// stop the feed if we're rotated
	deactivate_feed()

/obj/machinery/greenscreen_camera/set_anchored(anchorvalue)
	. = ..()
	if(anchored || isnull(display))
		return
	// stop the feed if we're unanchored
	deactivate_feed()

/obj/machinery/greenscreen_camera/on_set_is_operational(old_value)
	. = ..()
	if(is_operational || isnull(display))
		return
	// no more power, no more feed
	// (uses toggle for feedback)
	toggle_feed()

/obj/machinery/greenscreen_camera/update_overlays()
	. = ..()
	if(isnull(display))
		. += "camera_off"
	else
		. += "camera_on"
		. += emissive_appearance(icon, "camera_emissive", src, alpha = src.alpha)

/// Send an emergency alert signal to all status displays
/// alert_type: The picture state to display ("biohazard", "lockdown", "radiation", etc.)
/proc/send_status_display_alert(alert_type)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(frequency)
		var/datum/signal/alert_signal = new
		alert_signal.data["command"] = "alert"
		alert_signal.data["picture_state"] = alert_type
		alert_signal.data["emergency_override"] = TRUE
		alert_signal.data["emergency_type"] = alert_type  // Track specific emergency type
		var/atom/movable/virtualspeaker/virtual_speaker = new(null)
		frequency.post_signal(virtual_speaker, alert_signal)

/// Clear a specific emergency type from status displays
/// emergency_type: The specific type to clear ("biohazard", "lockdown", "radiation", etc.)
/// If emergency_type is null, clears ALL emergencies
/proc/clear_status_display_emergency(emergency_type = null)
	var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)
	if(frequency)
		var/datum/signal/clear_signal = new
		clear_signal.data["command"] = "clear_emergency"
		clear_signal.data["emergency_override"] = FALSE
		if(emergency_type)
			clear_signal.data["emergency_type"] = emergency_type
		var/atom/movable/virtualspeaker/virtual_speaker = new(null)
		frequency.post_signal(virtual_speaker, clear_signal)

/// Send a biohazard alert signal to all status displays
/proc/send_status_display_biohazard_alert()
	send_status_display_alert("biohazard")

/// Send a lockdown alert signal to all status displays
/proc/send_status_display_lockdown_alert()
	send_status_display_alert("lockdown")

/// Send a radiation alert signal to all status displays
/proc/send_status_display_radiation_alert()
	send_status_display_alert("radiation")

/// Clear specific emergency types
/proc/clear_status_display_biohazard()
	clear_status_display_emergency("biohazard")

/proc/clear_status_display_lockdown()
	clear_status_display_emergency("lockdown")

/proc/clear_status_display_radiation()
	clear_status_display_emergency("radiation")
