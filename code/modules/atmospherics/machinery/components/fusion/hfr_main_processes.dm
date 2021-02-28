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
	if(power_level >= 5)
		critical_threshold_proximity = max(critical_threshold_proximity + max((round((internal_fusion.total_moles() * 1e5 + internal_fusion.temperature) / 1e5, 1) - 2500) / 200, 0), 0)

		critical_threshold_proximity = max(critical_threshold_proximity + max(log(10, internal_fusion.temperature) - 5, 0), 0)

	if(internal_fusion.total_moles() < 1200 || power_level <= 4)
		critical_threshold_proximity = max(critical_threshold_proximity + min((internal_fusion.total_moles() - 800) / 150, 0), 0)

	if(internal_fusion.total_moles() > 0 && internal_fusion.temperature < 5e5 && power_level <= 4)
		critical_threshold_proximity = max(critical_threshold_proximity + min(log(10, internal_fusion.temperature) - 5.5, 0), 0)

	critical_threshold_proximity += max(round(iron_content, 1) - 1, 0)

	critical_threshold_proximity = min(critical_threshold_proximity_archived + (DAMAGE_CAP_MULTIPLIER * melting_point), critical_threshold_proximity)

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

	if(!start_fuel)
		return

	//Start by storing the gasmix of the inputs inside the internal_fusion and moderator_internal
	if(!linked_input.airs[1].total_moles())
		return
	var/datum/gas_mixture/buffer
	if(linked_input.airs[1].gases[/datum/gas/hydrogen][MOLES] > 0)
		buffer = linked_input.airs[1].remove_specific(/datum/gas/hydrogen, fuel_injection_rate * 0.1)
		internal_fusion.merge(buffer)
	if(linked_input.airs[1].gases[/datum/gas/tritium][MOLES] > 0)
		buffer = linked_input.airs[1].remove_specific(/datum/gas/tritium, fuel_injection_rate * 0.1)
		internal_fusion.merge(buffer)
	buffer = linked_moderator.airs[1].remove(moderator_injection_rate * 0.1)
	moderator_internal.merge(buffer)

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
	internal_fusion.assert_gases(/datum/gas/helium, /datum/gas/antinoblium)
	moderator_internal.assert_gases(/datum/gas/plasma,
									/datum/gas/nitrogen,
									/datum/gas/oxygen,
									/datum/gas/carbon_dioxide,
									/datum/gas/water_vapor,
									/datum/gas/nitrous_oxide,
									/datum/gas/nitryl,
									/datum/gas/freon,
									/datum/gas/bz,
									/datum/gas/proto_nitrate,
									/datum/gas/healium,
									/datum/gas/zauker,
									/datum/gas/hypernoblium,
									/datum/gas/antinoblium
									)

	//Store the fuel gases and the product gas moles
	tritium = internal_fusion.gases[/datum/gas/tritium][MOLES]
	hydrogen = internal_fusion.gases[/datum/gas/hydrogen][MOLES]
	helium = internal_fusion.gases[/datum/gas/helium][MOLES]

	//Store the moderators gases moles
	m_plasma = moderator_internal.gases[/datum/gas/plasma][MOLES]
	m_nitrogen = moderator_internal.gases[/datum/gas/nitrogen][MOLES]
	m_oxygen = moderator_internal.gases[/datum/gas/oxygen][MOLES]
	m_co2 = moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES]
	m_h2o = moderator_internal.gases[/datum/gas/water_vapor][MOLES]
	m_n2o = moderator_internal.gases[/datum/gas/nitrous_oxide][MOLES]
	m_no2 = moderator_internal.gases[/datum/gas/nitryl][MOLES]
	m_freon = moderator_internal.gases[/datum/gas/freon][MOLES]
	m_bz = moderator_internal.gases[/datum/gas/bz][MOLES]
	m_proto_nitrate = moderator_internal.gases[/datum/gas/proto_nitrate][MOLES]
	m_healium = moderator_internal.gases[/datum/gas/healium][MOLES]
	m_zauker = moderator_internal.gases[/datum/gas/zauker][MOLES]
	m_antinoblium = moderator_internal.gases[/datum/gas/antinoblium][MOLES]
	m_hypernoblium = moderator_internal.gases[/datum/gas/hypernoblium][MOLES]

	//We scale it down by volume/2 because for fusion conditions, moles roughly = 2*volume, but we want it to be based off something constant between reactions.
	var/scale_factor = volume * 0.5

	//Scaled down moles of gases, no less than 0
	var/scaled_tritium = max((tritium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_hydrogen = max((hydrogen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_helium = max((helium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

	var/scaled_m_plasma = max((m_plasma - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_nitrogen = max((m_nitrogen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_oxygen = max((m_oxygen - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_co2 = max((m_co2 - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_h2o = max((m_h2o - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_n2o = max((m_n2o - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_no2 = max((m_no2 - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_freon = max((m_freon - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_bz = max((m_bz - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_proto_nitrate = max((m_proto_nitrate - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_healium = max((m_healium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_zauker = max((m_zauker - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_antinoblium = max((m_antinoblium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)
	var/scaled_m_hypernoblium = max((m_hypernoblium - FUSION_MOLE_THRESHOLD) / scale_factor, 0)

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
	var/positive_modifiers = scaled_hydrogen + \
								scaled_tritium + \
								scaled_m_nitrogen * 0.35 + \
								scaled_m_co2 * 0.55 + \
								scaled_m_n2o * 0.95 + \
								scaled_m_zauker * 1.55 + \
								scaled_m_antinoblium * 10 - \
								scaled_m_hypernoblium * 10 //Hypernob decreases the amount of energy
	///Those are the scaled gases that gets produced and consumes energy or help decrease that energy
	var/negative_modifiers = scaled_helium + \
								scaled_m_h2o * 0.75 + \
								scaled_m_no2 * 0.15 + \
								scaled_m_healium * 0.45 + \
								scaled_m_freon * 1.15 - \
								scaled_m_antinoblium * 10
	///Between 0.25 and 100, this value is used to modify the behaviour of the internal energy and the core temperature based on the gases present in the mix
	var/power_modifier = clamp( scaled_tritium * 1.05 + \
								scaled_m_oxygen * 0.55 + \
								scaled_m_co2 * 0.95 + \
								scaled_m_no2 * 1.45 + \
								scaled_m_zauker * 5.55 + \
								scaled_m_plasma * 0.05 - \
								scaled_helium * 0.55 - \
								scaled_m_n2o * 0.05 - \
								scaled_m_freon * 0.75, \
								0.25, 100)
	///Minimum 0.25, this value is used to modify the behaviour of the energy emission based on the gases present in the mix
	var/heat_modifier = clamp( scaled_hydrogen * 1.15 + \
								scaled_helium * 1.05 + \
								scaled_m_plasma * 1.25 - \
								scaled_m_nitrogen * 0.75 - \
								scaled_m_n2o * 1.45 - \
								scaled_m_freon * 0.95, \
								0.25, 100)
	///Between 0.005 and 1000, this value modify the radiation emission of the reaction, higher values increase the emission
	var/radiation_modifier = clamp( scaled_helium * 0.55 - \
									scaled_m_freon * 1.15 - \
									scaled_m_nitrogen * 0.45 - \
									scaled_m_plasma * 0.95 + \
									scaled_m_bz * 1.9 + \
									scaled_m_proto_nitrate * 0.1 + \
									scaled_m_antinoblium * 10, \
									0.005, 1000)

	/*
	 *Main calculations (energy, internal power, core temperature, delta temperature,
	 *conduction, radiation, efficiency, power output, heat limiter modifier and heat output)
	 */
	//Can go either positive or negative depending on the instability and the negative_modifiers
	//E=mc^2 with some changes for gameplay purposes
	energy = ((positive_modifiers - negative_modifiers) * LIGHT_SPEED ** 2) * max(internal_fusion.temperature * heat_modifier / 100, 1)
	energy = clamp(energy, 0, 1e35) //ugly way to prevent NaN error
	//Power of the gas mixture
	internal_power = (scaled_hydrogen * power_modifier / 100) * (scaled_tritium * power_modifier / 100) * (PI * (2 * (scaled_hydrogen * CALCULATED_H2RADIUS) * (scaled_tritium * CALCULATED_TRITRADIUS))**2) * energy
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
	efficiency = VOID_CONDUCTION * clamp(scaled_helium, 1, 100)
	power_output = efficiency * (internal_power - conduction - radiation)
	//Hotter air is easier to heat up and cool down
	heat_limiter_modifier = 10 * (10 ** power_level) * (heating_conductor / 100)
	//The amount of heat that is finally emitted, based on the power output. Min and max are variables that depends of the modifier
	heat_output = clamp(internal_instability * power_output * heat_modifier / 100, - heat_limiter_modifier * 0.01, heat_limiter_modifier)

	var/datum/gas_mixture/internal_output = new
	//gas consumption and production
	if(check_fuel())
		var/fuel_consumption_rate = clamp((fuel_injection_rate * 0.001) * 5 * power_level, 0.05, 30)
		var/fuel_consumption = fuel_consumption_rate * delta_time
		internal_fusion.gases[/datum/gas/tritium][MOLES] -= min(tritium, fuel_consumption * 0.85)
		internal_fusion.gases[/datum/gas/hydrogen][MOLES] -= min(hydrogen, fuel_consumption * 0.95)
		internal_fusion.gases[/datum/gas/helium][MOLES] += fuel_consumption * 0.5
		//The decay of the tritium and the reaction's energy produces waste gases, different ones depending on whether the reaction is endo or exothermic
		//Also dependant on what is the power level and what moderator gases are present
		if(power_output)
			switch(power_level)
				if(1)
					var/scaled_production = clamp(heat_output * 1e-2, 0, fuel_consumption_rate) * delta_time
					moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += scaled_production * 0.95
					moderator_internal.gases[/datum/gas/water_vapor][MOLES] += scaled_production *0.75
					if(m_plasma > 100)
						moderator_internal.gases[/datum/gas/nitrous_oxide] += scaled_production * 0.5
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 0.85)
					if(m_bz > 150)
						internal_output.assert_gases(/datum/gas/healium, /datum/gas/halon, /datum/gas/proto_nitrate)
						internal_output.gases[/datum/gas/healium][MOLES] += scaled_production * 0.75
						internal_output.gases[/datum/gas/halon][MOLES] += scaled_production * 0.55
						internal_output.gases[/datum/gas/proto_nitrate][MOLES] += scaled_production * 0.25
						moderator_internal.gases[/datum/gas/bz][MOLES] -= min(moderator_internal.gases[/datum/gas/bz][MOLES], scaled_production * 0.95)
				if(2)
					var/scaled_production = clamp(heat_output * 1e-3, 0, fuel_consumption_rate) * delta_time
					moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += scaled_production * 1.65
					moderator_internal.gases[/datum/gas/water_vapor][MOLES] += scaled_production
					if(m_plasma > 50)
						internal_output.assert_gases(/datum/gas/bz)
						internal_output.gases[/datum/gas/bz][MOLES] += scaled_production * 1.8
						moderator_internal.gases[/datum/gas/nitrous_oxide] += scaled_production * 1.15
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 1.75)
					if(m_proto_nitrate > 20)
						radiation *= 1.55
						heat_output *= 1.025
						internal_output.assert_gases(/datum/gas/stimulum)
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.05
						moderator_internal.gases[/datum/gas/plasma][MOLES] += scaled_production * 1.65
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 1.35)
					if(m_n2o > 50)
						radiation *= 0.55
						heat_output *= 1.055
						moderator_internal.gases[/datum/gas/halon] += scaled_production * 1.35
						moderator_internal.gases[/datum/gas/nitrous_oxide][MOLES] -= min(moderator_internal.gases[/datum/gas/nitrous_oxide][MOLES], scaled_production * 1.5)
				if(3, 4)
					var/scaled_production = clamp(heat_output * 5e-4, 0, fuel_consumption_rate) * delta_time
					if(power_level == 3)
						moderator_internal.gases[/datum/gas/oxygen][MOLES] += scaled_production * 0.5
						moderator_internal.gases[/datum/gas/nitrogen][MOLES] += scaled_production * 0.45
					if(power_level == 4)
						moderator_internal.gases[/datum/gas/carbon_dioxide][MOLES] += scaled_production * 1.65
						moderator_internal.gases[/datum/gas/water_vapor][MOLES] += scaled_production * 1.25
					if(m_plasma > 10)
						moderator_internal.gases[/datum/gas/bz][MOLES] += scaled_production * 1.1
						internal_output.assert_gases(/datum/gas/freon, /datum/gas/stimulum)
						internal_output.gases[/datum/gas/freon][MOLES] += scaled_production * 0.15
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.05
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 0.45)
					if(m_freon > 50)
						heat_output *= 0.9
						radiation *= 0.8
					if(m_proto_nitrate> 15)
						internal_output.assert_gases(/datum/gas/stimulum, /datum/gas/halon)
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.25
						internal_output.gases[/datum/gas/halon][MOLES] += scaled_production * 1.15
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 1.55)
						radiation *= 1.95
						heat_output *= 1.25
					if(m_bz > 100)
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
					moderator_internal.gases[/datum/gas/nitryl][MOLES] += scaled_production * 1.65
					moderator_internal.gases[/datum/gas/water_vapor][MOLES] += scaled_production
					if(m_plasma > 15)
						moderator_internal.gases[/datum/gas/bz][MOLES] += scaled_production * 1.35
						internal_output.assert_gases(/datum/gas/freon)
						internal_output.gases[/datum/gas/freon][MOLES] += scaled_production *0.25
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 1.45)
					if(m_freon > 500)
						heat_output *= 0.5
						radiation *= 0.2
					if(m_proto_nitrate > 50)
						internal_output.assert_gases(/datum/gas/stimulum, /datum/gas/pluoxium)
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 1.95
						internal_output.gases[/datum/gas/pluoxium][MOLES] += scaled_production
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 1.35)
						radiation *= 1.95
						heat_output *= 1.25
					if(m_bz > 100)
						internal_output.assert_gases(/datum/gas/healium)
						internal_output.gases[/datum/gas/healium][MOLES] += scaled_production
						for(var/mob/living/carbon/human/l in view(src, HALLUCINATION_HFR(heat_output))) // If they can see it without mesons on.  Bad on them.
							if(!istype(l.glasses, /obj/item/clothing/glasses/meson))
								var/D = sqrt(1 / max(1, get_dist(l, src)))
								l.hallucination += power_level * 100 * D
								l.hallucination = clamp(l.hallucination, 0, 200)
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] += scaled_production * 1.25
						moderator_internal.gases[/datum/gas/freon][MOLES] += scaled_production * 1.15
					if(m_healium > 100)
						if(critical_threshold_proximity > 400)
							critical_threshold_proximity = max(critical_threshold_proximity - (m_healium / 100 * delta_time ), 0)
							moderator_internal.gases[/datum/gas/healium][MOLES] -= min(moderator_internal.gases[/datum/gas/healium][MOLES], scaled_production * 20)
					if(moderator_internal.temperature < 1e7 || (m_plasma > 100 && m_bz > 50))
						internal_output.assert_gases(/datum/gas/antinoblium)
						internal_output.gases[/datum/gas/antinoblium][MOLES] += 0.1 * (scaled_helium / (fuel_injection_rate * 0.0065)) * delta_time
				if(6)
					var/scaled_production = clamp(heat_output * 1e-7, 0, fuel_consumption_rate) * delta_time
					if(m_plasma > 30)
						moderator_internal.gases[/datum/gas/bz][MOLES] += scaled_production * 1.15
						moderator_internal.gases[/datum/gas/plasma][MOLES] -= min(moderator_internal.gases[/datum/gas/plasma][MOLES], scaled_production * 1.45)
					if(m_proto_nitrate)
						internal_output.assert_gases(/datum/gas/zauker, /datum/gas/stimulum)
						internal_output.gases[/datum/gas/zauker][MOLES] += scaled_production * 5.35
						internal_output.gases[/datum/gas/stimulum][MOLES] += scaled_production * 2.15
						moderator_internal.gases[/datum/gas/proto_nitrate][MOLES] -= min(moderator_internal.gases[/datum/gas/proto_nitrate][MOLES], scaled_production * 3.35)
						radiation *= 2
						heat_output *= 2.25
					if(m_bz)
						for(var/mob/living/carbon/human/human in view(src, HALLUCINATION_HFR(heat_output)))
							//mesons won't protect you at fusion level 6
							var/distance_root = sqrt(1 / max(1, get_dist(human, src)))
							human.hallucination += power_level * 150 * distance_root
							human.hallucination = clamp(human.hallucination, 0, 200)
						moderator_internal.gases[/datum/gas/antinoblium][MOLES] += clamp((scaled_helium / (fuel_injection_rate * 0.0045)), 0, 10) * delta_time
					if(m_healium > 100)
						if(critical_threshold_proximity > 400)
							critical_threshold_proximity = max(critical_threshold_proximity - (m_healium / 100 * delta_time ), 0)
							moderator_internal.gases[/datum/gas/healium][MOLES] -= min(moderator_internal.gases[/datum/gas/healium][MOLES], scaled_production * 20)
					internal_fusion.gases[/datum/gas/antinoblium][MOLES] += 0.01 * (scaled_helium / (fuel_injection_rate * 0.0095)) * delta_time

	//Modifies the internal_fusion temperature with the amount of heat output
	if(internal_fusion.temperature <= FUSION_MAXIMUM_TEMPERATURE)
		internal_fusion.temperature = clamp(internal_fusion.temperature + heat_output,TCMB,FUSION_MAXIMUM_TEMPERATURE)
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
	if(power_level > 4 && prob(17 * power_level))//at power level 6 is 100%
		iron_content += 0.005 * delta_time
	if(iron_content > 0 && power_level <= 4 && prob(25 / (power_level + 1)))
		iron_content = max(iron_content - 0.01 * delta_time, 0)

	//Gases can be removed from the moderator internal by using the interface. Helium and antinoblium inside the fusion mix will get always removed at a fixed rate
	if(waste_remove && power_level <= 5)
		var/filtering = TRUE
		if(!ispath(filter_type))
			if(filter_type)
				filter_type = gas_id2path(filter_type)
			else
				filtering = FALSE
		if(filtering && moderator_internal.gases[filter_type])
			var/datum/gas_mixture/removed = moderator_internal.remove_specific(filter_type, 20 * delta_time)
			if(removed)
				linked_output.airs[1].merge(removed)

		var/datum/gas_mixture/internal_remove
		if(internal_fusion.gases[/datum/gas/helium][MOLES] > 0)
			internal_remove = internal_fusion.remove_specific(/datum/gas/helium, internal_fusion.gases[/datum/gas/helium][MOLES] * (1 - (1 - 0.5) ** delta_time))
			linked_output.airs[1].merge(internal_remove)
		if(internal_fusion.gases[/datum/gas/antinoblium][MOLES] > 0)
			internal_remove = internal_fusion.remove_specific(/datum/gas/antinoblium, internal_fusion.gases[/datum/gas/antinoblium][MOLES] * (1 - (1 - 0.05) ** delta_time))
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
