vs_control/var/IgnitionLevel = 10 //Moles of oxygen+plasma - co2 needed to burn.

#define OXYGEN
atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null

turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)

turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh)
	if(fire_protection) return
	var/datum/gas_mixture/air_contents = return_air(1)
	if(!air_contents)
		return 0

  /*if(active_hotspot)
		if(soh)
			if(air_contents.toxins > 0.5 && air_contents.oxygen > 0.5)
				if(active_hotspot.temperature < exposed_temperature)
					active_hotspot.temperature = exposed_temperature
				if(active_hotspot.volume < exposed_volume)
					active_hotspot.volume = exposed_volume
		return 1*/
	var/igniting = 0
	if(locate(/obj/fire) in src)
		return 1
	var/datum/gas/volatile_fuel/fuel = locate() in air_contents.trace_gases
	var/obj/liquid_fuel/liquid = locate() in src
	var/fuel_level = 0
	var/liquid_level = 0
	if(fuel) fuel_level = fuel.moles
	if(liquid) liquid_level = liquid.amount
	var/total_fuel = air_contents.toxins + fuel_level + liquid_level
	if((air_contents.oxygen + air_contents.toxins + fuel_level*1.5 + liquid_level*1.5) - (air_contents.carbon_dioxide*0.25) > vsc.IgnitionLevel && total_fuel > 0.5)
		igniting = 1
		if(air_contents.oxygen < 0.5)
			return 0

		if(parent&&parent.group_processing)
			parent.suspend_group_processing()

		if(! (locate(/obj/fire) in src))
			var/obj/fire/F = new(src,1000)
			F.temperature = exposed_temperature
			F.volume = CELL_VOLUME

		//active_hotspot.just_spawned = (current_cycle < air_master.current_cycle)
		//remove just_spawned protection if no longer processing this cell

	return igniting

obj/effect/hotspot
	//Icon for fire on turfs, also helps for nurturing small fires until they are full tile

	anchored = 1

	mouse_opacity = 0

	//luminosity = 3

	icon = 'fire.dmi'
	icon_state = "1"

	layer = TURF_LAYER

	var
		volume = 125
		temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST

		just_spawned = 1

		bypassing = 0

obj/effect/hotspot/proc/perform_exposure()
	var/turf/simulated/floor/location = loc
	if(!istype(location))
		return 0

	if(volume > CELL_VOLUME*0.95)
		bypassing = 1
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
			item.temperature_expose(null, temperature, volume)

obj/effect/hotspot/process(turf/simulated/list/possible_spread)
	if(just_spawned)
		just_spawned = 0
		return 0

	var/turf/simulated/floor/location = loc
	if(!istype(location))
		del(src)

	if((temperature < FIRE_MINIMUM_TEMPERATURE_TO_EXIST) || (volume <= 1))
		del(src)

	if(location.air.toxins < 0.5 || location.air.oxygen < 0.5)
		del(src)


	perform_exposure()

	if(location.wet) location.wet = 0

	if(bypassing)
		icon_state = "3"
		location.burn_tile()

		//Possible spread due to radiated heat
		if(location.air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_SPREAD)
			var/radiated_temperature = location.air.temperature*FIRE_SPREAD_RADIOSITY_SCALE

			for(var/turf/simulated/possible_target in possible_spread)
				if(!locate(/obj/effect/hotspot) in possible_target)
					possible_target.hotspot_expose(radiated_temperature, CELL_VOLUME/4)

	else
		if(volume > CELL_VOLUME*0.4)
			icon_state = "2"
		else
			icon_state = "1"

	return 1

obj/effect/hotspot/New()
	..()
	dir = pick(cardinal)
	sd_SetLuminosity(3)

obj/effect/hotspot/Del()
	src.sd_SetLuminosity(0)
	loc = null
	..()

var
	fire_ratio_1 = 0.05

