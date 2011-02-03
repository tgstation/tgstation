obj/structure
	icon = 'structures.dmi'

	girder
		icon_state = "girder"
		anchored = 1
		density = 1
		var/state = 0

		displaced
			icon_state = "displaced"
			anchored = 0

		reinforced
			icon_state = "reinforced"
			state = 2

/obj/structure/girder/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench) && state == 0 && anchored && !istype(src,/obj/structure/girder/displaced))
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		user << "\blue Now disassembling the girder"
		if(do_after(user,40))
			user << "\blue You dissasembled the girder!"
			new /obj/item/stack/sheet/metal(get_turf(src))
			del(src)

	else if((istype(W, /obj/item/stack/sheet/metal)) && (W:amount >= 2) && istype(src,/obj/structure/girder/displaced))
		W:use(2)
		user << "\blue You create a false wall! Push on it to open or close the passage."
		new /obj/falsewall (src.loc)
		del(src)

	else if(istype(W, /obj/item/stack/sheet/r_metal) && istype(src,/obj/structure/girder/displaced))
		W:use(2)
		user << "\blue You create a false r wall! Push on it to open or close the passage."
		new /obj/falserwall (src.loc)
		del(src)

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 && istype(src,/obj/structure/girder/reinforced))
		playsound(src.loc, 'Screwdriver.ogg', 100, 1)
		user << "\blue Now unsecuring support struts"
		if(do_after(user,40))
			user << "\blue You unsecured the support struts!"
			state = 1

	else if(istype(W, /obj/item/weapon/wirecutters) && istype(src,/obj/structure/girder/reinforced) && state == 1)
		playsound(src.loc, 'Wirecutter.ogg', 100, 1)
		user << "\blue Now removing support struts"
		if(do_after(user,40))
			user << "\blue You removed the support struts!"
			new/obj/structure/girder( src.loc )
			del(src)

	else if(istype(W, /obj/item/weapon/crowbar) && state == 0 && anchored )
		playsound(src.loc, 'Crowbar.ogg', 100, 1)
		user << "\blue Now dislodging the girder"
		if(do_after(user, 40))
			user << "\blue You dislodged the girder!"
			new/obj/structure/girder/displaced( src.loc )
			del(src)

	else if(istype(W, /obj/item/weapon/wrench) && state == 0 && !anchored )
		playsound(src.loc, 'Ratchet.ogg', 100, 1)
		user << "\blue Now securing the girder"
		if(get_turf(user, 40))
			user << "\blue You secured the girder!"
			new/obj/structure/girder( src.loc )
			del(src)

	else if((istype(W, /obj/item/stack/sheet/metal)) && (W:amount >= 2))
		user << "\blue Now adding plating..."
		if (do_after(user,40))
			user << "\blue You added the plating!"
			var/turf/Tsrc = get_turf(src)
			Tsrc.ReplaceWithWall()
			W:use(2)
			del(src)
		return

	else if (istype(W, /obj/item/stack/sheet/r_metal))
		if (src.icon_state == "reinforced") //Time to finalize!
			user << "\blue Now finalising reinforced wall."
			if(do_after(user, 50))
				user << "\blue Wall fully reinforced!"
				var/turf/Tsrc = get_turf(src)
				Tsrc.ReplaceWithRWall()
				if (W)
					W:use(1)
				del(src)
				return
		else
			user << "\blue Now reinforcing girders"
			if (do_after(user,60))
				user << "\blue Girders reinforced!"
				W:use(1)
				new/obj/structure/girder/reinforced( src.loc )
				del(src)
				return
	else
		..()

/obj/structure/girder/blob_act()
	if(prob(40))
		del(src)

/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(30))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				del(src)
			return
		if(3.0)
			if (prob(5))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				del(src)
			return
		else
	return

// LATTICE


/obj/lattice/blob_act()
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

/obj/lattice/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/tile))

		C:build(get_turf(src))
		C:use(1)
		playsound(src.loc, 'Genhit.ogg', 50, 1)
		if (C)
			C.add_fingerprint(user)
		del(src)
		return
	if (istype(C, /obj/item/weapon/weldingtool) && C:welding)
		user << "\blue Slicing lattice joints ..."
		C:eyecheck(user)
		new /obj/item/stack/rods(src.loc)
		del(src)

	return
