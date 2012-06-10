obj/structure
	icon = 'structures.dmi'

obj/structure/blob_act()
	if(prob(50))
		del(src)

obj/structure/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if(prob(50))
				del(src)
				return
		if(3.0)
			return

obj/structure/meteorhit(obj/O as obj)
	del(src)



/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = 2
	var/state = 0

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench) && state == 0 && anchored && !istype(src,/obj/structure/girder/displaced))
			playsound(src.loc, 'Ratchet.ogg', 100, 1)
			user << "\blue Now disassembling the girder"
			if(do_after(user,40))
				user << "\blue You dissasembled the girder!"
				new /obj/item/stack/sheet/metal(get_turf(src))
				del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			user << "\blue Now slicing apart the girder"
			if(do_after(user,30))
				user << "\blue You slice apart the girder!"
			new /obj/item/stack/sheet/metal(get_turf(src))
			del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/diamonddrill))
			user << "\blue You drill through the girder!"
			new /obj/item/stack/sheet/metal(get_turf(src))
			del(src)

		else if((istype(W, /obj/item/stack/sheet/metal)) && (W:amount >= 2) && istype(src,/obj/structure/girder/displaced))
			W:use(2)
			user << "\blue You create a false wall! Push on it to open or close the passage."
			new /obj/structure/falsewall (src.loc)
			add_hiddenprint(usr)
			del(src)

		else if(istype(W, /obj/item/stack/sheet/plasteel) && istype(src,/obj/structure/girder/displaced))
			W:use(2)
			user << "\blue You create a false r wall! Push on it to open or close the passage."
			new /obj/structure/falserwall (src.loc)
			add_hiddenprint(usr)
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
				if(!W)
					return
				user << "\blue You added the plating!"
				var/turf/Tsrc = get_turf(src)
				Tsrc.ReplaceWithWall()
				for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
					P.layer = 1
				for(var/turf/simulated/wall/X in Tsrc.loc)
					if(X)	X.add_hiddenprint(usr)
				if (W)	W:use(2)
				del(src)
			return

		else if (istype(W, /obj/item/stack/sheet/plasteel))
			if (src.icon_state == "reinforced") //Time to finalize!
				user << "\blue Now finalising reinforced wall."
				if(do_after(user, 50))
					if(!W)
						return
					user << "\blue Wall fully reinforced!"
					var/turf/Tsrc = get_turf(src)
					Tsrc.ReplaceWithRWall()
					for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
						P.layer = 1
					for(var/turf/simulated/wall/r_wall/X in Tsrc.loc)
						if(X)	X.add_hiddenprint(usr)
					if (W)
						W:use(1)
					del(src)
					return
			else
				user << "\blue Now reinforcing girders"
				if (do_after(user,60))
					if(!W)
						return
					user << "\blue Girders reinforced!"
					W:use(1)
					new/obj/structure/girder/reinforced( src.loc )
					del(src)
					return
		else if(istype(W, /obj/item/pipe))
			var/obj/item/pipe/P = W
			if (P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
				user.drop_item()
				P.loc = src.loc
				user << "\blue You fit the pipe into the [src]!"
		else
			..()


	blob_act()
		if(prob(40))
			del(src)


	ex_act(severity)
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

/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = 0

/obj/structure/girder/reinforced
	icon_state = "reinforced"
	state = 2

/obj/structure/cultgirder
	icon= 'cult.dmi'
	icon_state= "cultgirder"
	anchored = 1
	density = 1
	layer = 2

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench))
			playsound(src.loc, 'Ratchet.ogg', 100, 1)
			user << "\blue Now disassembling the girder"
			if(do_after(user,40))
				user << "\blue You dissasembled the girder!"
				new /obj/effect/decal/remains/human(get_turf(src))
				del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			user << "\blue Now slicing apart the girder"
			if(do_after(user,30))
				user << "\blue You slice apart the girder!"
			new /obj/effect/decal/remains/human(get_turf(src))
			del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/diamonddrill))
			user << "\blue You drill through the girder!"
			new /obj/effect/decal/remains/human(get_turf(src))
			del(src)

	blob_act()
		if(prob(40))
			del(src)


	ex_act(severity)
		switch(severity)
			if(1.0)
				del(src)
				return
			if(2.0)
				if (prob(30))
					new /obj/effect/decal/remains/human(loc)
					del(src)
				return
			if(3.0)
				if (prob(5))
					new /obj/effect/decal/remains/human(loc)
					del(src)
				return
			else
		return

// LATTICE


/obj/structure/lattice/blob_act()
	del(src)
	return

/obj/structure/lattice/ex_act(severity)
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

/obj/structure/lattice/attackby(obj/item/C as obj, mob/user as mob)

	if (istype(C, /obj/item/stack/tile/plasteel))
		var/turf/T = get_turf(src)
		T.attackby(C, user) //BubbleWrap - hand this off to the underlying turf instead
		return
	if (istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = C
		if(WT.remove_fuel(0, user))
			user << "\blue Slicing lattice joints ..."
		new /obj/item/stack/rods(src.loc)
		del(src)

	return
