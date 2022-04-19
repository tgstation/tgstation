/*

Making Bombs with ZAS:
Get gas to react in an air tank so that it gains pressure. If it gains enough pressure, it goes boom.
The more pressure, the more boom.
If it gains pressure too slowly, it may leak or just rupture instead of exploding.
*/

//#define FIREDBG

/turf/var/obj/effect/hotspot/fire = null

//Some legacy definitions so fires can be started.
/atom/proc/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return null

/atom/movable/proc/is_burnable()
	return FALSE

/mob/is_burnable()
	return simulated

/turf/proc/hotspot_expose(exposed_temperature, exposed_volume, soh = 0)


/turf/simulated/hotspot_expose(exposed_temperature, exposed_volume, soh)
	if(fire_protection > world.time-300)
		return 0
	if(locate(/obj/effect/hotspot) in src)
		return 1
	var/datum/gas_mixture/air_contents = return_air()
	if(!air_contents || exposed_temperature < PHORON_MINIMUM_BURN_TEMPERATURE)
		return 0

	var/igniting = 0
	var/obj/effect/decal/cleanable/oil/liquid = locate() in src

	if(air_contents.check_combustability(liquid))
		igniting = 1

		create_fire(exposed_temperature)
	return igniting

/zone/proc/process_fire()
	var/datum/gas_mixture/burn_gas = air.remove_ratio(SSzas.settings.fire_consuption_rate, fire_tiles.len)

	var/firelevel = burn_gas.react(src, fire_tiles, force_burn = 1, no_check = 1)

	air.merge(burn_gas)

	if(firelevel)
		for(var/turf/T in fire_tiles)
			if(T.fire)
				T.fire.firelevel = firelevel
			else
				var/obj/effect/decal/cleanable/oil/fuel = locate() in T
				fire_tiles -= T
				fuel_objs -= fuel
	else
		//for(var/turf/simulated/T in fire_tiles) ZASTURF
		for(var/turf/T in fire_tiles)
			if(istype(T.fire))
				qdel(T.fire)
		fire_tiles.Cut()
		fuel_objs.Cut()

	if(!fire_tiles.len)
		SSzas.active_fire_zones.Remove(src)

/zone/proc/remove_liquidfuel(var/used_liquid_fuel, var/remove_fire=0)
	if(!fuel_objs.len)
		return

	//As a simplification, we remove fuel equally from all fuel sources. It might be that some fuel sources have more fuel,
	//some have less, but whatever. It will mean that sometimes we will remove a tiny bit less fuel then we intended to.

	var/fuel_to_remove = used_liquid_fuel/(fuel_objs.len*LIQUIDFUEL_AMOUNT_TO_MOL) //convert back to liquid volume units

	for(var/O in fuel_objs)
		var/obj/effect/decal/cleanable/oil/fuel = O
		if(!istype(fuel))
			fuel_objs -= fuel
			continue

		fuel.reagent_amount -= fuel_to_remove
		if(fuel.reagent_amount <= 0)
			fuel_objs -= fuel
			if(remove_fire)
				var/turf/T = fuel.loc
				if(istype(T) && T.fire) qdel(T.fire)
			qdel(fuel)

/turf/proc/create_fire(fl)
	return 0

//turf/simulated/create_fire(fl) ZASTURF
/turf/create_fire(fl)
	if(fire)
		fire.firelevel = max(fl, fire.firelevel)
		return 1

	if(!zone)
		return 1

	fire = new(src, fl)
	SSzas.active_fire_zones |= zone

	var/obj/effect/decal/cleanable/oil/fuel = locate() in src
	zone.fire_tiles |= src
	if(fuel) zone.fuel_objs += fuel

	return 0

/turf/open/space/create_fire()
	return

/obj/effect/hotspot
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = GASFIRE_LAYER
	plane = ABOVE_GAME_PLANE
	blend_mode = BLEND_ADD
	light_system = MOVABLE_LIGHT
	light_range = LIGHT_RANGE_FIRE
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

	var/firelevel = 1 //Calculated by gas_mixture.calculate_firelevel()

