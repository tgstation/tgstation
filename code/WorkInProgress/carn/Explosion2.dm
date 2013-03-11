//TODO: Flash range does nothing currently
//NOTE: This has not yet been updated with the lighting deferal stuff. ~Carn
//Needs some work anyway.

proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1)
	spawn(0)
		var/start = world.timeofday
		epicenter = get_turf(epicenter)
		if(!epicenter) return

		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		playsound(epicenter, 'sound/effects/explosionfar.ogg', 100, 1, round(devastation_range*2,1) )
		playsound(epicenter, "explosion", 100, 1, round(devastation_range,1) )

		tension_master.explosion()

		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 1

		if(heavy_impact_range > 1)
			var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
			E.set_up(epicenter)
			E.start()

		var/x = epicenter.x
		var/y = epicenter.y
		var/z = epicenter.z

		var/counter = 0

		if(devastation_range > 0)
			counter += explosion_turf(x,y,z,1)
		else
			devastation_range = 0
			if(heavy_impact_range > 0)
				counter += explosion_turf(x,y,z,2)
			else
				heavy_impact_range = 0
				if(light_impact_range > 0)
					counter += explosion_turf(x,y,z,3)
				else
					return

		//Diamond 'splosions (looks more round than square version)
		for(var/i=0, i<devastation_range, i++)
			for(var/j=0, j<i, j++)
				counter += explosion_turf((x-i)+j, y+j, z, 1)
				counter += explosion_turf(x+j, (y+i)-j, z, 1)
				counter += explosion_turf((x+i)-j, y-j, z, 1)
				counter += explosion_turf(x-j, (y-i)+j, z, 1)

		for(var/i=devastation_range, i<heavy_impact_range, i++)
			for(var/j=0, j<i, j++)
				counter += explosion_turf((x-i)+j, y+j, z, 2)
				counter += explosion_turf(x+j, (y+i)-j, z, 2)
				counter += explosion_turf((x+i)-j, y-j, z, 2)
				counter += explosion_turf(x-j, (y-i)+j, z, 2)

		for(var/i=heavy_impact_range, i<light_impact_range, i++)
			for(var/j=0, j<i, j++)
				counter += explosion_turf((x-i)+j, y+j, z, 3)
				counter += explosion_turf(x+j, (y+i)-j, z, 3)
				counter += explosion_turf((x+i)-j, y-j, z, 3)
				counter += explosion_turf(x-j, (y-i)+j, z, 3)

/*		//Square 'splosions
		for(var/i=0, i<devastation_range, i++)
			for(var/j=-i, j<i, j++)
				counter += explosion_turf(x+j, y-i, z, 1)
				counter += explosion_turf(x-j, y+i, z, 1)
				counter += explosion_turf(x+i, y+j, z, 1)
				counter += explosion_turf(x-i, y-j, z, 1)
				sleep(1)

		for(var/i=devastation_range, i<heavy_impact_range, i++)
			for(var/j=-i, j<i, j++)
				counter += explosion_turf(x+j, y-i, z, 2)
				counter += explosion_turf(x-j, y+i, z, 2)
				counter += explosion_turf(x+i, y+j, z, 2)
				counter += explosion_turf(x-i, y-j, z, 2)
				sleep(1)

		for(var/i=heavy_impact_range, i<light_impact_range, i++)
			for(var/j=-i, j<i, j++)
				counter += explosion_turf(x+j, y-i, z, 3)
				counter += explosion_turf(x-j, y+i, z, 3)
				counter += explosion_turf(x+i, y+j, z, 3)
				counter += explosion_turf(x-i, y-j, z, 3)
				sleep(1)
*/

		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 0

		world.log << "## Explosion([x],[y],[z])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [(world.timeofday-start)/10] seconds. Processed [counter] atoms."
	return 1

proc/explosion_turf(var/x,var/y,var/z,var/force)
	var/counter = 1
	var/turf/T = locate(x,y,z)
	if(T)
		T.ex_act(force)
		if(T)
			for(var/atom/movable/AM in T.contents)
				counter++
				AM.ex_act(force)

//	sleep(0)
	return counter


proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in range(range, epicenter))
		tile.ex_act(2)