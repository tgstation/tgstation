//TODO: Flash range does nothing currently

/proc/trange(var/Dist = 0, var/turf/Center = null)//alternative to range (ONLY processes turfs and thus less intensive)
	if (isnull(Center))
		return

	//var/x1 = ((Center.x-Dist) < 1 ? 1 : Center.x - Dist)
	//var/y1 = ((Center.y-Dist) < 1 ? 1 : Center.y - Dist)
	//var/x2 = ((Center.x+Dist) > world.maxx ? world.maxx : Center.x + Dist)
	//var/y2 = ((Center.y+Dist) > world.maxy ? world.maxy : Center.y + Dist)

	var/turf/x1y1 = locate(((Center.x - Dist) < 1 ? 1 : Center.x - Dist), ((Center.y - Dist) < 1 ? 1 : Center.y - Dist), Center.z)
	var/turf/x2y2 = locate(((Center.x + Dist) > world.maxx ? world.maxx : Center.x + Dist), ((Center.y + Dist) > world.maxy ? world.maxy : Center.y + Dist), Center.z)
	return block(x1y1, x2y2)

/**
 * Make boom
 *
 * @param epicenter          Where explosion is centered
 * @param devastation_range
 * @param heavy_impact_range
 * @param light_impact_range
 * @param flash_range        Unused
 * @param adminlog           Log to admins
 * @param ignored            Do not notify explosion listeners
 * @param verbose            Explosion listeners will treat as an important explosion worth reporting on radio
 */
/proc/explosion(turf/epicenter, const/devastation_range, const/heavy_impact_range, const/light_impact_range, const/flash_range, adminlog = 1, ignored = 0, verbose = 1)
	src = null	//so we don't abort once src is deleted

	spawn()
		if(config.use_recursive_explosions)
			var/power = devastation_range * 2 + heavy_impact_range + light_impact_range //The ranges add up, ie light 14 includes both heavy 7 and devestation 3. So this calculation means devestation counts for 4, heavy for 2 and light for 1 power, giving us a cap of 27 power.
			explosion_rec(epicenter, power)
			return

		var/start = world.timeofday
		epicenter = get_turf(epicenter)
		if(!epicenter)
			return

		score["explosions"]++ //For the scoreboard

		var/max_range = max(devastation_range, heavy_impact_range, light_impact_range)
//		playsound(epicenter, 'sound/effects/explosionfar.ogg', 100, 1, round(devastation_range*2,1) )
//		playsound(epicenter, "explosion", 100, 1, round(devastation_range,1) )


//Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
//Stereo users will also hear the direction of the explosion!
//Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
//3/7/14 will calculate to 80 + 35
		var/far_dist = (devastation_range * 20) + (heavy_impact_range * 5)
		var/frequency = get_rand_frequency()

		for (var/mob/M in player_list)
			//Double check for client
			if(M && M.client)
				var/turf/M_turf = get_turf(M)
				if(M_turf && M_turf.z == epicenter.z)
					var/dist = get_dist(M_turf, epicenter)
					//If inside the blast radius + world.view - 2
					if(dist <= round(max_range + world.view - 2, 1))
						if(devastation_range > 0)
							M.playsound_local(epicenter, get_sfx("explosion"), 100, 1, frequency, falloff = 5) // get_sfx() is so that everyone gets the same sound
							shake_camera(M, 10, 2)
						else
							M.playsound_local(epicenter, get_sfx("explosion_small"), 100, 1, frequency, falloff = 5)
							shake_camera(M, 4, 1)

						//You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.

					else if(dist <= far_dist)
						var/far_volume = Clamp(far_dist, 30, 50) // Volume is based on explosion size and dist
						far_volume += (dist <= far_dist * 0.5 ? 50 : 0) // add 50 volume if the mob is pretty close to the explosion
						if(devastation_range > 0)
							M.playsound_local(epicenter, 'sound/effects/explosionfar.ogg', far_volume, 1, frequency, falloff = 5)
							to_chat(M, "<span class='warning'>You feel something shake the structure...</span>")
							shake_camera(M, 4, 1)
						else
							M.playsound_local(epicenter, 'sound/effects/explosionsmallfar.ogg', far_volume, 1, frequency, falloff = 5)

		var/close = trange(world.view+round(devastation_range,1), epicenter)
		//To all distanced mobs play a different sound
		for(var/mob/M in mob_list) if(M.z == epicenter.z) if(!(M in close))
			//Check if the mob can hear
			if(M.ear_deaf <= 0 || !M.ear_deaf) if(!istype(M.loc,/turf/space))
				to_chat(M, 'sound/effects/explosionfar.ogg')
		if(adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[epicenter.x];Y=[epicenter.y];Z=[epicenter.z]'>JMP</A>)")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		//Pause the lighting updates for a bit.
		var/datum/controller/process/lighting = processScheduler.getProcess("lighting")
		lighting.disable()

		if(heavy_impact_range > 1)
			var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
			E.set_up(epicenter)
			E.start()
		else
			epicenter.turf_animation('icons/effects/96x96.dmi',"explosion_small",-32, -32, 13)

		var/x0 = epicenter.x
		var/y0 = epicenter.y
		var/z0 = epicenter.z

		for(var/turf/T in spiral_block(epicenter,max_range,1))
			var/dist = cheap_pythag(T.x - x0, T.y - y0)

			if(explosion_newmethod)	//Realistic explosions that take obstacles into account
				var/turf/Trajectory = T
				while(Trajectory != epicenter)
					Trajectory = get_step_towards(Trajectory,epicenter)
					if(Trajectory.density && Trajectory.explosion_block)
						dist += Trajectory.explosion_block

					for (var/obj/machinery/door/D in Trajectory.contents)
						if(D.density && D.explosion_block)
							dist += D.explosion_block

			if(dist < devastation_range)
				dist = 1
			else if(dist < heavy_impact_range)
				dist = 2
			else if(dist < light_impact_range)
				dist = 3
			else
				continue

			for(var/atom/movable/A in T.contents)
				A.ex_act(dist)

			T.ex_act(dist)

		var/took = (world.timeofday-start)/10
		//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
		if(Debug2)
			world.log << "## DEBUG: Explosion([x0],[y0],[z0])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds."

		//Machines which report explosions.
		if(!ignored)
			for(var/obj/machinery/computer/bhangmeter/bhangmeter in doppler_arrays)
				if(bhangmeter && !bhangmeter.stat)
					bhangmeter.sense_explosion(x0, y0, z0, devastation_range, heavy_impact_range, light_impact_range, took, 0, verbose)

		sleep(8)

		lighting.enable()

	return 1



proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in trange(range, epicenter))
		tile.ex_act(2)
