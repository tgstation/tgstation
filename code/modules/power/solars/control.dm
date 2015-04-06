/obj/machinery/power/solar/control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/computer.dmi'
	icon_state = "solar"
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 300
	var/id_tag = 0
	var/cdir = 0
	var/gen = 0
	var/lastgen = 0
	var/track = 0			//0 = off  1 = manual  2 = automatic
	var/trackrate = 60		//Measured in tenths of degree per minute (i.e. defaults to 6.0 deg/min)
	var/trackdir = 1		//-1 = CCW, 1 = CW
	var/nexttime = 0		//Next clock time that manual tracking will move the array

	l_color = "#FF9933"

/obj/machinery/power/solar/control/initialize()
	..()

	if(get_powernet())
		set_panels(cdir)

/obj/machinery/power/solar/control/Destroy()
	for(var/obj/machinery/power/solar/panel/P in getPowernetNodes())
		if(P.control == src)
			P.control = null

	..()

/obj/machinery/power/solar/control/update_icon()
	overlays.len = 0

	if(stat & BROKEN)
		icon_state = "broken"
		return

	if(stat & NOPOWER)
		icon_state = "c_unpowered"
		return

	icon_state = "solar"

	if(cdir > 0)
		overlays += image('icons/obj/computer.dmi', "solcon-o", FLY_LAYER, angle2dir(cdir))

/obj/machinery/power/solar/control/attack_ai(mob/user)
	add_hiddenprint(user)
	interact(user)

/obj/machinery/power/solar/control/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/power/solar/control/process()
	lastgen = gen
	gen = 0

	if(stat & (NOPOWER | BROKEN))
		return

	if(track == 1 && nexttime < world.time && trackdir * trackrate)
		// Increments nexttime using itself and not world.time to prevent drift
		nexttime = nexttime + 6000 / trackrate
		// Nudges array 1 degree in desired direction
		cdir = (cdir + trackdir + 360) % 360
		set_panels(cdir)
		update_icon()

	updateDialog()

/obj/machinery/power/solar/control/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/screwdriver))
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if(src.stat & BROKEN)
				visible_message("<span class='notice'>[user] clears the broken monitor off of [src].</span>", \
				"You clear the broken monitor off of [src]")
				var/obj/structure/computerframe/A = new /obj/structure/computerframe(src.loc)
				getFromPool(/obj/item/weapon/shard, loc)
				var/obj/item/weapon/circuitboard/solar_control/M = new /obj/item/weapon/circuitboard/solar_control(A)
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				qdel(src)
			else
				visible_message("[user] begins to unscrew \the [src]'s monitor.",
				"You begin to unscrew the monitor...")
				var/obj/structure/computerframe/A = new /obj/structure/computerframe(src.loc)
				var/obj/item/weapon/circuitboard/solar_control/M = new /obj/item/weapon/circuitboard/solar_control(A)
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				qdel(src)
	else
		src.attack_hand(user)

// called by solar tracker when sun position changes (somehow, that's not supposed to be in process)
/obj/machinery/power/solar/control/proc/tracker_update(angle)
	if(track != 2 || stat & (NOPOWER | BROKEN))
		return

	cdir = angle
	set_panels(cdir)
	update_icon()
	updateDialog()

