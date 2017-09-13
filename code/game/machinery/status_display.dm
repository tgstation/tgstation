#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Arial Black"
#define SCROLL_SPEED 2

// Status display
// (formerly Countdown timer display)

// Use to show shuttle ETA/ETD times
// Alert status
// And arbitrary messages set by comms computer

/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "status display"
	anchored = TRUE
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	var/mode = 1	// 0 = Blank
					// 1 = Emergency Shuttle timer
					// 2 = Arbitrary message(s)
					// 3 = alert picture
					// 4 = Supply shuttle timer
					// 5 = Generic shuttle timer

	var/picture_state	// icon_state of alert picture
	var/message1 = ""	// message line 1
	var/message2 = ""	// message line 2
	var/index1			// display index for scrolling messages or 0 if non-scrolling
	var/index2

	var/frequency = 1435		// radio frequency
	var/supply_display = 0		// true if a supply shuttle display
	var/shuttle_id				// Id used for "generic shuttle timer" mode

	var/friendc = 0      // track if Friend Computer mode

	maptext_height = 26
	maptext_width = 32

	// new display
	// register for radio system

/obj/machinery/status_display/Initialize()
	. = ..()
	GLOB.ai_status_displays.Add(src)
	SSradio.add_object(src, frequency)

/obj/machinery/status_display/Destroy()
	SSradio.remove_object(src,frequency)
	GLOB.ai_status_displays.Remove(src)
	return ..()

// timed process

/obj/machinery/status_display/process()
	if(stat & NOPOWER)
		remove_display()
		return
	update()

/obj/machinery/status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

// set what is displayed

/obj/machinery/status_display/proc/update()
	if(friendc && mode!=4) //Makes all status displays except supply shuttle timer display the eye -- Urist
		set_picture("ai_friend")
		return

	switch(mode)
		if(0)				//blank
			remove_display()
		if(1)				//emergency shuttle timer
			display_shuttle_status()
		if(2)				//custom messages
			var/line1
			var/line2

			if(!index1)
				line1 = message1
			else
				line1 = copytext(message1+"|"+message1, index1, index1+CHARS_PER_LINE)
				var/message1_len = length(message1)
				index1 += SCROLL_SPEED
				if(index1 > message1_len)
					index1 -= message1_len

			if(!index2)
				line2 = message2
			else
				line2 = copytext(message2+"|"+message2, index2, index2+CHARS_PER_LINE)
				var/message2_len = length(message2)
				index2 += SCROLL_SPEED
				if(index2 > message2_len)
					index2 -= message2_len
			update_display(line1, line2)
		if(4)				// supply shuttle timer
			var/line1
			var/line2
			if(SSshuttle.supply.mode == SHUTTLE_IDLE)
				if(SSshuttle.supply.z in GLOB.station_z_levels)
					line1 = "CARGO"
					line2 = "Docked"
			else
				line1 = "CARGO"
				line2 = SSshuttle.supply.getTimerStr()
				if(lentext(line2) > CHARS_PER_LINE)
					line2 = "Error"

			update_display(line1, line2)
		if(5)
			display_shuttle_status()

/obj/machinery/status_display/examine(mob/user)
	. = ..()
	switch(mode)
		if(1,2,4,5)
			to_chat(user, "The display says:<br>\t<xmp>[message1]</xmp><br>\t<xmp>[message2]</xmp>")
	if(mode == 1 && SSshuttle.emergency)
		to_chat(user, "Current Shuttle: [SSshuttle.emergency.name]")


/obj/machinery/status_display/proc/set_message(m1, m2)
	if(m1)
		index1 = (length(m1) > CHARS_PER_LINE)
		message1 = m1
	else
		message1 = ""
		index1 = 0

	if(m2)
		index2 = (length(m2) > CHARS_PER_LINE)
		message2 = m2
	else
		message2 = ""
		index2 = 0

/obj/machinery/status_display/proc/set_picture(state)
	picture_state = state
	remove_display()
	add_overlay(picture_state)

/obj/machinery/status_display/proc/update_display(line1, line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/obj/machinery/status_display/proc/remove_display()
	cut_overlays()
	if(maptext)
		maptext = ""

/obj/machinery/status_display/proc/display_shuttle_status()
	var/obj/docking_port/mobile/shuttle

	if(mode == 1)
		shuttle = SSshuttle.emergency
	else
		shuttle = SSshuttle.getShuttle(shuttle_id)

	if(!shuttle)
		update_display("shutl?","")
	else if(shuttle.timer)
		var/line1 = "-[shuttle.getModeStr()]-"
		var/line2 = shuttle.getTimerStr()

		if(length(line2) > CHARS_PER_LINE)
			line2 = "Error!"
		update_display(line1, line2)
	else
		remove_display()


/obj/machinery/status_display/receive_signal(datum/signal/signal)
	if(supply_display)
		mode = 4
		return
	switch(signal.data["command"])
		if("blank")
			mode = 0
		if("shuttle")
			mode = 1
		if("message")
			mode = 2
			set_message(signal.data["msg1"], signal.data["msg2"])
		if("alert")
			mode = 3
			set_picture(signal.data["picture_state"])

/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	desc = "A small screen which the AI can use to present itself."
	icon_state = "frame"
	name = "\improper AI display"
	anchored = TRUE
	density = FALSE

	var/mode = 0	// 0 = Blank
					// 1 = AI emoticon
					// 2 = Blue screen of death

	var/picture_state	// icon_state of ai picture

	var/emotion = "Neutral"

/obj/machinery/ai_status_display/Initialize()
	. = ..()
	GLOB.ai_status_displays.Add(src)

/obj/machinery/ai_status_display/Destroy()
	GLOB.ai_status_displays.Remove(src)
	. = ..()

/obj/machinery/ai_status_display/attack_ai(mob/living/silicon/ai/user)
	if(isAI(user))
		user.ai_statuschange()

/obj/machinery/ai_status_display/process()
	if(stat & NOPOWER)
		cut_overlays()
		return

	update()

/obj/machinery/ai_status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

/obj/machinery/ai_status_display/proc/update()

	if(mode==0) //Blank
		cut_overlays()
		return

	if(mode==1)	// AI emoticon
		switch(emotion)
			if("Very Happy")
				set_picture("ai_veryhappy")
			if("Happy")
				set_picture("ai_happy")
			if("Neutral")
				set_picture("ai_neutral")
			if("Unsure")
				set_picture("ai_unsure")
			if("Confused")
				set_picture("ai_confused")
			if("Sad")
				set_picture("ai_sad")
			if("BSOD")
				set_picture("ai_bsod")
			if("Blank")
				set_picture("ai_off")
			if("Problems?")
				set_picture("ai_trollface")
			if("Awesome")
				set_picture("ai_awesome")
			if("Dorfy")
				set_picture("ai_urist")
			if("Facepalm")
				set_picture("ai_facepalm")
			if("Friend Computer")
				set_picture("ai_friend")
			if("Blue Glow")
				set_picture("ai_sal")
			if("Red Glow")
				set_picture("ai_hal")

		return

	if(mode==2)	// BSOD
		set_picture("ai_bsod")
		return


/obj/machinery/ai_status_display/proc/set_picture(state)
	picture_state = state
	cut_overlays()
	add_overlay(picture_state)

#undef CHARS_PER_LINE
#undef FOND_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_SPEED
