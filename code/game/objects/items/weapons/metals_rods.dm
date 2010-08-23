/*
CONTAINS:
RODS
METAL
REINFORCED METAL
LATTICE

*/



// RODS

/obj/item/weapon/rods/examine()
	set src in view(1)

	..()
	usr << text("There are [] rod\s left on the stack.", src.amount)
	return

/obj/item/weapon/rods/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/rods/F = new /obj/item/weapon/rods( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
	else
		..()
	return

/obj/item/weapon/rods/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		if(amount < 2)
			user << "\blue You need at least two rods to do this."
			return
		if (W:get_fuel() < 2)
			user << "\blue You need more welding fuel to complete this task."
			return
		W:eyecheck(user)
		W:use_fuel(2)
		new /obj/item/weapon/sheet/metal(usr.loc)
		for (var/mob/M in viewers(src))
			M.show_message("\red [src] is shaped into metal by [user.name] with the weldingtool.", 3, "\red You hear welding.", 2)

		amount -= 2
		if(amount == 0)
			del(src)
		return
	if (istype(W, /obj/item/weapon/rods))
		if (W:amount == 6)
			return
		if (W:amount + src:amount > 6)
			src.amount = W:amount + src:amount - 6
			W:amount = 6
		else
			W:amount += src:amount
			//SN src = null
			del(src)
			return
	return

/obj/item/weapon/rods/attack_self(mob/user as mob)
	if (locate(/obj/grille, usr.loc))
		for(var/obj/grille/G in usr.loc)
			if (G.destroyed)
				G.health = 10
				G.density = 1
				G.destroyed = 0
				G.icon_state = "grille"
				src.amount--
			else
	else
		if (src.amount < 2)
			return
		src.amount -= 2
		new /obj/grille( usr.loc )
	if (src.amount < 1)
		del(src)
		return
	src.add_fingerprint(user)
	return




// METAL SHEET

/obj/item/weapon/sheet/metal/examine()
	set src in view(1)

	..()
	usr << text("There are [] metal sheet\s on the stack.", src.amount)
	return

/obj/item/weapon/sheet/metal/attack_hand(mob/user as mob)
	if ((user.r_hand == src || user.l_hand == src))
		src.add_fingerprint(user)
		var/obj/item/weapon/sheet/metal/F = new /obj/item/weapon/sheet/metal( user )
		F.amount = 1
		src.amount--
		if (user.hand)
			user.l_hand = F
		else
			user.r_hand = F
		F.layer = 20
		F.add_fingerprint(user)
		if (src.amount < 1)
			del(src)
			return
	else
		..()
	src.force = 5
	return

/obj/item/weapon/sheet/metal/attackby(obj/item/weapon/sheet/metal/W as obj, mob/user as mob)
	if (!( istype(W, /obj/item/weapon/sheet/metal) ))
		return
	if (W.amount >= 5)
		return
	if (W.amount + src.amount > 5)
		src.amount = W.amount + src.amount - 5
		W.amount = 5
	else
		W.amount += src.amount
		//SN src = null
		del(src)
		return
	return



/obj/item/weapon/sheet/metal/attack_self(mob/user as mob)
	var/t1 = text("<HTML><HEAD></HEAD><TT>Amount Left: [] <BR>", src.amount)
	var/counter = 1
	var/list/L = list(  )
	L["stool"] = "stool"
	L["chair"] = "chair"
	L["bed"] = "bed (2 metal)<BR>"
	L["table"] = "table parts (2 metal)"
	L["rack"] = "rack parts<BR>"
	L["aircan"] = "air canister (2 metal)"
	L["o2can"] = "oxygen canister (2 metal)"
	L["carboncan"] = "co2 canister (2 metal)"
	L["plcan"] = "plasma canister (2 metal)"
	L["n2can"] = "n2 canister (2 metal)"
	L["n2ocan"] = "n2o canister (2 metal)"
	L["closet"] = "closet (2 metal)<BR>"
	L["fl_tiles"] = "4x floor tiles"
	L["rods"] = "2x metal rods"
	L["casing"] = "grenade casing (1 metal)"
	L["reinforced"] = "reinforced sheet (2 metal)<BR>"
	L["computer"] = "computer frame (5 metal)<BR>"
	L["construct"] = "construct wall girders (2 metal)"

	for(var/t in L)
		counter++
		t1 += text("<A href='?src=\ref[];make=[]'>[]</A>  ", src, t, L[t])
		if (counter > 2)
			counter = 1
		t1 += "<BR>"
	t1 += "</TT></HTML>"
	user << browse(t1, "window=met_sheet")
	onclose(user, "met_sheet")
	return

/obj/item/weapon/sheet/metal/Topic(href, href_list)
	..()
	if ((usr.restrained() || usr.stat || usr.equipped() != src))
		return
	if (href_list["make"])
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
		switch(href_list["make"])
			if("rods")
				src.amount--
				var/obj/item/weapon/rods/R = new /obj/item/weapon/rods( usr.loc )
				R.amount = 2
			if("table")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the table parts!")
					return
				src.amount -= 2
				new /obj/item/weapon/table_parts( usr.loc )
			if("stool")
				src.amount--
				new /obj/stool( usr.loc )
			if("chair")
				src.amount--
				var/obj/stool/chair/C = new /obj/stool/chair( usr.loc )
				C.dir = usr.dir
				if (C.dir == NORTH)
					C.layer = 5
			if("rack")
				src.amount--
				new /obj/item/weapon/rack_parts( usr.loc )

			if("aircan")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the canister!")
					return
				src.amount -= 2
				var/obj/machinery/portable_atmospherics/canister/C = new /obj/machinery/portable_atmospherics/canister(usr.loc)
				C.color = "grey"
				C.icon_state = "grey"

			if("o2can")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the canister!")
					return
				src.amount -= 2

				var/obj/machinery/portable_atmospherics/canister/C = new /obj/machinery/portable_atmospherics/canister(usr.loc)
				C.color = "blue"
				C.icon_state = "blue"

			if("carboncan")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the canister!")
					return
				src.amount -= 2

				var/obj/machinery/portable_atmospherics/canister/C = new /obj/machinery/portable_atmospherics/canister(usr.loc)
				C.color = "black"
				C.icon_state = "black"

			if("plcan")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the canister!")
					return
				src.amount -= 2

				var/obj/machinery/portable_atmospherics/canister/C = new /obj/machinery/portable_atmospherics/canister(usr.loc)
				C.color = "orange"
				C.icon_state = "orange"

			if("n2can")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the canister!")
					return
				src.amount -= 2
				var/obj/machinery/portable_atmospherics/canister/C = new /obj/machinery/portable_atmospherics/canister(usr.loc)
				C.color = "red"
				C.icon_state = "red"
			if("n2ocan")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the canister!")
					return
				src.amount -= 2
				var/obj/machinery/portable_atmospherics/canister/C = new /obj/machinery/portable_atmospherics/canister(usr.loc)
				C.color = "redws"
				C.icon_state = "redws"

			if("reinforced")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the reinforced sheet!")
					return
				src.amount -= 2
				var/obj/item/weapon/sheet/r_metal/C = new /obj/item/weapon/sheet/r_metal( usr.loc )
				C.amount = 1

			if("casing")
				if (src.amount < 1) //Not possible!
					usr << text("\red You haven't got enough metal to create the grenade casing!")
					return
				src.amount--
				new /obj/item/weapon/chem_grenade( usr.loc )

			if("closet")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the reinforced closet!")
					return
				src.amount -= 2
				new /obj/closet( usr.loc )
			if("fl_tiles")
				src.amount--
				var/obj/item/weapon/tile/R = new /obj/item/weapon/tile( usr.loc )
				R.amount = 4
			if("bed")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the bed!")
					return
				src.amount -= 2
				new /obj/stool/bed( usr.loc )
			if("computer")
				if(src.amount < 5)
					usr << text("\red You haven't got enough metal to build the computer frame!")
					return
				src.amount -= 5
				new /obj/computerframe( usr.loc )
			if("construct")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to construct the wall girders!")
					return
				usr << "\blue Building wall girders ..."
				var/turf/location = usr.loc
				sleep(50)
				if ((usr.loc == location))
					if (!istype(location, /turf/simulated/floor))
						return

					src.amount -= 2
					new /obj/structure/girder(location)

		if (src.amount <= 0)
			usr << browse(null, "window=met_sheet")
			onclose(usr, "met_sheet")
			usr.u_equip(src)
			del(src)


			return
	spawn( 0 )
		src.attack_self(usr)
		return
	return





// REINFORCED METAL SHEET


/obj/item/weapon/sheet/r_metal/attack_self(mob/user as mob)
	var/t1 = text("<HTML><HEAD></HEAD><TT>Amount Left: [] <BR>", src.amount)
	var/counter = 1
	var/list/L = list(  )
	L["table"] = "table parts (2 metal)"
	L["metal"] = "2x metal sheet (1 metal)<BR>"
	for(var/t in L)
		counter++
		t1 += text("<A href='?src=\ref[];make=[]'>[]</A>  ", src, t, L[t])
		if (counter > 2)
			counter = 1
		t1 += "<BR>"
	t1 += "</TT></HTML>"
	user << browse(t1, "window=met_sheet")
	onclose(user, "met_sheet")
	return

/obj/item/weapon/sheet/r_metal/Topic(href, href_list)
	..()
	if ((usr.restrained() || usr.stat || usr.equipped() != src))
		return
	if (href_list["make"])
		if (src.amount < 1)
			//SN src = null
			del(src)
			return
		switch(href_list["make"])
			if("table")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the reinforced table parts!")
					return
				src.amount -= 2
				new /obj/item/weapon/table_parts/reinforced( usr.loc )
			if("metal")
				if (src.amount < 2)
					usr << text("\red You haven't got enough metal to build the metal sheets!")
					return
				src.amount -= 2
				var/obj/item/weapon/sheet/C = new /obj/item/weapon/sheet( usr.loc )
				C.amount = 2

		if (src.amount <= 0)
			usr << browse(null, "window=met_sheet")
			onclose(usr, "met_sheet")
			usr.u_equip(src)
			del(src)


			return
	spawn( 0 )
		src.attack_self(usr)
		return
	return



// LATTICE????


/obj/lattice/blob_act()
	if(prob(75))
		del(src)
		return

/obj/lattice/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			del(src)
			return
		if(3.0)
			return
		else
	return

/obj/lattice/attackby(obj/item/weapon/C as obj, mob/user as mob)

	if (istype(C, /obj/item/weapon/tile))

		C:build(get_turf(src))
		C:amount--
		playsound(src.loc, 'Genhit.ogg', 50, 1)
		C.add_fingerprint(user)

		if (C:amount < 1)
			user.u_equip(C)
			del(C)
		del(src)
		return
	if (istype(C, /obj/item/weapon/weldingtool) && C:welding)
		user << "\blue Slicing lattice joints ..."
		C:eyecheck(user)
		new /obj/item/weapon/rods(src.loc)
		del(src)

	return