/obj/effect/hotspot/process()
	. = 1

	//var/turf/simulated/my_tile = loc ZASTURF
	var/turf/my_tile = loc
	if(istype(my_tile, /turf/open/space) || !my_tile.zone)
		if(my_tile && my_tile.fire == src)
			my_tile.fire = null
		qdel(src)
		return PROCESS_KILL

	var/datum/gas_mixture/air_contents = my_tile.return_air()

	if(firelevel > 6)
		icon_state = "3"
		set_light(1, 2, 7)
	else if(firelevel > 2.5)
		icon_state = "2"
		set_light(0.7, 2, 5)
	else
		icon_state = "1"
		set_light(0.5, 1, 3)

	for(var/mob/living/L in loc)
		L.FireBurn(firelevel, air_contents.temperature, air_contents.return_pressure())  //Burn the mobs!

	loc.fire_act(air_contents, air_contents.temperature, air_contents.volume)
	for(var/atom/A in loc)
		A.fire_act(air_contents, air_contents.temperature, air_contents.volume)

	//spread
	for(var/direction in GLOB.cardinals)
		//var/turf/simulated/enemy_tile = get_step(my_tile, direction) ZASTURF
		var/turf/enemy_tile = get_step(my_tile, direction)
		if(!istype(enemy_tile, /turf/open/space))
			if(my_tile.open_directions & direction) //Grab all valid bordering tiles
				if(!enemy_tile.zone || enemy_tile.fire)
					continue

				//if(!enemy_tile.zone.fire_tiles.len) TODO - optimize
				var/datum/gas_mixture/acs = enemy_tile.return_air()
				var/obj/effect/decal/cleanable/oil/liquid = locate() in enemy_tile
				if(!acs || !acs.check_combustability(liquid))
					continue

				//If extinguisher mist passed over the turf it's trying to spread to, don't spread and
				//reduce firelevel.
				if(enemy_tile.fire_protection > world.time-30)
					firelevel -= 1.5
					continue

				//Spread the fire.
				if(prob( 50 + 50 * (firelevel/SSzas.settings.fire_firelevel_multiplier) ) && my_tile.CanPass(null, enemy_tile, 0,0) && enemy_tile.CanPass(null, my_tile, 0,0))
					enemy_tile.create_fire(firelevel)

			else
				enemy_tile.adjacent_fire_act(loc, air_contents, air_contents.temperature, air_contents.volume)

	animate(src, color = fire_color(air_contents.temperature), 5)
	set_light(l_color = color)

/obj/effect/hotspot/New(newLoc,fl)
	..()

	if(!istype(loc, /turf))
		qdel(src)
		return

	setDir(pick(GLOB.cardinals))

	var/datum/gas_mixture/air_contents = loc.return_air()
	color = fire_color(air_contents.temperature)
	set_light(0.5, 1, 3, l_color = color)

	firelevel = fl
	SSzas.active_hotspots.Add(src)

/obj/effect/hotspot/proc/fire_color(var/env_temperature)
	var/temperature = max(4000*sqrt(firelevel/SSzas.settings.fire_firelevel_multiplier), env_temperature)
	return heat2color(temperature)

/obj/effect/hotspot/Destroy()
	var/turf/T = loc
	if (istype(T))
		set_light(0)
		T.fire = null
	SSzas.active_hotspots.Remove(src)
	. = ..()

//turf/simulated/var/fire_protection = 0 //Protects newly extinguished tiles from being overrun again. ZASTURF
/turf/var/fire_protection = 0
/turf/proc/apply_fire_protection()
	fire_protection = world.time
/*/turf/simulated/apply_fire_protection() ZASTURF
	fire_protection = world.time*/

/turf/open/space/apply_fire_protection()
	return

