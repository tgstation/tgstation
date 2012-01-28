//The laser control computer
//Used to control the lasers
/obj/machinery/computer/lasercon
	name = "Laser control computer"
	var/obj/machinery/engine/laser/laser = null
	icon_state = "atmos"
	var/id
	var/advanced = 0

/obj/machinery/computer/lasercon/New()
	spawn(1)
		if(istype(src.id,/list))
			laser = list()
			for(var/obj/machinery/engine/laser/las in world)
				if(las.id in src.id)
					laser += las
		else
			for(var/obj/machinery/engine/laser/las in world)
				if(las.id == src.id)
					laser = list(las)



/obj/machinery/computer/lasercon/attack_ai(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/computer/lasercon/attack_hand(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)


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


/obj/machinery/computer/lasercon/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=lascomp")
		usr.machine = null
		return

	else if( href_list["input"] )
		var/i = text2num(href_list["input"])
		var/d = 0
		switch(i)
			if(-4)
				d = -1000
			if(4)
				d = 1000
			if(1)
				d = 1
			if(-1)
				d = -1
			if(2)
				d = 10
			if(-2)
				d = -10
			if(3)
				d = 100
			if(-3)
				d = -100
		for(var/obj/machinery/engine/laser/laser in src.laser)
			laser.power += d
			laser.setpower(max(1, min(3000, laser.power)))// clamp to range
			src.updateDialog()
	else if( href_list["online"] )
		for(var/obj/machinery/engine/laser/laser in src.laser)
			laser.on = !laser.on
			src.updateDialog()
	else if( href_list["freq"] )
		var/amt = text2num(href_list["freq"])
		for(var/obj/machinery/engine/laser/laser in src.laser)
			if(laser.freq+amt>0)
				laser.freq+=amt
				src.updateDialog()
/obj/machinery/computer/lasercon/process()
	if(!(stat & (NOPOWER|BROKEN)) )
		use_power(250)

	//src.updateDialog()


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

