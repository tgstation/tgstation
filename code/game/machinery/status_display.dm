// Status display
// (formerly Countdown timer display)

#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Small Fonts"
#define SCROLL_RATE (0.04 SECONDS) // time per pixel
#define LINE1_Y -8
#define LINE2_Y -15

#define SD_BLANK 0  // 0 = Blank
#define SD_EMERGENCY 1  // 1 = Emergency Shuttle timer
#define SD_MESSAGE 2  // 2 = Arbitrary message(s)
#define SD_PICTURE 3  // 3 = alert picture

/// Status display which can show images and scrolling text.
/obj/machinery/status_display
	name = "status display"
	desc = null
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	base_icon_state = "unanchoredstatusdisplay"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	layer = ABOVE_WINDOW_LAYER

	var/obj/effect/overlay/status_display_text/message1_overlay
	var/obj/effect/overlay/status_display_text/message2_overlay

/obj/item/wallframe/status_display
	name = "status display frame"
	desc = "Used to build status displays, just secure to the wall."
	icon_state = "unanchoredstatusdisplay"
	custom_materials = list(/datum/material/iron=14000, /datum/material/glass=8000)
	result_path = /obj/machinery/status_display
	pixel_shift = 32

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

/obj/machinery/status_display/deconstruct(disassembled = TRUE)
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(!disassembled)
		new /obj/item/stack/sheet/iron(drop_location(), 2)
		new /obj/item/shard(drop_location())
		new /obj/item/shard(drop_location())
	else
		new /obj/item/wallframe/status_display(drop_location())
	qdel(src)

/// Immediately blank the display.
/obj/machinery/status_display/proc/remove_display()
	cut_overlays()
	vis_contents.Cut()
	if(message1_overlay)
		QDEL_NULL(message1_overlay)
	if(message2_overlay)
		QDEL_NULL(message2_overlay)

/// Immediately change the display to the given picture.
/obj/machinery/status_display/proc/set_picture(state)
	remove_display()
	add_overlay(state)

/// Immediately change the display to the given two lines.
/obj/machinery/status_display/proc/update_display(line1, line2)
	line1 = uppertext(line1)
	line2 = uppertext(line2)

	if( \
		(message1_overlay && message1_overlay.message == line1) && \
		(message2_overlay && message2_overlay.message == line2) \
	)
		return

	remove_display()

	message1_overlay = new(LINE1_Y, line1)
	vis_contents += message1_overlay

	message2_overlay = new(LINE2_Y, line2)
	vis_contents += message2_overlay

// Timed process - performs nothing in the base class
/obj/machinery/status_display/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		remove_display()

	return PROCESS_KILL

/// Update the display and, if necessary, re-enable processing.
/obj/machinery/status_display/proc/update()
	if (process(SSMACHINES_DT) != PROCESS_KILL)
		START_PROCESSING(SSmachines, src)

/obj/machinery/status_display/power_change()
	. = ..()
	update()

/obj/machinery/status_display/emp_act(severity)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN) || . & EMP_PROTECT_SELF)
		return
	set_picture("ai_bsod")

/obj/machinery/status_display/examine(mob/user)
	. = ..()
	if (message1_overlay || message2_overlay)
		. += "The display says:"
		if (message1_overlay.message)
			. += "<br>\t<tt>[html_encode(message1_overlay.message)]</tt>"
		if (message2_overlay.message)
			. += "<br>\t<tt>[html_encode(message2_overlay.message)]</tt>"

// Helper procs for child display types.
/obj/machinery/status_display/proc/display_shuttle_status(obj/docking_port/mobile/shuttle)
	if(!shuttle)
		// the shuttle is missing - no processing
		update_display("shutl?","")
		return PROCESS_KILL
	else if(shuttle.timer)
		var/line1 = "-[shuttle.getModeStr()]-"
		var/line2 = shuttle.getTimerStr()

		if(length_char(line2) > CHARS_PER_LINE)
			line2 = "error"
		update_display(line1, line2)
	else
		// don't kill processing, the timer might turn back on
		remove_display()

/obj/machinery/status_display/proc/examine_shuttle(mob/user, obj/docking_port/mobile/shuttle)
	if (shuttle)
		var/modestr = shuttle.getModeStr()
		if (modestr)
			if (shuttle.timer)
				modestr = "<br>\t<tt>[modestr]: [shuttle.getTimerStr()]</tt>"
			else
				modestr = "<br>\t<tt>[modestr]</tt>"
		return "The display says:<br>\t<tt>[shuttle.name]</tt>[modestr]"
	else
		return "The display says:<br>\t<tt>Shuttle missing!</tt>"

