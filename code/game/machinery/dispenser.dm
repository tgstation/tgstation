/obj/machinery/dispenser/New()
	..()
	update_icon()

/obj/machinery/dispenser/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				while(src.o2tanks > 0)
					new /obj/item/weapon/tank/oxygen( src.loc )
					src.o2tanks--
					update_icon()
				while(src.pltanks > 0)
					new /obj/item/weapon/tank/plasma( src.loc )
					src.pltanks--
					update_icon()
		else
	return

/obj/machinery/dispenser/blob_act()
	if (prob(50))
		while(src.o2tanks > 0)
			new /obj/item/weapon/tank/oxygen( src.loc )
			src.o2tanks--
			update_icon()
		while(src.pltanks > 0)
			new /obj/item/weapon/tank/plasma( src.loc )
			src.pltanks--
			update_icon()
		del(src)

/obj/machinery/dispenser/meteorhit()
	while(src.o2tanks > 0)
		new /obj/item/weapon/tank/oxygen( src.loc )
		src.o2tanks--
		update_icon()
	while(src.pltanks > 0)
		new /obj/item/weapon/tank/plasma( src.loc )
		src.pltanks--
		update_icon()
	del(src)
	return

/obj/machinery/dispenser/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/dispenser/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/dispenser/attack_hand(mob/user as mob)
	if(stat & BROKEN)
		return
	user.machine = src
	var/dat = text("<TT><B>Loaded Tank Dispensing Unit</B><BR>\n<FONT color = 'blue'><B>Oxygen</B>: []</FONT> []<BR>\n<FONT color = 'orange'><B>Plasma</B>: []</FONT> []<BR>\n</TT>", src.o2tanks, (src.o2tanks ? text("<A href='?src=\ref[];oxygen=1'>Dispense</A>", src) : "empty"), src.pltanks, (src.pltanks ? text("<A href='?src=\ref[];plasma=1'>Dispense</A>", src) : "empty"))
	user << browse(dat, "window=dispenser")
	onclose(user, "dispenser")
	return

/obj/machinery/dispenser/Topic(href, href_list)
	if(stat & BROKEN)
		return
	if(usr.stat || usr.restrained())
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker))
		if (!istype(usr, /mob/living/silicon/ai))
			usr << "\red You don't have the dexterity to do this!"
		else
			usr << "\red You are unable to dispense anything, since the controls are physical levers which don't go through any other kind of input."
		return

	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["oxygen"])
			if (text2num(href_list["oxygen"]))
				if (src.o2tanks > 0)
					use_power(5)
					new /obj/item/weapon/tank/oxygen( src.loc )
					src.o2tanks--
					update_icon()
			if (istype(src.loc, /mob))
				attack_hand(src.loc)
		else
			if (href_list["plasma"])
				if (text2num(href_list["plasma"]))
					if (src.pltanks > 0)
						use_power(5)
						new /obj/item/weapon/tank/plasma( src.loc )
						src.pltanks--
						update_icon()
				if (istype(src.loc, /mob))
					attack_hand(src.loc)
		src.add_fingerprint(usr)
		for(var/mob/M in viewers(1, src))
			if ((M.client && M.machine == src))
				src.attack_hand(M)
	else
		usr << browse(null, "window=dispenser")
		return
	return

/obj/machinery/dispenser/update_icon()
	overlays = null
	switch(o2tanks)
		if(1 to 3)	overlays += "oxygen-[o2tanks]"
		if(4 to INFINITY) overlays += "oxygen-4"
	switch(pltanks)
		if(1 to 4)	overlays += "plasma-[pltanks]"
		if(5 to INFINITY) overlays += "plasma-5"