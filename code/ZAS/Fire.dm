/*

Making Bombs with ZAS:
Make burny fire with lots of burning
Draw off 5000K gas from burny fire
Separate gas into oxygen and plasma components
Obtain plasma and oxygen tanks filled up about 50-75% with normal-temp gas
Fill rest with super hot gas from separated canisters, they should be about 125C now.
Attach to transfer valve and open. BOOM.

*/
/atom
	var/autoignition_temperature = 0 // In Kelvin.  0 = Not flammable
	var/on_fire=0
	var/fire_fuel=0 // Do NOT rely on this.  getFireFuel may be overridden.
	var/fire_dmi = 'icons/effects/fire.dmi'
	var/fire_sprite = "fire"
	var/fire_overlay = null
	var/ashtype = /obj/effect/decal/cleanable/ash

	var/melt_temperature=0
	var/molten = 0


/atom/proc/getFireFuel()
	return fire_fuel

/atom/proc/burnFireFuel(var/used_fuel_ratio,var/used_reactants_ratio)
	fire_fuel -= (fire_fuel * used_fuel_ratio * used_reactants_ratio) //* 5
	if(fire_fuel<=0.1)
		ashify()

/atom/proc/ashify()
	if(!on_fire)
		return
	new ashtype(src.loc)
	qdel(src)

/atom/proc/extinguish()
	on_fire=0
	if(fire_overlay)
		overlays -= fire_overlay

/atom/proc/ignite(var/temperature)
	on_fire=1
	//visible_message("\The [src] bursts into flame!")
	if(fire_dmi && fire_sprite)
		fire_overlay = image(fire_dmi,fire_sprite)
		overlays += fire_overlay
	var/turf/T = get_turf(src)
	if(! (locate(/obj/fire) in T))
		new /obj/fire(T)

/atom/proc/melt()
	return //lolidk

/atom/proc/solidify()
	return //lolidk

/atom/proc/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(autoignition_temperature && !on_fire && exposed_temperature > autoignition_temperature)
		ignite(exposed_temperature)
		return 1

	if(melt_temperature)
		if(melt_temperature <= exposed_temperature && !molten && prob(5))
			molten=1
			melt()
			return 1
		if(melt_temperature > exposed_temperature && molten && prob(5))
			molten=0
			solidify()
			return 1

	return 0

/turf
	var/soot_type = /obj/effect/decal/cleanable/soot

/turf/simulated/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	var/obj/effect/E = null
	if(soot_type)
		E = locate(soot_type) in src
	if(..())
		return 1
	if(molten || on_fire)
		if(istype(E))
			qdel(E)
		return 0
	if(!E && soot_type && prob(25))
		new soot_type(src)

	return 0

/turf/proc/hotspot_expose(var/exposed_temperature, var/exposed_volume, var/soh = 0, var/surfaces=0)

/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh, surfaces)
	var/obj/effect/effect/foam/fire/W = locate() in contents
	if(istype(W))
		return 0
	if(fire_protection > world.time-300)
		return 0
	if(locate(/obj/fire) in src)
		return 1
	var/datum/gas_mixture/air_contents = return_air()
	if(!air_contents || exposed_temperature < PLASMA_MINIMUM_BURN_TEMPERATURE)
		return 0

	var/igniting = 0

	if(air_contents.check_combustability(src, surfaces))
		igniting = 1
		if(! (locate(/obj/fire) in src))
			new /obj/fire(src)

	return igniting

// ignite_temp: 0 = Don't check, just get fuel.
/turf/simulated/proc/getAmtFuel(var/ignite_temp=0)
	var/fuel_found=0
	if(!ignite_temp || src.autoignition_temperature<ignite_temp)
		fuel_found += src.getFireFuel()
	for(var/atom/A in src)
		if(!A) continue
		if(ignite_temp && A.autoignition_temperature>ignite_temp) continue
		fuel_found += A.getFireFuel()
	return fuel_found

/obj/fire
	//Icon for fire on turfs.

	anchored = 1
	mouse_opacity = 0

	//luminosity = 3

	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = TURF_LAYER

	l_color = "#ED9200"

/obj/fire/proc/Extinguish()
	var/turf/simulated/S=loc

	if(istype(S))
		S.extinguish()

	for(var/atom/A in loc)
		A.extinguish()

	qdel(src)


