//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:05

#define SOLARGENRATE 1500
/obj/machinery/power/solar
	name = "solar panel"
	desc = "A solar electrical generator."
	icon = 'power.dmi'
	icon_state = "sp_base"
	anchored = 1
	density = 1
	directwired = 1
	use_power = 0
	idle_power_usage = 0
	active_power_usage = 0
	var/health = 10
	var/id = 1
	var/obscured = 0
	var/sunfrac = 0
	var/adir = SOUTH
	var/ndir = SOUTH
	var/turn_angle = 0
	var/obj/machinery/power/solar_control/control = null
	proc
		healthcheck()
		updateicon()
		update_solar_exposure()
		broken()


	New()
		..()
		spawn(10)
			updateicon()
			update_solar_exposure()
			if(powernet)
				for(var/obj/machinery/power/solar_control/SC in powernet.nodes)
					if(SC.id == id)
						control = SC


	attackby(obj/item/weapon/W, mob/user)
		..()
		if (W)
			src.add_fingerprint(user)
			src.health -= W.force
			src.healthcheck()
			return


	blob_act()
		src.health--
		src.healthcheck()
		return


	healthcheck()
		if (src.health <= 0)
			if(!(stat & BROKEN))
				broken()
			else
				new /obj/item/weapon/shard(src.loc)
				new /obj/item/weapon/shard(src.loc)
				del(src)
				return
		return


	updateicon()
		overlays = null
		if(stat & BROKEN)
			overlays += image('power.dmi', icon_state = "solar_panel-b", layer = FLY_LAYER)
		else
			overlays += image('power.dmi', icon_state = "solar_panel", layer = FLY_LAYER)
			src.dir = angle2dir(adir)
		return


	update_solar_exposure()
		if(!sun)
			return
		if(obscured)
			sunfrac = 0
			return
		var/p_angle = abs((360+adir)%360 - (360+sun.angle)%360)
		if(p_angle > 90)			// if facing more than 90deg from sun, zero output
			sunfrac = 0
			return
		sunfrac = cos(p_angle) ** 2


	process()
		if(stat & BROKEN)	return
		if(!control)	return
		if(obscured)	return

		var/sgen = SOLARGENRATE * sunfrac
		add_avail(sgen)
		if(powernet && control)
			if(control in powernet.nodes) //this line right here...
				control.gen += sgen

		if(adir != ndir)
			spawn(10+rand(0,15))
				adir = (360+adir+dd_range(-10,10,ndir-adir))%360
				updateicon()
				update_solar_exposure()


	broken()
		stat |= BROKEN
		updateicon()
		return


	meteorhit()
		if(stat & !BROKEN)
			broken()
		else
			del(src)


	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				if(prob(15))
					new /obj/item/weapon/shard( src.loc )
				return
			if(2.0)
				if (prob(25))
					new /obj/item/weapon/shard( src.loc )
					del(src)
					return
				if (prob(50))
					broken()
			if(3.0)
				if (prob(25))
					broken()
		return


	blob_act()
		if(prob(75))
			broken()
			src.density = 0


/obj/machinery/power/solar/fake/process()
	machines.Remove(src)
	return




