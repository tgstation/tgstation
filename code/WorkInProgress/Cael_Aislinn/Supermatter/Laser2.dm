//mostly replaced these with emitter code
//they're functionally identical

/obj/machinery/computer/laser
	name = "Zero-point laser"
	desc = "A super-powerful laser"
	var/visible = 1
	var/state = 1.0
	//var/obj/beam/e_beam/first
	var/power = 500
	icon = 'icons/obj/engine.dmi'
	icon_state = "laser"
	anchored = 1
	var/id
	var/on = 0
	var/freq = 50000
	var/phase = 0
	var/phase_variance = 0

/obj/machinery/computer/laser/process()
	/*if(on)
		if(!first)
			src.first = new /obj/beam/e_beam(src.loc)
			src.first.master = src
			src.first.dir = src.dir
			src.first.power = src.power
			src.first.freq = src.freq
			src.first.phase = src.phase
			src.first.phase_variance = src.phase_variance
			step(first, dir)
			if(first)
				src.first.updatebeam()
		else
			src.first.updatebeam()
	else
		if(first)
			del first*/

/obj/machinery/computer/laser/proc/setpower(var/powera)
	/*src.power = powera
	if(first)
		first.setpower(src.power)*/

/*
/obj/beam/e_beam
	name = "Laser beam"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "u_laser"
	var/obj/machinery/engine/laser/master = null
	var/obj/beam/e_beam/next = null
	var/power
	var/freq = 50000
	var/phase = 0
	var/phase_variance = 0
	anchored = 1

/obj/beam/e_beam/New()
	sd_SetLuminosity(1, 1, 4)

/obj/beam/e_beam/proc/updatebeam()
	if(!next)
		if(get_step(src.loc,src.dir))
			var/obj/beam/e_beam/e = new /obj/beam/e_beam(src.loc)
			e.dir = src.dir
			src.next = e
			e.master = src.master
			e.power = src.power
			e.phase = src.phase
			src.phase+=src.phase_variance
			e.freq = src.freq
			e.phase_variance = src.phase_variance
			if(src.loc.density == 0)
				for(var/atom/o in src.loc.contents)
					if(o.density || o == src.master || (ismob(o) && !istype(o, /mob/dead)) )
						o.laser_act(src)
						del src
						return
			else
				src.loc.laser_act(src)
				del e
				return
			step(e,e.dir)
			if(e)
				e.updatebeam()
	else
		next.updatebeam()

/atom/proc/laser_act(var/obj/beam/e_beam/b)
	return

/mob/living/carbon/laser_act(var/obj/beam/e_beam/b)
	for(var/t in organs)
		var/datum/organ/external/affecting = organs["[t]"]
		if (affecting.take_damage(0, b.power/400,0,0))
			UpdateDamageIcon()
		else
			UpdateDamage()

/obj/beam/e_beam/Bump(atom/Obstacle)
	Obstacle.laser_act(src)
	del(src)
	return


/obj/beam/e_beam/proc/setpower(var/powera)
	src.power = powera
	if(src.next)
		src.next.setpower(powera)

/obj/beam/e_beam/Bumped()
	src.hit()
	return

/obj/beam/e_beam/HasEntered(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/beam))
		return
	spawn( 0 )
		AM.laser_act(src)
		src.hit()
		return
	return

/obj/beam/e_beam/Del()
	if(next)
		del(next)
	..()
	return

/obj/beam/e_beam/proc/hit()
	del src
	return
	*/