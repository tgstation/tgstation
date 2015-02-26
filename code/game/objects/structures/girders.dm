/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = 2
	var/state = 0

/obj/structure/girder/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench) && state == 0)
		if(anchored && !istype(src,/obj/structure/girder/displaced))
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
			user << "<span class='info'>Now disassembling the girder</span>"
			if(do_after(user,40))
				if(!src) return
				user << "<span class='info'>You dissasembled the girder!</span>"
				//new /obj/item/stack/sheet/metal(get_turf(src))
				var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
				M.amount = 1
				qdel(src)
		else if(!anchored)
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
			user << "\<span class='info'>Now securing the girder</span>"
			if(get_turf(user, 40))
				user << "<span class='info'>You secured the girder!</span>"
				//var/obj/structure/girder/G = new/obj/structure/girder( src.loc )
				add_hiddenprint(user)
				add_fingerprint(user)
				anchored = 1
				update_icon()

	else if(istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_WALLS)) //we can dig a wall, we can dig a girder
			return

		user.visible_message("<span class='warning'>[user] starts [PK.drill_verb] \the [src] with \the [PK]</span>",
							"<span class='notice'>You start [PK.drill_verb] \the [src] with \the [PK]</span>")
		if(do_after(user,30))
			if(!src) return
			user.visible_message("<span class='warning'>[user] destroys \the [src]!</span>",
								"<span class='notice'>You start [PK.drill_verb] \the [src] with \the [PK]</span>")
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
			M.amount = 1
			qdel(src)

	else if(istype(W, /obj/item/weapon/screwdriver) && state == 2)
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
		user << "<span class='info'>Now unsecuring support struts.</span>"
		if(do_after(user,40))
			if(!src || !get_turf(src)) return
			user << "<span class='info'>You unsecured the support struts!</span>"
			state = 1
			update_icon()

	else if(istype(W, /obj/item/weapon/wirecutters) && state == 1)
		playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 100, 1)
		user << "<span class='info'>Now removing support struts</span>"
		if(do_after(user,40))
			if(!src || !get_turf(src)) return
			user << "<span class='info'>You removed the support struts!</span>"
			state = 0
			update_icon()

	else if(istype(W, /obj/item/weapon/crowbar) && state == 0 && anchored )
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 100, 1)
		user << "<span class='info'>Now dislodging the girder</span>"
		if(do_after(user, 40))
			if(!src) return
			user << "<span class='info'>You dislodged the girder!</span>"
			add_hiddenprint(user)
			add_fingerprint(user)
			anchored = 0
			update_icon()

	else if(istype(W, /obj/item/stack/sheet))

		var/obj/item/stack/sheet/S = W
		switch(S.type)

			if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
				if(!anchored)
					if(S.amount < 2) return
					var/pdiff=performWallPressureCheck(src.loc)
					if(!pdiff)
						S.use(2)
						user << "<span class='info'>You create a false wall! Push on it to open or close the passage.</span>"
						var/obj/structure/falsewall/FW = new /obj/structure/falsewall (src.loc)
						FW.add_hiddenprint(user)
						qdel(src)
					else
						user << "<span class='warning'>There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>"
						message_admins("Attempted false wall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
						log_admin("Attempted false wall made by [user.real_name] (user.ckey) at [loc] had a pressure difference of [pdiff]!")
						return
				else
					if(S.amount < 2) return ..()
					user << "<span class='info'>Now adding plating...</span>"
					if (do_after(user,40))
						if(!src || !S || S.amount < 2 || !get_turf(src)) return
						S.use(2)
						user << "<span class='info'>You added the plating!</span>"
						var/turf/Tsrc = get_turf(src)
						var/turf/simulated/wall/X = Tsrc.ChangeTurf(/turf/simulated/wall)
						if(X)
							X.add_hiddenprint(user)
							X.add_fingerprint(user)
						qdel(src)
					return

			if(/obj/item/stack/sheet/plasteel)
				if(!anchored)
					if(S.amount < 2) return
					var/pdiff=performWallPressureCheck(src.loc)
					if(!pdiff)
						S.use(2)
						user << "<span class='info'>You create a false wall! Push on it to open or close the passage.</span>"
						var/obj/structure/falserwall/FW = new /obj/structure/falserwall (src.loc)
						FW.add_hiddenprint(user)
						del(src)
					else
						user << "<span class='warning'>There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>"
						message_admins("Attempted false rwall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
						log_admin("Attempted false rwall made by [user.real_name] ([user.ckey]) at [loc] had a pressure difference of [pdiff]!")
						return
				else
					if (state == 2) //I cant believe someone would actually write this line of code...
						if(S.amount < 1) return ..()
						user << "<span class='info'>Now finalising reinforced wall.</span>"
						if(do_after(user, 50))
							if(!src || !S || S.amount < 1) return
							S.use(1)
							user << "\blue Wall fully reinforced!"
							var/turf/Tsrc = get_turf(src)
							var/turf/simulated/wall/r_wall/X = Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
							if(X)
								X.add_hiddenprint(user)
								X.add_fingerprint(user)
							qdel(src)
						return
					else
						if(S.amount < 1) return ..()
						user << "<span class='info'>Now reinforcing girders</span>"
						if (do_after(user,60))
							if(!src || !S || S.amount < 1 || !get_turf(src)) return
							S.use(1)
							user << "<span class='info'>Girders reinforced!</span>"
							add_hiddenprint(user)
							add_fingerprint(user)
							state = 2
							update_icon()
						return

		if(S.sheettype)
			var/M = S.sheettype
			if(!anchored)
				if(S.amount < 2) return
				var/pdiff=performWallPressureCheck(src.loc)
				if(!pdiff)
					S.use(2)
					user << "<span class='info'>You create a false wall! Push on it to open or close the passage.</span>"
					var/F = text2path("/obj/structure/falsewall/[M]")
					var/obj/structure/falsewall/FW = new F (src.loc)
					FW.add_hiddenprint(user)
					qdel(src)
				else
					user << "<span class='warning'>There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>"
					message_admins("Attempted false [M] wall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
					log_admin("Attempted false [M] wall made by [user.real_name] ([user.ckey]) at [loc] had a pressure difference of [pdiff]!")
					return
			else
				if(S.amount < 2) return ..()
				user << "<span class='info'>Now adding plating...</span>"
				if (do_after(user,40))
					if(!src || !S || S.amount < 2) return
					S.use(2)
					user << "<span class='info'>You added the plating!</span>"
					var/turf/Tsrc = get_turf(src)
					var/turf/simulated/wall/mineral/X = Tsrc.ChangeTurf(text2path("/turf/simulated/wall/mineral/[M]"))
					if(X)
						X.add_hiddenprint(user)
						X.add_fingerprint(user)
					qdel(src)
				return

		add_hiddenprint(usr)

	else if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if (P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
			user.drop_item()
			P.loc = src.loc
			user << "\blue You fit the pipe into the [src]!"
	else
		..()


/obj/structure/girder/blob_act()
	if(prob(40))
		qdel(src)

/obj/structure/girder/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam/pulse))
		src.ex_act(2)
	..()
	return 0

/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(30))
				if(prob(50))
					new /obj/item/stack/rods(loc)
				else
					var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
					M.amount = 1
				qdel(src)
			return
		if(3.0)
			if (prob(5))
				if(prob(50))
					new /obj/item/stack/rods(loc)
				else
					var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
					M.amount = 1
				qdel(src)
			return
	return
/obj/structure/girder/update_icon()
	if(anchored)
		if(state)
			icon_state = "reinforced"
		else
			icon_state = "girder"
	else
		icon_state = "displaced"

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

/obj/structure/cultgirder/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/wrench))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
		user << "<span class='info'>Now disassembling the girder</span>"
		if(do_after(user,40))
			if(!src || !get_turf(src)) return
			user << "\blue You dissasembled the girder!"
			new /obj/effect/decal/remains/human(get_turf(src))
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_WALLS))
			return

		user.visible_message("<span class='warning'>[user] starts [PK.drill_verb] \the [src] with \the [PK]</span>",
							"<span class='notice'>You start [PK.drill_verb] \the [src] with \the [PK]</span>")
		if(do_after(user,30))
			if(!src || !get_turf(src)) return
			user.visible_message("<span class='warning'>[user] destroys \the [src]!</span>",
								"<span class='notice'>You start [PK.drill_verb] \the [src] with \the [PK]</span>")
			new /obj/effect/decal/remains/human(loc)
			del(src)

/obj/structure/cultgirder/blob_act()
	if(prob(40))
		del(src)


/obj/structure/cultgirder/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(30))
				new /obj/effect/decal/remains/human(loc)
				qdel(src)
			return
		if(3.0)
			if (prob(5))
				new /obj/effect/decal/remains/human(loc)
				qdel(src)
			return
	return