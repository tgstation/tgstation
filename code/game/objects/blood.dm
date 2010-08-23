/obj/decal/cleanable/New()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	..()
/*
/obj/decal/cleanable/blood/burn(fi_amount)
	if(fi_amount > 900000.0)
		src.virus = null
	sleep(11)
	del(src)
	return
*/

/obj/decal/cleanable/blood/gibs/proc/streak(var/list/directions)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				var/obj/decal/cleanable/blood/b = new /obj/decal/cleanable/blood/splatter(src.loc)
				if (src.virus)
					b.virus = src.virus
			if (step_to(src, get_step(src, direction), 0))
				break

/obj/decal/cleanable/robot_debris/proc/streak(var/list/directions)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				if (prob(40))
					/*var/obj/decal/cleanable/oil/o =*/
					new /obj/decal/cleanable/oil/streak(src.loc)
				else if (prob(10))
					var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
					s.set_up(3, 1, src)
					s.start()
			if (step_to(src, get_step(src, direction), 0))
				break


// not a great place for it, but as good as any

/obj/decal/cleanable/greenglow

	New()
		..()
		sd_SetLuminosity(1)

		spawn(1200)		// 2 minutes
			del(src)