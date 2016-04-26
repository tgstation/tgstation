var/list/obj/machinery/prism/prism_list = list()
/obj/machinery/prism
	name = "Prism"
	desc = "A simple device that combines emitter beams."

	icon='icons/obj/machines/optical/prism.dmi'
	icon_state="prism_off"

	use_power = 0
	anchored = 0
	density = 1

	var/obj/effect/beam/emitter/beam

	machine_flags = WRENCHMOVE | SCREWTOGGLE | CROWDESTROY

	var/list/powerchange_hooks=list()

/obj/machinery/prism/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/prism
	)
	prism_list += src

/obj/machinery/prism/Destroy()
	qdel(beam)
	beam=null
	prism_list -= src
	..()

/obj/machinery/prism/proc/check_rotation()
	for(var/obj/effect/beam/emitter/B in beams)
		to_chat(world, "[src] \ref[src] found [get_dir(src, B)] its dir is [dir]")
		if(get_dir(src, B) != dir)
			return 1
/obj/machinery/prism/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, -90)
	qdel(beam)
	beam=null
	update_beams()
	return 1

/obj/machinery/prism/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 90)
	qdel(beam)
	beam=null
	update_beams()
	return 1

/obj/machinery/prism/wrenchAnchor(var/mob/user)
	. = ..()
	if(. == 1)
		if(beams && beams.len)
			update_beams()
	return .

/obj/machinery/prism/beam_connect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
		powerchange_hooks[B]=B.power_change.Add(src,"on_power_change")
		update_beams(B)

/obj/machinery/prism/beam_disconnect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		if(B.HasSource(src))
			return // Prevent infinite loops.
		..()
		B.power_change.Remove(powerchange_hooks[B])
		powerchange_hooks.Remove(B)
		update_beams(B)

// When beam power changes
/obj/machinery/prism/proc/on_power_change(var/list/args)
	//Don't care about args, just update beam.
	update_beams()

/obj/machinery/prism/proc/update_beams(var/obj/effect/beam/emitter/touching_beam)
	overlays.len = 0
	//testing("Beam count: [beams.len]")
	if(get_dir(src, touching_beam) == dir) return 0 //Make no change for beams touching us on our emission side.
	if(!beams)
		if(loc || !gcDestroyed)
			beams = list()
		else
			return
	if(beams.len>0 && anchored)
		var/newbeam=0
		if(!beam)
			beam = new (loc)
			beam.dir=dir
			newbeam=1
		beam.power=0
		var/list/spawners = list(src)
		for(var/obj/effect/beam/emitter/B in beams)
			if(get_dir(src, B) == dir)
				continue
			if(B.HasSource(src))
				warning("Ignoring beam [B] due to recursion.")
				continue // Prevent infinite loops.
			// Don't process beams firing into our emission side.

			spawners |= B.sources
			beam.power += B.power

			/// Propogate anti-recursion info
			if(beam.steps<B.steps+1)
				beam.steps=B.steps+1

			var/beamdir=get_dir(B.loc,src)
			overlays += image(icon=icon,icon_state="beam_arrow",dir=beamdir)
		if(newbeam)
			beam.emit(spawn_by=spawners)
		else
			beam.set_power(beam.power)
		icon_state = "prism_on"
	else
		icon_state = "prism_off"
		qdel(beam)
		beam=null
