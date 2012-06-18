#define USE_CIRCULAR_EXPLOSIONS 1

//TODO: Flash range does nothing currently

proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1)
	if(!epicenter) return
	spawn(0)
		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 1

		if (!istype(epicenter, /turf))
			epicenter = get_turf(epicenter.loc)

		playsound(epicenter.loc, 'explosionfar.ogg', 100, 1, round(devastation_range*2,1) )
		playsound(epicenter.loc, "explosion", 100, 1, round(devastation_range,1) )

		if (adminlog)
			message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")
			log_game("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		tension_master.explosion()

		if(heavy_impact_range > 1)
			var/datum/effect/system/explosion/E = new/datum/effect/system/explosion()
			E.set_up(epicenter)
			E.start()

		var/list/expTurfs = list() // All turfs being affected by the explosion (not flash range)

		#ifdef USE_CIRCULAR_EXPLOSIONS
		expTurfs = circlerangeturfs(epicenter, max(devastation_range, heavy_impact_range, light_impact_range))
		#else
		expTurfs = range(epicenter, max(devastation_range, heavy_impact_range, light_impact_range))
		#endif

		// Hello future editors, please note that 1000 calls to spawn will not speed this up, but this exact amount has been tested
		// Now, tonnes of calls to spawn will allow other stuff to happen, but I believe we may as well let explosions
		// Get over with and blow up like an explosion would

		var/list/dTurfs = list()
		var/list/hTurfs = list()
		var/list/lTurfs = list()

		for(var/turf/T in expTurfs) // This doesn't slow it down at all, even 100,100,100 bombs
			var/dist = approx_dist(epicenter, T)

			if(dist < devastation_range)
				dTurfs.Add(T)
			else if(dist < heavy_impact_range)
				hTurfs.Add(T)
			else // The expTurfs list only has turfs that are in it's range, so no if here for light_impact
				lTurfs.Add(T)

		spawn()
			for(var/turf/T in dTurfs)
				if(prob(10))
					T.ex_act(2)
				else
					T.ex_act(1)
				for(var/atom/object in T.contents)
					object.ex_act(1)
		spawn()
			for(var/turf/T in hTurfs)
				T.ex_act(2)
				for(var/atom/object in T.contents)
					object.ex_act(2)

		spawn()
			for(var/turf/T in lTurfs)
				T.ex_act(3)
				for(var/atom/object in T.contents)
					object.ex_act(3)

		if(defer_powernet_rebuild != 2)
			defer_powernet_rebuild = 0
	return 1

#undef USE_CIRCULAR_EXPLOSIONS


proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in range(range, epicenter))
		tile.ex_act(2)