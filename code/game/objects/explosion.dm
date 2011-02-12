proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
	if(!epicenter) return
	spawn(0)
		defer_powernet_rebuild = 1
		if (!istype(epicenter, /turf))
			epicenter = epicenter.loc
			return explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range)
		playsound(epicenter.loc, 'explosionfar.ogg', 100, 1, round(devastation_range*2,1) )
		playsound(epicenter.loc, "explosion", 100, 1, round(devastation_range,1) )
		message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range]) in area [epicenter.loc.name] ")

		if(heavy_impact_range > 1)
			var/datum/effects/system/explosion/E = new/datum/effects/system/explosion()
			E.set_up(epicenter)
			E.start()

		for(var/turf/T in range(light_impact_range, epicenter))
			var/distance = get_dist(epicenter, T)
			if(distance < 0)
				distance = 0
			if(distance < devastation_range)
				for(var/atom/object in T.contents)
					object.ex_act(1)
				if(prob(5))
					T.ex_act(2)
				else
					T.ex_act(1)
			else if(distance < heavy_impact_range)
				for(var/atom/object in T.contents)
					object.ex_act(2)
				T.ex_act(2)
			else if (distance == heavy_impact_range)
				for(var/atom/object in T.contents)
					object.ex_act(2)
				if(prob(15) && devastation_range > 2 && heavy_impact_range > 2)
					secondaryexplosion(T, 1)
				else
					T.ex_act(2)
			else if(distance <= light_impact_range)
				for(var/atom/object in T.contents)
					object.ex_act(3)
				T.ex_act(3)
			for(var/mob/living/carbon/mob in T)
				flick("flash", mob:flash)

		makepowernets()
		defer_powernet_rebuild = 0
	return 1



proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in range(range, epicenter))
		tile.ex_act(2)