obj
	fire
		//Icon for fire on turfs, also helps for nurturing small fires until they are full tile

		anchored = 1
		mouse_opacity = 0

		//luminosity = 3

		icon = 'fire.dmi'
		icon_state = "1"

		layer = TURF_LAYER

		var
			volume = CELL_VOLUME
			temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
			firelevel = 10000
			archived_firelevel = 0

		process()
			if(firelevel > vsc.IgnitionLevel)
				var/turf/simulated/floor/S = loc
				if(!S.zone) del src
				//src.temperature += (src.firelevel/FireTempDivider+FireOffset - src.temperature) / FireRate
				if(istype(S,/turf/simulated/floor))
					var
						datum/gas_mixture/air_contents = S.return_air()
						datum/gas/volatile_fuel/fuel = locate(/datum/gas/volatile_fuel/) in air_contents.trace_gases
						fuel_level = 0
						obj/liquid_fuel/liquid = locate() in S
						liquid_level = 0

					if(fuel) fuel_level = fuel.moles
					if(liquid)
						liquid_level = liquid.amount
						if(liquid.amount <= 0)
							del liquid
							liquid_level = 0

					firelevel = (air_contents.oxygen + air_contents.toxins + fuel_level*1.5 + liquid_level*1.5) - (air_contents.carbon_dioxide*0.25)

					firelevel = min(firelevel,vsc.IgnitionLevel*5)

					if(firelevel > vsc.IgnitionLevel * 1.5 && (air_contents.toxins || fuel_level || liquid_level))
						for(var/direction in cardinal)
							if(S.air_check_directions&direction) //Grab all valid bordering tiles
								var/turf/simulated/enemy_tile = get_step(S, direction)
								if(istype(enemy_tile))
									if(enemy_tile.fire_protection)
										firelevel -= vsc.IgnitionLevel
										continue
									if(!(locate(/obj/fire) in enemy_tile))
										if( prob( firelevel/(vsc.IgnitionLevel*0.1) ) )
											new/obj/fire(enemy_tile,firelevel)
					//					else
					//						world << "Spread Probability: [firelevel/(vsc.IgnitionLevel*0.1)]%."
					//				else
					//					world << "There's a fire there bitch."
					//			else
					//				world << "[enemy_tile] cannot be spread to."
					//else
					//	world << "Not enough firelevel to spread: [firelevel]/[vsc.IgnitionLevel*1.5]"

					var/datum/gas_mixture/flow = air_contents.remove_ratio(0.5)
					//n = PV/RT, taking the volume of a single tile from the gas.

					if(flow)

						if(flow.oxygen > 0.3 && (flow.toxins || fuel_level || liquid))

							icon_state = "1"
							if(firelevel > vsc.IgnitionLevel * 2)
								icon_state = "2"
							if(firelevel > vsc.IgnitionLevel * 3.5)
								icon_state = "3"
							flow.temperature = max(PLASMA_MINIMUM_BURN_TEMPERATURE+0.1,flow.temperature)
							flow.zburn(liquid)

						else
							del src


						S.assume_air(flow)
					else
						//world << "No air at all."
						del src
				else
					del src
			else
				//world << "Insufficient fire level for ignition: [firelevel]/[IgnitionLevel]"
				del src

			for(var/mob/living/carbon/human/M in loc)
				M.FireBurn(firelevel/(vsc.IgnitionLevel*10))


		New(newLoc,fl)
			..()
			dir = pick(cardinal)
			sd_SetLuminosity(3)
			firelevel = fl
			for(var/mob/living/carbon/human/M in loc)
				M.FireBurn(firelevel/(vsc.IgnitionLevel*10))

		Del()
			if (istype(loc, /turf/simulated))
				src.sd_SetLuminosity(0)

				loc = null

			..()

obj/liquid_fuel
	icon = 'effects.dmi'
	icon_state = "slube"
	layer = TURF_LAYER+0.2
	anchored = 1
	var/amount = 1

	New(newLoc)
		for(var/obj/liquid_fuel/other in newLoc)
			if(other != src)
				other.amount += src.amount
				del src
		. = ..()

vs_control/var/switch_fire = 1

turf/simulated/var/fire_protection = 0

datum/gas_mixture/proc/zburn(obj/liquid_fuel/liquid)
	if(vsc.switch_fire)
		. = fire()
		if(liquid && liquid.amount > 0)
			oxygen -= fire_ratio_1
			liquid.amount = max(liquid.amount-fire_ratio_1,0)
			carbon_dioxide += fire_ratio_1
			if(liquid.amount <= 0)
				del liquid
		return
	if(temperature > PLASMA_MINIMUM_BURN_TEMPERATURE)
		var
			fuel_level = 0
			datum/gas/volatile_fuel/fuel = locate() in trace_gases
			liquid_level = 0
		if(fuel) fuel_level = fuel.moles
		if(liquid) liquid_level = liquid.amount
		if(liquid && liquid_level <= 0)
			del liquid
			liquid_level = 0
		if(oxygen > 0.3 && (toxins || fuel_level || liquid_level))
			if(toxins && temperature < PLASMA_UPPER_TEMPERATURE)
				temperature += (FIRE_PLASMA_ENERGY_RELEASED*fire_ratio_1) / heat_capacity()

			if((fuel_level || liquid_level) && temperature < PLASMA_UPPER_TEMPERATURE)
				temperature += (FIRE_CARBON_ENERGY_RELEASED*fire_ratio_1) / heat_capacity()

			if(toxins > fire_ratio_1)
				oxygen -= vsc.plc.OXY_TO_PLASMA*fire_ratio_1
				toxins -= fire_ratio_1
				carbon_dioxide += fire_ratio_1
			else if(toxins)
				oxygen -= toxins * vsc.plc.OXY_TO_PLASMA
				carbon_dioxide += toxins
				toxins = 0

			if(fuel_level > fire_ratio_1/1.5)
				oxygen -= vsc.plc.OXY_TO_PLASMA*fire_ratio_1
				fuel.moles -= fire_ratio_1
				carbon_dioxide += fire_ratio_1

			else if(fuel_level)
				oxygen -= fuel.moles * vsc.plc.OXY_TO_PLASMA
				carbon_dioxide += fuel.moles
				fuel.moles = 0

			if(liquid_level > 0)
				oxygen -= fire_ratio_1
				liquid.amount = max(liquid.amount-fire_ratio_1,0)
				carbon_dioxide += fire_ratio_1
				if(liquid.amount <= 0)
					del liquid
			return 1
	return 0