/obj/fire/process()
	. = 1

	// Get location and check if it is in a proper ZAS zone.
	var/turf/simulated/S = get_turf(loc)

	if (!istype(S))
		Extinguish()
		return

	if (isnull(S.zone))
		Extinguish()
		return

	var/datum/gas_mixture/air_contents = S.return_air()

	//and the volatile stuff from the air
	var/datum/gas/volatile_fuel/fuel = locate() in air_contents.trace_gases

	//since the air is processed in fractions, we need to make sure not to have any minuscle residue or
	//the amount of moles might get to low for some functions to catch them and thus result in wonky behaviour
	if(air_contents.oxygen < 0.1)
		air_contents.oxygen = 0
	if(air_contents.toxins < 0.1)
		air_contents.toxins = 0
	if(fuel)
		if(fuel.moles < 0.1)
			air_contents.trace_gases.Remove(fuel)

	// Check if there is something to combust.
	if (!air_contents.check_recombustability(S))
		//testing("Not recombustible.")
		Extinguish()
		return

	//get a firelevel and set the icon
	var/firelevel = air_contents.calculate_firelevel(S)

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

	// Burn the turf, too.
	S.fire_act(air_contents, air_contents.temperature, air_contents.return_volume())

	//spread
	for(var/direction in cardinal)
		if(S.open_directions & direction) //Grab all valid bordering tiles

			var/turf/simulated/enemy_tile = get_step(S, direction)

			if(istype(enemy_tile))
				var/datum/gas_mixture/acs = enemy_tile.return_air()

				if(!acs) continue
				if(!acs.check_recombustability(enemy_tile)) continue
				//If extinguisher mist passed over the turf it's trying to spread to, don't spread and
				//reduce firelevel.
				var/obj/effect/effect/foam/fire/W = locate() in enemy_tile
				if(istype(W))
					firelevel -= 3
					continue
				if(enemy_tile.fire_protection > world.time-30)
					firelevel -= 1.5
					continue

				//Spread the fire.
				if(!(locate(/obj/fire) in enemy_tile))
					if( prob( 50 + 50 * (firelevel/zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier)) ) && S.CanPass(null, enemy_tile, 0,0) && enemy_tile.CanPass(null, S, 0,0))
						new/obj/fire(enemy_tile)

	//seperate part of the present gas
	//this is done to prevent the fire burning all gases in a single pass
	var/datum/gas_mixture/flow = air_contents.remove_ratio(zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate))
///////////////////////////////// FLOW HAS BEEN CREATED /// DONT DELETE THE FIRE UNTIL IT IS MERGED BACK OR YOU WILL DELETE AIR ///////////////////////////////////////////////

	if(flow)
		flow.zburn(S, 1)

		//merge the air back
		S.assume_air(flow)

///////////////////////////////// FLOW HAS BEEN REMERGED /// feel free to delete the fire again from here on //////////////////////////////////////////////////////////////////


/obj/fire/New()
	. = ..()
	dir = pick(cardinal)
	SetLuminosity(3)
	air_master.active_hotspots.Add(src)

/obj/fire/Destroy()
	air_master.active_hotspots.Remove(src)

	SetLuminosity(0)
	..()

turf/simulated/var/fire_protection = 0 //Protects newly extinguished tiles from being overrun again.
turf/proc/apply_fire_protection()
turf/simulated/apply_fire_protection()
	fire_protection = world.time


datum/gas_mixture/proc/zburn(var/turf/T, force_burn)
	// NOTE: zburn is also called from canisters and in tanks/pipes (via react()).  Do NOT assume T is always a turf.
	//  In the aforementioned cases, it's null. - N3X.
	var/value = 0

	if((temperature > PLASMA_MINIMUM_BURN_TEMPERATURE || force_burn) && check_recombustability(T))
		var/total_fuel = 0
		var/datum/gas/volatile_fuel/fuel = locate() in trace_gases

		total_fuel += toxins

		if(fuel)
		//Volatile Fuel
			total_fuel += fuel.moles

		var/can_use_turf=(T && istype(T))
		if(can_use_turf)
			for(var/atom/A in T)
				if(!A) continue
				total_fuel += A.getFireFuel()

		if (0 == total_fuel) // Fix zburn /0 runtime
			//testing("zburn: No fuel left.")
			return 0

		//Calculate the firelevel.
		var/firelevel = calculate_firelevel(T)

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

		if(can_use_turf)
			if(T.getFireFuel()>0)
				T.burnFireFuel(used_fuel_ratio, used_reactants_ratio)
			for(var/atom/A in T)
				if(A.getFireFuel()>0)
					A.burnFireFuel(used_fuel_ratio, used_reactants_ratio)

		//calculate the energy produced by the reaction and then set the new temperature of the mix
		temperature = (starting_energy + zas_settings.Get(/datum/ZAS_Setting/fire_fuel_energy_release) * total_fuel) / heat_capacity()

		update_values()
		value = total_reactants * used_reactants_ratio
	return value

