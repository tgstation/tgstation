var/roundExplosions = 1

proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1)
	if(!epicenter) return
	spawn(0)
		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 1
		if (!istype(epicenter, /turf))
			epicenter = get_turf(epicenter.loc)
		//playsound(epicenter.loc, 'explosionfar.ogg', 100, 1, round(devastation_range*2,1) )
		playsound(epicenter.loc, "explosion", 100, 1, round(devastation_range,1) )


		var/close = range(world.view+round(devastation_range,1), epicenter)
		// to all distanced mobs play a different sound
		for(var/mob/M in world) if(M.z == epicenter.z) if(!(M in close))
			// check if the mob can hear
			if(M.ear_deaf <= 0 || !M.ear_deaf) if(!istype(M.loc,/turf/space))
				M << 'explosionfar.ogg'
		if (adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] (<a href=\"byond://?src=%admin_ref%;teleto=\ref[epicenter]\">Jump</a>)", admin_ref = 1)
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		tension_master.explosion()

		if(heavy_impact_range > 1)
			var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
			E.set_up(epicenter)
			E.start()

		var/list/dTurfs = list() //Holds the turfs in devestation range.
		var/list/hTurfs = list() //Holds the turfs in heavy impact range, minus turfs in devestation range.
		var/list/lTurfs = list() //Holds the turfs in light impact range, minus turfs in devestation range and heavy impact range.
		var/list/fTurfs = list() //Holds turfs to loop through for mobs to flash. (Hehehe, dirty)

		if(roundExplosions)
			fTurfs = circlerange(epicenter,max(devastation_range, heavy_impact_range, light_impact_range, flash_range))
			dTurfs = circlerange(epicenter,devastation_range)
			hTurfs = circlerange(epicenter,heavy_impact_range) - dTurfs
			lTurfs = circlerange(epicenter,light_impact_range) - dTurfs - hTurfs
		else
			fTurfs = circlerange(epicenter,max(devastation_range, heavy_impact_range, light_impact_range, flash_range))
			dTurfs = circlerange(epicenter,devastation_range)
			hTurfs = circlerange(epicenter,heavy_impact_range) - dTurfs
			lTurfs = circlerange(epicenter,light_impact_range) - dTurfs - hTurfs

		spawn() //Lets pop these into different threads.
			for(var/turf/T in dTurfs) //Loop through the turfs in devestation range.
				spawn() //Try to pop each turf into it's own thread, speed things along.
					if(T) //Sanity checking.
						//Now, the actual explosion stuff happens.
						if(prob(5))
							T.ex_act(2)
						else
							T.ex_act(1)
						for(var/atom/object in T.contents)
							spawn()
								if(object)
									object.ex_act(1)
		spawn()
			for(var/turf/T in hTurfs)
				spawn()
					if(T)
						if(prob(15) && devastation_range > 2 && heavy_impact_range > 2)
							secondaryexplosion(T, 1)
						else
							T.ex_act(2)
						for(var/atom/object in T.contents)
							if(object)
								object.ex_act(2)
		spawn()
			for(var/turf/T in lTurfs)
				spawn()
					if(T)
						T.ex_act(3)
						for(var/atom/object in T.contents)
							spawn()
								if(object)
									object.ex_act(3)

		spawn()
			for(var/mob/living/carbon/mob in fTurfs)
				flick("flash", mob:flash)

		sleep(-1)
		sleep(20)
		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 0
	return 1



proc/secondaryexplosion(turf/epicenter, range)
	spawn()
		for(var/turf/tile in range(range, epicenter))
			tile.ex_act(2)