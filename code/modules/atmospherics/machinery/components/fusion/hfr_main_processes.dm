/**
 * Main Fusion processes
 * process_atmos() is mainly used to dea with the damage calculation, gas moving between the parts (like cooling, gas injection, output) and the calculation for the power level
 * process() calls fusion_process() and set the fusion_started var to TRUE if the power level goes over 0
 * fusion_process() the main calculations are done here
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/process_atmos()
	/*
	 *Pre-checks
	 */
	//first check if the machine is active
	if(!active)
		return

	//then check if the other machines are still there
	if(!check_part_connectivity())
		deactivate()
		return

	//now check if the machine has been turned on by the user
	if(!start_power)
		return

	//We play delam/neutral sounds at a rate determined by power and critical_threshold_proximity
	if(last_accent_sound < world.time && prob(20))
		var/aggression = min(((critical_threshold_proximity / 800) * ((power_level) / 5)), 1.0) * 100
		if(critical_threshold_proximity >= 300)
			playsound(src, "hypertorusmelting", max(50, aggression), FALSE, 40, 30, falloff_distance = 10)
		else
			playsound(src, "hypertoruscalm", max(50, aggression), FALSE, 25, 25, falloff_distance = 10)
		var/next_sound = round((100 - aggression) * 5) + 5
		last_accent_sound = world.time + max(HYPERTORUS_ACCENT_SOUND_MIN_COOLDOWN, next_sound)

	soundloop.volume = clamp((power_level + 1) * 8, 0, 50)

	/*
	 *Storing variables such as gas mixes, temperature, volume, moles
	 */

	critical_threshold_proximity_archived = critical_threshold_proximity
	if(power_level == 6)
		critical_threshold_proximity = max(critical_threshold_proximity + max((round((internal_fusion.total_moles() * 9e5 + coolant_temperature) / 9e5, 1) - 2700) / 400, 0), 0)

	if(internal_fusion.total_moles() < HYPERTORUS_SUBCRITICAL_MOLES || power_level <= 5)
		critical_threshold_proximity = max(critical_threshold_proximity + min((internal_fusion.total_moles() - 1200) / 200, 0), 0)

	if(internal_fusion.total_moles() > 0 && (airs[1].total_moles() && coolant_temperature < 5e5) || power_level <= 4)
		critical_threshold_proximity = max(critical_threshold_proximity + min(log(10, max(coolant_temperature, 1)) - 5, 0), 0)

	critical_threshold_proximity += max(iron_content - 0.35, 0)

	critical_threshold_proximity = min(critical_threshold_proximity_archived + (DAMAGE_CAP_MULTIPLIER * melting_point), critical_threshold_proximity)

	if(internal_fusion.total_moles() >= HYPERTORUS_HYPERCRITICAL_MOLES)
		critical_threshold_proximity += min(max(0.001 * internal_fusion.total_moles() - 10, 0), HYPERTORUS_MAX_MOLE_DAMAGE)

	if(moderator_internal.total_moles() >= HYPERTORUS_HYPERCRITICAL_MOLES && !check_cracked_parts())
		var/obj/machinery/atmospherics/components/unary/hypertorus/part = create_crack()
		if(moderator_internal.return_pressure() >= 10000 && moderator_internal.return_pressure() < 12000)
			explosion(
				origin = part,
				devastation_range = 0,
				heavy_impact_range = 0,
				light_impact_range = 1,
				flame_range = 3,
				flash_range = 3
				)
			spill_gases(part, moderator_internal, ratio = 0.25)
		else if(moderator_internal.return_pressure() >= 12000)
			explosion(
				origin = part,
				devastation_range = 0,
				heavy_impact_range = 1,
				light_impact_range = 3,
				flame_range = 5,
				flash_range = 5
				)
			spill_gases(part, moderator_internal, ratio = 0.75)

	check_alert()

	if(!check_power_use())
		return

	if(!start_cooling)
		return

	if(moderator_internal.total_moles() > 0 && internal_fusion.total_moles() > 0)
		//Modifies the moderator_internal temperature based on energy conduction and also the fusion by the same amount
		var/fusion_temperature_delta = internal_fusion.temperature - moderator_internal.temperature
		var/fusion_heat_amount = METALLIC_VOID_CONDUCTIVITY * fusion_temperature_delta * (internal_fusion.heat_capacity() * moderator_internal.heat_capacity() / (internal_fusion.heat_capacity() + moderator_internal.heat_capacity()))
		internal_fusion.temperature = max(internal_fusion.temperature - fusion_heat_amount / internal_fusion.heat_capacity(), TCMB)
		moderator_internal.temperature = max(moderator_internal.temperature + fusion_heat_amount / moderator_internal.heat_capacity(), TCMB)

	if(airs[1].total_moles() * 0.05 > MINIMUM_MOLE_COUNT)
		var/datum/gas_mixture/cooling_port = airs[1]
		var/datum/gas_mixture/cooling_remove = cooling_port.remove(0.05 * cooling_port.total_moles())
		//Cooling of the moderator gases with the cooling loop in and out the core
		if(moderator_internal.total_moles() > 0)
			var/coolant_temperature_delta = cooling_remove.temperature - moderator_internal.temperature
			var/cooling_heat_amount = HIGH_EFFICIENCY_CONDUCTIVITY * coolant_temperature_delta * (cooling_remove.heat_capacity() * moderator_internal.heat_capacity() / (cooling_remove.heat_capacity() + moderator_internal.heat_capacity()))
			cooling_remove.temperature = max(cooling_remove.temperature - cooling_heat_amount / cooling_remove.heat_capacity(), TCMB)
			moderator_internal.temperature = max(moderator_internal.temperature + cooling_heat_amount / moderator_internal.heat_capacity(), TCMB)

		else if(internal_fusion.total_moles() > 0)
			var/coolant_temperature_delta = cooling_remove.temperature - internal_fusion.temperature
			var/cooling_heat_amount = METALLIC_VOID_CONDUCTIVITY * coolant_temperature_delta * (cooling_remove.heat_capacity() * internal_fusion.heat_capacity() / (cooling_remove.heat_capacity() + internal_fusion.heat_capacity()))
			cooling_remove.temperature = max(cooling_remove.temperature - cooling_heat_amount / cooling_remove.heat_capacity(), TCMB)
			internal_fusion.temperature = max(internal_fusion.temperature + cooling_heat_amount / internal_fusion.heat_capacity(), TCMB)
		cooling_port.merge(cooling_remove)

	fusion_temperature = internal_fusion.temperature
	moderator_temperature = moderator_internal.temperature
	coolant_temperature = airs[1].temperature
	output_temperature = linked_output.airs[1].temperature

	//Set the power level of the fusion process
	switch(fusion_temperature)
		if(-INFINITY to 500)
			power_level = 0
		if(500 to 1e3)
			power_level = 1
		if(1e3 to 1e4)
			power_level = 2
		if(1e4 to 1e5)
			power_level = 3
		if(1e5 to 1e6)
			power_level = 4
		if(1e6 to 1e7)
			power_level = 5
		else
			power_level = 6

	//Update pipenets
	update_parents()
	linked_input.update_parents()
	linked_output.update_parents()
	linked_moderator.update_parents()

	//Check and stores the gases from the moderator input in the moderator internal gasmix
	var/datum/gas_mixture/moderator_port = linked_moderator.airs[1]
	if(start_moderator && moderator_port.total_moles())
		moderator_internal.merge(moderator_port.remove(moderator_injection_rate * 0.1))
		linked_moderator.update_parents()

	//Check if the fuels are present and move them inside the fuel internal gasmix
	if(!start_fuel || !selected_fuel || !check_gas_requirements())
		return

	var/datum/gas_mixture/fuel_port = linked_input.airs[1]
	for(var/gas_type in selected_fuel.requirements)
		internal_fusion.assert_gas(gas_type)
		internal_fusion.merge(fuel_port.remove_specific(gas_type, fuel_port.gases[gas_type][MOLES] * fuel_injection_rate * 0.1))
		linked_input.update_parents()

