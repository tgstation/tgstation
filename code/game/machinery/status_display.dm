// Status display
// (formerly Countdown timer display)

#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Small Fonts"
#define SCROLL_SPEED 2

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
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10

	maptext_height = 26
	maptext_width = 32
	maptext_y = -1

	var/message1 = "" // message line 1
	var/message2 = "" // message line 2
	var/index1 // display index for scrolling messages or 0 if non-scrolling
	var/index2

/// Immediately blank the display.
/obj/machinery/status_display/proc/remove_display()
	cut_overlays()
	if(maptext)
		maptext = ""

/// Immediately change the display to the given picture.
/obj/machinery/status_display/proc/set_picture(state)
	remove_display()
	add_overlay(state)

/// Immediately change the display to the given two lines.
/obj/machinery/status_display/proc/update_display(line1, line2)
	line1 = uppertext(line1)
	line2 = uppertext(line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/// Prepare the display to marquee the given two lines.
///
/// Call with no arguments to disable.
/obj/machinery/status_display/proc/set_message(m1, m2)
	if(m1)
		index1 = (length_char(m1) > CHARS_PER_LINE)
		message1 = m1
	else
		message1 = ""
		index1 = 0

	if(m2)
		index2 = (length_char(m2) > CHARS_PER_LINE)
		message2 = m2
	else
		message2 = ""
		index2 = 0

// Timed process - performs default marquee action if so needed.
/obj/machinery/status_display/process()
	if(machine_stat & NOPOWER)
		// No power, no processing.
		remove_display()
		return PROCESS_KILL

	var/line1 = message1
	if(index1)
		line1 = copytext_char("[message1]|[message1]", index1, index1 + CHARS_PER_LINE)
		var/message1_len = length_char(message1)
		index1 += SCROLL_SPEED
		if(index1 > message1_len + 1)
			index1 -= (message1_len + 1)

	var/line2 = message2
	if(index2)
		line2 = copytext_char("[message2]|[message2]", index2, index2 + CHARS_PER_LINE)
		var/message2_len = length_char(message2)
		index2 += SCROLL_SPEED
		if(index2 > message2_len + 1)
			index2 -= (message2_len + 1)

	update_display(line1, line2)
	if (!index1 && !index2)
		// No marquee, no processing.
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
	if (message1 || message2)
		. += "The display says:"
		if (message1)
			. += "<br>\t<tt>[html_encode(message1)]</tt>"
		if (message2)
			. += "<br>\t<tt>[html_encode(message2)]</tt>"

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


/// Evac display which shows shuttle timer or message set by Command.
/obj/machinery/status_display/evac
	var/frequency = FREQ_STATUS_DISPLAYS
	var/mode = SD_EMERGENCY
	var/friendc = FALSE      // track if Friend Computer mode
	var/last_picture  // For when Friend Computer mode is undone

/obj/machinery/status_display/evac/Initialize()
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
			return ..()

		if(SD_PICTURE)
			set_picture(last_picture)
			return PROCESS_KILL

/obj/machinery/status_display/evac/examine(mob/user)
	. = ..()
	if(mode == SD_EMERGENCY)
		. += examine_shuttle(user, SSshuttle.emergency)
	else if(!message1 && !message2)
		. += "The display is blank."

/obj/machinery/status_display/evac/receive_signal(datum/signal/signal)
	switch(signal.data["command"])
		if("blank")
			mode = SD_BLANK
			set_message(null, null)
		if("shuttle")
			mode = SD_EMERGENCY
			set_message(null, null)
		if("message")
			mode = SD_MESSAGE
			set_message(signal.data["msg1"], signal.data["msg2"])
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

/obj/machinery/status_display/ai/Initialize()
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
#undef SCROLL_SPEED
