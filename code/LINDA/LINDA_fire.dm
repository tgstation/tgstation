
/atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null



/turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)
	return


/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh)
	var/datum/gas_mixture/air_contents = return_air()
	if(!air_contents)
		return 0
	if(active_hotspot)
		if(soh)
			if(air_contents.toxins > 0.5 && air_contents.oxygen > 0.5)
				if(active_hotspot.temperature < exposed_temperature)
					active_hotspot.temperature = exposed_temperature
				if(active_hotspot.volume < exposed_volume)
					active_hotspot.volume = exposed_volume
		return 1

	var/igniting = 0

	if((exposed_temperature > PLASMA_MINIMUM_BURN_TEMPERATURE) && air_contents.toxins > 0.5)
		igniting = 1

	if(igniting)
		if(air_contents.oxygen < 0.5 || air_contents.toxins < 0.5)
			return 0

		active_hotspot = new(src)
		active_hotspot.temperature = exposed_temperature
		active_hotspot.volume = exposed_volume

		active_hotspot.just_spawned = (current_cycle < air_master.current_cycle)
			//remove just_spawned protection if no longer processing this cell
		air_master.add_to_active(src, 0)
	return igniting

//This is the icon for fire on turfs, also helps for nurturing small fires until they are full tile
/obj/effect/hotspot
	anchored = 1
	mouse_opacity = 0
	unacidable = 1//So you can't melt fire with acid.
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = TURF_LAYER
	luminosity = 3

	var/volume = 125
	var/temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
	var/just_spawned = 1
	var/bypassing = 0

/obj/effect/hotspot/New()
	..()
	air_master.hotspots += src
	perform_exposure()

/obj/effect/hotspot/proc/perform_exposure()
	var/turf/simulated/floor/location = loc
	if(!istype(location))	return 0

	if(volume > CELL_VOLUME*0.95)	bypassing = 1
	else bypassing = 0

	if(bypassing)
		if(!just_spawned)
			volume = location.air.fuel_burnt*FIRE_GROWTH_RATE
			temperature = location.air.temperature
	else
		var/datum/gas_mixture/affected = location.air.remove_ratio(volume/location.air.volume)
		affected.temperature = temperature
		affected.react()
		temperature = affected.temperature
		volume = affected.fuel_burnt*FIRE_GROWTH_RATE
		location.assume_air(affected)

	for(var/atom/item in loc)
		if(item && item != src) // It's possible that the item is deleted in temperature_expose
			item.fire_act(null, temperature, volume)
	return 0


/obj/effect/hotspot/process()
	if(just_spawned)
		just_spawned = 0
		return 0

	var/turf/simulated/floor/location = loc
	if(!istype(location))
		Kill()
		return

	if(location.excited_group)
		location.excited_group.reset_cooldowns()

	if((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
		Kill()
		return

	if(location.air.toxins < 0.5 || location.air.oxygen < 0.5)
		Kill()
		return

	perform_exposure()

	if(location.wet) location.wet = 0

	if(bypassing)
		icon_state = "3"
		location.burn_tile()

		//Possible spread due to radiated heat
		if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE
			for(var/direction in cardinal)
				if(!(location.atmos_adjacent_turfs & direction))
					continue
				var/turf/simulated/T = get_step(src, direction)
				if(istype(T) && T.active_hotspot)
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

// Garbage collect itself by nulling reference to it

/obj/effect/hotspot/proc/Kill()
	air_master.hotspots -= src
	DestroyTurf()
	garbage_collect()

/obj/effect/hotspot/proc/garbage_collect()
	if(istype(loc, /turf/simulated))
		var/turf/simulated/T = loc
		if(T.active_hotspot == src)
			T.active_hotspot = null
	loc = null

/obj/effect/hotspot/proc/DestroyTurf()

	if(istype(loc, /turf/simulated))
		var/turf/simulated/T = loc
		if(T.to_be_destroyed)
			var/chance_of_deletion
			if (T.heat_capacity) //beware of division by zero
				chance_of_deletion = T.max_fire_temperature_sustained / T.heat_capacity * 8 //there is no problem with prob(23456), min() was redundant --rastaf0
			else
				chance_of_deletion = 100
			if(prob(chance_of_deletion))
				T.ChangeTurf(/turf/space)
			else
				T.to_be_destroyed = 0
				T.max_fire_temperature_sustained = 0

/obj/effect/hotspot/New()
	..()
	dir = pick(cardinal)
	air_update_turf()
	return

/obj/effect/hotspot/Crossed(mob/living/L)
	..()
	if(isliving(L))
		L.fire_act()