/obj/machinery/atmospherics/components/unary/hypertorus/core/process(delta_time)
	fusion_process(delta_time)
	if(!active)
		return
	if(power_level > 0)
		fusion_started = TRUE
		linked_input.fusion_started = TRUE
		linked_output.fusion_started = TRUE
		linked_moderator.fusion_started = TRUE
		linked_interface.fusion_started = TRUE
		for(var/obj/machinery/hypertorus/corner/corner in corners)
			corner.fusion_started = TRUE
	else
		fusion_started = FALSE
		linked_input.fusion_started = FALSE
		linked_output.fusion_started = FALSE
		linked_moderator.fusion_started = FALSE
		linked_interface.fusion_started = FALSE
		for(var/obj/machinery/hypertorus/corner/corner in corners)
			corner.fusion_started = FALSE

/**
 * Called by process()
 * Contains the main fusion calculations and checks, for more informations check the comments along the code.
 */
/obj/machinery/atmospherics/components/unary/hypertorus/core/proc/fusion_process(delta_time)
//fusion: a terrible idea that was fun but broken. Now reworked to be less broken and more interesting. Again (and again, and again). Again! Again but with machine!
//Fusion Rework Counter: Please increment this if you make a major overhaul to this system again.
//7 reworks
	/*
	 *Pre-checks
	 */
	//first check if the machine is active
	if(!active)
		return

	//then check if the other machines are still there
	if(!check_part_connectivity())
		deactivate()
		return

	if(!selected_fuel)
		return

	if(!check_fuel())
		return

	if(!check_power_use())
		magnetic_constrictor = 100
		heating_conductor = 500
		current_damper = 0
		fuel_injection_rate = 200
		moderator_injection_rate = 500
		waste_remove = FALSE
		iron_content += 0.1 * delta_time

	//Store the temperature of the gases after one cicle of the fusion reaction
	var/archived_heat = internal_fusion.temperature
	//Store the volume of the fusion reaction multiplied by the force of the magnets that controls how big it will be
	var/volume = internal_fusion.volume * (magnetic_constrictor * 0.01)

	//Assert the gases that will be used/created during the process
	for(var/gas_id in selected_fuel.requirements) //These are the fuels
		internal_fusion.assert_gas(gas_id)

	for(var/gas_id in selected_fuel.primary_products) //These are the gases that can be produced inside the internal_fusion mix
		internal_fusion.assert_gas(gas_id)

	internal_fusion.assert_gas(/datum/gas/antinoblium)

	for(var/gas_id in GLOB.meta_gas_info)
		moderator_internal.assert_gas(gas_id)

	//Store the fuel gases and the product gas moles

	var/list/fuel_list = list()
	for(var/gas_id in selected_fuel.requirements)
		fuel_list |= gas_id
		fuel_list[gas_id] = internal_fusion.gases[gas_id][MOLES]

	for(var/gas_id in selected_fuel.primary_products)
		fuel_list |= gas_id
		fuel_list[gas_id] = internal_fusion.gases[gas_id][MOLES]

	//Store the moderators gases moles
	var/list/moderator_list = list()
	for(var/gas_id in moderator_internal.gases)
		moderator_list |= gas_id
		moderator_list[gas_id] = moderator_internal.gases[gas_id][MOLES]

	//We scale it down by volume/2 because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/scale_factor = volume * 0.5

	//Scaled down moles of gases, no less than 0
	var/list/scaled_fuel_list = list()
	for(var/gas_id in selected_fuel.requirements)
		scaled_fuel_list |= gas_id
		scaled_fuel_list[gas_id] = max((fuel_list[gas_id] - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

	for(var/gas_id in selected_fuel.primary_products)
		scaled_fuel_list |= gas_id
		scaled_fuel_list[gas_id] = max((fuel_list[gas_id] - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

	var/list/scaled_moderator_list = list()
	for(var/gas_id in moderator_internal.gases)
		scaled_moderator_list |= gas_id
		scaled_moderator_list[gas_id] = max((moderator_list[gas_id] - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

	/*
	 *FUSION MAIN PROCESS
	 */
	//This section is used for the instability calculation for the fusion reaction
	//The size of the phase space hypertorus
	var/toroidal_size = (2 * PI) + TORADIANS(arctan((volume - TOROID_VOLUME_BREAKEVEN) / TOROID_VOLUME_BREAKEVEN))
	//Calculation of the gas power, only for theoretical instability calculations
	var/gas_power = 0
	for (var/gas_id in internal_fusion.gases)
		gas_power += (internal_fusion.gases[gas_id][GAS_META][META_GAS_FUSION_POWER] * internal_fusion.gases[gas_id][MOLES])
	for (var/gas_id in moderator_internal.gases)
		gas_power += (moderator_internal.gases[gas_id][GAS_META][META_GAS_FUSION_POWER] * moderator_internal.gases[gas_id][MOLES] * 0.75)

	instability = MODULUS((gas_power * INSTABILITY_GAS_POWER_FACTOR)**2, toroidal_size) + (current_damper * 0.01) - iron_content * 0.05
	//Effective reaction instability (determines if the energy is used/released)
	var/internal_instability = 0
	if(instability * 0.5 < FUSION_INSTABILITY_ENDOTHERMALITY)
		internal_instability = 1
	else
		internal_instability = -1

	/*
	 *Modifiers
	 */
	///Those are the scaled gases that gets consumed and releases energy or help increase that energy
	var/positive_modifiers = scaled_fuel_list[scaled_fuel_list[1]] + \
								scaled_fuel_list[scaled_fuel_list[2]] + \
								scaled_moderator_list[/datum/gas/nitrogen] * 0.35 + \
								scaled_moderator_list[/datum/gas/carbon_dioxide] * 0.55 + \
								scaled_moderator_list[/datum/gas/nitrous_oxide] * 0.95 + \
								scaled_moderator_list[/datum/gas/zauker] * 1.55 + \
								scaled_moderator_list[/datum/gas/antinoblium] * 10 - \
								scaled_moderator_list[/datum/gas/hypernoblium] * 10 //Hypernob decreases the amount of energy
	///Those are the scaled gases that gets produced and consumes energy or help decrease that energy
	var/negative_modifiers = scaled_fuel_list[scaled_fuel_list[3]] + \
								scaled_moderator_list[/datum/gas/water_vapor] * 0.75 + \
								scaled_moderator_list[/datum/gas/nitryl] * 0.15 + \
								scaled_moderator_list[/datum/gas/healium] * 0.45 + \
								scaled_moderator_list[/datum/gas/freon] * 1.15 - \
								scaled_moderator_list[/datum/gas/antinoblium] * 10
	///Between 0.25 and 100, this value is used to modify the behaviour of the internal energy and the core temperature based on the gases present in the mix
	var/power_modifier = clamp( scaled_fuel_list[scaled_fuel_list[2]] * 1.05 + \
								scaled_moderator_list[/datum/gas/oxygen] * 0.55 + \
								scaled_moderator_list[/datum/gas/carbon_dioxide] * 0.95 + \
								scaled_moderator_list[/datum/gas/nitryl] * 1.45 + \
								scaled_moderator_list[/datum/gas/zauker] * 5.55 + \
								scaled_moderator_list[/datum/gas/plasma] * 0.05 - \
								scaled_fuel_list[scaled_fuel_list[3]] * 0.55 - \
								scaled_moderator_list[/datum/gas/nitrous_oxide] * 0.05 - \
								scaled_moderator_list[/datum/gas/freon] * 0.75, \
								0.25, 100)
	///Minimum 0.25, this value is used to modify the behaviour of the energy emission based on the gases present in the mix
	var/heat_modifier = clamp( scaled_fuel_list[scaled_fuel_list[1]] * 1.15 + \
								scaled_fuel_list[scaled_fuel_list[3]] * 1.05 + \
								scaled_moderator_list[/datum/gas/plasma] * 1.25 - \
								scaled_moderator_list[/datum/gas/nitrogen] * 0.75 - \
								scaled_moderator_list[/datum/gas/nitrous_oxide] * 1.45 - \
								scaled_moderator_list[/datum/gas/freon] * 0.95, \
								0.25, 100)
	///Between 0.005 and 1000, this value modify the radiation emission of the reaction, higher values increase the emission
	var/radiation_modifier = clamp( scaled_fuel_list[scaled_fuel_list[3]] * 0.55 - \
									scaled_moderator_list[/datum/gas/freon] * 1.15 - \
									scaled_moderator_list[/datum/gas/nitrogen] * 0.45 - \
									scaled_moderator_list[/datum/gas/plasma] * 0.95 + \
									scaled_moderator_list[/datum/gas/bz] * 1.9 + \
									scaled_moderator_list[/datum/gas/proto_nitrate] * 0.1 + \
									scaled_moderator_list[/datum/gas/antinoblium] * 10, \
									0.005, 1000)

	/*
	 *Main calculations (energy, internal power, core temperature, delta temperature,
	 *conduction, radiation, efficiency, power output, heat limiter modifier and heat output)
	 */
	//Can go either positive or negative depending on the instability and the negative_modifiers
	//E=mc^2 with some changes for gameplay purposes
	energy = ((positive_modifiers - negative_modifiers) * LIGHT_SPEED ** 2) * max(internal_fusion.temperature * heat_modifier / 100, 1)
	energy = energy / selected_fuel.energy_concentration_multiplier
	energy = clamp(energy, 0, 1e35) //ugly way to prevent NaN error
	//Power of the gas mixture
	internal_power = (scaled_fuel_list[scaled_fuel_list[1]] * power_modifier / 100) * (scaled_fuel_list[scaled_fuel_list[2]] * power_modifier / 100) * (PI * (2 * (scaled_fuel_list[scaled_fuel_list[1]] * CALCULATED_H2RADIUS) * (scaled_fuel_list[scaled_fuel_list[2]] * CALCULATED_TRITRADIUS))**2) * energy
	//Temperature inside the center of the gas mixture
	core_temperature = internal_power * power_modifier / 1000
	core_temperature = max(TCMB, core_temperature)
	//Difference between the gases temperature and the internal temperature of the reaction
	delta_temperature = archived_heat - core_temperature
	//Energy from the reaction lost from the molecule colliding between themselves.
	conduction = - delta_temperature * (magnetic_constrictor * 0.001)
	//The remaining wavelength that actually can do damage to mobs.
	radiation = max(-(PLANCK_LIGHT_CONSTANT / 5e-18) * radiation_modifier * delta_temperature, 0)
	//Efficiency of the reaction, it increases with the amount of helium
	efficiency = VOID_CONDUCTION * clamp(scaled_fuel_list[scaled_fuel_list[3]], 1, 100)
	power_output = efficiency * (internal_power - conduction - radiation)
	//Hotter air is easier to heat up and cool down
	heat_limiter_modifier = 10 * (10 ** power_level) * (heating_conductor / 100)
	//The amount of heat that is finally emitted, based on the power output. Min and max are variables that depends of the modifier
	heat_output = clamp(internal_instability * power_output * heat_modifier / 100, \
					- heat_limiter_modifier * 0.01 * selected_fuel.negative_temperature_multiplier, \
					heat_limiter_modifier * selected_fuel.positive_temperature_multiplier)

	var/datum/gas_mixture/internal_output = new
	//gas consumption and production
	if(check_fuel())
		var/fuel_consumption_rate = clamp((fuel_injection_rate * 0.001) * 5 * power_level, 0.05, 30) * selected_fuel.gas_production_multiplier
		var/fuel_consumption = fuel_consumption_rate * delta_time

		for(var/gas_id in selected_fuel.requirements)
			internal_fusion.gases[gas_id][MOLES] -= min(fuel_list[gas_id], fuel_consumption * 0.85 * selected_fuel.fuel_consumption_multiplier)
		for(var/gas_id in selected_fuel.primary_products)
			internal_fusion.gases[gas_id][MOLES] += fuel_consumption * 0.5
		//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
		//Also dependant on what is the power level and what moderator gases are present
		if(power_output)
			switch(power_level)
				if(1)
					var/scaled_production = clamp(heat_output * 1e-2, 0, fuel_consumption_rate) * delta_time
					moderator_internal.gases[selected_fuel.secondary_products[1]][MOLES] += scaled_production * 0.95
					moderator_internal.gases[selected_fuel.secondary_products[2]][MOLES] += scaled_production *0.75
					if(moderator_list[/datum/gas/plasma] > 100)
						moderator_internal.gases[/datum/gas/nitrous_oxide] += scaled_production * 0.5
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 0.85)
					if(moderator_list[/datum/gas/bz] > 150)
						internal_output.assert_gases(/datum/gas/halon)
						internal_output.gases[/datum/gas/halon][MOLES] += scaled_production * 0.55
						moderator_internal.gases[/datum/gas/bz][MOLES] -= min(moderator_internal.gases[/datum/gas/bz][MOLES], scaled_production * 0.95)
				if(2)
					var/scaled_production = clamp(heat_output * 1e-3, 0, fuel_consumption_rate) * delta_time
					moderator_internal.gases[selected_fuel.secondary_products[1]][MOLES] += scaled_production * 1.65
					moderator_internal.gases[selected_fuel.secondary_products[2]][MOLES] += scaled_production
					if(moderator_list[/datum/gas/plasma] > 50)
						internal_output.assert_gases(/datum/gas/bz)
						internal_output.gases[/datum/gas/bz][MOLES] += scaled_production * 1.8
						moderator_internal.gases[selected_fuel.secondary_products[3]] += scaled_production * 1.15
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 1.75)
					if(moderator_list[/datum/gas/proto_nitrate] > 20)
						radiation *= 1.55
						heat_output *= 1.025
						internal_output.assert_gases(/datum/gas/stimulum)
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.05
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 1.35)
				if(3, 4)
					var/scaled_production = clamp(heat_output * 5e-4, 0, fuel_consumption_rate) * delta_time
					if(power_level == 3)
						moderator_internal.gases[selected_fuel.secondary_products[2]][MOLES] += scaled_production * 0.5
						moderator_internal.gases[selected_fuel.secondary_products[3]][MOLES] += scaled_production * 0.45
					if(power_level == 4)
						moderator_internal.gases[selected_fuel.secondary_products[3]][MOLES] += scaled_production * 1.65
						moderator_internal.gases[selected_fuel.secondary_products[4]][MOLES] += scaled_production * 1.25
					if(moderator_list[/datum/gas/plasma] > 10)
						internal_output.assert_gases(/datum/gas/freon, /datum/gas/stimulum)
						internal_output.gases[/datum/gas/freon][MOLES] += scaled_production * 0.15
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.05
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 0.45)
					if(moderator_list[/datum/gas/freon] > 50)
						heat_output *= 0.9
						radiation *= 0.8
					if(moderator_list[/datum/gas/proto_nitrate]> 15)
						internal_output.assert_gases(/datum/gas/stimulum, /datum/gas/halon)
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.25
						internal_output.gases[/datum/gas/halon][MOLES] += scaled_production * 1.15
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 1.55)
						radiation *= 1.95
						heat_output *= 1.25
					if(moderator_list[/datum/gas/bz] > 100)
						internal_output.assert_gases(/datum/gas/healium, /datum/gas/proto_nitrate)
						internal_output.gases[/datum/gas/proto_nitrate][MOLES] += scaled_production * 1.5
						internal_output.gases[/datum/gas/healium][MOLES] += scaled_production * 1.5
						for(var/mob/living/carbon/human/l in view(src, HALLUCINATION_HFR(heat_output))) // If they can see it without mesons on.  Bad on them.
							if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
								var/D = sqrt(1 / max(1, get_dist(l, src)))
								l.hallucination += power_level * 50 * D * delta_time
								l.hallucination = clamp(l.hallucination, 0, 200)
				if(5)
					var/scaled_production = clamp(heat_output * 1e-6, 0, fuel_consumption_rate) * delta_time
					moderator_internal.gases[selected_fuel.secondary_products[4]][MOLES] += scaled_production * 0.65
					moderator_internal.gases[selected_fuel.secondary_products[5]][MOLES] += scaled_production
					moderator_internal.gases[selected_fuel.secondary_products[6]][MOLES] += scaled_production * 0.75
					if(moderator_list[/datum/gas/plasma] > 15)
						internal_output.assert_gases(/datum/gas/freon)
						internal_output.gases[/datum/gas/freon][MOLES] += scaled_production *0.25
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 1.45)
					if(moderator_list[/datum/gas/freon] > 500)
						heat_output *= 0.5
						radiation *= 0.2
					if(moderator_list[/datum/gas/proto_nitrate] > 50)
						internal_output.assert_gases(/datum/gas/stimulum, /datum/gas/pluoxium)
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.95
						internal_output.gases[/datum/gas/pluoxium][MOLES] += scaled_production
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 1.35)
						radiation *= 1.95
						heat_output *= 1.25
					if(moderator_list[/datum/gas/bz] > 100)
						internal_output.assert_gases(/datum/gas/healium)
						internal_output.gases[/datum/gas/healium][MOLES] += scaled_production
						for(var/mob/living/carbon/human/l in view(src, HALLUCINATION_HFR(heat_output))) // If they can see it without mesons on.  Bad on them.
							if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
								var/D = sqrt(1 / max(1, get_dist(l, src)))
								l.hallucination += power_level * 100 * D
								l.hallucination = clamp(l.hallucination, 0, 200)
						moderator_internal.gases[/datum/gas/freon][MOLES] += scaled_production * 1.15
					if(moderator_list[/datum/gas/healium] > 100)
						if(critical_threshold_proximity > 400)
							critical_threshold_proximity = max(critical_threshold_proximity - (moderator_list[/datum/gas/healium] / 100 * delta_time ), 0)
							moderator_internal.gases[/datum/gas/healium][MOLES] -= min(moderator_internal.gases[/datum/gas/healium][MOLES], scaled_production * 20)
					if(moderator_internal.temperature < 1e7 || (moderator_list[/datum/gas/plasma] > 100 && moderator_list[/datum/gas/bz] > 50))
						internal_output.assert_gases(/datum/gas/antinoblium)
						internal_output.gases[/datum/gas/antinoblium][MOLES] += 0.9 * (scaled_fuel_list[scaled_fuel_list[3]] / (fuel_injection_rate * 0.0065)) * delta_time
				if(6)
					var/scaled_production = clamp(heat_output * 1e-7, 0, fuel_consumption_rate) * delta_time
					moderator_internal.gases[selected_fuel.secondary_products[5]][MOLES] += scaled_production * 0.35
					moderator_internal.gases[selected_fuel.secondary_products[6]][MOLES] += scaled_production
					if(moderator_list[/datum/gas/plasma] > 30)
						moderator_internal.gases[/datum/gas/bz][MOLES] += scaled_production * 1.15
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 1.45)
					if(moderator_list[/datum/gas/proto_nitrate])
						internal_output.assert_gases(/datum/gas/zauker, /datum/gas/stimulum)
						internal_output.gases[/datum/gas/zauker][MOLES] += scaled_production * 5.35
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 2.15
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 3.35)
						radiation *= 2
						heat_output *= 2.25
					if(moderator_list[/datum/gas/bz])
						for(var/mob/living/carbon/human/human in view(src, HALLUCINATION_HFR(heat_output)))
							//mesons won't protect you at fusion level 6
							var/distance_root = sqrt(1 / max(1, get_dist(human, src)))
							human.hallucination += power_level * 150 * distance_root
							human.hallucination = clamp(human.hallucination, 0, 200)
						moderator_internal.gases[/datum/gas/antinoblium][MOLES] += clamp((scaled_fuel_list[scaled_fuel_list[3]] / (fuel_injection_rate * 0.0045)), 0, 10) * delta_time
					if(moderator_list[/datum/gas/healium] > 100)
						if(critical_threshold_proximity > 400)
							critical_threshold_proximity = max(critical_threshold_proximity - (moderator_list[/datum/gas/healium] / 100 * delta_time ), 0)
							moderator_internal.gases[/datum/gas/healium][MOLES] -= min(moderator_internal.gases[/datum/gas/healium][MOLES], scaled_production * 20)
					internal_fusion.gases[/datum/gas/antinoblium][MOLES] += 0.01 * (scaled_fuel_list[scaled_fuel_list[3]] / (fuel_injection_rate * 0.0095)) * delta_time

	//Modifies the internal_fusion temperature with the amount of heat output
	var/temperature_modifier = selected_fuel.temperature_change_multiplier
	if(internal_fusion.temperature <= FUSION_MAXIMUM_TEMPERATURE * temperature_modifier)
		internal_fusion.temperature = clamp(internal_fusion.temperature + heat_output,TCMB,FUSION_MAXIMUM_TEMPERATURE * temperature_modifier)
	else
		internal_fusion.temperature -= heat_limiter_modifier * 0.01 * delta_time

	//heat up and output what's in the internal_output into the linked_output port
	if(internal_output.total_moles() > 0)
		if(moderator_internal.total_moles() > 0)
			internal_output.temperature = moderator_internal.temperature * HIGH_EFFICIENCY_CONDUCTIVITY
		else
			internal_output.temperature = internal_fusion.temperature * METALLIC_VOID_CONDUCTIVITY
		linked_output.airs[1].merge(internal_output)

	//High power fusion might create other matter other than helium, iron is dangerous inside the machine, damage can be seen
	if(moderator_internal.total_moles() > 0)
		moderator_internal.remove(moderator_internal.total_moles() * (1 - (1 - 0.0005 * power_level) ** delta_time))
	if(power_level > 4 && prob(IRON_CHANCE_PER_FUSION_LEVEL * power_level))//at power level 6 is 100%
		iron_content += IRON_ACCUMULATED_PER_SECOND * delta_time
	if(iron_content > 0 && power_level <= 4 && prob(25 / (power_level + 1)))
		iron_content = max(iron_content - 0.01 * delta_time, 0)
	iron_content = clamp(iron_content, 0, 1)

	if(power_level >= 4)
		if(moderator_list[/datum/gas/bz] > (150 / power_level))
			var/obj/machinery/hypertorus/corner/picked_corner = pick(corners)
			picked_corner.loc.fire_nuclear_particle(turn(picked_corner.dir, 180))

		if(moderator_list[/datum/gas/antinoblium] > 50 || critical_threshold_proximity > 500)
			var/zap_number = power_level - 2

			if(critical_threshold_proximity > 650 && prob(20))
				zap_number += 1

			var/cutoff = 1500
			cutoff = clamp(3000 - (power_level * (internal_fusion.total_moles() * 0.45)), 450, 3000)

			var/zaps_aspect = DEFAULT_ZAP_ICON_STATE
			var/flags = ZAP_SUPERMATTER_FLAGS
			switch(power_level)
				if(5)
					zaps_aspect = SLIGHTLY_CHARGED_ZAP_ICON_STATE
					flags |= (ZAP_MOB_DAMAGE)
				if(6)
					zaps_aspect = OVER_9000_ZAP_ICON_STATE
					flags |= (ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE)

			playsound(loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
			for(var/i in 1 to zap_number)
				supermatter_zap(src, 5, power_level * 300, flags, zap_cutoff = cutoff, power_level = src.power_level * 1000, zap_icon = zaps_aspect)

	if(moderator_list[/datum/gas/oxygen] > 150)
		if(iron_content > 0)
			var/max_iron_removable = IRON_OXYGEN_HEAL_PER_SECOND
			var/iron_removed = min(max_iron_removable * delta_time, iron_content)
			iron_content -= iron_removed
			moderator_internal.gases[/datum/gas/oxygen] -= iron_removed * OXYGEN_MOLES_CONSUMED_PER_IRON_HEAL

	if(prob(critical_threshold_proximity / 15))
		var/grav_range = round(log(2.5, critical_threshold_proximity))
		for(var/mob/alive_mob in GLOB.alive_mob_list)
			if(alive_mob.z != z || get_dist(alive_mob, src) > grav_range || alive_mob.mob_negates_gravity())
				continue
			step_towards(alive_mob, loc)

	//Gases can be removed from the moderator internal by using the interface.
	if(waste_remove)
		var/filtering_amount = moderator_scrubbing.len
		for(var/gas in moderator_internal.gases & moderator_scrubbing)
			var/datum/gas_mixture/removed = moderator_internal.remove_specific(gas, (moderator_filtering_rate / filtering_amount) * delta_time)
			if(removed)
				linked_output.airs[1].merge(removed)

		var/datum/gas_mixture/internal_remove
		for(var/gas_id in selected_fuel.primary_products)
			if(internal_fusion.gases[gas_id][MOLES] > 0)
				internal_remove = internal_fusion.remove_specific(gas_id, internal_fusion.gases[gas_id][MOLES] * (1 - (1 - 0.25) ** delta_time))
				linked_output.airs[1].merge(internal_remove)
		internal_fusion.garbage_collect()
		moderator_internal.garbage_collect()


	//Update pipenets
	update_parents()
	linked_input.update_parents()
	linked_output.update_parents()
	linked_moderator.update_parents()

	//better heat and rads emission
	//To do
	if(power_output)
		var/particle_chance = max(((PARTICLE_CHANCE_CONSTANT)/(power_output-PARTICLE_CHANCE_CONSTANT)) + 1, 0)//Asymptopically approaches 100% as the energy of the reaction goes up.
		if(prob(PERCENT(particle_chance)))
			var/obj/machinery/hypertorus/corner/picked_corner = pick(corners)
			picked_corner.loc.fire_nuclear_particle()
		rad_power = clamp((radiation / 1e5), 0, FUSION_RAD_MAX)
		radiation_pulse(loc, rad_power)
