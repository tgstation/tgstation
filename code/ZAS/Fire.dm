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
	if(fire_protection > world.time-300)
		return 0
	if(locate(/obj/fire) in src)
		return 1
	var/datum/gas_mixture/air_contents = return_air()
	if(!air_contents || exposed_temperature < PLASMA_MINIMUM_BURN_TEMPERATURE)
		return 0

	var/igniting = 0
	var/obj/effect/decal/cleanable/liquid_fuel/liquid = locate() in src

	if(air_contents.check_combustability(liquid))
		igniting = 1

		if(! (locate(/obj/fire) in src))

			new /obj/fire(src,1000)

		//active_hotspot.just_spawned = (current_cycle < air_master.current_cycle)
		//remove just_spawned protection if no longer processing this cell

	return igniting

/obj/fire
	//Icon for fire on turfs.

	anchored = 1
	mouse_opacity = 0

	//luminosity = 3

	icon = 'icons/effects/fire.dmi'
	icon_state = "1"

	layer = TURF_LAYER

	var/firelevel = 10000 //Calculated by gas_mixture.calculate_firelevel()

/obj/fire/process()
	. = 1

	//get location and check if it is in a proper ZAS zone
	var/turf/simulated/S = loc

	if(!istype(S))
		del src

	if(!S.zone)
		del src

	var/datum/gas_mixture/air_contents = S.return_air()
	//get liquid fuels on the ground.
	var/obj/effect/decal/cleanable/liquid_fuel/liquid = locate() in S
	//and the volatile stuff from the air
	var/datum/gas/volatile_fuel/fuel = locate() in air_contents.trace_gases

	//since the air is processed in fractions, we need to make sure not to have any minuscle residue or
	//the amount of moles might get to low for some functions to catch them and thus result in wonky behaviour
	if(air_contents.oxygen < 0.001)
		air_contents.oxygen = 0
	if(air_contents.toxins < 0.001)
		air_contents.toxins = 0
	if(fuel)
		if(fuel.moles < 0.001)
			air_contents.trace_gases.Remove(fuel)

	//check if there is something to combust
	if(!air_contents.check_recombustability(liquid))
		//del src
		RemoveFire()

	//get a firelevel and set the icon
	firelevel = air_contents.calculate_firelevel(liquid)

	if(firelevel > 6)
		icon_state = "3"
		SetLuminosity(7)
	else if(firelevel > 2.5)
		icon_state = "2"
		SetLuminosity(5)
	else
		icon_state = "1"
		SetLuminosity(3)

	//im not sure how to implement a version that works for every creature so for now monkeys are firesafe
	for(var/mob/living/carbon/human/M in loc)
		M.FireBurn(firelevel, air_contents.temperature, air_contents.return_pressure() ) //Burn the humans!
	for(var/atom/A in loc)
		A.fire_act(air_contents, air_contents.temperature, air_contents.return_volume())
	//spread
	for(var/direction in cardinal)
		if(S.air_check_directions&direction) //Grab all valid bordering tiles

			var/turf/simulated/enemy_tile = get_step(S, direction)

			if(istype(enemy_tile))
				var/datum/gas_mixture/acs = enemy_tile.return_air()
				var/obj/effect/decal/cleanable/liquid_fuel/liq = locate() in enemy_tile
				if(!acs) continue
				if(!acs.check_recombustability(liq)) continue
				//If extinguisher mist passed over the turf it's trying to spread to, don't spread and
				//reduce firelevel.
				if(enemy_tile.fire_protection > world.time-30)
					firelevel -= 1.5
					continue

				//Spread the fire.
				if(!(locate(/obj/fire) in enemy_tile))
					if( prob( 50 + 50 * (firelevel/zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier)) ) && S.CanPass(null, enemy_tile, 0,0) && enemy_tile.CanPass(null, S, 0,0))
						new/obj/fire(enemy_tile,firelevel)

	//seperate part of the present gas
	//this is done to prevent the fire burning all gases in a single pass
	var/datum/gas_mixture/flow = air_contents.remove_ratio(zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate))
