/obj/machinery/computer/telescience
	name = "telepad control console"
	desc = "Used to teleport objects to and from the telescience telepad."
	icon_state = "teleport"
	var/sending = 1

	// VARIABLES //
	var/teles_left	// How many teleports left until it becomes uncalibrated
	var/x_off	// X offset
	var/y_off	// Y offset
	var/x_co	// X coordinate
	var/y_co	// Y coordinate
	var/z_co	// Z coordinate

/obj/machinery/computer/telescience/New()
	teles_left = rand(8,12)
	x_off = rand(-10,10)
	y_off = rand(-10,10)

/obj/machinery/computer/telescience/update_icon()
	if(stat & BROKEN)
		icon_state = "telescib"
	else
		if(stat & NOPOWER)
			src.icon_state = "teleport0"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER

/obj/machinery/computer/telescience/attack_paw(mob/user)
	user << "You are too primitive to use this computer."
	return

/obj/machinery/computer/telescience/attack_ai(mob/user)
	src.attack_hand(user)

/obj/machinery/computer/telescience/attack_hand(mob/user)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	var/t = ""
	t += "<A href='?src=\ref[src];setx=1'>Set X</A>"
	t += "<A href='?src=\ref[src];sety=1'>Set Y</A>"
	t += "<A href='?src=\ref[src];setz=1'>Set Z</A>"
	t += "<BR><BR>Current set coordinates:"
	t += "([x_co], [y_co], [z_co])"
	t += "<BR><BR><A href='?src=\ref[src];send=1'>Send</A>"
	t += " <A href='?src=\ref[src];receive=1'>Receive</A>"
	t += "<BR><BR><A href='?src=\ref[src];recal=1'>Recalibrate</A>"
	var/datum/browser/popup = new(user, "telesci", name, 640, 480)
	popup.set_content(t)
	popup.open()
	return
/obj/machinery/computer/telescience/proc/sparks()
	for(var/obj/machinery/telepad/E in machines)
		var/L = get_turf(E)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, L)
		s.start()
/obj/machinery/computer/telescience/proc/telefail()
	sparks()
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class = 'caution'>The telepad weakly fizzles.</span>", 2)
	return
/obj/machinery/computer/telescience/proc/doteleport(mob/user)
	var/trueX = (x_co + x_off)
	var/trueY = (y_co + y_off)
	for(var/obj/machinery/telepad/E in machines)
		var/L = get_turf(E)
		var/T = locate(trueX, trueY, z_co)
		var/G = get_turf(T)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, L)
		s.start()
		flick("pad-beam", E)
		usr << "<span class = 'caution'> Teleport successful.</span>"
		var/sparks = get_turf(T)
		var/datum/effect/effect/system/spark_spread/y = new /datum/effect/effect/system/spark_spread
		y.set_up(5, 1, sparks)
		y.start()
		for(var/obj/ROI in G)
			if(sending == 1)
				do_teleport(ROI, E, 0)
			else
				do_teleport(ROI, G, 0)
		for(var/mob/RSM in G)
			if(sending == 1)
				do_teleport(RSM, E, 0)
			else
				do_teleport(RSM, G, 0)
		return
	return

/obj/machinery/computer/telescience/proc/teleport(mob/user)
	if(x_co == "" || y_co == "" || z_co == "")
		user << "<span class = 'caution'>  Error: set coordinates.</span>"
		return
	if(x_co < 1 || x_co > 255)
		telefail()
		user << "<span class = 'caution'>  Error: X is less than 1 or greater than 255.</span>"
		return
	if(y_co < 1 || y_co > 255)
		telefail()
		user << "<span class = 'caution'>  Error: Y is less than 1 or greater than 255.</span>"
		return
	if(z_co == 2 || z_co < 1 || z_co > 6)
		telefail()
		user << "<span class = 'caution'>  Error: Z is less than 1, greater than 6, or equal to 2.</span>"
		return
	if(teles_left > 0)
		teles_left -= 1
		doteleport()
	else
		telefail()
		return
	return

/obj/machinery/computer/telescience/Topic(href, href_list)
	if(..())
		return
	if(href_list["setx"])
		input("Please input desired X coordinate.", name, x_co) as num
		return
	if(href_list["sety"])
		input("Please input desired Y coordinate.", name, y_co) as num
		return
	if(href_list["setz"])
		input("Please input desired Z coordinate.", name, z_co) as num
		return
	if(href_list["send"])
		sending = 1
		teleport()
		return
	if(href_list["receive"])
		sending = 0
		teleport()
		return
	if(href_list["recal"])
		teles_left = rand(9,12)
		x_off = rand(-10,10)
		y_off = rand(-10,10)
		sparks()
		usr << "<span class = 'caution'> Calibration successful.</span>"
		return