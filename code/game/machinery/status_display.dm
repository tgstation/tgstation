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

#define MODE_BLANK				0
#define MODE_SHUTTLE_TIMER		1
#define MODE_MESSAGE			2
#define MODE_IMAGE				3
#define MODE_CARGO_TIMER		4

var/global/list/status_displays = list() //This list contains both normal status displays, and AI status dispays

/obj/machinery/status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "status display"
	anchored = 1
	density = 0
	use_power = 1
	idle_power_usage = 10
	var/mode = 1	// 0 = Blank
					// 1 = Shuttle timer
					// 2 = Arbitrary message(s)
					// 3 = alert picture
					// 4 = Supply shuttle timer

	var/picture_state	// icon_state of alert picture
	var/message1 = ""	// message line 1
	var/message2 = ""	// message line 2
	var/index1			// display index for scrolling messages or 0 if non-scrolling
	var/index2

	var/frequency = 1435		// radio frequency
	var/supply_display = 0		// true if a supply shuttle display

	var/friendc = 0      // track if Friend Computer mode

	var/spookymode=0 // Ghosts.

	maptext_height = 26
	maptext_width = 32

// new display
// register for radio system
/obj/machinery/status_display/New()
	..()
	status_displays |= src
	spawn(5)	// must wait for map loading to finish
		if(radio_controller)
			radio_controller.add_object(src, frequency)

/obj/machinery/status_display/Destroy()
	.=..()
	status_displays -= src

// timed process
/obj/machinery/status_display/process()
	if(stat & NOPOWER)
		remove_display()
		return
	if(spookymode)
		spookymode = 0
		remove_display()
		return
	update()

/obj/machinery/status_display/attack_ai(mob/user)
	if(spookymode)	return
	if(user.stat)	return

	if(isAI(user)) //This allows AIs to load any image into the status displays
		//Some fluff
		if(user.stat)
			to_chat(user, "<span class='warning'>Unable to connect to [src] (error #408)</span>")
			return
		if(stat & (BROKEN|NOPOWER))
			to_chat(user, "<span class='warning'>Unable to connect to [src] (error #[(stat & BROKEN) ? "120" : "408"])</span>")
			return

		var/mob/living/silicon/ai/A = user

		var/choice = input(A, "Select a mode for [src].", "Status display") in list("Blank", "Emergency shuttle timer", "Text message", "Picture", "Supply shuttle timer")

		switch(choice)
			if("Blank")
				mode = MODE_BLANK
			if("Emergency shuttle timer")
				mode = MODE_SHUTTLE_TIMER
			if("Text message")
				var/msg1 = input(A, "Write the first line: ", "Status display", message1) //First line
				var/msg2 = input(A, "Write the second line: ", "Status display", message2) //Second line
				mode = MODE_MESSAGE

				set_message(msg1, msg2)
			if("Picture")
				var/new_icon = input(A, "Load an image to be desplayed on [src].", "Status display") in status_display_images

				if(new_icon)
					src.mode = MODE_IMAGE
					src.set_picture(status_display_images[new_icon])
			if("Supply shuttle timer")
				mode = MODE_CARGO_TIMER

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
		if(MODE_BLANK)				//blank
			remove_display()
		if(MODE_SHUTTLE_TIMER)				//emergency shuttle timer
			if(emergency_shuttle.online)
				var/line1
				var/line2 = get_shuttle_timer()
				if(emergency_shuttle.location == 1)
					line1 = "-ETD-"
				else
					line1 = "-ETA-"
				if(length(line2) > CHARS_PER_LINE)
					line2 = "Error!"
				update_display(line1, line2)
			else
				remove_display()
		if(MODE_MESSAGE)				//custom messages
			remove_display()

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
		if(MODE_CARGO_TIMER)				// supply shuttle timer
			var/line1 = "SUPPLY"
			var/line2
			if(supply_shuttle.moving)
				line2 = get_supply_shuttle_timer()
				if(length(line2) > CHARS_PER_LINE)
					line2 = "Error"
			else
				if(supply_shuttle.at_station)
					line2 = "Docked"
				else
					line1 = ""
			update_display(line1, line2)

/obj/machinery/status_display/examine(mob/user)
	. = ..()
	switch(mode)
		if(MODE_SHUTTLE_TIMER,MODE_MESSAGE,MODE_CARGO_TIMER)
			to_chat(user, "<span class='info'>The display says:<br>\t<xmp>[message1]</xmp><br>\t<xmp>[message2]</xmp></span>")


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
	overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)

