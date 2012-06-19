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

		else if(istype(W, /obj/item/stack/sheet) && !anchored)
			switch(W.type)
				if(/obj/item/stack/sheet/metal)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falsewall (src.loc)
				if(/obj/item/stack/sheet/plasteel)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falserwall (src.loc)
				if(/obj/item/stack/sheet/gold)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falsewall/gold (src.loc)
				if(/obj/item/stack/sheet/silver)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falsewall/silver (src.loc)
				if(/obj/item/stack/sheet/diamond)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falsewall/diamond (src.loc)
				if(/obj/item/stack/sheet/uranium)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falsewall/uranium (src.loc)
				if(/obj/item/stack/sheet/plasma)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falsewall/plasma (src.loc)
				if(/obj/item/stack/sheet/clown)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falsewall/clown (src.loc)
				if(/obj/item/stack/sheet/sandstone)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falsewall/sandstone (src.loc)
/*				if(/obj/item/stack/sheet/wood)
					W:use(2)
					user << "\blue You create a false wall! Push on it to open or close the passage."
					new /obj/structure/falsewall/wood (src.loc)*/
			add_hiddenprint(usr)
			del(src)


/*		else if((istype(W, /obj/item/stack/sheet/metal)) && (W:amount >= 2) && istype(src,/obj/structure/girder/displaced))
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
			del(src)*/


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

		else if((istype(W, /obj/item/stack/sheet)) && (W:amount >= 2))
			switch(W.type)

				if(/obj/item/stack/sheet/metal)
					user << "\blue Now adding plating..."
					if (do_after(user,40))
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

				if (/obj/item/stack/sheet/plasteel)
					if (src.icon_state == "reinforced") //Time to finalize!
						user << "\blue Now finalising reinforced wall."
						if(do_after(user, 50))
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
							user << "\blue Girders reinforced!"
							W:use(1)
							new/obj/structure/girder/reinforced( src.loc )
							del(src)
							return

				if(/obj/item/stack/sheet/gold)
					user << "\blue Now adding plating..."
					if (do_after(user,40))
						user << "\blue You added the plating!"
						var/turf/Tsrc = get_turf(src)
						Tsrc.ReplaceWithMineralWall("gold")
						for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
							P.layer = 1
						for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						if (W)	W:use(2)
						del(src)
						return

				if(/obj/item/stack/sheet/silver)
					user << "\blue Now adding plating..."
					if (do_after(user,40))
						user << "\blue You added the plating!"
						var/turf/Tsrc = get_turf(src)
						Tsrc.ReplaceWithMineralWall("silver")
						for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
							P.layer = 1
						for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						if (W)	W:use(2)
						del(src)
						return

				if(/obj/item/stack/sheet/diamond)
					user << "\blue Now adding plating..."
					if (do_after(user,40))
						user << "\blue You added the plating!"
						var/turf/Tsrc = get_turf(src)
						Tsrc.ReplaceWithMineralWall("diamond")
						for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
							P.layer = 1
						for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						if (W)	W:use(2)
						del(src)
						return

				if(/obj/item/stack/sheet/uranium)
					user << "\blue Now adding plating..."
					if (do_after(user,40))
						user << "\blue You added the plating!"
						var/turf/Tsrc = get_turf(src)
						Tsrc.ReplaceWithMineralWall("uranium")
						for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
							P.layer = 1
						for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						if (W)	W:use(2)
						del(src)
						return

				if(/obj/item/stack/sheet/plasma)
					user << "\blue Now adding plating..."
					if (do_after(user,40))
						user << "\blue You added the plating!"
						var/turf/Tsrc = get_turf(src)
						Tsrc.ReplaceWithMineralWall("plasma")
						for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
							P.layer = 1
						for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						if (W)	W:use(2)
						del(src)
						return

				if(/obj/item/stack/sheet/clown)
					user << "\blue Now adding plating..."
					if (do_after(user,40))
						user << "\blue You added the plating!"
						var/turf/Tsrc = get_turf(src)
						Tsrc.ReplaceWithMineralWall("clown")
						for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
							P.layer = 1
						for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						if (W)	W:use(2)
						del(src)
						return

				if(/obj/item/stack/sheet/sandstone)
					user << "\blue Now adding plating..."
					if (do_after(user,40))
						user << "\blue You added the plating!"
						var/turf/Tsrc = get_turf(src)
						Tsrc.ReplaceWithMineralWall("sandstone")
						for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
							P.layer = 1
						for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
							if(X)	X.add_hiddenprint(usr)
						if (W)	W:use(2)
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

/obj/structure/falsewall
	var/mineral = "metal"

/obj/structure/falserwall
	var/mineral = "metal"

/obj/structure/falsewall/gold
	mineral = "gold"

/obj/structure/falsewall/silver
	mineral = "silver"

/obj/structure/falsewall/diamond
	mineral = "diamond"

/obj/structure/falsewall/uranium
	mineral = "uranium"
	var/active = null
	var/last_event = 0

/obj/structure/falsewall/plasma
	mineral = "plasma"

