//TODO: Flash range does nothing currently

//A very crude linear approximatiaon of pythagoras theorem.
/proc/cheap_pythag(var/dx, var/dy)
	dx = abs(dx); dy = abs(dy);
	if(dx>=dy)	return dx + (0.5*dy)	//The longest side add half the shortest side approximates the hypotenuse
	else		return dy + (0.5*dx)


proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1, ignorecap = 0, flame_range = 0)
	src = null	//so we don't abort once src is deleted
	epicenter = get_turf(epicenter)

	// Archive the uncapped explosion for the doppler array
	var/orig_dev_range = devastation_range
	var/orig_heavy_range = heavy_impact_range
	var/orig_light_range = light_impact_range

	if(!ignorecap)
		// Clamp all values to MAX_EXPLOSION_RANGE
		devastation_range = min (MAX_EX_DEVESTATION_RANGE, devastation_range)
		heavy_impact_range = min (MAX_EX_HEAVY_RANGE, heavy_impact_range)
		light_impact_range = min (MAX_EX_LIGHT_RANGE, light_impact_range)
		flash_range = min (MAX_EX_FLASH_RANGE, flash_range)
		flame_range = min (MAX_EX_FLAME_RANGE, flame_range)

	spawn(0)
		if(config.use_recursive_explosions)
			devastation_range += 1	//Original code uses -1 as no explosion, this code uses 0 as no explosion and -1 would ruin everything
			heavy_impact_range += 1
			light_impact_range += 1
			var/power = devastation_range * 3 + heavy_impact_range * 1.5 + light_impact_range * 0.75
			//So max power is (3 * 4) + (1.5 * 8) + (0.75 * 15) = 36,25
			explosion_rec(epicenter, power)
			return

		var/start = world.timeofday
		if(!epicenter) return

		var/max_range = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)

		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z])")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) in area [epicenter.loc.name] ")

		// Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
		// Stereo users will also hear the direction of the explosion!

		// Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
		// 3/7/14 will calculate to 80 + 35

		var/far_dist = 0
		far_dist += heavy_impact_range * 5
		far_dist += devastation_range * 20

		var/frequency = get_rand_frequency()
		for(var/mob/M in player_list)
			// Double check for client
			if(M && M.client)
				var/turf/M_turf = get_turf(M)
				if(M_turf && M_turf.z == epicenter.z)
					var/dist = get_dist(M_turf, epicenter)
					// If inside the blast radius + world.view - 2
					if(dist <= round(max_range + world.view - 2, 1))
						M.playsound_local(epicenter, get_sfx("explosion"), 100, 1, frequency, falloff = 5) // get_sfx() is so that everyone gets the same sound
					// You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
					else if(dist <= far_dist)
						var/far_volume = Clamp(far_dist, 30, 50) // Volume is based on explosion size and dist
						far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
						M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1, frequency, falloff = 5)



		var/lighting_controller_was_processing = lighting_controller.processing	//Pause the lighting updates for a bit
		lighting_controller.processing = 0
		var/powernet_rebuild_was_deferred_already = defer_powernet_rebuild
		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 1

		if(heavy_impact_range > 1)
			var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
			E.set_up(epicenter)
			E.start()

		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z

		for(var/turf/T in range(epicenter, max_range))
			var/dist = cheap_pythag(T.x - x0,T.y - y0)
			var/flame_dist = 0
			var/hotspot_exists

			if(dist < flame_range)
				flame_dist = 1

			if(dist < devastation_range)		dist = 1
			else if(dist < heavy_impact_range)	dist = 2
			else if(dist < light_impact_range)	dist = 3
			else 								dist = 0


			//------- TURF FIRES -------\\
			if(T)
				if(flame_dist && prob(40) && !istype(T, /turf/space))
					new/obj/effect/hotspot(T) //Mostly for ambience!
					hotspot_exists = 1
				if(dist)
					T.ex_act(dist)

			//------- THINGS IN TURFS FIRES -------\\

				for(var/atom_movable in T.contents)	//bypass type checking since only atom/movable can be contained by turfs anyway
					var/atom/movable/AM = atom_movable

					if(AM) //Something is inside T (We have already checked T exists above) - RR
						if(flame_dist) //if it has flame distance, run this - RR
							if(isliving(AM) && !hotspot_exists && !istype(T, /turf/space))
								new /obj/effect/hotspot(AM.loc)
								//Just in case we missed a mob while they were in flame_range, but a hotspot didn't spawn on them, otherwise it looks weird when you just burst into flame out of nowhere
						if(dist) //if no flame_dist, run this - RR
							AM.ex_act(dist)



		var/took = (world.timeofday-start)/10
		//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
		if(Debug2)	world.log << "## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds."

		//Machines which report explosions.
		for(var/i,i<=doppler_arrays.len,i++)
			var/obj/machinery/doppler_array/Array = doppler_arrays[i]
			if(Array)
				Array.sense_explosion(x0,y0,z0,devastation_range,heavy_impact_range,light_impact_range,took,orig_dev_range,orig_heavy_range,orig_light_range)

		sleep(8)

		if(!lighting_controller.processing)	lighting_controller.processing = lighting_controller_was_processing
		if(!powernet_rebuild_was_deferred_already)
			if(defer_powernet_rebuild != 2)
				defer_powernet_rebuild = 0

	return 1



proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in range(range, epicenter))
		tile.ex_act(2)