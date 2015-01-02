/obj/machinery/mirror
	name = "mirror"
	desc = "Looks too expensive and sciencey to mount above your bathroom sink."

	icon='icons/obj/machines/optical/beamsplitter.dmi'
	icon_state="base"
	var/mirror_state = "mirror"

	var/nsplits=1

	use_power = 0
	anchored = 0
	density = 1

	var/list/emitted_beams[4] // directions

	machine_flags = WRENCHMOVE | SCREWTOGGLE | CROWDESTROY

	var/list/powerchange_hooks=list()

/obj/machinery/mirror/New()
	..()
	overlays += mirror_state // TODO: break on BROKEN
	component_parts = newlist(
		/obj/item/stack/sheet/rglass,
		/obj/item/stack/sheet/rglass,
		/obj/item/stack/sheet/rglass,
		/obj/item/stack/sheet/rglass,
		/obj/item/stack/sheet/rglass,
	)

/obj/machinery/mirror/proc/get_deflections(var/in_dir)
	if(dir in list(EAST, WEST))
		testing("[src]: Detected orientation: \\, in_dir=[in_dir], dir=[dir]")
		switch(in_dir) // \\ orientation
			if(NORTH) return list(EAST)
			if(SOUTH) return list(WEST)
			if(EAST)  return list(NORTH)
			if(WEST)  return list(SOUTH)
	else
		testing("[src]: Detected orientation: /, in_dir=[in_dir], dir=[dir]")
		switch(in_dir) // / orientation
			if(NORTH) return list(WEST)
			if(SOUTH) return list(EAST)
			if(EAST)  return list(SOUTH)
			if(WEST)  return list(NORTH)

/obj/machinery/mirror/Destroy()
	kill_all_beams()
	..()
/obj/machinery/mirror/Move()
	..()
	kill_all_beams()

/obj/machinery/mirror/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, -90)
	//kill_all_beams()
	update_beams()
	return 1

/obj/machinery/mirror/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, 90)
	//kill_all_beams()
	update_beams()
	return 1

/obj/machinery/mirror/beam_connect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
		powerchange_hooks[B]=B.power_change.Add(src,"on_power_change")
		update_beams()

/obj/machinery/mirror/beam_disconnect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
		B.power_change.Remove(powerchange_hooks[B])
		powerchange_hooks.Remove(B)
		update_beams()

// When beam power changes
/obj/machinery/mirror/proc/on_power_change(var/list/args)
	//Don't care about args, just update beam.
	update_beams()

/obj/machinery/mirror/proc/kill_all_beams()
	for(var/i=1;i<=4;i++)
		var/obj/effect/beam/beam = emitted_beams[i]
		qdel(beam)
		emitted_beams[i]=null
		beam=null

/obj/machinery/mirror/proc/update_beams()
	overlays.Cut()

	var/list/beam_dirs[4] // dir = list(
		                  //  type = power
		                  // )

	var/i = 0 // Iteration index.

	// Initialize list.
	for(i=1;i<=4;i++)
		beam_dirs[i]=list()

	// For tracking recursion.
	var/list/spawners = list(src)

	//testing("Beam count: [beams.len]")
	if(beams.len>0)
		// Figure out what we're getting hit by.
		for(var/obj/effect/beam/B in beams)
			if(B.HasSource(src))
				warning("Ignoring beam [B] due to recursion.")
				continue // Prevent infinite loops.

			// For recursion protection
			spawners += B.sources

			var/beamdir=get_dir(src,B)

			overlays += B.get_machine_underlay(beamdir)

			// Figure out how much power to emit in each direction
			var/list/deflections = get_deflections(beamdir)
			var/splitpower=1
			if(istype(B, /obj/effect/beam/emitter))
				var/obj/effect/beam/emitter/EB=B
				splitpower = round(EB.power/nsplits, 0.1) // Remember, round() is equivalent to other languages' floor().
			for(i=1;i<=nsplits;i++)
				var/splitdir = deflections[i]
				var/diridx = cardinal.Find(splitdir)
				var/list/dirdata = beam_dirs[diridx]

				if(!(B.type in dirdata))
					dirdata[B.type] = splitpower
				else
					dirdata[B.type] += splitpower


	// Emit beams.
	for(i=1;i<=4;i++)
		var/cdir = cardinal[i]
		var/list/dirdata = beam_dirs[i]
		var/delbeam=0
		var/obj/effect/beam/beam
		if(dirdata.len > 0)
			for(var/beamtype in dirdata)
				var/newbeam=0
				beam = emitted_beams[i]
				if(!beam || beam.type != beamtype)
					if (beam && beam.type != beamtype)
						qdel(beam)
						emitted_beams[i]=null
						beam=null

					if(!beam)
						beam = new beamtype(loc)
						emitted_beams[i]=beam
						beam.dir=cdir
						newbeam=1

					if(istype(beam, /obj/effect/beam/emitter))
						var/obj/effect/beam/emitter/EB=beam
						EB.power = dirdata[beamtype]

					overlays += beam.get_machine_underlay(cdir)

					if(newbeam)
						beam.emit(spawn_by=spawners)
					else if(istype(beam, /obj/effect/beam/emitter))
						var/obj/effect/beam/emitter/EB=beam
						EB.set_power(EB.power)
					break
				else
					delbeam=1
		else // dirdata.len == 0
			delbeam=1
		beam = emitted_beams[i] // One last check.
		if(delbeam && beam)
			qdel(beam)
			emitted_beams[i]=null

	overlays += mirror_state

