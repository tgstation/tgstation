/atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null



/turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)
	return


/turf/open/hotspot_expose(exposed_temperature, exposed_volume, soh)
	var/datum/gas_mixture/air_contents = return_air()
	if(!air_contents)
		return 0

	var/oxy = air_contents.gases["o2"] ? air_contents.gases["o2"][MOLES] : 0
	var/tox = air_contents.gases["plasma"] ? air_contents.gases["plasma"][MOLES] : 0

	if(active_hotspot)
		if(soh)
			if(tox > 0.5 && oxy > 0.5)
				if(active_hotspot.temperature < exposed_temperature)
					active_hotspot.temperature = exposed_temperature
				if(active_hotspot.volume < exposed_volume)
					active_hotspot.volume = exposed_volume
		return 1

	var/igniting = 0

	if((exposed_temperature > PLASMA_MINIMUM_BURN_TEMPERATURE) && tox > 0.5)
		igniting = 1

	if(igniting)
		if(oxy < 0.5 || tox < 0.5)
			return 0

		active_hotspot = new /obj/effect/hotspot(src)
		active_hotspot.temperature = exposed_temperature
		active_hotspot.volume = exposed_volume

		active_hotspot.just_spawned = (current_cycle < SSair.times_fired)
			//remove just_spawned protection if no longer processing this cell
		SSair.add_to_active(src, 0)
	return igniting

//This is the icon for fire on turfs, also helps for nurturing small fires until they are full tile
/obj/effect/hotspot
	anchored = TRUE
	mouse_opacity = 0
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = ABOVE_OPEN_TURF_LAYER
	light_range = 3
	light_color = LIGHT_COLOR_FIRE

	var/volume = 125
	var/temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	var/just_spawned = 1
	var/bypassing = 0

/obj/effect/hotspot/New()
	..()
	SSair.hotspots += src
	perform_exposure()
	setDir(pick(GLOB.cardinal))
	air_update_turf()

/obj/effect/hotspot/make_frozen_visual()
	return	//you take my fun i take yours

/obj/effect/hotspot/proc/perform_exposure()
	var/turf/open/location = loc
	if(!istype(location) || !(location.air))
		return 0

	location.active_hotspot = src

	if(volume > CELL_VOLUME*0.95)
		bypassing = 1
	else
		bypassing = 0

	if(bypassing)
		if(!just_spawned)
			volume = location.air.reaction_results["fire"]*FIRE_GROWTH_RATE
			temperature = location.air.temperature
	else
		var/datum/gas_mixture/affected = location.air.remove_ratio(volume/location.air.volume)
		affected.temperature = temperature
		affected.react()
		temperature = affected.temperature
		volume = affected.reaction_results["fire"]*FIRE_GROWTH_RATE
		location.assume_air(affected)

	for(var/A in loc)
		var/atom/AT = A
		if(AT && AT != src) // It's possible that the item is deleted in temperature_expose
			AT.fire_act(temperature, volume)
	return 0


/obj/effect/hotspot/process()
	if(just_spawned)
		just_spawned = 0
		return 0

	var/turf/open/location = loc
	if(!istype(location))
		qdel(src)
		return

	if(location.excited_group)
		location.excited_group.reset_cooldowns()

	if((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
		qdel(src)
		return

	if(!(location.air) || !location.air.gases["plasma"] || !location.air.gases["o2"] || location.air.gases["plasma"][MOLES] < 0.5 || location.air.gases["o2"][MOLES] < 0.5)
		qdel(src)
		return

	perform_exposure()

	if(bypassing)
		icon_state = "3"
		location.burn_tile()

		//Possible spread due to radiated heat
		if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE
			for(var/t in location.atmos_adjacent_turfs)
				var/turf/open/T = t
				if(T.active_hotspot)
					T.hotspot_expose(radiated_temperature, CELL_VOLUME/4)

	else
		if(volume > CELL_VOLUME*0.4)
			icon_state = "2"
		else
			icon_state = "1"

	if(temperature > location.max_fire_temperature_sustained)
		location.max_fire_temperature_sustained = temperature

	if(location.heat_capacity && temperature > location.heat_capacity)
		location.to_be_destroyed = 1
		/*if(prob(25))
			location.ReplaceWithSpace()
			return 0*/
	return 1

/obj/effect/hotspot/Destroy()
	set_light(0)
	SSair.hotspots -= src
	var/turf/open/T = loc
	if(istype(T) && T.active_hotspot == src)
		T.active_hotspot = null
	DestroyTurf()
	loc = null
	. = ..()

/obj/effect/hotspot/proc/DestroyTurf()
	if(isturf(loc))
		var/turf/T = loc
		if(T.to_be_destroyed)
			var/chance_of_deletion
			if (T.heat_capacity) //beware of division by zero
				chance_of_deletion = T.max_fire_temperature_sustained / T.heat_capacity * 8 //there is no problem with prob(23456), min() was redundant --rastaf0
			else
				chance_of_deletion = 100
			if(prob(chance_of_deletion))
				T.ChangeTurf(T.baseturf)
			else
				T.to_be_destroyed = 0
				T.max_fire_temperature_sustained = 0

/obj/effect/hotspot/Crossed(mob/living/L)
	..()
	if(isliving(L))
		L.fire_act(temperature, volume)