/obj/machinery/status_display/proc/update_display(line1, line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/obj/machinery/status_display/proc/get_shuttle_timer()
	var/timeleft = emergency_shuttle.timeleft()
	if(timeleft)
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	return ""

/obj/machinery/status_display/proc/get_supply_shuttle_timer()
	if(supply_shuttle.moving)
		var/timeleft = round((supply_shuttle.eta_timeofday - world.timeofday) / 10,1)
		if(timeleft < 0)
			return "Late"
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	return ""

/obj/machinery/status_display/proc/remove_display()
	if(overlays.len)
		overlays.len = 0
	if(maptext)
		maptext = ""

/obj/machinery/status_display/receive_signal(datum/signal/signal)
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

		if("supply")
			if(supply_display)
				mode = 4

/obj/machinery/status_display/spook()
	if(..())
		spookymode = 1

#undef MODE_BLANK
#undef MODE_SHUTTLE_TIMER
#undef MODE_MESSAGE
#undef MODE_IMAGE
#undef MODE_CARGO_TIMER

//This list contains ALL possible overlays for AI status display. It contains overlay's name (like "Very Happy"), associated with the name of the icon state ("ai_veryhappy").
var/global/list/ai_emotions = list(
	"Very Happy"		= "ai_veryhappy",
	"Happy"				= "ai_happy",
	"Neutral"			= "ai_neutral",
	"Unsure"			= "ai_unsure",
	"Confused"			= "ai_confused",
	"Sad"				= "ai_sad",
	"Surprised"			= "ai_surprised",
	"Agree"				= "ai_agree",
	"Disagree"			= "ai_disagree",
	"Crying"			= "ai_cry",
	"Awesome"			= "ai_awesome",
	"BSOD"				= "ai_bsod",
	"Problems?"			= "ai_trollface",
	"Facepalm"			= "ai_facepalm",
	"Friend Computer"	= "ai_friend",
	"Retro Dorfy"		= "ai_urist",
	"Modern Dorfy"		= "ai_dwarf",
	"Beer"				= "ai_beer",
	"Tribunal"			= "ai_tribunal",
	"Malf Tribunal"		= "ai_tribunal_malf",
	"Plump Helmet"		= "ai_plump",
	"Fish Tank"			= "ai_fishtank",
)

//This list contains ALL possible overlays for both AI status displays, and normal status displays
var/global/list/status_display_images = list(
	"NT Logo"			= "default",
	"Red Alert"			= "redalert",
	"Biohazard"			= "biohazard",
	"Lockdown"			= "lockdown",

	"Very Happy"		= "ai_veryhappy",
	"Happy"				= "ai_happy",
	"Neutral"			= "ai_neutral",
	"Unsure"			= "ai_unsure",
	"Confused"			= "ai_confused",
	"Sad"				= "ai_sad",
	"Surprised"			= "ai_surprised",
	"Agree"				= "ai_agree",
	"Disagree"			= "ai_disagree",
	"Crying"			= "ai_cry",
	"Awesome"			= "ai_awesome",
	"BSOD"				= "ai_bsod",
	"Problems?"			= "ai_trollface",
	"Facepalm"			= "ai_facepalm",
	"Friend Computer"	= "ai_friend",
	"Retro Dorfy"		= "ai_urist",
	"Modern Dorfy"		= "ai_dwarf",
	"Beer"				= "ai_beer",
	"Tribunal"			= "ai_tribunal",
	"Malf Tribunal"		= "ai_tribunal_malf",
	"Plump Helmet"		= "ai_plump",
	"Fish Tank"			= "ai_fishtank",)

#define MODE_BLANK		0
#define MODE_EMOTION	1
#define MODE_BSOD		2

/obj/machinery/ai_status_display
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	name = "AI display"
	anchored = 1
	density = 0

	var/spookymode=0 // Ghosts

	var/mode = 0	// 0 = Blank
					// 1 = AI emoticon
					// 2 = Blue screen of death

	var/picture_state	// icon_state of ai picture

	var/emotion = "Neutral"

/obj/machinery/ai_status_display/New()
	..()
	status_displays |= src

/obj/machinery/ai_status_display/Destroy()
	.=..()
	status_displays -= src

/obj/machinery/ai_status_display/attack_ai(mob/user)
	if(spookymode)	return
	if(user.stat)	return

	if(isAI(user)) //This allows AIs to load any image into the status displays
		var/mob/living/silicon/ai/A = user

		//Some fluff
		if(user.stat)
			to_chat(user, "<span class='warning'>Unable to connect to [src] (error #408)</span>")
			return
		if(stat & (BROKEN|NOPOWER))
			to_chat(user, "<span class='warning'>Unable to connect to [src] (error #[(stat & BROKEN) ? "120" : "408"])</span>")
			return

		var/new_icon = input(A, "Load an image to be desplayed on [src].", "AI status display") in status_display_images

		if(new_icon)
			src.mode = MODE_EMOTION
			src.emotion = new_icon
			src.set_picture(status_display_images[new_icon])

/obj/machinery/ai_status_display/process()
	if(stat & NOPOWER)
		overlays.len = 0
		return
	if(spookymode)
		spookymode = 0
		overlays.len = 0
		return

	update()

/obj/machinery/ai_status_display/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	set_picture("ai_bsod")
	..(severity)

/obj/machinery/ai_status_display/proc/update()
	switch(mode)
		if(MODE_BLANK)
			overlays = list()

		if(MODE_EMOTION)
			if(emotion in status_display_images)
				set_picture(status_display_images[emotion])
			else
				set_picture("ai_bsod") //Can't find icon state for our emotion - throw a BSOD

		if(MODE_BSOD)
			set_picture("ai_bsod")

/obj/machinery/ai_status_display/proc/set_picture(var/state)
	picture_state = state
	if(overlays.len)
		overlays.len = 0
	overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)

/obj/machinery/ai_status_display/spook()
	spookymode = 1

#undef MODE_BLANK
#undef MODE_EMOTION
#undef MODE_BSOD

#undef CHARS_PER_LINE
#undef FOND_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_SPEED