/**
 * Nice overlay to make text smoothly scroll with no client updates after setup.
 */
/obj/effect/overlay/status_display_text
	icon = 'icons/obj/status_display.dmi'
	vis_flags = VIS_INHERIT_LAYER | VIS_INHERIT_PLANE | VIS_INHERIT_ID

	var/message = ""

/obj/effect/overlay/status_display_text/New(yoffset, line)
	maptext_y = yoffset
	message = line

	var/line_length = length_char(line)

	if(line_length > CHARS_PER_LINE)
		// Marquee text
		var/marquee_message = "[line] • [line] • [line]"
		var/marqee_length = line_length * 3 + 6
		maptext = generate_text(marquee_message, center = FALSE)
		maptext_width = 6 * marqee_length
		maptext_x = 32

		// Mask off to fit in screen.
		add_filter("mask", 1, alpha_mask_filter(icon = icon(icon, "outline")))

		// Scroll.
		var/width = 4 * marqee_length
		var/time = (width + 32) * SCROLL_RATE
		animate(src, maptext_x = -width, time = time, loop = -1)
		animate(maptext_x = 32, time = 0)
	else
		// Centered text
		maptext = generate_text(line, center = TRUE)
		maptext_x = 0

/obj/effect/overlay/status_display_text/proc/generate_text(text, center)
	return {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]'[center ? ";text-align:center" : ""]" valign="top">[text]</div>"}

/// Evac display which shows shuttle timer or message set by Command.
/obj/machinery/status_display/evac
	var/frequency = FREQ_STATUS_DISPLAYS
	var/mode = SD_EMERGENCY
	var/friendc = FALSE      // track if Friend Computer mode
	var/last_picture  // For when Friend Computer mode is undone

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/evac, 32)

//makes it go on the wall when built
/obj/machinery/status_display/Initialize(mapload, ndir, building)
	. = ..()
	update_appearance()

/obj/machinery/status_display/evac/Initialize(mapload)
	. = ..()
	// register for radio system
	SSradio.add_object(src, frequency)

/obj/machinery/status_display/evac/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/machinery/status_display/evac/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		remove_display()
		return PROCESS_KILL

	if(friendc) //Makes all status displays except supply shuttle timer display the eye -- Urist
		set_picture("ai_friend")
		return PROCESS_KILL

	switch(mode)
		if(SD_BLANK)
			remove_display()
			return PROCESS_KILL

		if(SD_EMERGENCY)
			return display_shuttle_status(SSshuttle.emergency)

		if(SD_MESSAGE)
			return PROCESS_KILL

		if(SD_PICTURE)
			set_picture(last_picture)
			return PROCESS_KILL

/obj/machinery/status_display/evac/examine(mob/user)
	. = ..()
	if(mode == SD_EMERGENCY)
		. += examine_shuttle(user, SSshuttle.emergency)
	else if(!message1_overlay && !message2_overlay)
		. += "The display is blank."

/obj/machinery/status_display/evac/receive_signal(datum/signal/signal)
	switch(signal.data["command"])
		if("blank")
			mode = SD_BLANK
			remove_display()
		if("shuttle")
			mode = SD_EMERGENCY
			remove_display()
		if("message")
			mode = SD_MESSAGE
			update_display(signal.data["msg1"], signal.data["msg2"])
		if("alert")
			mode = SD_PICTURE
			last_picture = signal.data["picture_state"]
			set_picture(last_picture)
		if("friendcomputer")
			friendc = !friendc
	update()


/// Supply display which shows the status of the supply shuttle.
/obj/machinery/status_display/supply
	name = "supply display"

/obj/machinery/status_display/supply/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		remove_display()
		return PROCESS_KILL

	var/line1
	var/line2
	if(!SSshuttle.supply)
		// Might be missing in our first update on initialize before shuttles
		// have loaded. Cross our fingers that it will soon return.
		line1 = "CARGO"
		line2 = "shutl?"
	else if(SSshuttle.supply.mode == SHUTTLE_IDLE)
		if(is_station_level(SSshuttle.supply.z))
			line1 = "CARGO"
			line2 = "Docked"
	else
		line1 = "CARGO"
		line2 = SSshuttle.supply.getTimerStr()
		if(length_char(line2) > CHARS_PER_LINE)
			line2 = "Error"
	update_display(line1, line2)

