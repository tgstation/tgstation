/obj/machinery/computer/door_control
	name = "Door Control"
	icon = 'stationobjs.dmi'
	icon_state = "sec_computer"
	req_access = list(access_brig)
//	var/authenticated = 0.0		if anyone wants to make it so you need to log in in future go ahead.
	var/id = 1.0

/obj/machinery/computer/door_control/proc/alarm()
	if(stat & (NOPOWER|BROKEN))
		return
	for(var/obj/machinery/door/window/brigdoor/M in world)
		if (M.id == src.id)
			if(M.density)
				spawn( 0 )
					M.open()
			else
				spawn( 0 )
					M.close()
	src.updateUsrDialog()
	return

/obj/machinery/computer/door_control/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/door_control/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/door_control/attack_hand(var/mob/user as mob)
	if(..())
		return
	var/dat = "<HTML><BODY><TT><B>Brig Computer</B><br><br>"
	user.machine = src
	for(var/obj/machinery/door/window/brigdoor/M in world)
		if(M.id == 1)
			dat += text("<A href='?src=\ref[src];setid=1'>Door 1: [(M.density ? "Closed" : "Opened")]</A><br>")
		else if(M.id == 2)
			dat += text("<A href='?src=\ref[src];setid=2'>Door 2: [(M.density ? "Closed" : "Opened")]</A><br>")
		else if(M.id == 3)
			dat += text("<A href='?src=\ref[src];setid=3'>Door 3: [(M.density ? "Closed" : "Opened")]</A><br>")
		else if(M.id == 4)
			dat += text("<A href='?src=\ref[src];setid=4'>Door 4: [(M.density ? "Closed" : "Opened")]</A><br>")
		else if(M.id == 5)
			dat += text("<A href='?src=\ref[src];setid=5'>Door 5: [(M.density ? "Closed" : "Opened")]</A><br>")
		else
			world << "Invalid ID detected on brigdoor ([M.x],[M.y],[M.z]) with id [M.id]"
	dat += text("<br><A href='?src=\ref[src];openall=1'>Open All</A><br>")
	dat += text("<A href='?src=\ref[src];closeall=1'>Close All</A><br>")
	dat += text("<BR><BR><A href='?src=\ref[user];mach_close=computer'>Close</A></TT></BODY></HTML>")
	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return

/obj/machinery/computer/door_control/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["setid"])
			if(src.allowed(usr))
				src.id = text2num(href_list["setid"])
				src.alarm()
		if (href_list["openall"])
			if(src.allowed(usr))
				for(var/obj/machinery/door/window/brigdoor/M in world)
					if(M.density)
						M.open()
		if (href_list["closeall"])
			if(src.allowed(usr))
				for(var/obj/machinery/door/window/brigdoor/M in world)
					if(!M.density)
						M.close()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return




//////////////////////////////////////////////////////////////////////////////////////////////////////////




/obj/machinery/door_timer
	name = "Door Timer"
	icon = 'stationobjs.dmi'
	icon_state = "doortimer0"
	desc = "A remote control switch for a door."
	req_access = list(access_brig)
	anchored = 1.0
	var/id = null
	var/time = 30.0
	var/timing = 0.0

/obj/machinery/door_timer/process()
	..()
	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
		else
			alarm()
			src.time = 0
			src.timing = 0
		src.updateDialog()
		src.update_icon()
	return

/obj/machinery/door_timer/power_change()
	update_icon()


/obj/machinery/door_timer/proc/alarm()
	if(stat & (NOPOWER|BROKEN))
		return
	for(var/obj/machinery/door/window/brigdoor/M in world)
		if (M.id == src.id)
			if(M.density)
				spawn( 0 )
					M.open()
			else
				spawn( 0 )
					M.close()
	for(var/obj/secure_closet/brig/B in world)
		if (B.id == src.id)
			if(B.locked)
				B.locked = 0
			B.icon_state = text("[(B.locked ? "1" : null)]secloset0")
	src.updateUsrDialog()
	src.update_icon()
	return

/obj/machinery/door_timer/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_timer/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/door_timer/attack_hand(var/mob/user as mob)
	if(..())
		return

	var/dat = "<HTML><BODY><TT><B>Door [src.id] controls</B>"
	user.machine = src
	var/d2
	if (src.timing)
		d2 = text("<A href='?src=\ref[];time=0'>Stop Timed</A><br>", src)
	else
		d2 = text("<A href='?src=\ref[];time=1'>Initiate Time</A><br>", src)
	var/second = src.time % 60
	var/minute = (src.time - second) / 60
	dat += text("<br><HR>\nTimer System: [d2]\nTime Left: [(minute ? text("[minute]:") : null)][second] <A href='?src=\ref[src];tp=-30'>-</A> <A href='?src=\ref[src];tp=-1'>-</A> <A href='?src=\ref[src];tp=1'>+</A> <A href='?src=\ref[src];tp=30'>+</A>")
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

/obj/machinery/door_timer/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["time"])
			if(src.allowed(usr))
				src.timing = text2num(href_list["time"])
		else
			if (href_list["tp"])
				if(src.allowed(usr))
					var/tp = text2num(href_list["tp"])
					src.time += tp
					src.time = min(max(round(src.time), 0), 600)
			if (href_list["fc"])
				if(src.allowed(usr))
					for (var/obj/machinery/flasher/F in world)
						if (F.id == src.id)
							F.flash()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		src.update_icon()
	return

/obj/machinery/door_timer/proc/update_icon()
	if(stat & (NOPOWER))
		icon_state = "doortimer-p"
		return
	else if(stat & (BROKEN))
		icon_state = "doortimer-b"
		return
	else
		if(src.timing)
			icon_state = "doortimer1"
		else if(src.time > 0)
			icon_state = "doortimer0"
		else
			spawn( 50 )
				icon_state = "doortimer0"
			icon_state = "doortimer2"