/obj/structure/frame/computer
	name = "computer frame"
	icon_state = "0"
	state = 0

/obj/structure/frame/computer/attackby(obj/item/P, mob/user, params)
	add_fingerprint(user)
	switch(state)
		if(0)
			if(istype(P, /obj/item/wrench))
				playsound(src.loc, P.usesound, 50, 1)
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
						to_chat(user, "<span class='warning'>The welding tool must be on to complete this task!</span>")
					return
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You start deconstructing the frame...</span>")
				if(do_after(user, 20*P.toolspeed, target = src))
					if(!src || !WT.isOn()) return
					to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
					var/obj/item/stack/sheet/metal/M = new (loc, 5)
					M.add_fingerprint(user)
					qdel(src)
				return
		if(1)
			if(istype(P, /obj/item/wrench))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You start to unfasten the frame...</span>")
				if(do_after(user, 20*P.toolspeed, target = src))
					to_chat(user, "<span class='notice'>You unfasten the frame.</span>")
					anchored = FALSE
					state = 0
				return
			if(istype(P, /obj/item/circuitboard/computer) && !circuit)
				if(!user.drop_item())
					return
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
				icon_state = "1"
				circuit = P
				circuit.add_fingerprint(user)
				P.loc = null
				return

			else if(istype(P, /obj/item/circuitboard) && !circuit)
				to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return
			if(istype(P, /obj/item/screwdriver) && circuit)
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
				state = 2
				icon_state = "2"
				return
			if(istype(P, /obj/item/crowbar) && circuit)
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
				state = 1
				icon_state = "0"
				circuit.loc = src.loc
				circuit.add_fingerprint(user)
				circuit = null
				return
		if(2)
			if(istype(P, /obj/item/screwdriver) && circuit)
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
				return
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
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
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the cables.</span>")
				state = 2
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new (loc)
				A.amount = 5
				A.add_fingerprint(user)
				return

			if(istype(P, /obj/item/stack/sheet/glass))
				var/obj/item/stack/sheet/glass/G = P
				if(G.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two glass sheets to continue construction!</span>")
					return
				else
					playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
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
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
				state = 3
				icon_state = "3"
				var/obj/item/stack/sheet/glass/G = new (loc, 2)
				G.add_fingerprint(user)
				return
			if(istype(P, /obj/item/screwdriver))
				playsound(src.loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/obj/B = new src.circuit.build_path (src.loc, circuit)
				transfer_fingerprints_to(B)
				qdel(src)
				return
	if(user.a_intent == INTENT_HARM)
		return ..()


/obj/structure/frame/computer/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(state == 4)
			new /obj/item/shard(loc)
			new /obj/item/shard(loc)
		if(state >= 3)
			new /obj/item/stack/cable_coil(loc , 5)
	..()