/obj/machinery/power/solar/control/interact(mob/user)
	if(stat & (BROKEN | NOPOWER))
		return

	if (!src.Adjacent(user))
		if (!issilicon(user)&&!isobserver(user))
			user.unset_machine()
			user << browse(null, "window=solcon")
			return

	user.set_machine(src)


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\power\solar.dm:407: var/t = "<TT><B>Solar Generator Control</B><HR><PRE>"
	var/t = {"<TT><B>Solar Generator Control</B><HR><PRE>
<B>Generated power</B> : [round(lastgen)] W<BR>
Station Orbital Period : [60/abs(sun.rotationRate)] minutes<BR>
Station Orbital Direction : [sun.rotationRate < 0 ? "CCW" : "CW"]<BR>
Star Orientation : [sun.angle]&deg ([angle2text(sun.angle)])<BR>
Array Orientation : [rate_control(src,"cdir","[cdir]&deg",1,10,60)] ([angle2text(cdir)])<BR>
<BR><HR><BR>
Tracking :"}
	// END AUTOFIX
	switch(track)
		if(0)
			t += "<B>Off</B> <A href='?src=\ref[src];track=1'>Manual</A> <A href='?src=\ref[src];track=2'>Automatic</A><BR>"
		if(1)
			t += "<A href='?src=\ref[src];track=0'>Off</A> <B>Manual</B> <A href='?src=\ref[src];track=2'>Automatic</A><BR>"
		if(2)
			t += "<A href='?src=\ref[src];track=0'>Off</A> <A href='?src=\ref[src];track=1'>Manual</A> <B>Automatic</B><BR>"


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\power\solar.dm:423: t += "Manual Tracking Rate: [rate_control(src,"tdir","[trackrate/10]&deg/min ([trackdir<0 ? "CCW" : "CW"])",1,10)]<BR>"
	t += {"Manual Tracking Rate: [rate_control(src,"tdir","[trackrate/10]&deg/min ([trackdir<0 ? "CCW" : "CW"])",1,10)]<BR>
Manual Tracking Direction:"}
	// END AUTOFIX
	switch(trackdir)
		if(-1)
			t += "<A href='?src=\ref[src];trackdir=1'>CW</A> <B>CCW</B><BR>"
		if(1)
			t += "<B>CW</B> <A href='?src=\ref[src];trackdir=-1'>CCW</A><BR>"
	t += "<A href='?src=\ref[src];close=1'>Close</A></TT>"
	user << browse(t, "window=solcon")
	onclose(user, "solcon")
	return

/obj/machinery/power/solar/control/Topic(href, href_list)
	if(..())
		usr << browse(null, "window=solcon")
		usr.unset_machine()
		return

	if(href_list["close"] )
		usr << browse(null, "window=solcon")
		usr.unset_machine()
		return

	if(href_list["dir"])
		cdir = text2num(href_list["dir"])
		set_panels(cdir)
		update_icon()

	if(href_list["rate control"])
		if(href_list["cdir"])
			cdir = Clamp((360 + cdir + text2num(href_list["cdir"])) % 360, 0, 359)
			spawn(1)
				set_panels(cdir)
				update_icon()
		if(href_list["tdir"])
			trackrate = Clamp(trackrate + text2num(href_list["tdir"]), 0, 360)
			if(trackrate)
				nexttime = world.time + 6000 / trackrate

	if(href_list["track"])
		if(trackrate)
			nexttime = world.time + 6000 / trackrate

		track = text2num(href_list["track"])

		if(track == 2)
			for(var/obj/machinery/power/solar/panel/tracker/T in getPowernetNodes())
				cdir = T.sun_angle
				break

	if(href_list["trackdir"])
		trackdir = text2num(href_list["trackdir"])

	set_panels(cdir)
	update_icon()
	updateUsrDialog()

/obj/machinery/power/solar/control/proc/set_panels(var/cdir)
	for(var/obj/machinery/power/solar/panel/P in getPowernetNodes())
		if(get_dist(P, src) < SOLAR_MAX_DIST)
			if(!P.control)
				P.control = src

			P.ndir = cdir

/obj/machinery/power/solar/control/power_change()
	if(powered())
		stat &= ~NOPOWER
		update_icon()
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			update_icon()

/obj/machinery/power/solar/control/proc/broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/power/solar/control/meteorhit()
	broken()
	return

/obj/machinery/power/solar/control/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				broken()
		if(3.0)
			if (prob(25))
				broken()

/obj/machinery/power/solar/control/blob_act()
	if(prob(75))
		broken()
		density = 0