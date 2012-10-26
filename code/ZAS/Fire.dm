/*

Making Bombs with ZAS:
Make burny fire with lots of burning
Draw off 5000K gas from burny fire
Separate gas into oxygen and plasma components
Obtain plasma and oxygen tanks filled up about 50-75% with normal-temp gas
Fill rest with super hot gas from separated canisters, they should be about 125C now.
Attach to transfer valve and open. BOOM.

*/




//Some legacy definitions so fires can be started.
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
	var/obj/effect/decal/cleanable/liquid_fuel/liquid = locate() in src
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

obj
	fire
		//Icon for fire on turfs.

		anchored = 1
		mouse_opacity = 0

		luminosity = 3

		icon = 'fire.dmi'
		icon_state = "1"

		layer = TURF_LAYER

		var
			volume = CELL_VOLUME
			temperature = FIRE_MINIMUM_TEMPERATURE_TO_EXIST
			firelevel = 10000 //Calculated by gas_mixture.calculate_firelevel()
			archived_firelevel = 0

		process()
			. = 1

			if(firelevel > vsc.IgnitionLevel)

				var/turf/simulated/floor/S = loc
				if(!S.zone) del src //Cannot exist where zones are broken.

				if(istype(S,/turf/simulated/floor))
					var
						datum/gas_mixture/air_contents = S.return_air()
						//Get whatever trace fuels are in the area
						datum/gas/volatile_fuel/fuel = locate(/datum/gas/volatile_fuel/) in air_contents.trace_gases
						//Also get liquid fuels on the ground.
						obj/effect/decal/cleanable/liquid_fuel/liquid = locate() in S

					var/datum/gas_mixture/flow = air_contents.remove_ratio(0.25)
					//The reason we're taking a part of the air instead of all of it is so that it doesn't jump to
					//the fire's max temperature instantaneously.

					firelevel = air_contents.calculate_firelevel(liquid)

					//Ensure that there is an appropriate amount of fuel and O2 here.
					if(firelevel > 0.25 && flow.oxygen > 0.3 && (air_contents.toxins || fuel || liquid))

						for(var/direction in cardinal)
							if(S.air_check_directions&direction) //Grab all valid bordering tiles

								var/turf/simulated/enemy_tile = get_step(S, direction)

								if(istype(enemy_tile))
									//If extinguisher mist passed over the turf it's trying to spread to, don't spread and
									//reduce firelevel.
									if(enemy_tile.fire_protection > world.time-30)
										firelevel -= 1.5
										continue

									//Spread the fire.
									if(!(locate(/obj/fire) in enemy_tile))
										if( prob( firelevel*10 ) )
											new/obj/fire(enemy_tile,firelevel)

					if(flow)

						//Ensure adequate oxygen and fuel.
						if(flow.oxygen > 0.3 && (flow.toxins || fuel || liquid))

							//Change icon depending on the fuel, and thus temperature.
							if(firelevel > 6)
								icon_state = "3"
							else if(firelevel > 2.5)
								icon_state = "2"
							else
								icon_state = "1"

							//Ensure flow temperature is higher than minimum fire temperatures.
							flow.temperature = max(PLASMA_MINIMUM_BURN_TEMPERATURE+0.1,flow.temperature)

							//Burn the gas mixture.
							flow.zburn(liquid)

						else

							del src


						S.assume_air(flow) //Then put it back where you found it.

					else
						del src
				else
					del src
			else
				del src

			for(var/mob/living/carbon/human/M in loc)
				M.FireBurn(min(max(0.1,firelevel / 20),10)) //Burn the humans!


		New(newLoc,fl)
			..()

			if(!istype(loc, /turf) || !loc.CanPass(null, loc, 0, 0))
				del src

			dir = pick(cardinal)
			//sd_SetLuminosity(3,2,0)
			firelevel = fl
			for(var/mob/living/carbon/human/M in loc)
				M.FireBurn(min(max(0.1,firelevel / 20),10)) //Burn the humans!
			air_master.active_hotspots.Add(src)

		Del()
			if (istype(loc, /turf/simulated))
				//sd_SetLuminosity(0)

				loc = null
			air_master.active_hotspots.Remove(src)

			..()

