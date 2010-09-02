///////////////////////////////////////////////////////////////////////////////////////////////
// Brig Door control displays.
//  Description: This is a controls the timer for the brig doors, displays the timer on itself and
//               has a popup window when used, allowing to set the timer.
//  Code Notes: Combination of old brigdoor.dm code from rev4407 and the status_display.dm code
//  Date: 01/September/2010
//  Programmer: Veryinky
/////////////////////////////////////////////////////////////////////////////////////////////////
/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'status_display.dmi'
	icon_state = "frame"
	desc = "A remote control for a door."
	req_access = list(access_brig)
	anchored = 1.0    		// can't pick it up
	density = 0       		// can walk through it.
	var/id = null     		// id of door it controls.
	var/time = 1      		// defaults to 0 seconds timer
	var/timing = 1    		// boolean, true/1 timer is on, false/0 means it's not timing
	var/childproof = 0		// boolean, when activating the door controls, locks door for 1 minute
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers

//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process()
	..()
	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
		else
			src.opendoor() // open doors, reset timer, clear status screen
			src.time = 0
			src.timing = 0
		src.updateDialog()
		src.update_icon()
	else // keep door open may cause lag as it's checking every second if someone closed door
		for(var/obj/machinery/door/window/brigdoor/M in world)
			if (M.id == src.id)
				if(M.density)
					spawn( 0 )
						M.open()
	return

// has the door power sitatuation changed, if so update icon.
/obj/machinery/door_timer/power_change()
	update_icon()

// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.
/obj/machinery/door_timer/proc/opendoor()
	if(stat & (NOPOWER|BROKEN))
		return
	for(var/obj/machinery/door/window/brigdoor/M in world)
		if (M.id == src.id)
			if(M.density)
				spawn( 0 )
					M.open()
	src.updateUsrDialog()
	src.update_icon()
	return

/obj/machinery/door_timer/proc/closedoor()
	if(stat & (NOPOWER|BROKEN))
		return
	for(var/obj/machinery/door/window/brigdoor/M in world)
		if (M.id == src.id)
			if(!M.density)
				spawn( 0 )
					M.close()
	src.updateUsrDialog()
	src.update_icon()
	return


//Allows AIs to use door_timer, see human attack_hand function below
/obj/machinery/door_timer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

//Allows monkeys to use door_timer, see human attack_hand function below
/obj/machinery/door_timer/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

//Allows humans to use door_timer
//Opens dialog window when someone clicks on door timer
// Allows altering timer and the timing boolean.
// Flasher activation limited to 150 seconds
/obj/machinery/door_timer/attack_hand(var/mob/user as mob)
	if(..())
		return
	var/dat = "<HTML><BODY><TT><B>Door [src.id] controls</B>"
	user.machine = src
	var/d2
	if (!src.timing)
		update_display("SET","TIME")
	if (src.timing)
		d2 = text("<A href='?src=\ref[];time=0'>Stop Timer</A><br>", src)
	else
		d2 = text("<A href='?src=\ref[];time=1'>Set Timer</A><br>", src)
	var/second = src.time % 60
	var/minute = (src.time - second) / 60
	dat += text("<br><HR>\nTimer System: [d2]\nTime Left: [(minute ? text("[minute]:") : null)][second] <A href='?src=\ref[src];tp=-60'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=60'>+</A>")
	for(var/obj/machinery/flasher/F in world)
		if(F.id == src.id)
			if(F.last_flash && world.time < F.last_flash + 150)
				dat += text("<BR><BR><A href='?src=\ref[];fc=1'>Flash Cell (Charging)</A>", src)
			else
				dat += text("<BR><BR><A href='?src=\ref[];fc=1'>Flash Cell</A>", src)
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=computer'>Close</A></TT></BODY></HTML>", user)
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

//Function for using door_timer dialog input, checks if user has permission
// href_list to
//  "time" turns on timer
//  "tp" value to modify timer
//  "fc" activates flasher
// Also updates dialog window and timer icon
/obj/machinery/door_timer/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["time"])
			if(src.allowed(usr))
				src.timing = text2num(href_list["time"])
				src.closedoor()
		else
			if (href_list["tp"])  //adjust timer, close door if not already closed
				if(src.allowed(usr))
					var/tp = text2num(href_list["tp"])
					src.time += tp
					src.time = min(max(round(src.time), 0), 600)
					src.timing = 1
					src.closedoor()
			if (href_list["fc"])
				if(src.allowed(usr))
					for (var/obj/machinery/flasher/F in world)
						if (F.id == src.id)
							F.flash()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		src.update_icon()
	if (!src.timing) // was a timer set? if not, open door.
		src.opendoor()
	return

//icon update function
// if NOPOWER, display blank
// if BROKEN, display blue screen of death icon AI uses
// if timing=true, run update display function
/obj/machinery/door_timer/proc/update_icon()
	var/disp1
	var/disp2
	disp1 = uppertext(id)
	disp2 = "[add_zero(num2text((time / 60) % 60),2)]~[add_zero(num2text(time % 60), 2)]"
	if(stat & (NOPOWER))
		icon_state = "frame"
		return
	else
		if(stat & (BROKEN))
			set_picture("ai_bsod")
			return
		else
			if(src.timing)
				spawn( 5 )
					update_display(disp1, disp2)

// Adds an icon in case the screen is broken/off, stolen from status_display.dm
/obj/machinery/door_timer/proc/set_picture(var/state)
	picture_state = state
	overlays = null
	overlays += image('status_display.dmi', icon_state=picture_state)

//Checks to see if there's 1 line or 2, adds text-icons-numbers/letters over display
// Stolen from status_display
/obj/machinery/door_timer/proc/update_display(var/line1, var/line2)
	if(line2 == null)		// single line display
		overlays = null
		overlays += texticon(line1, 23, -13)
	else					// dual line display
		overlays = null
		overlays += texticon(line1, 23, -9)
		overlays += texticon(line2, 23, -17)
	// return an icon of a time text string (tn)
	// valid characters are 0-9 and :
	// px, py are pixel offsets

//Actual string input to icon display for loop, with 5 pixel x offsets for each letter.
//Stolen from status_display
/obj/machinery/door_timer/proc/texticon(var/tn, var/px = 0, var/py = 0)
	var/image/I = image('status_display.dmi', "blank")
	var/len = lentext(tn)

	for(var/d = 1 to len)
		var/char = copytext(tn, len-d+1, len-d+2)
		if(char == " ")
			continue
		var/image/ID = image('status_display.dmi', icon_state=char)
		ID.pixel_x = -(d-1)*5 + px
		ID.pixel_y = py

		I.overlays += ID

	return I


