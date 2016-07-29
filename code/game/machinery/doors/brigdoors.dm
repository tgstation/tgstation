<<<<<<< HEAD
#define CHARS_PER_LINE 5
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Arial Black"
#define MAX_TIMER 9000

#define PRESET_SHORT 1200
#define PRESET_MEDIUM 3000
#define PRESET_LONG 6000

//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer
	name = "door timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(access_security)
	anchored = 1
	density = 0
	var/id = null // id of linked machinery/lockers

	var/activation_time = 0
	var/timer_duration = 0

	var/timing = FALSE		// boolean, true/1 timer is on, false/0 means it's not timing
	var/list/obj/machinery/targets = list()
	var/obj/item/device/radio/Radio //needed to send messages to sec radio

	maptext_height = 26
	maptext_width = 32

/obj/machinery/door_timer/New()
	..()

	Radio = new/obj/item/device/radio(src)
	Radio.listening = 0

/obj/machinery/door_timer/initialize()
	for(var/obj/machinery/door/window/brigdoor/M in urange(20, src))
		if (M.id == id)
			targets += M

	for(var/obj/machinery/flasher/F in urange(20, src))
		if(F.id == id)
			targets += F

	for(var/obj/structure/closet/secure_closet/brig/C in urange(20, src))
		if(C.id == id)
			targets += C

	if(!targets.len)
		stat |= BROKEN
	update_icon()


//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(timing)
		if(world.time - activation_time >= timer_duration)
			timer_end() // open doors, reset timer, clear status screen
		update_icon()

// has the door power sitatuation changed, if so update icon.
/obj/machinery/door_timer/power_change()
	..()
	update_icon()


// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.
/obj/machinery/door_timer/proc/timer_start()
	if(stat & (NOPOWER|BROKEN))
		return 0

	activation_time = world.time
	timing = TRUE

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(door.density)
			continue
		addtimer(door, "close", 0)

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened && !C.close())
			continue
		C.locked = 1
		C.update_icon()
	return 1


/obj/machinery/door_timer/proc/timer_end(forced = FALSE)

	if(stat & (NOPOWER|BROKEN))
		return 0

	if(!forced)
		Radio.set_frequency(SEC_FREQ)
		Radio.talk_into(src, "Timer has expired. Releasing prisoner.", SEC_FREQ)

	timing = FALSE
	activation_time = null
	set_timer(0)
	update_icon()

	for(var/obj/machinery/door/window/brigdoor/door in targets)
		if(!door.density)
			continue
		addtimer(door, "open", 0)

	for(var/obj/structure/closet/secure_closet/brig/C in targets)
		if(C.broken)
			continue
		if(C.opened)
			continue
		C.locked = 0
		C.update_icon()

	return 1


/obj/machinery/door_timer/proc/time_left(seconds = FALSE)
	. = max(0,timer_duration - (activation_time ? world.time - activation_time : 0))
	if(seconds)
		. /= 10

/obj/machinery/door_timer/proc/set_timer(value)
	var/new_time = Clamp(value,0,MAX_TIMER)
	. = new_time == timer_duration //return 1 on no change
	timer_duration = new_time

/obj/machinery/door_timer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, \
										datum/tgui/master_ui = null, datum/ui_state/state = default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "brig_timer", name, 300, 200, master_ui, state)
		ui.open()

