//The laser control computer
//Used to control the lasers
/obj/machinery/computer/lasercon
	name = "Laser control computer"
	var/list/lasers = new/list
	icon_state = "atmos"
	var/id
	//var/advanced = 0

/obj/machinery/computer/lasercon
	New()
		spawn(1)
			for(var/obj/machinery/emitter/zero_point_laser/las in world)
				if(las.id == src.id)
					lasers += las

	attack_hand(mob/user)
		add_fingerprint(user)
		if(stat & (BROKEN|NOPOWER))
			return
		interact(user)

	attack_ai(mob/user)
		attack_hand(user)

	process()
		..()
		updateDialog()

	proc
		interact(mob/user)
			if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
				if (!istype(user, /mob/living/silicon))
					user.machine = null
					user << browse(null, "window=laser_control")
					return
			var/t = "<TT><B>Laser status monitor</B><HR>"
			for(var/obj/machinery/emitter/zero_point_laser/laser in lasers)
				t += "Zero Point Laser<br>"
				t += "Power level: <A href = '?src=\ref[laser];input=-0.005'>-</A> <A href = '?src=\ref[laser];input=-0.001'>-</A> <A href = '?src=\ref[laser];input=-0.0005'>-</A> <A href = '?src=\ref[laser];input=-0.0001'>-</A> [laser.mega_energy]MeV <A href = '?src=\ref[laser];input=0.0001'>+</A> <A href = '?src=\ref[laser];input=0.0005'>+</A> <A href = '?src=\ref[laser];input=0.001'>+</A> <A href = '?src=\ref[laser];input=0.005'>+</A><BR>"
				t += "Frequency: <A href = '?src=\ref[laser];freq=-10000'>-</A> <A href = '?src=\ref[laser];freq=-1000'>-</A> [laser.freq] <A href = '?src=\ref[laser];freq=1000'>+</A> <A href = '?src=\ref[laser];freq=10000'>+</A><BR>"
				t += "Output: [laser.active ? "<B>Online</B> <A href = '?src=\ref[laser];online=1'>Offline</A>" : "<A href = '?src=\ref[laser];online=1'>Online</A> <B>Offline</B> "]<BR>"
			t += "<hr>"
			t += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
			user << browse(t, "window=laser_control;size=500x800")
			user.machine = src

/*
/obj/machinery/computer/lasercon/proc/interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=powcomp")
			return


	user.machine = src
	var/t = "<TT><B>Laser status monitor</B><HR>"

	var/obj/machinery/engine/laser/laser = src.laser[1]

	if(!laser)
		t += "\red No laser found"
	else


		t += "Power level:  <A href = '?src=\ref[src];input=-4'>-</A> <A href = '?src=\ref[src];input=-3'>-</A> <A href = '?src=\ref[src];input=-2'>-</A> <A href = '?src=\ref[src];input=-1'>-</A> [add_lspace(laser.power,5)] <A href = '?src=\ref[src];input=1'>+</A> <A href = '?src=\ref[src];input=2'>+</A> <A href = '?src=\ref[src];input=3'>+</A> <A href = '?src=\ref[src];input=4'>+</A><BR>"
		if(advanced)
			t += "Frequency:  <A href = '?src=\ref[src];freq=-10000'>-</A> <A href = '?src=\ref[src];freq=-1000'>-</A> [add_lspace(laser.freq,5)] <A href = '?src=\ref[src];freq=1000'>+</A> <A href = '?src=\ref[src];freq=10000'>+</A><BR>"

		t += "Output: [laser.on ? "<B>Online</B> <A href = '?src=\ref[src];online=1'>Offline</A>" : "<A href = '?src=\ref[src];online=1'>Online</A> <B>Offline</B> "]<BR>"

		t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A></TT>"

	user << browse(t, "window=lascomp;size=420x700")
	onclose(user, "lascomp")
*/

/obj/machinery/computer/lasercon/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=laser_control")
		usr.machine = null
		return

	else if( href_list["input"] )
		var/i = text2num(href_list["input"])
		var/d = i
		for(var/obj/machinery/emitter/zero_point_laser/laser in lasers)
			var/new_power = laser.mega_energy + d
			new_power = max(new_power,0.0001)	//lowest possible value
			new_power = min(new_power,0.01)		//highest possible value
			laser.mega_energy = new_power
			//
			src.updateDialog()
	else if( href_list["online"] )
		var/obj/machinery/emitter/zero_point_laser/laser = href_list["online"]
		laser.active = !laser.active
		src.updateDialog()
	else if( href_list["freq"] )
		var/amt = text2num(href_list["freq"])
		for(var/obj/machinery/emitter/zero_point_laser/laser in lasers)
			var/new_freq = laser.frequency + amt
			new_freq = max(new_freq,1)		//lowest possible value
			new_freq = min(new_freq,20000)	//highest possible value
			laser.frequency = new_freq
			//
			src.updateDialog()

/*
/obj/machinery/computer/lasercon/process()
	if(!(stat & (NOPOWER|BROKEN)) )
		use_power(250)

	//src.updateDialog()
*/

/*
/obj/machinery/computer/lasercon/power_change()

	if(stat & BROKEN)
		icon_state = "broken"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
				stat |= NOPOWER
*/
