//TODO: Flash range does nothing currently

//A very crude linear approximatiaon of pythagoras theorem.
/proc/cheap_pythag(var/dx, var/dy)
	dx = abs(dx); dy = abs(dy);
	if(dx>=dy)	return dx + (0.5*dy)	//The longest side add half the shortest side approximates the hypotenuse
	else		return dy + (0.5*dx)


proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1)
	spawn(0)
		var/start = world.timeofday
		epicenter = get_turf(epicenter)
		if(!epicenter) return

		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z])")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		playsound(epicenter, 'sound/effects/explosionfar.ogg', 100, 1, round(devastation_range*2,1) )
		playsound(epicenter, "explosion", 100, 1, round(devastation_range,1) )

		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 1

		if(heavy_impact_range > 1)
			var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
			E.set_up(epicenter)
			E.start()

		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z

		for(var/turf/T in range(epicenter, max(devastation_range, heavy_impact_range, light_impact_range)))
			var/dist = cheap_pythag(T.x - x0,T.y - y0)

			if(dist < devastation_range)
				dist = 1
			else if(dist < heavy_impact_range)
				dist = 2
			else if(dist < light_impact_range)
				dist = 3
			else
				continue

			T.ex_act(dist)
			if(T)
				for(var/atom/object in T.contents)
					object.ex_act(dist)

		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 0

		//here util we get explosions to be less laggy, might help us identify issues after changes to splosions (because let's face it we've had a few)
		world.log << "## Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [(world.timeofday-start)/10] seconds."

	return 1



proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in range(range, epicenter))
		tile.ex_act(2)