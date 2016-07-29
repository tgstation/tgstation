// The assembly piece. I'm not entirely sure if it should be a child of machinery, but it is.
//
//

/obj/machinery/conveyor_assembly
	name = "conveyor belt assembly"
	desc = "These are the thingies that make the loop go round."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "conveyor-assembly"
	density = 0
	anchored = 1
	use_power = 0
	var/obj/item/weapon/circuitboard/conveyor/circuit = null

/obj/machinery/conveyor_assembly/New(loc, var/newdir)
	. = ..(loc)
	if(newdir)
		dir = newdir

/obj/machinery/conveyor_assembly/examine(mob/user)
	..()
	if(!circuit)
		to_chat(user, "<span class='info'>It needs a conveyor belt circuit.</span>")
	else
		to_chat(user, "<span class='info'>It needs to be screwed together.</span>")

/obj/machinery/conveyor_assembly/attackby(obj/item/P, mob/user)
	..()
	if(iswrench(P))
		playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, src, 20))
			to_chat(user, "<span class='notice'>You dismantle the frame.</span>")
			var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, src.loc)
			M.amount = 5
			if(circuit)
				circuit.forceMove(src.loc)
				circuit = null
			qdel(src)
			return
	if(!circuit)
		if(istype(P, /obj/item/weapon/circuitboard/conveyor))
			if(!user.drop_item(P, src))
				user << "<span class='warning'>You can't let go of \the [P]!</span>"
				return
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
			circuit = P
			to_chat(user, "<span class='notice'>You insert the circuit into the conveyor frame.</span>")
	else
		if(isscrewdriver(P))
			playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
			if(do_after(user, src, 30))
				to_chat(user, "<span class='notice'>You put together \the [src].</span>")
				var/obj/machinery/conveyor/CB = new(src.loc, src.dir)
				//Transplanting the circuitboard, I'm not sure if this is the way it's meant to be done but the constructable frame code for this part is indecipherable
				for(var/obj/O in CB.component_parts)
					returnToPool(O)
				CB.component_parts = list()
				circuit.loc = null //I swear this is what happens for constructable frames
				CB.component_parts += circuit
				circuit = null
				qdel(src)

/*/obj/machinery/conveyor_assembly/proc/flush_with()
	var/mob/builder = locate() in loc //until someone gives me a better idea on how to get the user that builds us this is what we're using
	dir = builder.dir
	check_for_parent_belt:
		for(var/direction in cardinal)
			for(var/obj/machinery/domino in get_step(src, direction))
				var/list/dirs = list()
				if(istype(domino, /obj/machinery/conveyor))
					var/obj/machinery/conveyor/CB = domino
					dirs = conveyor_directions(CB.dir, CB.in_reverse)
				else if(istype(domino, /obj/machinery/conveyor_assembly))
					dirs = conveyor_directions(domino.dir)
				world << "Testing [domino] with a dir of [domino.dir]"
				if(dirs.len)
					world << "[domino] seems to have a forwards of [dirs[1]] and a backwards of [dirs[2]]"
				if(dirs.len && get_step(domino, dirs[1]) == loc)
					world << "We have a parent, [domino], whose dir is [domino.dir] and whose forwards is [dirs[1]]."
					world << "Since our dir is [dir], we're adding [dirs[1]] to it and the final result is [dir+dirs[1]]"
					if(dir != dirs[1])
						dir = dir + dirs[1]
					break check_for_parent_belt*/