//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/door_timer/update_icon()
	if(stat & (NOPOWER))
		icon_state = "frame"
		return

	if(stat & (BROKEN))
		set_picture("ai_bsod")
		return

	if(timing)
		var/disp1 = id
		var/time_left = time_left(seconds = TRUE)
		var/disp2 = "[add_zero(num2text((time_left / 60) % 60),2)]~[add_zero(num2text(time_left % 60), 2)]"
		if(length(disp2) > CHARS_PER_LINE)
			disp2 = "Error"
		update_display(disp1, disp2)
	else
		if(maptext)
			maptext = ""
	return


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/door_timer/proc/set_picture(state)
	if(maptext)
		maptext = ""
	cut_overlays()
	add_overlay(image('icons/obj/status_display.dmi', icon_state=state))


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/door_timer/proc/update_display(line1, line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text

/obj/machinery/door_timer/ui_data()
	var/list/data = list()
	var/time_left = time_left(seconds = TRUE)
	data["seconds"] = round(time_left % 60)
	data["minutes"] = round((time_left - data["seconds"]) / 60)
	data["timing"] = timing
	data["flash_charging"] = FALSE
	for(var/obj/machinery/flasher/F in targets)
		if(F.last_flash && (F.last_flash + 150) > world.time)
			data["flash_charging"] = TRUE
			break
	return data


/obj/machinery/door_timer/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("time")
			var/value = text2num(params["adjust"])
			if(value)
				. = set_timer(time_left()+value)
		if("start")
			timer_start()
		if("stop")
			timer_end(forced = TRUE)
		if("flash")
			for(var/obj/machinery/flasher/F in targets)
				F.flash()
		if("preset")
			var/preset = params["preset"]
			var/preset_time = time_left()
			switch(preset)
				if("short")
					preset_time = PRESET_SHORT
				if("medium")
					preset_time = PRESET_MEDIUM
				if("long")
					preset_time = PRESET_LONG
			. = set_timer(preset_time)
			if(timing)
				activation_time = world.time
		else
			. = FALSE


#undef PRESET_SHORT
#undef PRESET_MEDIUM
#undef PRESET_LONG

#undef MAX_TIMER
#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef CHARS_PER_LINE
=======
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/september/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(access_brig)
	anchored = 1.0    		// can't pick it up
	density = 0       		// can walk through it.
	var/id_tag = null     	// id of door it controls.
	var/releasetime = 0		// when world.time reaches it - release the prisoneer
	var/timing = 1    		// boolean, true/1 timer is on, false/0 means it's not timing
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers
	var/list/obj/machinery/targets = list()


	New()
		..()

		pixel_x = ((src.dir & 3)? (0) : (src.dir == 4 ? 32 : -32))
		pixel_y = ((src.dir & 3)? (src.dir ==1 ? 32 : -32) : (0))

		spawn(20)
			for(var/obj/machinery/door/window/brigdoor/M in all_doors)
				if (M.id_tag == src.id_tag)
					targets += M

			for(var/obj/machinery/flasher/F in flashers)
				if(F.id_tag == src.id_tag)
					targets += F

			for(var/obj/structure/closet/secure_closet/brig/C in world)
				if(C.id_tag == src.id_tag)
					targets += C

			if(targets.len==0)
				stat |= BROKEN
			update_icon()
			return
		return


//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
	process()
		if(stat & (NOPOWER|BROKEN))	return
		if(src.timing)
			if(world.time > src.releasetime)
				src.timer_end() // open doors, reset timer, clear status screen
				src.timing = 0
			src.updateUsrDialog()
			src.update_icon()
		else
			timer_end()
		return


// has the door power sitatuation changed, if so update icon.
	power_change()
		..()
		update_icon()
		return


// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.
	proc/timer_start()
		if(stat & (NOPOWER|BROKEN))	return 0

		for(var/obj/machinery/door/window/brigdoor/door in targets)
			if(door.density)	continue
			spawn(0)
				door.close()

		for(var/obj/structure/closet/secure_closet/brig/C in targets)
			if(C.broken)	continue
			if(C.opened && !C.close())	continue
			C.locked = 1
			C.icon_state = C.icon_locked
		return 1


	proc/timer_end()
		if(stat & (NOPOWER|BROKEN))	return 0

		for(var/obj/machinery/door/window/brigdoor/door in targets)
			if(!door.density)	continue
			spawn(0)
				door.open()

		for(var/obj/structure/closet/secure_closet/brig/C in targets)
			if(C.broken)	continue
			if(C.opened)	continue
			C.locked = 0
			C.icon_state = C.icon_closed

		return 1


	proc/timeleft()
		. = (releasetime-world.time)/10
		if(. < 0)
			. = 0


	proc/timeset(var/seconds)
		releasetime=world.time+seconds*10
		return


//Allows AIs to use door_timer, see human attack_hand function below
	attack_ai(var/mob/user as mob)
		src.add_hiddenprint(user)
		return src.attack_hand(user)


//Allows humans to use door_timer
//Opens dialog window when someone clicks on door timer
// Allows altering timer and the timing boolean.
// Flasher activation limited to 150 seconds
	attack_hand(var/mob/user as mob)
		if(..())
			return
		var/second = round(timeleft() % 60)
		var/minute = round((timeleft() - second) / 60)
		user.set_machine(src)
		var/dat = "<HTML><BODY><TT>"

		dat += {"<HR>Timer System:</hr>
			<b>Door [src.id_tag] controls</b><br/>"}
		if (src.timing)
			dat += "<a href='?src=\ref[src];timing=0'>Stop Timer and open door</a><br/>"
		else
			dat += "<a href='?src=\ref[src];timing=1'>Activate Timer and close door</a><br/>"


		dat += {"Time Left: [(minute ? text("[minute]:") : null)][second] <br/>
			<a href='?src=\ref[src];tp=-60'>-</a> <a href='?src=\ref[src];tp=-1'>-</a> <a href='?src=\ref[src];tp=1'>+</a> <A href='?src=\ref[src];tp=60'>+</a><br/>"}
		for(var/obj/machinery/flasher/F in targets)
			if(F.last_flash && (F.last_flash + 150) > world.time)
				dat += "<br/><A href='?src=\ref[src];fc=1'>Flash Charging</A>"
			else
				dat += "<br/><A href='?src=\ref[src];fc=1'>Activate Flash</A>"


		dat += {"<br/><br/><a href='?src=\ref[user];mach_close=computer'>Close</a>
			</TT></BODY></HTML>"}
		user << browse(dat, "window=computer;size=400x500")
		onclose(user, "computer")
		return


//Function for using door_timer dialog input, checks if user has permission
// href_list to
//  "timing" turns on timer
//  "tp" value to modify timer
//  "fc" activates flasher
// Also updates dialog window and timer icon
	Topic(href, href_list)
		if(..())
			return
		if(!src.allowed(usr))
			return

		usr.set_machine(src)
		if(href_list["timing"])
			src.timing = text2num(href_list["timing"])
		else
			if(href_list["tp"])  //adjust timer, close door if not already closed
				var/tp = text2num(href_list["tp"])
				var/timeleft = timeleft()
				timeleft += tp
				timeleft = min(max(round(timeleft), 0), 3600)
				timeset(timeleft)
				//src.timing = 1
				//src.closedoor()
			if(href_list["fc"])
				for(var/obj/machinery/flasher/F in targets)
					F.flash()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		src.update_icon()
		if(src.timing)
			src.timer_start()
		else
			src.timer_end()
		return


//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
	update_icon()
		if(stat & (NOPOWER))
			icon_state = "frame"
			return
		if(stat & (BROKEN))
			set_picture("ai_bsod")
			return
		if(src.timing)
			var/disp1 = uppertext(id_tag)
			var/timeleft = timeleft()
			var/disp2 = "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
			spawn( 5 )
				update_display(disp1, disp2)
		else
			update_display("SET","TIME")
		return


// Adds an icon in case the screen is broken/off, stolen from status_display.dm
	proc/set_picture(var/state)
		picture_state = state
		overlays.len = 0
		overlays += image('icons/obj/status_display.dmi', icon_state=picture_state)


//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
	proc/update_display(var/line1, var/line2)
		if(line2 == null)		// single line display
			overlays.len = 0
			overlays += texticon(line1, 23, -13)
		else					// dual line display
			overlays.len = 0
			overlays += texticon(line1, 23, -9)
			overlays += texticon(line2, 23, -17)
		// return an icon of a time text string (tn)
		// valid characters are 0-9 and :
		// px, py are pixel offsets


//Actual string input to icon display for loop, with 5 pixel x offsets for each letter.
//Stolen from status_display
	proc/texticon(var/tn, var/px = 0, var/py = 0)
		var/image/I = image('icons/obj/status_display.dmi', "blank")
		var/len = length(tn)

		for(var/d = 1 to len)
			var/char = copytext(tn, len-d+1, len-d+2)
			if(char == " ")
				continue
			var/image/ID = image('icons/obj/status_display.dmi', icon_state=char)
			ID.pixel_x = -(d-1)*5 + px
			ID.pixel_y = py
			I.overlays += ID
		return I


/obj/machinery/door_timer/cell_1
	name = "Cell 1"
	id_tag = "Cell 1"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_2
	name = "Cell 2"
	id_tag = "Cell 2"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_3
	name = "Cell 3"
	id_tag = "Cell 3"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_4
	name = "Cell 4"
	id_tag = "Cell 4"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_5
	name = "Cell 5"
	id_tag = "Cell 5"
	dir = 2
	pixel_y = -32


/obj/machinery/door_timer/cell_6
	name = "Cell 6"
	id_tag = "Cell 6"
	dir = 4
	pixel_x = 32
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