/obj/machinery/status_display/supply/examine(mob/user)
	. = ..()
	var/obj/docking_port/mobile/shuttle = SSshuttle.supply
	var/shuttleMsg = null
	if (shuttle.mode == SHUTTLE_IDLE)
		if (is_station_level(shuttle.z))
			shuttleMsg = "Docked"
	else
		shuttleMsg = "[shuttle.getModeStr()]: [shuttle.getTimerStr()]"
	if (shuttleMsg)
		. += "The display says:<br>\t<tt>[shuttleMsg]</tt>"
	else
		. += "The display is blank."


/// General-purpose shuttle status display.
/obj/machinery/status_display/shuttle
	name = "shuttle display"
	var/shuttle_id

/obj/machinery/status_display/shuttle/process()
	if(!shuttle_id || (machine_stat & NOPOWER))
		// No power, no processing.
		remove_display()
		return PROCESS_KILL

	return display_shuttle_status(SSshuttle.getShuttle(shuttle_id))

/obj/machinery/status_display/shuttle/examine(mob/user)
	. = ..()
	if(shuttle_id)
		. += examine_shuttle(user, SSshuttle.getShuttle(shuttle_id))
	else
		. += "The display is blank."

/obj/machinery/status_display/shuttle/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return
	switch(var_name)
		if(NAMEOF(src, shuttle_id))
			update()

/obj/machinery/status_display/shuttle/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	if(port)
		shuttle_id = port.id
	update()


/// Pictograph display which the AI can use to emote.
/obj/machinery/status_display/ai
	name = "\improper AI display"
	desc = "A small screen which the AI can use to present itself."

	var/emotion = AI_EMOTION_BLANK

	/// A mapping between AI_EMOTION_* string constants, which also double as user readable descriptions, and the name of the iconfile.
	var/static/list/emotion_map = list(
		AI_EMOTION_BLANK = "ai_off",
		AI_EMOTION_VERY_HAPPY = "ai_veryhappy",
		AI_EMOTION_HAPPY = "ai_happy",
		AI_EMOTION_NEUTRAL = "ai_neutral",
		AI_EMOTION_UNSURE = "ai_unsure",
		AI_EMOTION_CONFUSED = "ai_confused",
		AI_EMOTION_SAD = "ai_sad",
		AI_EMOTION_BSOD = "ai_bsod",
		AI_EMOTION_PROBLEMS = "ai_trollface",
		AI_EMOTION_AWESOME = "ai_awesome",
		AI_EMOTION_DORFY = "ai_urist",
		AI_EMOTION_THINKING = "ai_thinking",
		AI_EMOTION_FACEPALM = "ai_facepalm",
		AI_EMOTION_FRIEND_COMPUTER = "ai_friend",
		AI_EMOTION_BLUE_GLOW = "ai_sal",
		AI_EMOTION_RED_GLOW = "ai_hal",
	)


MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ai, 32)

/obj/machinery/status_display/ai/Initialize(mapload)
	. = ..()
	GLOB.ai_status_displays.Add(src)

/obj/machinery/status_display/ai/Destroy()
	GLOB.ai_status_displays.Remove(src)
	. = ..()

/obj/machinery/status_display/ai/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	var/list/choices = list()
	for(var/emotion_const in emotion_map)
		var/icon_state = emotion_map[emotion_const]
		choices[emotion_const] = image(icon = 'icons/obj/status_display.dmi', icon_state = icon_state)

	var/emotion_result = show_radial_menu(user, src, choices, tooltips = TRUE)
	for(var/_emote in typesof(/datum/emote/ai/emotion_display))
		var/datum/emote/ai/emotion_display/emote = _emote
		if(initial(emote.emotion) == emotion_result)
			user.emote(initial(emote.key))
			break

/obj/machinery/status_display/ai/process()
	if(machine_stat & NOPOWER)
		remove_display()
		return PROCESS_KILL

	set_picture(emotion_map[emotion])
	return PROCESS_KILL

#undef CHARS_PER_LINE
#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_RATE
#undef LINE1_Y
#undef LINE2_Y