/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'computer.dmi'
	icon_state = "solar"
	anchored = 1
	density = 1
	directwired = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 20
	var/id = 1
	var/cdir = 0
	var/gen = 0
	var/lastgen = 0
	var/track = 2			// 0= off  1=timed  2=auto (tracker)
	var/trackrate = 600		// 300-900 seconds
	var/trackdir = 1		// 0 =CCW, 1=CW
	var/nexttime = 0
	proc
		updateicon()
		tracker_update(var/angle)
		set_panels(var/cdir)
		broken()
		interact(mob/user)


	New()
		..()
		spawn(15)
			if(!powernet) return
			for(var/obj/machinery/power/solar/S in powernet.nodes)
				if(S.id != id) continue
				cdir = S.adir//The hell is this even doing?
				S.control = src
				updateicon()


	updateicon()
		if(stat & BROKEN)
			icon_state = "broken"
			overlays = null
			return
		if(stat & NOPOWER)
			icon_state = "c_unpowered"
			overlays = null
			return
		icon_state = "solar"
		overlays = null
		if(cdir > 0)
			overlays += image('computer.dmi', "solcon-o", FLY_LAYER, angle2dir(cdir))
		return


	attack_ai(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN | NOPOWER)) return
		interact(user)


	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN | NOPOWER)) return
		interact(user)


	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					new /obj/item/weapon/shard( src.loc )
					var/obj/item/weapon/circuitboard/solar_control/M = new /obj/item/weapon/circuitboard/solar_control( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					del(src)
				else
					user << "\blue You disconnect the monitor."
					var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
					var/obj/item/weapon/circuitboard/solar_control/M = new /obj/item/weapon/circuitboard/solar_control( A )
					for (var/obj/C in src)
						C.loc = src.loc
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					del(src)
		else
			src.attack_hand(user)
		return


	process()
		lastgen = gen
		gen = 0

		if(stat & (NOPOWER | BROKEN))
			return

		use_power(250)
		if(track==1 && nexttime < world.timeofday && trackrate)
			nexttime = world.timeofday + 3600/abs(trackrate)
			cdir = (cdir+trackrate/abs(trackrate)+360)%360
			set_panels(cdir)
			updateicon()

		src.updateDialog()


// called by solar tracker when sun position changes
	tracker_update(var/angle)
		if(track != 2 || stat & (NOPOWER | BROKEN))
			return
		cdir = angle
		set_panels(cdir)
		updateicon()
		src.updateDialog()


	interact(mob/user)
		if(stat & (BROKEN | NOPOWER)) return
		if ( (get_dist(src, user) > 1 ))
			if (!istype(user, /mob/living/silicon/ai))
				user.machine = null
				user << browse(null, "window=solcon")
				return

		add_fingerprint(user)
		user.machine = src

		var/t = "<TT><B>Solar Generator Control</B><HR><PRE>"
		t += "Generated power : [round(lastgen)] W<BR><BR>"
		t += "<B>Orientation</B>: [rate_control(src,"cdir","[cdir]&deg",1,15)] ([angle2text(cdir)])<BR><BR><BR>"
		t += "<BR><HR><BR><BR>"
		t += "Tracking: "
		switch(track)
			if(0)
				t += "<B>Off</B> <A href='?src=\ref[src];track=1'>Timed</A> <A href='?src=\ref[src];track=2'>Auto</A><BR>"
			if(1)
				t += "<A href='?src=\ref[src];track=0'>Off</A> <B>Timed</B> <A href='?src=\ref[src];track=2'>Auto</A><BR>"
			if(2)
				t += "<A href='?src=\ref[src];track=0'>Off</A> <A href='?src=\ref[src];track=1'>Timed</A> <B>Auto</B><BR>"

		t += "Tracking Rate: [rate_control(src,"tdir","[trackrate] deg/h ([trackrate<0 ? "CCW" : "CW"])",5,30,180)]<BR><BR>"
		t += "<A href='?src=\ref[src];close=1'>Close</A></TT>"
		user << browse(t, "window=solcon")
		onclose(user, "solcon")
		return


	Topic(href, href_list)
		if(..())
			usr << browse(null, "window=solcon")
			usr.machine = null
			return
		if(href_list["close"] )
			usr << browse(null, "window=solcon")
			usr.machine = null
			return

		if(href_list["dir"])
			cdir = text2num(href_list["dir"])
			spawn(1)
				set_panels(cdir)
				updateicon()

		if(href_list["rate control"])
			if(href_list["cdir"])
				src.cdir = dd_range(0,359,(360+src.cdir+text2num(href_list["cdir"]))%360)
				spawn(1)
					set_panels(cdir)
					updateicon()
			if(href_list["tdir"])
				src.trackrate = dd_range(-7200,7200,src.trackrate+text2num(href_list["tdir"]))
				if(src.trackrate) nexttime = world.timeofday + 3600/abs(trackrate)

		if(href_list["track"])
			if(src.trackrate) nexttime = world.timeofday + 3600/abs(trackrate)
			track = text2num(href_list["track"])
			if(track == 2)
				var/obj/machinery/power/tracker/T = locate() in world
				if(T)
					cdir = T.sun_angle

		set_panels(cdir)
		updateicon()
		src.updateUsrDialog()
		return


	set_panels(var/cdir)
		if(!powernet) return
		for(var/obj/machinery/power/solar/S in powernet.nodes)
			if(S.id != id) continue
			if(!S.control)
				S.control = src
			S.ndir = cdir


	power_change()
		if(powered())
			stat &= ~NOPOWER
			updateicon()
		else
			spawn(rand(0, 15))
				stat |= NOPOWER
				updateicon()


	broken()
		stat |= BROKEN
		updateicon()


	meteorhit()
		broken()
		return


	ex_act(severity)
		switch(severity)
			if(1.0)
				//SN src = null
				del(src)
				return
			if(2.0)
				if (prob(50))
					broken()
			if(3.0)
				if (prob(25))
					broken()
		return


	blob_act()
		if (prob(75))
			broken()
			src.density = 0