/obj/structure/falsewall/clown
	mineral = "clown"

/obj/structure/falsewall/sandstone
	mineral = "sandstone"

/*/obj/structure/falsewall/wood
	mineral = "wood"*/

/obj/structure/falsewall/attack_hand(mob/user as mob)
	if(density)
		// Open wall
		icon_state = "[mineral]fwall_open"
		flick("[mineral]fwall_opening", src)
		sleep(15)
		src.density = 0
		src.sd_SetOpacity(0)
		var/turf/T = src.loc
		T.sd_LumReset()

	else
		flick("[mineral]fwall_closing", src)
		icon_state = "[mineral]0"
		sleep(15)
		src.density = 1
		src.sd_SetOpacity(1)
		var/turf/T = src.loc
		//T.sd_LumUpdate()
		src.relativewall()
		T.sd_LumReset()

/obj/structure/falsewall/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/obj/structure/falsewall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/screwdriver))
		var/turf/T = get_turf(src)
		user.visible_message("[user] tightens some bolts on the wall.", "You tighten the bolts on the wall.")
		if(!mineral)
			T.ReplaceWithWall()
		else
			T.ReplaceWithMineralWall(mineral)
		del(src)

	if( istype(W, /obj/item/weapon/weldingtool) )
		var/obj/item/weapon/weldingtool/WT = W
		if( WT:welding )
			var/turf/T = get_turf(src)
			if(!mineral)
				T.ReplaceWithWall()
			else
				T.ReplaceWithMineralWall(mineral)
			if(mineral != "plasma")//Stupid shit keeps me from pushing the attackby() to plasma walls -Sieve
				T = get_turf(src)
				T.attackby(W,user)
			del(src)

	else if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ReplaceWithWall()
		else
			T.ReplaceWithMineralWall(mineral)
		if(mineral != "plasma")
			T = get_turf(src)
			T.attackby(W,user)
		del(src)

	//DRILLING
	else if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ReplaceWithWall()
		else
			T.ReplaceWithMineralWall(mineral)
		T = get_turf(src)
		T.attackby(W,user)
		del(src)

	else if( istype(W, /obj/item/weapon/melee/energy/blade) )
		var/turf/T = get_turf(src)
		if(!mineral)
			T.ReplaceWithWall()
		else
			T.ReplaceWithMineralWall(mineral)
		if(mineral != "plasma")
			T = get_turf(src)
			T.attackby(W,user)
		del(src)
	/*

		var/turf/T = get_turf(user)
		user << "\blue Now adding plating..."
		sleep(40)
		if (get_turf(user) == T)
			user << "\blue You added the plating!"
			var/turf/Tsrc = get_turf(src)
			Tsrc.ReplaceWithWall()

	*/

/obj/structure/falsewall/uranium/attackby(obj/item/weapon/W as obj, mob/user as mob)
	radiate()
	..()

/obj/structure/falserwall/
	attack_hand(mob/user as mob)
		if(density)
			// Open wall
			icon_state = "frwall_open"
			flick("frwall_opening", src)
			sleep(15)
			src.density = 0
			src.sd_SetOpacity(0)
			var/turf/T = src.loc
			T.sd_LumReset()

		else
			icon_state = "r_wall"
			flick("frwall_closing", src)
			sleep(15)
			src.density = 1
			src.sd_SetOpacity(1)
			var/turf/T = src.loc
			//T.sd_LumUpdate()
			src.relativewall()
			T.sd_LumReset()


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/screwdriver))
			var/turf/T = get_turf(src)
			user.visible_message("[user] tightens some bolts on the r wall.", "You tighten the bolts on the r wall.")
			T.ReplaceWithWall() //Intentionally makes a regular wall instead of an r-wall (no cheap r-walls for you).
			del(src)

		if( istype(W, /obj/item/weapon/weldingtool) )
			var/obj/item/weapon/weldingtool/WT = W
			if( WT.remove_fuel(0,user) )
				var/turf/T = get_turf(src)
				T.ReplaceWithWall()
				T = get_turf(src)
				T.attackby(W,user)
				del(src)

		else if( istype(W, /obj/item/weapon/pickaxe/plasmacutter) )
			var/turf/T = get_turf(src)
			T.ReplaceWithWall()
			T = get_turf(src)
			T.attackby(W,user)
			del(src)

		//DRILLING
		else if (istype(W, /obj/item/weapon/pickaxe/diamonddrill))
			var/turf/T = get_turf(src)
			T.ReplaceWithWall()
			T = get_turf(src)
			T.attackby(W,user)
			del(src)

		else if( istype(W, /obj/item/weapon/melee/energy/blade) )
			var/turf/T = get_turf(src)
			T.ReplaceWithWall()
			T = get_turf(src)
			T.attackby(W,user)
			del(src)

/obj/structure/falsewall/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/turf/simulated/wall/mineral/T in range(3,src))
				if(T.mineral == "uranium")
					T.radiate()
			last_event = world.time
			active = null
			return
	return
