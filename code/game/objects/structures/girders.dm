<<<<<<< HEAD
#define GIRDER_NORMAL 0
#define GIRDER_REINF_STRUTS 1
#define GIRDER_REINF 2
#define GIRDER_DISPLACED 3
#define GIRDER_DISASSEMBLED 4

/obj/structure/girder
	name = "girder"
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = BELOW_OBJ_LAYER
	var/state = GIRDER_NORMAL
	var/girderpasschance = 20 // percentage chance that a projectile passes through the girder.
	var/can_displace = TRUE //If the girder can be moved around by wrenching it

/obj/structure/girder/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(state == GIRDER_DISPLACED)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			user.visible_message("<span class='warning'>[user] disassembles the girder.</span>", \
								"<span class='notice'>You start to disassemble the girder...</span>", "You hear clanking and banging noises.")
			if(do_after(user, 40/W.toolspeed, target = src))
				if(state != GIRDER_DISPLACED)
					return
				state = GIRDER_DISASSEMBLED
				user << "<span class='notice'>You disassemble the girder.</span>"
				var/obj/item/stack/sheet/metal/M = new (loc, 2)
				M.add_fingerprint(user)
				qdel(src)
		else if(state == GIRDER_REINF)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			user << "<span class='notice'>You start unsecuring support struts...</span>"
			if(do_after(user, 40/W.toolspeed, target = src))
				if(state != GIRDER_REINF)
					return
				user << "<span class='notice'>You unsecure the support struts.</span>"
				state = GIRDER_REINF_STRUTS

	else if(istype(W, /obj/item/weapon/wrench))
		if(state == GIRDER_DISPLACED)
			if(!istype(loc, /turf/open/floor))
				user << "<span class='warning'>A floor must be present to secure the girder!</span>"
				return
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user << "<span class='notice'>You start securing the girder...</span>"
			if(do_after(user, 40/W.toolspeed, target = src))
				user << "<span class='notice'>You secure the girder.</span>"
				var/obj/structure/girder/G = new (loc)
				transfer_fingerprints_to(G)
				qdel(src)
		else if(state == GIRDER_NORMAL && can_displace)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user << "<span class='notice'>You start unsecuring the girder...</span>"
			if(do_after(user, 40/W.toolspeed, target = src))
				user << "<span class='notice'>You unsecure the girder.</span>"
				var/obj/structure/girder/displaced/D = new (loc)
				transfer_fingerprints_to(D)
				qdel(src)

	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		user << "<span class='notice'>You start slicing apart the girder...</span>"
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		if(do_after(user, 30, target = src))
			user << "<span class='notice'>You slice apart the girder.</span>"
			var/obj/item/stack/sheet/metal/M = new (loc, 2)
			M.add_fingerprint(user)
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		user << "<span class='notice'>You smash through the girder!</span>"
		new /obj/item/stack/sheet/metal(get_turf(src))
		D.playDigSound()
		qdel(src)

	else if(istype(W, /obj/item/weapon/wirecutters) && state == GIRDER_REINF_STRUTS)
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		user << "<span class='notice'>You start removing support struts...</span>"
		if(do_after(user, 40/W.toolspeed, target = src))
			user << "<span class='notice'>You remove the support struts.</span>"
			new /obj/item/stack/sheet/plasteel(get_turf(src))
			var/obj/structure/girder/G = new (loc)
			transfer_fingerprints_to(G)
			qdel(src)

	else if(istype(W, /obj/item/stack))
		if (istype(src.loc, /turf/closed/wall))
			user << "<span class='warning'>There is already a wall present!</span>"
			return
		if (!istype(src.loc, /turf/open/floor))
			user << "<span class='warning'>A floor must be present to build a false wall!</span>"
			return
		if (locate(/obj/structure/falsewall) in src.loc.contents)
			user << "<span class='warning'>There is already a false wall present!</span>"
			return

		if(istype(W,/obj/item/stack/rods))
			var/obj/item/stack/rods/S = W
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					user << "<span class='warning'>You need at least two rods to create a false wall!</span>"
					return
				user << "<span class='notice'>You start building a reinforced false wall...</span>"
				if(do_after(user, 20, target = src))
					if(!src.loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					user << "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>"
					var/obj/structure/falsewall/iron/FW = new (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(S.get_amount() < 5)
					user << "<span class='warning'>You need at least five rods to add plating!</span>"
					return
				user << "<span class='notice'>You start adding plating...</span>"
				if (do_after(user, 40, target = src))
					if(!src.loc || !S || S.get_amount() < 5)
						return
					S.use(5)
					user << "<span class='notice'>You add the plating.</span>"
					var/turf/T = get_turf(src)
					T.ChangeTurf(/turf/closed/wall/mineral/iron)
					transfer_fingerprints_to(T)
					qdel(src)
				return

		if(!istype(W,/obj/item/stack/sheet))
			return

		var/obj/item/stack/sheet/S = W
		if(istype(S,/obj/item/stack/sheet/metal))
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					user << "<span class='warning'>You need two sheets of metal to create a false wall!</span>"
					return
				user << "<span class='notice'>You start building a false wall...</span>"
				if(do_after(user, 20, target = src))
					if(!src.loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					user << "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>"
					var/obj/structure/falsewall/F = new (loc)
					transfer_fingerprints_to(F)
					qdel(src)
			else
				if(S.get_amount() < 2)
					user << "<span class='warning'>You need two sheets of metal to finish a wall!</span>"
					return
				user << "<span class='notice'>You start adding plating...</span>"
				if (do_after(user, 40, target = src))
					if(loc == null || S.get_amount() < 2)
						return
					S.use(2)
					user << "<span class='notice'>You add the plating.</span>"
					var/turf/T = get_turf(src)
					T.ChangeTurf(/turf/closed/wall)
					transfer_fingerprints_to(T)
					qdel(src)
				return

		if(istype(S,/obj/item/stack/sheet/plasteel))
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					user << "<span class='warning'>You need at least two sheets to create a false wall!</span>"
					return
				user << "<span class='notice'>You start building a reinforced false wall...</span>"
				if(do_after(user, 20, target = src))
					if(!src.loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					user << "<span class='notice'>You create a reinforced false wall. Push on it to open or close the passage.</span>"
					var/obj/structure/falsewall/reinforced/FW = new (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(state == GIRDER_REINF)
					if(S.get_amount() < 1)
						return
					user << "<span class='notice'>You start finalizing the reinforced wall...</span>"
					if(do_after(user, 50, target = src))
						if(!src.loc || !S || S.get_amount() < 1)
							return
						S.use(1)
						user << "<span class='notice'>You fully reinforce the wall.</span>"
						var/turf/T = get_turf(src)
						T.ChangeTurf(/turf/closed/wall/r_wall)
						transfer_fingerprints_to(T)
						qdel(src)
					return
				else
					if(S.get_amount() < 1)
						return
					user << "<span class='notice'>You start reinforcing the girder...</span>"
					if (do_after(user, 60, target = src))
						if(!src.loc || !S || S.get_amount() < 1)
							return
						S.use(1)
						user << "<span class='notice'>You reinforce the girder.</span>"
						var/obj/structure/girder/reinforced/R = new (loc)
						transfer_fingerprints_to(R)
						qdel(src)
					return

		if(S.sheettype)
			var/M = S.sheettype
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < 2)
					user << "<span class='warning'>You need at least two sheets to create a false wall!</span>"
					return
				if(do_after(user, 20, target = src))
					if(!src.loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					user << "<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>"
					var/F = text2path("/obj/structure/falsewall/[M]")
					var/obj/structure/FW = new F (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
			else
				if(S.get_amount() < 2)
					user << "<span class='warning'>You need at least two sheets to add plating!</span>"
					return
				user << "<span class='notice'>You start adding plating...</span>"
				if (do_after(user, 40, target = src))
					if(!src.loc || !S || S.get_amount() < 2)
						return
					S.use(2)
					user << "<span class='notice'>You add the plating.</span>"
					var/turf/T = get_turf(src)
					T.ChangeTurf(text2path("/turf/closed/wall/mineral/[M]"))
					transfer_fingerprints_to(T)
					qdel(src)
				return

		add_hiddenprint(user)

	else if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if (P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
			if(!user.drop_item())
				return
			P.loc = src.loc
			user << "<span class='notice'>You fit the pipe into \the [src].</span>"
	else
		return ..()

/obj/structure/girder/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return prob(girderpasschance)
	else
		if(istype(mover, /obj/item/projectile))
			return prob(girderpasschance)
		else
			return 0

/obj/structure/girder/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSGRILLE)

/obj/structure/girder/blob_act(obj/effect/blob/B)
	if(prob(40))
		qdel(src)

/obj/structure/girder/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(70))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				qdel(src)
		if(3)
			if (prob(40))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				qdel(src)

/obj/structure/girder/narsie_act()
	if(prob(25))
		new /obj/structure/girder/cult(loc)
		qdel(src)
=======
/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	var/state = 0
	var/material = /obj/item/stack/sheet/metal

/obj/structure/girder/wood
	icon_state = "girder_wood"
	name = "wooden girder"
	material = /obj/item/stack/sheet/wood

/obj/structure/girder/wood/update_icon()
	if(anchored)
		name = "wooden girder"
		icon_state = "girder_wood"
	else
		name = "displaced wooden girder"
		icon_state = "displaced_wood"

/obj/structure/girder/attackby(obj/item/W as obj, mob/user as mob)
	if(iswrench(W))
		if(state == 0) //Normal girder or wooden girder
			if(anchored && !istype(src, /obj/structure/girder/displaced)) //Anchored, destroy it
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
				user.visible_message("<span class='notice'>[user] starts disassembling \the [src].</span>", \
				"<span class='notice'>You start disassembling \the [src].</span>")
				if(do_after(user, src, 40))
					user.visible_message("<span class='warning'>[user] dissasembles \the [src].</span>", \
					"<span class='notice'>You dissasemble \the [src].</span>")
					getFromPool(material, get_turf(src))
					qdel(src)
			else if(!anchored) //Unanchored, anchor it
				if(!istype(src.loc, /turf/simulated/floor)) //Prevent from anchoring shit to shuttles / space
					to_chat(user, "<span class='notice'>You can't secure \the [src] to [istype(src.loc,/turf/space) ? "space" : "this"]!</span>")
					return

				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
				user.visible_message("<span class='notice'>[user] starts securing \the [src].</span>", \
				"<span class='notice'>You start securing \the [src].</span>")
				if(do_after(user, src, 40))
					user.visible_message("<span class='notice'>[user] secures \the [src].</span>", \
					"<span class='notice'>You secure \the [src].</span>")
					add_hiddenprint(user)
					add_fingerprint(user)
					anchored = 1
					update_icon()
		else if(state == 1 || state == 2) //Clearly a reinforced girder
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
			user.visible_message("<span class='notice'>[user] starts [anchored ? "un" : ""]securing \the [src].</span>", \
			"<span class='notice'>You start [anchored ? "un" : ""]securing \the [src].</span>")
			if(do_after(user, src, 40))
				anchored = !anchored //Unachor it if anchored, or opposite
				user.visible_message("<span class='notice'>[user] [anchored ? "" : "un"]secures \the [src].</span>", \
				"<span class='notice'>You [anchored ? "" : "un"]secure \the [src].</span>")
				add_hiddenprint(user)
				add_fingerprint(user)
				update_icon()

	else if(istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_WALLS)) //If we can't dig a wall, we can't dig a girder
			return

		user.visible_message("<span class='warning'>[user] starts [PK.drill_verb] \the [src] with \the [PK]</span>", \
		"<span class='notice'>You start [PK.drill_verb] \the [src] with \the [PK]</span>")
		if(do_after(user, src, 30))
			user.visible_message("<span class='warning'>[user] destroys \the [src]!</span>", \
			"<span class='notice'>Your [PK] tears through the last of \the [src]!</span>")
			getFromPool(material, get_turf(src))
			qdel(src)

	else if(isscrewdriver(W) && state == 2) //Unsecuring support struts, stage 2 to 1
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] starts unsecuring \the [src]'s internal support struts.</span>", \
		"<span class='notice'>You start unsecuring \the [src]'s internal support struts.</span>")
		if(do_after(user, src, 40))
			user.visible_message("<span class='warning'>[user] unsecures \the [src]'s internal support struts.</span>", \
			"<span class='notice'>You unsecure \the [src]'s internal support struts.</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			state = 1
			update_icon()

	else if(isscrewdriver(W) && state == 1) //Securing support struts, stage 1 to 2
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("<span class='notice'>[user] starts securing \the [src]'s internal support struts.</span>", \
		"<span class='notice'>You start securing \the [src]'s internal support struts.</span>")
		if(do_after(user, src, 40))
			user.visible_message("<span class='notice'>[user] secures \the [src]'s internal support struts.</span>", \
			"<span class='notice'>You secure \the [src]'s internal support struts.</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			state = 2
			update_icon()

	else if(iswirecutter(W) && state == 1) //Removing support struts, stage 1 to 0 (normal girder)
		playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] starts removing \the [src]'s internal support struts.</span>", \
		"<span class='notice'>You start removing \the [src]'s internal support struts.</span>")
		if(do_after(user, src, 40))
			user.visible_message("<span class='warning'>[user] removes \the [src]'s internal support struts.</span>", \
			"<span class='notice'>You remove \the [src]'s internal support struts.</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			getFromPool(/obj/item/stack/rods, get_turf(src), 2)
			state = 0
			update_icon()

	else if(istype(W, /obj/item/stack/rods) && state == 0 && material == /obj/item/stack/sheet/metal) //Inserting support struts, stage 0 to 1 (reinforced girder, replaces plasteel step)
		var/obj/item/stack/rods/R = W
		if(R.amount < 2) //Do a first check BEFORE the user begins, in case he's using a single rod
			to_chat(user, "<span class='warning'>You need more rods to finish the support struts.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts inserting internal support struts into \the [src.]</span>", \
		"<span class='notice'>You start inserting internal support struts into \the [src].</span>")
		if(do_after(user, src,40))
			var/obj/item/stack/rods/O = W
			if(O.amount < 2) //In case our user is trying to be tricky
				to_chat(user, "<span class='warning'>You need more rods to finish the support struts.</span>")
				return
			O.use(2)
			user.visible_message("<span class='notice'>[user] inserts internal support struts into \the [src].</span>", \
			"<span class='notice'>You insert internal support struts into \the [src].</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			state = 1
			update_icon()

	else if(iscrowbar(W) && state == 0 && anchored) //Turning normal girder into disloged girder
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] starts dislodging \the [src].</span>", \
		"<span class='notice'>You start dislodging \the [src].</span>")
		if(do_after(user, src, 40))
			user.visible_message("<span class='warning'>[user] dislodges \the [src].</span>", \
			"<span class='notice'>You dislodge \the [src].</span>")
			add_hiddenprint(user)
			add_fingerprint(user)
			anchored = 0
			update_icon()

	else if(istype(W, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = W
		switch(S.type)
			if(/obj/item/stack/sheet/metal, /obj/item/stack/sheet/metal/cyborg)
				if(state) //We are trying to finish a reinforced girder with regular metal
					return
				if(!anchored)
					if(S.amount < 2)
						return
					var/pdiff = performWallPressureCheck(src.loc)
					if(!pdiff) //Should really not be that precise, 10 kPa is the usual breaking point
						S.use(2)
						user.visible_message("<span class='warning'>[user] creates a false wall!</span>", \
						"<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
						var/obj/structure/falsewall/FW = new /obj/structure/falsewall (src.loc)
						FW.add_hiddenprint(user)
						FW.add_fingerprint(user)
						qdel(src)
					else
						to_chat(user, "<span class='warning'>There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>")
						message_admins("Attempted false wall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
						log_admin("Attempted false wall made by [user.real_name] (user.ckey) at [loc] had a pressure difference of [pdiff]!")
						return
				else
					if(S.amount < 2)
						return ..() // ?
					user.visible_message("<span class='notice'>[user] starts installing plating to \the [src].</span>", \
					"<span class='notice'>You start installing plating to \the [src].</span>")
					if(do_after(user, src, 40))
						if(S.amount < 2) //User being tricky
							return
						S.use(2)
						user.visible_message("<span class='notice'>[user] finishes installing plating to \the [src].</span>", \
						"<span class='notice'>You finish installing plating to \the [src].</span>")
						var/turf/Tsrc = get_turf(src)
						if(!istype(Tsrc)) return 0
						var/turf/simulated/wall/X = Tsrc.ChangeTurf(/turf/simulated/wall)
						if(X)
							X.add_hiddenprint(user)
							X.add_fingerprint(user)
						qdel(src)
					return

			if(/obj/item/stack/sheet/plasteel)

				//Due to the way wall construction works, this uses both plasteel sheets immediately
				if(!anchored)
					if(S.amount < 2)
						return
					var/pdiff = performWallPressureCheck(src.loc)
					if(!pdiff)
						S.use(2)
						user.visible_message("<span class='warning'>[user] creates a false reinforced wall!</span>", \
						"<span class='notice'>You create a false reinforced wall. Push on it to open or close the passage.</span>")
						var/obj/structure/falserwall/FW = new /obj/structure/falserwall(src.loc)
						FW.add_hiddenprint(user)
						FW.add_fingerprint(user)
						qdel(src)
					else
						to_chat(user, "<span class='warning'>There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>")
						message_admins("Attempted false rwall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
						log_admin("Attempted false rwall made by [user.real_name] ([user.ckey]) at [loc] had a pressure difference of [pdiff]!")
						return

				//We are ready to turn this reinforced girder into a beautiful reinforced wall
				//The other plasteel sheet is used in the rest of the construction steps, see walls_reinforced.dm

				if(state != 2)
					return //Coders against indents
				user.visible_message("<span class='warning'>[user] starts installing reinforced plating to \the [src].</span>", \
				"<span class='notice'>You start installing reinforced plating to \the [src].</span>")
				if(do_after(user, src, 50))
					S.use(1)
					user.visible_message("<span class='warning'>[user] finishes installing reinforced plating to \the [src].</span>", \
					"<span class='notice'>You finish installing reinforced plating to \the [src].</span>")
					var/turf/Tsrc = get_turf(src)
					var/turf/simulated/wall/r_wall/X = Tsrc.ChangeTurf(/turf/simulated/wall/r_wall)
					if(X)
						X.add_hiddenprint(user)
						X.add_fingerprint(user)
						X.d_state = 4 //Reinforced wall not finished yet, but since we're changing to a turf, need to transfer desired variables
						X.update_icon() //Tell our reinforced wall to update its icon
					qdel(src)
				return

		if(S.sheettype)
			var/M = S.sheettype
			if(!anchored)
				if(S.amount < 2)
					return
				var/F = text2path("/obj/structure/falsewall/[M]")
				if(!ispath(F))
					return
				var/pdiff = performWallPressureCheck(src.loc)
				if(!pdiff)
					S.use(2)
					user.visible_message("<span class='warning'>[user] creates a false wall!</span>", \
					"<span class='notice'>You create a false wall. Push on it to open or close the passage.</span>")
					var/obj/structure/falsewall/FW = new F (src.loc)
					FW.add_hiddenprint(user)
					FW.add_fingerprint(user)
					qdel(src)
				else
					to_chat(user, "<span class='warning'>There is too much air moving through the gap!  The door wouldn't stay closed if you built it.</span>")
					message_admins("Attempted false [M] wall made by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)] had a pressure difference of [pdiff]!")
					log_admin("Attempted false [M] wall made by [user.real_name] ([user.ckey]) at [loc] had a pressure difference of [pdiff]!")
					return
			else
				if(S.amount < 2)
					return ..()
				var/wallpath = text2path("/turf/simulated/wall/mineral/[M]")
				if(!ispath(wallpath))
					return ..()
				user.visible_message("<span class='notice'>[user] starts installing plating to \the [src].</span>", \
				"<span class='notice'>You start installing plating to \the [src].</span>")
				if(do_after(user, src,40))
					if(S.amount < 2) //Don't be tricky now
						return
					S.use(2)
					user.visible_message("<span class='notice'>[user] finishes installing plating to \the [src].</span>", \
					"<span class='notice'>You finish installing plating to \the [src].</span>")
					var/turf/Tsrc = get_turf(src)
					var/turf/simulated/wall/mineral/X = Tsrc.ChangeTurf(wallpath)
					if(X)
						X.add_hiddenprint(user)
						X.add_fingerprint(user)
					qdel(src)
				return

		add_hiddenprint(usr)

	//Wait, what, WHAT ?
	else if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if(P.pipe_type in list(0, 1, 5))	//Simple pipes, simple bends, and simple manifolds.
			if(user.drop_item(P, src.loc))
				user.visible_message("<span class='warning'>[user] fits \the [P] into \the [src]</span>", \
				"<span class='notice'>You fit \the [P] into \the [src]</span>")
	else
		..()

/obj/structure/girder/blob_act()
	..()
	if(prob(40))
		qdel(src)

/obj/structure/girder/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.destroy)
		src.ex_act(2)
	..()
	return 0

/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(25) && state == 2) //Strong enough to have a chance to stand if finished, but not in one piece
				getFromPool(/obj/item/stack/rods, get_turf(src)) //Lose one rod
				state = 0
				update_icon()
			else //Not finished or not lucky
				qdel(src) //No scraps
			return
		if(2.0)
			if(prob(30))
				if(state == 2)
					state = 1
					update_icon()
				if(state == 1)
					getFromPool(/obj/item/stack/rods, get_turf(src))
					state = 0
					update_icon()
				else
					getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
					qdel(src)
			return
		if(3.0)
			if((state == 0) && prob(5))
				getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
				qdel(src)
			else if(prob(15))
				if(state == 2)
					state = 1
					update_icon()
				if(state == 1)
					getFromPool(/obj/item/stack/rods, get_turf(src), 2)
					state = 0
					update_icon()
			return
	return

/obj/structure/girder/mech_drill_act(severity)
	getFromPool(/obj/item/stack/sheet/metal, get_turf(src))
	qdel(src)
	return

/obj/structure/girder/update_icon()
	//Names really shouldn't be set here, but it's the only proc that checks where needed
	if(anchored)
		if(state)
			name = "reinforced girder"
			icon_state = "reinforced"
		else
			name = "girder"
			icon_state = "girder"
	else
		if(state)
			name = "displaced reinforced girder"
			icon_state = "r_displaced"
		else
			name = "displaced girder"
			icon_state = "displaced"

/obj/structure/girder/projectile_check()
	return PROJREACT_WALLS
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/girder/displaced
	name = "displaced girder"
	icon_state = "displaced"
	anchored = 0
<<<<<<< HEAD
	state = GIRDER_DISPLACED
	girderpasschance = 25
=======
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/structure/girder/reinforced
	name = "reinforced girder"
	icon_state = "reinforced"
<<<<<<< HEAD
	state = GIRDER_REINF
	girderpasschance = 0

/obj/structure/girder/reinforced/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				qdel(src)
		if(3)
			if (prob(20))
				var/remains = pick(/obj/item/stack/rods,/obj/item/stack/sheet/metal)
				new remains(loc)
				qdel(src)


//////////////////////////////////////////// cult girder //////////////////////////////////////////////

/obj/structure/girder/cult
	name = "runed girder"
	desc = "Framework made of a strange and shockingly cold metal. It doesn't seem to have any bolts."
	icon = 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	can_displace = FALSE

/obj/structure/girder/cult/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/weapon/tome) && iscultist(user)) //Cultists can demolish cult girders instantly with their tomes
		user.visible_message("<span class='warning'>[user] strikes [src] with [W]!</span>", "<span class='notice'>You demolish [src].</span>")
		var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
		R.amount = 1
		qdel(src)

	else if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
			user << "<span class='notice'>You start slicing apart the girder...</span>"
			if(do_after(user, 40/W.toolspeed, target = src))
				if( !WT.isOn() )
					return
				user << "<span class='notice'>You slice apart the girder.</span>"
				var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
				R.amount = 1
				transfer_fingerprints_to(R)
				qdel(src)

	else if(istype(W, /obj/item/weapon/gun/energy/plasmacutter))
		user << "<span class='notice'>You start slicing apart the girder...</span>"
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		if(do_after(user, 30, target = src))
			user << "<span class='notice'>You slice apart the girder.</span>"
			var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
			R.amount = 1
			transfer_fingerprints_to(R)
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe/drill/jackhammer))
		var/obj/item/weapon/pickaxe/drill/jackhammer/D = W
		user << "<span class='notice'>Your jackhammer smashes through the girder!</span>"
		var/obj/item/stack/sheet/runed_metal/R = new(get_turf(src))
		R.amount = 2
		transfer_fingerprints_to(R)
		D.playDigSound()
		qdel(src)

	else if(istype(W, /obj/item/stack/sheet/runed_metal))
		var/obj/item/stack/sheet/runed_metal/R = W
		if(R.get_amount() < 1)
			user << "<span class='warning'>You need at least one sheet of runed metal to construct a runed wall!</span>"
			return 0
		user.visible_message("<span class='notice'>[user] begins laying runed metal on [src]...</span>", "<span class='notice'>You begin constructing a runed wall...</span>")
		if(do_after(user, 50, target = src))
			if(R.get_amount() < 1 || !R)
				return
			user.visible_message("<span class='notice'>[user] plates [src] with runed metal.</span>", "<span class='notice'>You construct a runed wall.</span>")
			R.use(1)
			var/turf/T = get_turf(src)
			T.ChangeTurf(/turf/closed/wall/mineral/cult)
			qdel(src)

	else
		return ..()

/obj/structure/girder/cult/narsie_act()
	return

/obj/structure/girder/cult/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(30))
				new/obj/item/stack/sheet/runed_metal/(get_turf(src), 1)
				qdel(src)
		if(3)
			if(prob(5))
				new/obj/item/stack/sheet/runed_metal/(get_turf(src), 1)
				qdel(src)
=======
	state = 2

/obj/structure/cultgirder
	name = "cult girder"
	icon = 'icons/obj/cult.dmi'
	icon_state = "cultgirder"
	anchored = 1
	density = 1
	layer = 2

/obj/structure/cultgirder/attackby(obj/item/W as obj, mob/user as mob)
	if(iswrench(W))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 100, 1)
		user.visible_message("<span class='notice'>[user] starts disassembling \the [src].</span>", \
		"<span class='notice'>You start disassembling \the [src].</span>")
		if(do_after(user, src,40))
			user.visible_message("<span class='warning'>[src] dissasembles \the [src].</span>", \
			"<span class='notice'>You dissasemble \the [src].</span>")
			//new /obj/effect/decal/remains/human(get_turf(src))	//Commented out until remains are cleanable
			qdel(src)

	else if(istype(W, /obj/item/weapon/pickaxe))
		var/obj/item/weapon/pickaxe/PK = W
		if(!(PK.diggables & DIG_WALLS))
			return

		user.visible_message("<span class='warning'>[user] starts [PK.drill_verb] \the [src] with \the [PK].</span>",
							"<span class='notice'>You start [PK.drill_verb] \the [src] with \the [PK].</span>")
		if(do_after(user, src,30))
			user.visible_message("<span class='warning'>[user] destroys \the [src]!</span>",
								"<span class='notice'>Your [PK] tears through the last of \the [src]!</span>")
			new /obj/effect/decal/remains/human(loc)
			qdel(src)

/obj/structure/cultgirder/attack_construct(mob/user as mob)
	if(istype(user, /mob/living/simple_animal/construct/builder))
		to_chat(user, "You start repairing the girder.")
		if(do_after(user,src,30))
			to_chat(user, "<span class='notice'>Girder repaired.</span>")
			var/turf/Tsrc = get_turf(src)
			if(!istype(Tsrc)) return 0
			Tsrc.ChangeTurf(/turf/simulated/wall/cult)
			qdel(src)
		return 1
	return 0

/obj/structure/cultgirder/attack_animal(var/mob/living/simple_animal/M)
	M.delayNextAttack(8)
	if(M.environment_smash >= 2)
		new /obj/effect/decal/remains/human(get_turf(src))
		M.visible_message("<span class='danger'>[M] smashes through \the [src].</span>", \
		"<span class='attack'>You smash through \the [src].</span>")
		qdel(src)

/obj/structure/cultgirder/blob_act()
	if(prob(40))
		qdel(src)

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

/obj/structure/cultgirder/mech_drill_act(severity)
	new /obj/effect/decal/remains/human(loc)
	qdel(src)
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