//Returns the firelevel
/datum/gas_mixture/proc/react(zone/zone, force_burn, no_check = 0)
	. = 0
	if((temperature > PHORON_MINIMUM_BURN_TEMPERATURE || force_burn) && (no_check ||check_recombustability(zone? zone.fuel_objs : null)))

		#ifdef FIREDBG
		log_admin("***************** FIREDBG *****************")
		log_admin("Burning [zone? zone.name : "zoneless gas_mixture"]!")
		#endif

		var/gas_fuel = 0
		var/liquid_fuel = 0
		var/total_fuel = 0
		var/total_oxidizers = 0

		//*** Get the fuel and oxidizer amounts
		for(var/g in gas)
			if(xgm_gas_data.flags[g] & XGM_GAS_FUEL)
				gas_fuel += gas[g]
			if(xgm_gas_data.flags[g] & XGM_GAS_OXIDIZER)
				total_oxidizers += gas[g]
		gas_fuel *= group_multiplier
		total_oxidizers *= group_multiplier

		//Liquid Fuel
		var/fuel_area = 0
		if(zone)
			for(var/obj/effect/decal/cleanable/oil/fuel in zone.fuel_objs)
				liquid_fuel += fuel.reagent_amount*LIQUIDFUEL_AMOUNT_TO_MOL
				fuel_area++

		total_fuel = gas_fuel + liquid_fuel
		if(total_fuel <= 0.005)
			return 0

		//*** Determine how fast the fire burns

		//get the current thermal energy of the gas mix
		//this must be taken here to prevent the addition or deletion of energy by a changing heat capacity
		var/starting_energy = temperature * heat_capacity()

		//determine how far the reaction can progress
		var/reaction_limit = min(total_oxidizers*(FIRE_REACTION_FUEL_AMOUNT/FIRE_REACTION_OXIDIZER_AMOUNT), total_fuel) //stoichiometric limit

		//vapour fuels are extremely volatile! The reaction progress is a percentage of the total fuel (similar to old zburn).)
		var/gas_firelevel = calculate_firelevel(gas_fuel, total_oxidizers, reaction_limit, volume*group_multiplier) / SSzas.settings.fire_firelevel_multiplier
		var/min_burn = 0.30*volume*group_multiplier/CELL_VOLUME //in moles - so that fires with very small gas concentrations burn out fast
		var/gas_reaction_progress = min(max(min_burn, gas_firelevel*gas_fuel)*FIRE_GAS_BURNRATE_MULT, gas_fuel)

		//liquid fuels are not as volatile, and the reaction progress depends on the size of the area that is burning. Limit the burn rate to a certain amount per area.
		var/liquid_firelevel = calculate_firelevel(liquid_fuel, total_oxidizers, reaction_limit, 0) / SSzas.settings.fire_firelevel_multiplier
		var/liquid_reaction_progress = min((liquid_firelevel*0.2 + 0.05)*fuel_area*FIRE_LIQUID_BURNRATE_MULT, liquid_fuel)

		var/firelevel = (gas_fuel*gas_firelevel + liquid_fuel*liquid_firelevel)/total_fuel

		var/total_reaction_progress = gas_reaction_progress + liquid_reaction_progress
		var/used_fuel = min(total_reaction_progress, reaction_limit)
		var/used_oxidizers = used_fuel*(FIRE_REACTION_OXIDIZER_AMOUNT/FIRE_REACTION_FUEL_AMOUNT)

		#ifdef FIREDBG
		log_admin("gas_fuel = [gas_fuel], liquid_fuel = [liquid_fuel], total_oxidizers = [total_oxidizers]")
		log_admin("fuel_area = [fuel_area], total_fuel = [total_fuel], reaction_limit = [reaction_limit]")
		log_admin("firelevel -> [firelevel] (gas: [gas_firelevel], liquid: [liquid_firelevel])")
		log_admin("liquid_reaction_progress = [liquid_reaction_progress]")
		log_admin("gas_reaction_progress = [gas_reaction_progress]")
		log_admin("total_reaction_progress = [total_reaction_progress]")
		log_admin("used_fuel = [used_fuel], used_oxidizers = [used_oxidizers]; ")
		#endif

		//if the reaction is progressing too slow then it isn't self-sustaining anymore and burns out
		if(zone) //be less restrictive with canister and tank reactions
			if((!liquid_fuel || used_fuel <= FIRE_LIQUD_MIN_BURNRATE) && (!gas_fuel || used_fuel <= FIRE_GAS_MIN_BURNRATE*zone.contents.len))
				return 0


		//*** Remove fuel and oxidizer, add carbon dioxide and heat

		//remove and add gasses as calculated
		var/used_gas_fuel = min(max(0.25, used_fuel*(gas_reaction_progress/total_reaction_progress)), gas_fuel) //remove in proportion to the relative reaction progress
		var/used_liquid_fuel = min(max(0.25, used_fuel-used_gas_fuel), liquid_fuel)

		//remove_by_flag() and adjust_gas() handle the group_multiplier for us.
		remove_by_flag(XGM_GAS_OXIDIZER, used_oxidizers)
		var/datum/gas_mixture/burned_fuel = remove_by_flag(XGM_GAS_FUEL, used_gas_fuel)
		for(var/g in burned_fuel.gas)
			adjust_gas(xgm_gas_data.burn_product[g], burned_fuel.gas[g])

		if(zone)
			zone.remove_liquidfuel(used_liquid_fuel, !check_combustability())

		//calculate the energy produced by the reaction and then set the new temperature of the mix
		temperature = (starting_energy + SSzas.settings.fire_fuel_energy_release * (used_gas_fuel + used_liquid_fuel)) / heat_capacity()
		update_values()

		#ifdef FIREDBG
		log_admin("used_gas_fuel = [used_gas_fuel]; used_liquid_fuel = [used_liquid_fuel]; total = [used_fuel]")
		log_admin("new temperature = [temperature]; new pressure = [return_pressure()]")
		#endif

		if (temperature<220)
			firelevel = 0

		return firelevel

