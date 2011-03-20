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
	var/releasetime = 0		// when world.time reaches it - release the prisoneer
	var/timing = 1    		// boolean, true/1 timer is on, false/0 means it's not timing
	var/childproof = 0		// boolean, when activating the door controls, locks door for 1 minute
	var/picture_state		// icon_state of alert picture, if not displaying text/numbers
	var/list/obj/machinery/door/window/brigdoor/targetdoors = new
	var/list/obj/machinery/flasher/targetflashers = new

/obj/machinery/door_timer/New()
	..()
	for(var/obj/machinery/door/window/brigdoor/M in world)
		if (M.id == src.id)
			targetdoors += M
			break
	if (targetdoors.len==0)
		stat |= BROKEN
	targetflashers = list()
	for(var/obj/machinery/flasher/F in world)
		if(F.id == src.id)
			targetflashers += F
	update_icon()

//Main door timer loop, if it's timing and time is >0 reduce time by 1.
// if it's less than 0, open door, reset timer
// update the door_timer window and the icon
/obj/machinery/door_timer/process()
	if (stat & (NOPOWER|BROKEN))
		return
	if (src.timing)
		if (world.time > src.releasetime)
			src.opendoor() // open doors, reset timer, clear status screen
			src.timing = 0
		src.updateUsrDialog()
		src.update_icon()
	else
		opendoor()
	return

// has the door power sitatuation changed, if so update icon.
/obj/machinery/door_timer/power_change()
	..()
	update_icon()

// open/closedoor checks if door_timer has power, if so it checks if the
// linked door is open/closed (by density) then opens it/closes it.
/obj/machinery/door_timer/proc/opendoor()
	if(stat & (NOPOWER|BROKEN))
		return
	for (var/obj/machinery/door/window/brigdoor/targetdoor in targetdoors)
		if(targetdoor.density)
			spawn( 0 )
				targetdoor.open()
	return

/obj/machinery/door_timer/proc/closedoor()
	if(stat & (NOPOWER|BROKEN))
		return
	for (var/obj/machinery/door/window/brigdoor/targetdoor in targetdoors)
		if(!targetdoor.density)
			spawn( 0 )
				targetdoor.close()
	return

/obj/machinery/door_timer/proc/timeleft()
	. = (releasetime-world.time)/10
	if (. < 0)
		. = 0

/obj/machinery/door_timer/proc/timeset(var/seconds)
	releasetime=world.time+seconds*10

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
	if (src.timing)
		d2 = text("<A href='?src=\ref[];timing=0'>Stop Timer and open doors</A><br>", src)
	else
		d2 = text("<A href='?src=\ref[];timing=1'>Activate Timer and close doors</A><br>", src)
	var/timeleft = timeleft()
	var/second = round(timeleft % 60)
	var/minute = round((timeleft - second) / 60)
	dat += text("<br><HR>\nTimer System: [d2]\nTime Left: [(minute ? text("[minute]:") : null)][second] <A href='?src=\ref[src];tp=-60'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=60'>+</A>")
	if (targetflashers.len)
		dat += "<BR>"
	for(var/obj/machinery/flasher/F in targetflashers)
		if(F.last_flash && (F.last_flash + 150) > world.time)
			dat += text("<BR><A href='?src=\ref[];fc=1'>Flash Cell (Charging)</A>", src)
		else
			dat += text("<BR><A href='?src=\ref[];fc=1'>Flash Cell</A>", src)
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=computer'>Close</A></TT></BODY></HTML>", user)
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

//Function for using door_timer dialog input, checks if user has permission
// href_list to
//  "timing" turns on timer
//  "tp" value to modify timer
//  "fc" activates flasher
// Also updates dialog window and timer icon
/obj/machinery/door_timer/Topic(href, href_list)
	if(..())
		return
	if(!src.allowed(usr))
		return

	usr.machine = src
	if (href_list["timing"])
		src.timing = text2num(href_list["timing"])
	else
		if (href_list["tp"])  //adjust timer, close door if not already closed
			var/tp = text2num(href_list["tp"])
			var/timeleft = timeleft()
			timeleft += tp
			timeleft = min(max(round(timeleft), 0), 600)
			timeset(timeleft)
			//src.timing = 1
			//src.closedoor()
		if (href_list["fc"])
			for (var/obj/machinery/flasher/F in targetflashers)
				F.flash()
	src.add_fingerprint(usr)
	src.updateUsrDialog()
	src.update_icon()
	if (src.timing)
		src.closedoor()
	else
		src.opendoor()
	return

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
	if(src.timing)
		var/disp1 = uppertext(id)
		var/timeleft = timeleft()
		var/disp2 = "[add_zero(num2text((timeleft / 60) % 60),2)]~[add_zero(num2text(timeleft % 60), 2)]"
		spawn( 5 )
			update_display(disp1, disp2)
	else
		update_display("SET","TIME")

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