/datum/gas_mixture/proc/check_recombustability(var/turf/T)
	//this is a copy proc to continue a fire after its been started.

	var/datum/gas/volatile_fuel/fuel = locate() in trace_gases

	if(oxygen && (toxins || fuel))
		if(QUANTIZE(toxins * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= 0.1)
			return 1
		if(fuel && QUANTIZE(fuel.moles * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= 0.1)
			return 1

	// Check if we're actually in a turf or not before trying to check object fires.
	// Moved here to unbreak tankbombs - N3X
	if(!T)
		return 0

	if(!istype(T))
		warning("check_recombustability being asked to check a [T.type] instead of /turf.")
		return 0

	// We have to check all objects in order to extinguish object fires.
	var/still_burning=0
	for(var/atom/A in T)
		if(!A) continue
		if(!oxygen/* || A.autoignition_temperature > temperature*/)
			A.extinguish()
			continue
		if(QUANTIZE(A.getFireFuel() * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= 0.1)
			still_burning=1
		else
			A.ashify()

	return still_burning

datum/gas_mixture/proc/check_combustability(var/turf/T, var/objects)
	//this check comes up very often and is thus centralized here to ease adding stuff
	// zburn is used in tank fires, as well. This check, among others, broke tankbombs. - N3X
	/*
	if(!istype(T))
		warning("check_combustability being asked to check a [T.type] instead of /turf.")
		return 0
	*/

	var/datum/gas/volatile_fuel/fuel = locate() in trace_gases

	if(oxygen && (toxins || fuel))
		if(QUANTIZE(toxins * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= MOLES_PLASMA_VISIBLE)
			return 1
		if(fuel && QUANTIZE(fuel.moles * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= 0.1)
			return 1

	if(objects && istype(T))
		for(var/atom/A in T)
			if(!A || !oxygen || A.autoignition_temperature > temperature) continue
			if(QUANTIZE(A.getFireFuel() * zas_settings.Get(/datum/ZAS_Setting/fire_consumption_rate)) >= 0.1)
				return 1

	return 0

datum/gas_mixture/proc/calculate_firelevel(var/turf/T)
	//Calculates the firelevel based on one equation instead of having to do this multiple times in different areas.

	var/datum/gas/volatile_fuel/fuel = locate() in trace_gases
	var/total_fuel = 0
	var/firelevel = 0

	if(check_recombustability(T))

		total_fuel += toxins

		if(T && istype(T))
			total_fuel += T.getFireFuel()

			for(var/atom/A in T)
				if(A)
					total_fuel += A.getFireFuel()

		if(fuel)
			total_fuel += fuel.moles

		var/total_combustables = (total_fuel + oxygen)

		if(total_fuel > 0 && oxygen > 0)

			//slows down the burning when the concentration of the reactants is low
			var/dampening_multiplier = total_combustables / (total_combustables + nitrogen + carbon_dioxide)
			//calculates how close the mixture of the reactants is to the optimum
			var/mix_multiplier = 1 / (1 + (5 * ((oxygen / total_combustables) ** 2))) // Thanks, Mloc
			//toss everything together
			firelevel = zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier) * mix_multiplier * dampening_multiplier

	return max( 0, firelevel)


/mob/living/proc/FireBurn(var/firelevel, var/last_temperature, var/pressure)
	var/mx = 5 * firelevel/zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier) * min(pressure / ONE_ATMOSPHERE, 1)
	apply_damage(2.5*mx, BURN)


/mob/living/carbon/human/FireBurn(var/firelevel, var/last_temperature, var/pressure)
	//Burns mobs due to fire. Respects heat transfer coefficients on various body parts.
	//Due to TG reworking how fireprotection works, this is kinda less meaningful.

	var/head_exposure = 1
	var/chest_exposure = 1
	var/groin_exposure = 1
	var/legs_exposure = 1
	var/arms_exposure = 1

	//Get heat transfer coefficients for clothing.

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
	//minimize this for low-pressure enviroments
	var/mx = 5 * firelevel/zas_settings.Get(/datum/ZAS_Setting/fire_firelevel_multiplier) * min(pressure / ONE_ATMOSPHERE, 1)

	//Always check these damage procs first if fire damage isn't working. They're probably what's wrong.

	apply_damage(2.5*mx*head_exposure, BURN, "head", 0, 0, "Fire")
	apply_damage(2.5*mx*chest_exposure, BURN, "chest", 0, 0, "Fire")
	apply_damage(2.0*mx*groin_exposure, BURN, "groin", 0, 0, "Fire")
	apply_damage(0.6*mx*legs_exposure, BURN, "l_leg", 0, 0, "Fire")
	apply_damage(0.6*mx*legs_exposure, BURN, "r_leg", 0, 0, "Fire")
	apply_damage(0.4*mx*arms_exposure, BURN, "l_arm", 0, 0, "Fire")
	apply_damage(0.4*mx*arms_exposure, BURN, "r_arm", 0, 0, "Fire")