/datum/gas_mixture/proc/check_recombustability(list/fuel_objs)
	. = 0
	for(var/g in gas)
		if(xgm_gas_data.flags[g] & XGM_GAS_OXIDIZER && gas[g] >= 0.1)
			. = 1
			break

	if(!.)
		return 0

	if(fuel_objs && fuel_objs.len)
		return 1

	. = 0
	for(var/g in gas)
		if(xgm_gas_data.flags[g] & XGM_GAS_FUEL && gas[g] >= 0.1)
			. = 1
			break

/datum/gas_mixture/proc/check_combustability(obj/effect/decal/cleanable/oil/liquid)
	. = 0
	for(var/g in gas)
		if(xgm_gas_data.flags[g] & XGM_GAS_OXIDIZER && QUANTIZE(gas[g] * SSzas.settings.fire_consuption_rate) >= 0.1)
			. = 1
			break

	if(!.)
		return 0

	if(liquid)
		return 1

	. = 0
	for(var/g in gas)
		if(xgm_gas_data.flags[g] & XGM_GAS_FUEL && QUANTIZE(gas[g] * SSzas.settings.fire_consuption_rate) >= 0.1)
			. = 1
			break

//returns a value between 0 and SSzas.settings.fire_firelevel_multiplier
/datum/gas_mixture/proc/calculate_firelevel(total_fuel, total_oxidizers, reaction_limit, gas_volume)
	//Calculates the firelevel based on one equation instead of having to do this multiple times in different areas.
	var/firelevel = 0

	var/total_combustables = (total_fuel + total_oxidizers)
	var/active_combustables = (FIRE_REACTION_OXIDIZER_AMOUNT/FIRE_REACTION_FUEL_AMOUNT + 1)*reaction_limit

	if(total_moles && total_combustables > 0)
		//slows down the burning when the concentration of the reactants is low
		var/damping_multiplier = min(1, active_combustables / (total_moles/group_multiplier))

		//weight the damping mult so that it only really brings down the firelevel when the ratio is closer to 0
		damping_multiplier = 2*damping_multiplier - (damping_multiplier*damping_multiplier)

		//calculates how close the mixture of the reactants is to the optimum
		//fires burn better when there is more oxidizer -- too much fuel will choke the fire out a bit, reducing firelevel.
		var/mix_multiplier = 1 / (1 + (5 * ((total_fuel / total_combustables) ** 2)))

		#ifdef FIREDBG
		ASSERT(damping_multiplier <= 1)
		ASSERT(mix_multiplier <= 1)
		#endif

		//toss everything together -- should produce a value between 0 and fire_firelevel_multiplier
		firelevel = SSzas.settings.fire_firelevel_multiplier * mix_multiplier * damping_multiplier

	return max( 0, firelevel)