///////////////////////////////// FLOW HAS BEEN CREATED /// DONT DELETE THE FIRE UNTIL IT IS MERGED BACK OR YOU WILL DELETE AIR ///////////////////////////////////////////////

	if(flow)

		if(flow.check_recombustability(liquid))
			//Ensure flow temperature is higher than minimum fire temperatures.
				//this creates some energy ex nihilo but is necessary to get a fire started
				//lets just pretend this energy comes from the ignition source and dont mention this again
			//flow.temperature = max(PLASMA_MINIMUM_BURN_TEMPERATURE+0.1,flow.temperature)

			//burn baby burn!

			flow.zburn(liquid,1)
		//merge the air back
		S.assume_air(flow)

///////////////////////////////// FLOW HAS BEEN REMERGED /// feel free to delete the fire again from here on //////////////////////////////////////////////////////////////////


/obj/fire/New(newLoc,fl)
	..()

	if(!istype(loc, /turf))
		del src

	dir = pick(cardinal)
	SetLuminosity(3)
	firelevel = fl
	air_master.active_hotspots.Add(src)


/obj/fire/Del()
	if (istype(loc, /turf/simulated))
		SetLuminosity(0)

		loc = null
	air_master.active_hotspots.Remove(src)

	..()

/obj/fire/proc/RemoveFire()
	if (istype(loc, /turf/simulated))
		SetLuminosity(0)
		loc = null
	air_master.active_hotspots.Remove(src)



turf/simulated/var/fire_protection = 0 //Protects newly extinguished tiles from being overrun again.
turf/proc/apply_fire_protection()
turf/simulated/apply_fire_protection()
	fire_protection = world.time


datum/gas_mixture/proc/zburn(obj/effect/decal/cleanable/liquid_fuel/liquid, force_burn)
	var/value = 0

	if((temperature > PLASMA_MINIMUM_BURN_TEMPERATURE || force_burn) && check_recombustability(liquid))
		var/total_fuel = 0
		var/datum/gas/volatile_fuel/fuel = locate() in trace_gases

		total_fuel += toxins

		if(fuel)
		//Volatile Fuel
			total_fuel += fuel.moles

		if(liquid)
		//Liquid Fuel
			if(liquid.amount <= 0)
				del liquid
			else
				total_fuel += liquid.amount

		//Calculate the firelevel.
		var/firelevel = calculate_firelevel(liquid)

		//get the current inner energy of the gas mix
		//this must be taken here to prevent the addition or deletion of energy by a changing heat capacity
		var/starting_energy = temperature * heat_capacity()

		//determine the amount of oxygen used
		var/total_oxygen = min(oxygen, 2 * total_fuel)

		//determine the amount of fuel actually used
		var/used_fuel_ratio = min(oxygen / 2 , total_fuel) / total_fuel
		total_fuel = total_fuel * used_fuel_ratio

		var/total_reactants = total_fuel + total_oxygen

		//determine the amount of reactants actually reacting
		var/used_reactants_ratio = min( max(total_reactants * firelevel / zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier), 0.2), total_reactants) / total_reactants

		//remove and add gasses as calculated
		oxygen -= min(oxygen, total_oxygen * used_reactants_ratio )

		toxins -= min(toxins, (toxins * used_fuel_ratio * used_reactants_ratio ) * 3)
		if(toxins < 0)
			toxins = 0

		carbon_dioxide += max(2 * total_fuel, 0)

		if(fuel)
			fuel.moles -= (fuel.moles * used_fuel_ratio * used_reactants_ratio) * 5 //Fuel burns 5 times as quick
			if(fuel.moles <= 0) del fuel

		if(liquid)
			liquid.amount -= (liquid.amount * used_fuel_ratio * used_reactants_ratio) * 5 // liquid fuel burns 5 times as quick

			if(liquid.amount <= 0) del liquid

		//calculate the energy produced by the reaction and then set the new temperature of the mix
		temperature = (starting_energy + zas_settings.Get(/datum/ZAS_Setting/fire_fuel_energy_release) * total_fuel) / heat_capacity()

		update_values()
		value = total_reactants * used_reactants_ratio
	return value

