/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = 2
	var/state = 0

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench) && state == 0)
			if(anchored && !istype(src,/obj/structure/girder/displaced))
				playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
				user << "\blue Now disassembling the girder"
				if(do_after(user,40))
					if(!src) return
					user << "\blue You dissasembled the girder!"
					new /obj/item/stack/sheet/metal(get_turf(src))
					del(src)
			else if(!anchored)
				playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
				user << "\blue Now securing the girder"
				if(get_turf(user, 40))
					user << "\blue You secured the girder!"
					new/obj/structure/girder( src.loc )
					del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/plasmacutter))
			user << "\blue Now slicing apart the girder"
			if(do_after(user,30))
				if(!src) return
				user << "\blue You slice apart the girder!"
				new /obj/item/stack/sheet/metal(get_turf(src))
				del(src)

		else if(istype(W, /obj/item/weapon/pickaxe/diamonddrill))
			user << "\blue You drill through the girder!"
			new /obj/item/stack/sheet/metal(get_turf(src))
			del(src)

		else if(istype(W, /obj/item/weapon/screwdriver) && state == 2 && istype(src,/obj/structure/girder/reinforced))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			user << "\blue Now unsecuring support struts"
			if(do_after(user,40))
				if(!src) return
				user << "\blue You unsecured the support struts!"
				state = 1

		else if(istype(W, /obj/item/weapon/wirecutters) && istype(src,/obj/structure/girder/reinforced) && state == 1)
			playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
			user << "\blue Now removing support struts"
			if(do_after(user,40))
				if(!src) return
				user << "\blue You removed the support struts!"
				new/obj/structure/girder( src.loc )
				del(src)

		else if(istype(W, /obj/item/weapon/crowbar) && state == 0 && anchored )
			playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
			user << "\blue Now dislodging the girder"
			if(do_after(user, 40))
				if(!src) return
				user << "\blue You dislodged the girder!"
				new/obj/structure/girder/displaced( src.loc )
				del(src)

		else if(istype(W, /obj/item/stack/sheet))

			var/obj/item/stack/sheet/S = W
			switch(S.type)

				if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
					if(!anchored)
						if(S.amount < 2) return
						S.use(2)
						user << "\blue You create a false wall! Push on it to open or close the passage."
						new /obj/structure/falsewall (src.loc)
					else
						if(S.amount < 2) return ..()
						user << "\blue Now adding plating..."
						if (do_after(user,40))
							if(!src || !S || S.amount < 2) return
							S.use(2)
							user << "\blue You added the plating!"
							var/turf/Tsrc = get_turf(src)
							Tsrc.ReplaceWithWall()
							for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
								P.layer = 1
							for(var/turf/simulated/wall/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							del(src)
						return

				if(/obj/item/stack/sheet/plasteel)
					if(!anchored)
						if(S.amount < 2) return
						S.use(2)
						user << "\blue You create a false wall! Push on it to open or close the passage."
						new /obj/structure/falserwall (src.loc)
					else
						if (src.icon_state == "reinforced") //I cant believe someone would actually write this line of code...
							if(S.amount < 1) return ..()
							user << "\blue Now finalising reinforced wall."
							if(do_after(user, 50))
								if(!src || !S || S.amount < 1) return
								S.use(1)
								user << "\blue Wall fully reinforced!"
								var/turf/Tsrc = get_turf(src)
								Tsrc.ReplaceWithRWall()
								for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
									P.layer = 1
								for(var/turf/simulated/wall/r_wall/X in Tsrc.loc)
									if(X)	X.add_hiddenprint(usr)
								del(src)
							return
						else
							if(S.amount < 1) return ..()
							user << "\blue Now reinforcing girders"
							if (do_after(user,60))
								if(!src || !S || S.amount < 1) return
								S.use(1)
								user << "\blue Girders reinforced!"
								new/obj/structure/girder/reinforced( src.loc )
								del(src)
							return

				if(/obj/item/stack/sheet/gold)
					if(!anchored)
						if(S.amount < 2) return
						S.use(2)
						user << "\blue You create a false wall! Push on it to open or close the passage."
						new /obj/structure/falsewall/gold (src.loc)
					else
						if(S.amount < 2) return ..()
						user << "\blue Now adding plating..."
						if (do_after(user,40))
							if(!src || !S || S.amount < 2) return
							S.use(2)
							user << "\blue You added the plating!"
							var/turf/Tsrc = get_turf(src)
							Tsrc.ReplaceWithMineralWall("gold")
							for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
								P.layer = 1
							for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							del(src)
						return

				if(/obj/item/stack/sheet/silver)
					if(!anchored)
						if(S.amount < 2) return
						S.use(2)
						user << "\blue You create a false wall! Push on it to open or close the passage."
						new /obj/structure/falsewall/silver (src.loc)
					else
						if(S.amount < 2) return ..()
						user << "\blue Now adding plating..."
						if (do_after(user,40))
							if(!src || !S || S.amount < 2) return
							S.use(2)
							user << "\blue You added the plating!"
							var/turf/Tsrc = get_turf(src)
							Tsrc.ReplaceWithMineralWall("silver")
							for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
								P.layer = 1
							for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							del(src)
						return

				if(/obj/item/stack/sheet/diamond)
					if(!anchored)
						if(S.amount < 2) return
						S.use(2)
						user << "\blue You create a false wall! Push on it to open or close the passage."
						new /obj/structure/falsewall/diamond (src.loc)
					else
						if(S.amount < 2) return ..()
						user << "\blue Now adding plating..."
						if (do_after(user,40))
							if(!src || !S || S.amount < 2) return
							S.use(2)
							user << "\blue You added the plating!"
							var/turf/Tsrc = get_turf(src)
							Tsrc.ReplaceWithMineralWall("diamond")
							for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
								P.layer = 1
							for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							del(src)
						return

				if(/obj/item/stack/sheet/uranium)
					if(!anchored)
						if(S.amount < 2) return
						S.use(2)
						user << "\blue You create a false wall! Push on it to open or close the passage."
						new /obj/structure/falsewall/uranium (src.loc)
					else
						if(S.amount < 2) return ..()
						user << "\blue Now adding plating..."
						if (do_after(user,40))
							if(!src || !S || S.amount < 2) return
							S.use(2)
							user << "\blue You added the plating!"
							var/turf/Tsrc = get_turf(src)
							Tsrc.ReplaceWithMineralWall("uranium")
							for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
								P.layer = 1
							for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							del(src)
						return

				if(/obj/item/stack/sheet/plasma)
					if(!anchored)
						if(S.amount < 2) return
						S.use(2)
						user << "\blue You create a false wall! Push on it to open or close the passage."
						new /obj/structure/falsewall/plasma (src.loc)
					else
						if(S.amount < 2) return ..()
						user << "\blue Now adding plating..."
						if (do_after(user,40))
							if(!src || !S || S.amount < 2) return
							S.use(2)
							user << "\blue You added the plating!"
							var/turf/Tsrc = get_turf(src)
							Tsrc.ReplaceWithMineralWall("plasma")
							for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
								P.layer = 1
							for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							del(src)
						return

				if(/obj/item/stack/sheet/clown)
					if(!anchored)
						if(S.amount < 2) return
						S.use(2)
						user << "\blue You create a false wall! Push on it to open or close the passage."
						new /obj/structure/falsewall/clown (src.loc)
					else
						if(S.amount < 2) return ..()
						user << "\blue Now adding plating..."
						if (do_after(user,40))
							if(!src || !S || S.amount < 2) return
							user << "\blue You added the plating!"
							var/turf/Tsrc = get_turf(src)
							Tsrc.ReplaceWithMineralWall("clown")
							for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
								P.layer = 1
							for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							del(src)
						return

				if(/obj/item/stack/sheet/sandstone)
					if(!anchored)
						if(S.amount < 2) return
						S.use(2)
						user << "\blue You create a false wall! Push on it to open or close the passage."
						new /obj/structure/falsewall/sandstone (src.loc)
					else
						if(S.amount < 2) return ..()
						user << "\blue Now adding plating..."
						if (do_after(user,40))
							if(!src || !S || S.amount < 2) return
							S.use(2)
							user << "\blue You added the plating!"
							var/turf/Tsrc = get_turf(src)
							Tsrc.ReplaceWithMineralWall("sandstone")
							for(var/obj/machinery/atmospherics/pipe/P in Tsrc)
								P.layer = 1
							for(var/turf/simulated/wall/mineral/X in Tsrc.loc)
								if(X)	X.add_hiddenprint(usr)
							del(src)
						return

			add_hiddenprint(usr)
			del(src)

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
	icon= 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	anchored = 1
	density = 1
	layer = 2

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/wrench))
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
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