/mob/living/proc/FireBurn(var/firelevel, var/last_temperature, var/pressure)
	var/mx = 5 * firelevel/SSzas.settings.fire_firelevel_multiplier * min(pressure / ONE_ATMOSPHERE, 1)
	apply_damage(2.5*mx, BURN)
	return mx


/mob/living/carbon/human/FireBurn(var/firelevel, var/last_temperature, var/pressure)
	//Burns mobs due to fire. Respects heat transfer coefficients on various body parts.
	//Due to TG reworking how fireprotection works, this is kinda less meaningful.

	var/head_exposure = 1
	var/chest_exposure = 1
	var/groin_exposure = 1
	var/legs_exposure = 1
	var/arms_exposure = 1

	//Get heat transfer coefficients for clothing.

	for(var/obj/item/clothing/C in get_equipped_items())
		if( C.max_heat_protection_temperature >= last_temperature )
			if(C.body_parts_covered & HEAD)
				head_exposure = 0
			if(C.body_parts_covered & CHEST)
				chest_exposure = 0
			if(C.body_parts_covered & GROIN)
				groin_exposure = 0
			if(C.body_parts_covered & LEGS)
				legs_exposure = 0
			if(C.body_parts_covered & ARMS)
				arms_exposure = 0
	//minimize this for low-pressure environments
	var/mx = 5 * firelevel/SSzas.settings.fire_firelevel_multiplier * min(pressure / ONE_ATMOSPHERE, 1)

	//Always check these damage procs first if fire damage isn't working. They're probably what's wrong.

	apply_damage(0.9*mx*head_exposure,  BURN, BODY_ZONE_HEAD)
	apply_damage(2.5*mx*chest_exposure, BURN, BODY_ZONE_CHEST)
	apply_damage(2,0*mx*groin_exposure, BURN, BODY_ZONE_PRECISE_GROIN)
	apply_damage(0.6*mx*legs_exposure,  BURN, BODY_ZONE_L_LEG)
	apply_damage(0.6*mx*legs_exposure,  BURN, BODY_ZONE_R_LEG)
	apply_damage(0.4*mx*arms_exposure,  BURN, BODY_ZONE_L_ARM)
	apply_damage(0.4*mx*arms_exposure,  BURN, BODY_ZONE_R_ARM)

	//return a truthy value of whether burning actually happened
	return mx * (head_exposure + chest_exposure + groin_exposure + legs_exposure + arms_exposure)

//turf/proc/adjacent_fire_act(turf/simulated/floor/source, exposed_temperature, exposed_volume)
/turf/proc/adjacent_fire_act(turf/source, exposed_temperature, exposed_volume)
	return

//turf/simulated/floor/adjacent_fire_act(turf/simulated/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume) ZASTURF
/turf/open/floor/adjacent_fire_act(turf/open/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	var/dir_to = get_dir(src, adj_turf)

	for(var/obj/structure/window/W in src)
		if(W.dir == dir_to || W.fulltile) //Same direction or diagonal (full tile)
			W.fire_act(adj_air, adj_temp, adj_volume)

/turf/closed/wall/adjacent_fire_act(turf/open/floor/adj_turf, datum/gas_mixture/adj_air, adj_temp, adj_volume)
	//burn(adj_temp)
	if(adj_temp > heat_capacity)
		take_damage(log(Frand(0.9, 1.1) * (adj_temp - heat_capacity)), BURN)

	return ..()

/obj/effect/dummy/lighting_obj/moblight/fire
	name = "fire"
	light_color = LIGHT_COLOR_FIRE
	light_range = LIGHT_RANGE_FIRE
