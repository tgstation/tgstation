/obj/machinery/prism
	name = "Prism"
	desc = "A simple device that combines emitter beams."

	icon='icons/obj/machines/optical/prism.dmi'
	icon_state="prism_off"

	use_power = 0
	anchored = 0
	density = 1

	var/obj/effect/beam/emitter/beam

	machine_flags = WRENCHMOVE

	var/list/powerchange_hooks=list()

/obj/machinery/prism/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, 90)
	qdel(beam)
	beam=null
	update_beams()
	return 1

/obj/machinery/prism/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor!"
		return 0
	src.dir = turn(src.dir, -90)
	qdel(beam)
	beam=null
	update_beams()
	return 1

/obj/machinery/prism/beam_connect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		..()
		powerchange_hooks[B]=B.power_change.Add(src,"on_power_change")
		update_beams()

/obj/machinery/prism/beam_disconnect(var/obj/effect/beam/emitter/B)
	if(istype(B))
		..()
		B.power_change.Remove(powerchange_hooks[B])
		powerchange_hooks.Remove(B)
		update_beams()

// When beam power changes
/obj/machinery/prism/proc/on_power_change(var/list/args)
	//Don't care about args, just update beam.
	update_beams()

/obj/machinery/prism/proc/update_beams()
	overlays.Cut()
	//testing("Beam count: [beams.len]")
	if(beams.len>0)
		var/newbeam=0
		if(!beam)
			beam = new (loc)
			beam.dir=dir
			newbeam=1
		beam.power=0
		for(var/obj/effect/beam/emitter/B in beams)
			beam.power += B.power
			var/beamdir=get_dir(B.loc,src)
			overlays += image(icon=icon,icon_state="beam_arrow",dir=beamdir)
		if(newbeam)
			beam.emit(spawn_by=src)
		else
			beam.set_power(beam.power)
		icon_state = "prism_on"
	else
		icon_state = "prism_off"
		qdel(beam)
		beam=null