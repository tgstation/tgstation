vs_control/var/IgnitionLevel = 10 //Moles of oxygen+plasma - co2 needed to burn.

#define OXYGEN
atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null

turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)

turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh)
	if(fire_protection > world.time-300) return
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
	if(air_contents.calculate_firelevel(liquid) > vsc.IgnitionLevel && (fuel || liquid || air_contents.toxins > 0.5))
		igniting = 1
		if(air_contents.oxygen < 0.5)
			return 0

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
						obj/liquid_fuel/liquid = locate() in S

					firelevel = air_contents.calculate_firelevel(liquid)

					if(firelevel > 25 && (air_contents.toxins || fuel || liquid))
						for(var/direction in cardinal)
							if(S.air_check_directions&direction) //Grab all valid bordering tiles
								var/turf/simulated/enemy_tile = get_step(S, direction)
								if(istype(enemy_tile))
									if(enemy_tile.fire_protection > world.time-30)
										firelevel -= 150
										continue
									if(!(locate(/obj/fire) in enemy_tile))
										if( prob( firelevel/2.5 ) )
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

						if(flow.oxygen > 0.3 && (flow.toxins || fuel || liquid))

							icon_state = "1"
							if(firelevel > 25)
								icon_state = "2"
							if(firelevel > 100)
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
				M.FireBurn(min(max(0.1,firelevel / 20),10))


		New(newLoc,fl)
			..()
			dir = pick(cardinal)
			sd_SetLuminosity(3)
			firelevel = fl
			for(var/mob/living/carbon/human/M in loc)
				M.FireBurn(min(max(0.1,firelevel / 20),10))

		Del()
			if (istype(loc, /turf/simulated))
				src.sd_SetLuminosity(0)

				loc = null

			..()

obj/liquid_fuel
	icon = 'icons/effects/effects.dmi'
	icon_state = "fuel"
	layer = TURF_LAYER+0.2
	anchored = 1
	var/amount = 1

	New(newLoc,amt=1)
		src.amount = amt
		for(var/obj/liquid_fuel/other in newLoc)
			if(other != src)
				other.amount += src.amount
				spawn other.Spread()
				del src
				return
		Spread()
		. = ..()
	proc/Spread()
		if(amount < 0.5) return
		var/turf/simulated/S = loc
		if(!istype(S)) return
		for(var/d in cardinal)
			if(S.air_check_directions & d)
				if(rand(25))
					var/turf/simulated/O = get_step(src,d)
					new/obj/liquid_fuel(O,amount*0.25)
					amount *= 0.75

	flamethrower_fuel
		icon_state = "mustard"
		anchored = 0
		New(newLoc, amt = 1, d = 0)
			dir = d
			. = ..()
		Spread()
			if(amount < 0.1) return
			var/turf/simulated/S = loc
			if(!istype(S)) return
			for(var/d in list(turn(dir,90),turn(dir,-90)))
				if(S.air_check_directions & d)
					var/turf/simulated/O = get_step(S,d)
					new/obj/liquid_fuel/flamethrower_fuel(O,amount*0.25,d)
					O.hotspot_expose((T20C*2) + 380,500)
			amount *= 0.5

vs_control/var/switch_fire = 1

turf/simulated/var/fire_protection = 0

turf/proc/apply_fire_protection()
turf/simulated/apply_fire_protection()
	fire_protection = world.time

datum/gas_mixture/proc
	zburn(obj/liquid_fuel/liquid)
		if(temperature > PLASMA_MINIMUM_BURN_TEMPERATURE)
			var
				total_fuel = toxins
				fuel_sources = 0
				datum/gas/volatile_fuel/fuel = locate() in trace_gases
			if(fuel)
				total_fuel += fuel.moles
				fuel_sources++
			if(liquid)
				if(liquid.amount <= 0)
					del liquid
				else
					total_fuel += liquid.amount
					fuel_sources++
			if(toxins > 0.3) fuel_sources++

			if(!fuel_sources) return 0
			if(oxygen > 0.3 && total_fuel)
				var/firelevel = calculate_firelevel(liquid)
				//f(x) = 1000ln(0.01x + 1.45)
				temperature = 1000*log(0.016*firelevel + 1.45)
				var/consumed_gas = min(oxygen,0.002*firelevel,total_fuel) / fuel_sources
				oxygen -= consumed_gas
				toxins = max(0,toxins-consumed_gas)
				if(fuel)
					fuel.moles -= consumed_gas
					if(fuel.moles <= 0) del fuel
				if(liquid)
					liquid.amount -= consumed_gas
					if(liquid.amount <= 0) del liquid
				update_values()
				return consumed_gas*fuel_sources
		return 0
	calculate_firelevel(obj/liquid_fuel/liquid)
		var
			datum/gas/volatile_fuel/fuel = locate() in trace_gases
			fuel_level = 0
			liquid_level = 0
		if(fuel) fuel_level = fuel.moles
		if(liquid) liquid_level = liquid.amount
		return oxygen + toxins + liquid_level*15 + fuel_level*5

/mob/living/carbon/human/proc/FireBurn(mx as num)
	//NO! NOT INTO THE PIT! IT BURRRRRNS!

	var
		head_exposure = 1
		chest_exposure = 1
		groin_exposure = 1
		legs_exposure = 1
		arms_exposure = 1

	for(var/obj/item/clothing/C in src)
		if(l_hand == C || r_hand == C) continue
		if(C.body_parts_covered & HEAD)
			head_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & UPPER_TORSO)
			chest_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & LOWER_TORSO)
			groin_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & LEGS)
			legs_exposure *= C.heat_transfer_coefficient
		if(C.body_parts_covered & ARMS)
			arms_exposure *= C.heat_transfer_coefficient

	mx *= 1

	//Always check these damage procs first if fire damage isn't working. They're probably what's wrong.

	apply_damage(2.5*mx*head_exposure, BURN, "head", 0, 0, "Fire")
	apply_damage(2.5*mx*chest_exposure, BURN, "chest", 0, 0, "Fire")
	apply_damage(2.0*mx*groin_exposure, BURN, "groin", 0, 0, "Fire")
	apply_damage(0.6*mx*legs_exposure, BURN, "l_leg", 0, 0, "Fire")
	apply_damage(0.6*mx*legs_exposure, BURN, "r_leg", 0, 0, "Fire")
	apply_damage(0.4*mx*arms_exposure, BURN, "l_arm", 0, 0, "Fire")
	apply_damage(0.4*mx*arms_exposure, BURN, "r_arm", 0, 0, "Fire")

	flash_pain()