turf/simulated/var/fire_protection = 0 //Protects newly extinguished tiles from being overrun again.
turf/proc/apply_fire_protection()
turf/simulated/apply_fire_protection()
	fire_protection = world.time

datum/gas_mixture/proc/zburn(obj/effect/decal/cleanable/liquid_fuel/liquid)
	//This proc is similar to fire(), but uses a simple logarithm to calculate temp, and is thus more stable with ZAS.
	if(temperature > PLASMA_MINIMUM_BURN_TEMPERATURE)
		var
			total_fuel = toxins
			fuel_sources = 0 //We'll divide by this later so that fuel is consumed evenly.
			datum/gas/volatile_fuel/fuel = locate() in trace_gases

		if(fuel)
		//Volatile Fuel
			total_fuel += fuel.moles
			fuel_sources++

		if(liquid)
		//Liquid Fuel
			if(liquid.amount <= 0)
				del liquid
			else
				total_fuel += liquid.amount
				fuel_sources++

			//Toxins
		if(toxins > 0.3) fuel_sources++

		if(!fuel_sources) return 0 //If there's no fuel, there's no burn. Can't divide by zero anyway.

		if(oxygen > 0.3)

				//Calculate the firelevel.
			var/firelevel = calculate_firelevel(liquid)

				//Reaches a maximum practical temperature of around 4500.

			//Increase temperature.
			temperature = max( 1700*log(0.4*firelevel + 1.23) , temperature )

			//Consume some gas.
			var/consumed_gas = min(oxygen,firelevel,total_fuel) / fuel_sources

			oxygen = max(0,oxygen-consumed_gas)

			toxins = max(0,toxins-consumed_gas)

			carbon_dioxide += consumed_gas*2

			if(fuel)
				fuel.moles -= consumed_gas
				if(fuel.moles <= 0) del fuel

			if(liquid)
				liquid.amount -= consumed_gas
				if(liquid.amount <= 0) del liquid

			update_values()
			return consumed_gas*fuel_sources
	return 0


datum/gas_mixture/proc/calculate_firelevel(obj/effect/decal/cleanable/liquid_fuel/liquid)
		//Calculates the firelevel based on one equation instead of having to do this multiple times in different areas.
	var
		datum/gas/volatile_fuel/fuel = locate() in trace_gases
		liquid_concentration = 0
		fuel_concentration = 0

		oxy_concentration = oxygen / volume
		tox_concentration = toxins / volume

	if(fuel) fuel_concentration = (fuel.moles) / volume
	if(liquid) liquid_concentration = (liquid.amount*15) / volume

	var/final = tox_concentration + liquid_concentration + fuel_concentration
	if(final > oxy_concentration)
		final = oxy_concentration

	return final * 100

/mob/living/carbon/human/proc/FireBurn(mx as num)
	//Burns mobs due to fire. Respects heat transfer coefficients on various body parts.

	var
		head_exposure = 1
		chest_exposure = 1
		groin_exposure = 1
		legs_exposure = 1
		arms_exposure = 1

	//Get heat transfer coefficients for clothing.
	//skytodo: different handling of temp with tg
	/*for(var/obj/item/clothing/C in src)
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
			arms_exposure *= C.heat_transfer_coefficient*/

	//Always check these damage procs first if fire damage isn't working. They're probably what's wrong.

	apply_damage(2.5*mx*head_exposure, BURN, "head", 0, 0, "Fire")
	apply_damage(2.5*mx*chest_exposure, BURN, "chest", 0, 0, "Fire")
	apply_damage(2.0*mx*groin_exposure, BURN, "groin", 0, 0, "Fire")
	apply_damage(0.6*mx*legs_exposure, BURN, "l_leg", 0, 0, "Fire")
	apply_damage(0.6*mx*legs_exposure, BURN, "r_leg", 0, 0, "Fire")
	apply_damage(0.4*mx*arms_exposure, BURN, "l_arm", 0, 0, "Fire")
	apply_damage(0.4*mx*arms_exposure, BURN, "r_arm", 0, 0, "Fire")

	//flash_pain()