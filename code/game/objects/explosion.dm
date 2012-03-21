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

		var/list/exTurfs = list()

		if(roundExplosions)
			for(var/turf/T in circlerange(epicenter,light_impact_range))
				exTurfs += T
		else
			for(var/turf/T in range(light_impact_range, epicenter))
				exTurfs += T

		for(var/turf/T in exTurfs)
			var/distance = 0
			if(roundExplosions)
				distance = get_dist_euclidian(epicenter, T)
			else
				distance = get_dist(epicenter, T)
			if(distance < 0)
				distance = 0
			if(distance < devastation_range)
				for(var/atom/object in T.contents)
					spawn()
						if(object)
							object.ex_act(1)
				if(prob(5))
					if(T)
						T.ex_act(2)
				else
					if(T)
						T.ex_act(1)
			else if(distance < heavy_impact_range)
				for(var/atom/object in T.contents)
					spawn()
						if(object)
							object.ex_act(2)
				if(T)
					T.ex_act(2)
			else if (distance == heavy_impact_range)
				for(var/atom/object in T.contents)
					if(object)
						object.ex_act(2)
				if(prob(15) && devastation_range > 2 && heavy_impact_range > 2)
					secondaryexplosion(T, 1)
				else
					if(T)
						T.ex_act(2)
			else if(distance <= light_impact_range)
				for(var/atom/object in T.contents)
					spawn()
						if(object)
							object.ex_act(3)
				if(T)
					T.ex_act(3)
			for(var/mob/living/carbon/mob in T)
				flick("flash", mob:flash)

		sleep(-1)
		sleep(20)
		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 0
	return 1



proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in range(range, epicenter))
		tile.ex_act(2)