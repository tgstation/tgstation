/obj/machinery/holopad/attack_ai(user as mob)
	//branches depending on four things - is the user currently a hologram? does it have power?
	//is the holopad on? (moot if q2 = 0) is the user the one who is using this holopad? (moot if q3 = 0)
	if(!istype(user,/mob/living/silicon/aihologram/)) //question number one
		if(!(stat & NOPOWER)) //question number two
			if(src.state == "off") //question number three
				var/mob/living/silicon/aihologram/holo = new /mob/living/silicon/aihologram(src.loc)
				holo.parent_ai = user
				holo.ailaws = holo.parent_ai.laws_object
				holo.client = usr.client //should move the client there
				holo.name = holo.parent_ai.name
				holo.real_name = holo.parent_ai.real_name
				src.state = "on"
				src.icon_state = "holopad1"
				src.slave_holo = holo
				return
			else
				if(user != src.slave_holo:parent_ai) //question number four //there is always a slave_holo if it's on
					user << "\red You're not the one AI who is currently using this holopad!"
					return
				else
					user << "\red \b Something is very wrong, you should be in a hologram by now"
					return
		else
			user << "\red This holopad has no power."
			return
	else
		if(!(stat & NOPOWER)) //question number two
			if(src.state == "off") //question number three
				user << "\red This holopad is off, you should find your original holopad."
				return
			else
				if(user == src.slave_holo) //question number four
					del(user) //code for returning the control back to the AI is in the mob's del() code
					src.state = "off"
					src.icon_state = "holopad0"
					src.slave_holo = null
					return
				else
					user << "\red You're not the one AI who is currently using this holopad!"
					return
		else
			user << "\red This holopad is off, you should find your original holopad."
			return

/obj/machinery/holopad/process()
	if((stat & NOPOWER) && src.state == "on")
		src.state = "off"
	if(src.state == "on")
		if(!(src.slave_holo in view(src,5))) //if the hologram strayed too far, destroy it
			if(src.slave_holo)
				del(src.slave_holo) //code for returning the control back to the AI is in the mob's del() code
			src.state = "off"
			src.icon_state = "holopad0"
			src.slave_holo = null
		else
			use_power(300)
	if(src.state == "off" && src.slave_holo) //usually happens if the power ran out
		del(src.slave_holo) //code for returning the control back to the AI is in the mob's del() code
		src.slave_holo = null
	return 1

/obj/machinery/holopad/power_change()
	if (powered())
		stat &= ~NOPOWER
	else
		stat |= ~NOPOWER

/obj/machinery/holopad/Del()
	if(src.slave_holo)
		del(src.slave_holo) //code for returning the control back to the AI is in the mob's del() code
	..()

/* Old code which didn't work, I believe
/obj/machinery/hologram_ai/New()
	..()

/obj/machinery/hologram_ai/attack_ai(user as mob)
	src.show_console(user)
	return

/obj/machinery/hologram_ai/proc/render()
	var/icon/I = new /icon('human.dmi', "body_m_s")

	if (src.lumens >= 0)
		I.Blend(rgb(src.lumens, src.lumens, src.lumens), ICON_ADD)
	else
		I.Blend(rgb(- src.lumens,  -src.lumens,  -src.lumens), ICON_SUBTRACT)

	I.Blend(new /icon('human.dmi', "mouth_m_s"), ICON_OVERLAY)
	I.Blend(new /icon('human.dmi', "underwear1_m_s"), ICON_OVERLAY)

	var/icon/U = new /icon('human_face.dmi', "hair_a_s")
	U.Blend(rgb(src.h_r, src.h_g, src.h_b), ICON_ADD)

	I.Blend(U, ICON_OVERLAY)

	src.projection.icon = I

/obj/machinery/hologram_ai/proc/show_console(var/mob/user as mob)
	var/dat
	user.machine = src
	if (src.temp)
		dat = text("[]<BR><BR><A href='?src=\ref[];temp=1'>Clear</A>", src.temp, src)
	else
		dat = text("<B>Hologram Status:</B><HR>\nPower: <A href='?src=\ref[];power=1'>[]</A><HR>\n<B>Hologram Control:</B><BR>\nColor Luminosity: []/220 <A href='?src=\ref[];reset=1'>\[Reset\]</A><BR>\nLighten: <A href='?src=\ref[];light=1'>1</A> <A href='?src=\ref[];light=10'>10</A><BR>\nDarken: <A href='?src=\ref[];light=-1'>1</A> <A href='?src=\ref[];light=-10'>10</A><BR>\n<BR>\nHair Color: ([],[],[]) <A href='?src=\ref[];h_reset=1'>\[Reset\]</A><BR>\nRed (0-255): <A href='?src=\ref[];h_r=-300'>\[0\]</A> <A href='?src=\ref[];h_r=-10'>-10</A> <A href='?src=\ref[];h_r=-1'>-1</A> [] <A href='?src=\ref[];h_r=1'>1</A> <A href='?src=\ref[];h_r=10'>10</A> <A href='?src=\ref[];h_r=300'>\[255\]</A><BR>\nGreen (0-255): <A href='?src=\ref[];h_g=-300'>\[0\]</A> <A href='?src=\ref[];h_g=-10'>-10</A> <A href='?src=\ref[];h_g=-1'>-1</A> [] <A href='?src=\ref[];h_g=1'>1</A> <A href='?src=\ref[];h_g=10'>10</A> <A href='?src=\ref[];h_g=300'>\[255\]</A><BR>\nBlue (0-255): <A href='?src=\ref[];h_b=-300'>\[0\]</A> <A href='?src=\ref[];h_b=-10'>-10</A> <A href='?src=\ref[];h_b=-1'>-1</A> [] <A href='?src=\ref[];h_b=1'>1</A> <A href='?src=\ref[];h_b=10'>10</A> <A href='?src=\ref[];h_b=300'>\[255\]</A><BR>", src, (src.projection ? "On" : "Off"),  -src.lumens + 35, src, src, src, src, src, src.h_r, src.h_g, src.h_b, src, src, src, src, src.h_r, src, src, src, src, src, src, src.h_g, src, src, src, src, src, src, src.h_b, src, src, src)
	user << browse(dat, "window=hologram_console")
	onclose(user, "hologram_console")
	return

/obj/machinery/hologram_ai/Topic(href, href_list)
	..()
	if (!istype(usr, /mob/living/silicon/ai))
		return

	if (href_list["power"])
		if (src.projection)
			src.icon_state = "hologram0"
			//src.projector.projection = null
			del(src.projection)
		else
			src.projection = new /obj/projection( src.loc )
			src.projection.icon = 'human.dmi'
			src.projection.icon_state = "male"
			src.icon_state = "hologram1"
			src.render()
	else if (href_list["h_r"])
		if (src.projection)
			src.h_r += text2num(href_list["h_r"])
			src.h_r = min(max(src.h_r, 0), 255)
			render()
	else if (href_list["h_g"])
		if (src.projection)
			src.h_g += text2num(href_list["h_g"])
			src.h_g = min(max(src.h_g, 0), 255)
			render()
	else if (href_list["h_b"])
		if (src.projection)
			src.h_b += text2num(href_list["h_b"])
			src.h_b = min(max(src.h_b, 0), 255)
			render()
	else if (href_list["light"])
		if (src.projection)
			src.lumens += text2num(href_list["light"])
			src.lumens = min(max(src.lumens, -185.0), 35)
			render()
	else if (href_list["reset"])
		if (src.projection)
			src.lumens = 0
			render()
	else if (href_list["temp"])
		src.temp = null
	src.show_console(usr)
*/