/obj/machinery/mirror/beamsplitter
	name = "beamsplitter"
	desc = "Uses a half-silvered plasma-glass mirror to split beams in two directions."
	mirror_state = "splitter"
	nsplits = 2

/obj/machinery/mirror/beamsplitter/New()
	..()
	component_parts = newlist(
		/obj/item/stack/sheet/rglass/plasmarglass,
		/obj/item/stack/sheet/rglass/plasmarglass,
		/obj/item/stack/sheet/rglass/plasmarglass,
		/obj/item/stack/sheet/rglass/plasmarglass,
		/obj/item/stack/sheet/rglass/plasmarglass,
	)

/obj/machinery/mirror/beamsplitter/get_deflections(var/in_dir)
	// Splits like a real beam-splitter:
	//     |
	// >>==/-- (NORTH, SOUTH)
	//
	// >>==\-- (EAST, WEST)
	//     |
	// Can probably do this mathematically, but I'm too goddamn tired.

	if(dir in list(EAST, WEST)) // \\ orientation
		switch(in_dir)
			if(NORTH) return list(SOUTH, EAST)
			if(SOUTH) return list(NORTH, WEST)
			if(EAST)  return list(NORTH, WEST)
			if(WEST)  return list(SOUTH, EAST)
	else
		switch(in_dir) // / orientation
			if(NORTH) return list(SOUTH, WEST)
			if(SOUTH) return list(NORTH, EAST)
			if(EAST)  return list(SOUTH, WEST)
			if(WEST)  return list(NORTH, EAST)

/obj/structure/mirror_frame
	name = "mirror frame"
	desc = "Looks like it holds a sample or a mirror for getting lasered."

	icon='icons/obj/machines/optical/beamsplitter.dmi'
	icon_state = "base"

	anchored = 0
	density = 1
	opacity = 0 // Think table-height.

/obj/structure/mirror_frame/attackby(var/obj/item/W,var/mob/user)
	if(istype(W, /obj/item/weapon/wrench))
		user << "<span class='info'>You begin to unfasten \the [src]'s bolts.</span>"
		if(do_after(user,20))
			anchored=!anchored
			user.visible_message("<span class='info'>You unfasten \the [src]'s bolts.</span>", "[user] unfastens the [src]'s bolts.","You hear a ratchet.")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if (WT.remove_fuel(0,user))
			user << "Now welding the [src]..."
			if(do_after(user, 20))
				if(!src || !WT.isOn()) return
				playsound(get_turf(src), 'sound/items/Welder2.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] cuts the [src] apart.</span>", "<span class='warning'>You cut the [src] apart.</span>", "You hear welding.")
				new /obj/item/stack/sheet/metal(src.loc,5)
				qdel(src)
				return
			else
				user << "\blue The welding tool needs to be on to start this task."
		else
			user << "\blue You need more welding fuel to complete this task."

	if(istype(W, /obj/item/stack/sheet/rglass/plasmarglass))
		var/obj/item/stack/sheet/rglass/plasmarglass/stack = W
		if(stack.amount < 5)
			user << "<span class='warning'>You need at least 5 [stack] to build a beamsplitter.</span>"
			return
		if(do_after(user,10))
			if(stack.amount < 5)
				user << "<span class='warning'>You need at least 5 [stack] to build a beamsplitter.</span>"
				return
			stack.use(5)
			var/obj/machinery/mirror/beamsplitter/BS = new (get_turf(src))
			user.visible_message("[user] completes the [BS].", "<span class='info'>You successfully build the [BS]!</span>", "You hear a click.")
			qdel(src)
		return

	if(istype(W, /obj/item/stack/sheet/rglass))
		var/obj/item/stack/sheet/rglass/stack = W
		if(stack.amount < 5)
			user << "<span class='warning'>You need at least 5 [stack] to build a beamsplitter.</span>"
			return
		if(do_after(user,10))
			if(stack.amount < 5)
				user << "<span class='warning'>You need at least 5 [stack] to build a beamsplitter.</span>"
				return
			stack.use(5)
			var/obj/machinery/mirror/mirror = new (get_turf(src))
			user.visible_message("[user] completes the [mirror].", "<span class='info'>You successfully build the [mirror]!</span>", "You hear a click.")
			qdel(src)
			return