datum/gas_mixture/proc/check_recombustability(obj/effect/decal/cleanable/liquid_fuel/liquid)
	//this is a copy proc to continue a fire after its been started.

	var/datum/gas/volatile_fuel/fuel = locate() in trace_gases
	var/value = 0

	if(oxygen && (toxins || fuel || liquid))
		if(liquid)
			value = 1
		else if (toxins && !value)
			value = 1
		else if(fuel && !value)
			value = 1

	return value

datum/gas_mixture/proc/check_combustability(obj/effect/decal/cleanable/liquid_fuel/liquid)
	//this check comes up very often and is thus centralized here to ease adding stuff

	var/datum/gas/volatile_fuel/fuel = locate() in trace_gases
	var/value = 0

	if(oxygen && (toxins || fuel || liquid))
		if(liquid)
			value = 1
		else if (toxins >= 0.7 && !value)
			value = 1
		else if(fuel && !value)
			if(fuel.moles >= 1.4)
				value = 1

	return value

datum/gas_mixture/proc/calculate_firelevel(obj/effect/decal/cleanable/liquid_fuel/liquid)
	//Calculates the firelevel based on one equation instead of having to do this multiple times in different areas.

	var/datum/gas/volatile_fuel/fuel = locate() in trace_gases
	var/total_fuel = 0
	var/firelevel = 0

	if(check_recombustability(liquid))

		total_fuel += toxins

		if(liquid)
			total_fuel += liquid.amount

		if(fuel)
			total_fuel += fuel.moles

		var/total_combustables = (total_fuel + oxygen)

		if(total_fuel > 0 && oxygen > 0)

			//slows down the burning when the concentration of the reactants is low
			var/dampening_multiplier = total_combustables / (total_combustables + nitrogen + carbon_dioxide)
			//calculates how close the mixture of the reactants is to the optimum
			var/mix_multiplier = 1 / (1 + (5 * ((oxygen / total_combustables) ^2)))
			//toss everything together
			firelevel = zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier) * mix_multiplier * dampening_multiplier

	return max( 0, firelevel)


/mob/living/carbon/human/proc/FireBurn(var/firelevel, var/last_temperature, var/pressure)
// mostly using the old proc from Sky until I can think of something better
	//Burns mobs due to fire. Respects heat transfer coefficients on various body parts.
	//Due to TG reworking how fireprotection works, this is kinda less meaningful.

	var
		head_exposure = 1
		chest_exposure = 1
		groin_exposure = 1
		legs_exposure = 1
		arms_exposure = 1

	//determine the multiplier
	//minimize this for low-pressure enviroments
	var/mx = 5 * firelevel/zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier) * min(pressure / ONE_ATMOSPHERE, 1)

	//Get heat transfer coefficients for clothing.
	//skytodo: kill anyone who breaks things then orders me to fix them
	for(var/obj/item/clothing/C in src)
		if(l_hand == C || r_hand == C)
			continue

		if( C.max_heat_protection_temperature >= last_temperature )
			if(C.body_parts_covered & HEAD)
				head_exposure = 0
			if(C.body_parts_covered & UPPER_TORSO)
				chest_exposure = 0
			if(C.body_parts_covered & LOWER_TORSO)
				groin_exposure = 0
			if(C.body_parts_covered & LEGS)
				legs_exposure = 0
			if(C.body_parts_covered & ARMS)
				arms_exposure = 0

	//Always check these damage procs first if fire damage isn't working. They're probably what's wrong.

	apply_damage(2.5*mx*head_exposure, BURN, "head", 0, 0, "Fire")
	apply_damage(2.5*mx*chest_exposure, BURN, "chest", 0, 0, "Fire")
	apply_damage(2.0*mx*groin_exposure, BURN, "groin", 0, 0, "Fire")
	apply_damage(0.6*mx*legs_exposure, BURN, "l_leg", 0, 0, "Fire")
	apply_damage(0.6*mx*legs_exposure, BURN, "r_leg", 0, 0, "Fire")
	apply_damage(0.4*mx*arms_exposure, BURN, "l_arm", 0, 0, "Fire")
	apply_damage(0.4*mx*arms_exposure, BURN, "r_arm", 0, 0, "Fire")

	//flash_pain()
