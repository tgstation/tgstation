/obj/structure/frame/computer
	name = "computer frame"
	icon_state = "0"
	state = 0

/obj/structure/frame/computer/attackby(obj/item/P, mob/user, params)
	add_fingerprint(user)
	switch(state)
		if(0)
			if(istype(P, /obj/item/wrench))
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You start wrenching the frame into place...</span>")
				if(do_after(user, 20*P.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You wrench the frame into place.</span>")
					anchored = TRUE
					state = 1
				return
			if(istype(P, /obj/item/weldingtool))
				var/obj/item/weldingtool/WT = P
				if(!WT.remove_fuel(0, user))
					if(!WT.isOn())
						to_chat(user, "<span class='warning'>[WT] must be on to complete this task!</span>")
					return
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You start deconstructing the frame...</span>")
				if(do_after(user, 20*P.toolspeed, target = src))
					if(!src || !WT.isOn())
						return
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					var/obj/item/stack/sheet/metal/M = new (drop_location(), 5)
					M.add_fingerprint(user)
					qdel(src)
				return
		if(1)
			if(istype(P, /obj/item/wrench))
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You start to unfasten the frame...</span>")
				if(do_after(user, 20*P.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					anchored = FALSE
					state = 0
				return
			if(istype(P, /obj/item/circuitboard/computer) && !circuit)
				if(!user.transferItemToLoc(P, src))
					return
				playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You place [P] inside the frame.</span>")
				icon_state = "1"
				circuit = P
				circuit.add_fingerprint(user)
				return

			else if(istype(P, /obj/item/circuitboard) && !circuit)
				to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return
			if(istype(P, /obj/item/screwdriver) && circuit)
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You screw [circuit] into place.</span>")
				state = 2
				icon_state = "2"
				return
			if(istype(P, /obj/item/crowbar) && circuit)
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove [circuit].</span>")
				state = 1
				icon_state = "0"
				circuit.forceMove(drop_location())
				circuit.add_fingerprint(user)
				circuit = null
				return
		if(2)
			if(istype(P, /obj/item/screwdriver) && circuit)
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
				return
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start adding cables to the frame...</span>")
					if(do_after(user, 20*P.toolspeed, target = src))
						if(C.get_amount() >= 5 && state == 2)
							C.use(5)
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							state = 3
							icon_state = "3"
				else
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the frame!</span>")
				return
		if(3)
			if(istype(P, /obj/item/wirecutters))
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new (drop_location())
				A.amount = 5
				A.add_fingerprint(user)
				return

			if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if(G.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two glass sheets to continue construction!</span>")
					return
				else
					playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start to put in the glass panel...</span>")
					if(do_after(user, 20, target = src))
						if(G.get_amount() >= 2 && state == 3)
							G.use(2)
							to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
							state = 4
							src.icon_state = "4"
				return
		if(4)
			if(istype(P, /obj/item/crowbar))
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				icon_state = "3"
				var/obj/item/stack/sheet/glass/G = new(drop_location(), 2)
				G.add_fingerprint(user)
				return
			if(istype(P, /obj/item/screwdriver))
				playsound(src, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/obj/B = new circuit.build_path (loc, circuit)
				B.dir = dir
				transfer_fingerprints_to(B)
				qdel(src)
				return
	if(user.a_intent == INTENT_HARM)
		return ..()


/obj/structure/frame/computer/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(state == 4)
			new /obj/item/shard(drop_location())
			new /obj/item/shard(drop_location())
		if(state >= 3)
			new /obj/item/stack/cable_coil(drop_location(), 5)
	..()

/obj/structure/frame/computer/AltClick(mob/user)
	..()
	if(!in_range(src, user) || !isliving(user) || user.incapacitated())
		return

	if(anchored)
		to_chat(usr, "<span class='warning'>You must unwrench [src] before rotating it!</span>")
		return

	setDir(turn(dir, -90))
