/proc/init_sm_gas()
	var/list/gas_list = list()
	for (var/sm_gas_path in subtypesof(/datum/sm_gas))
		var/datum/sm_gas/sm_gas = new sm_gas_path
		gas_list[sm_gas.gas_path] = sm_gas
	return gas_list

/// Assoc of sm_gas_behavior[/datum/gas (path)] = datum/sm_gas (instance)
GLOBAL_LIST_INIT(sm_gas_behavior, init_sm_gas())

/// Contains effects of gases when absorbed by the sm.
/datum/sm_gas
	/// Path of the [/datum/gas] involved with this interaction.
	var/gas_path

	/// Influences zap power without interfering with the crystal's own energy.
	var/transmit_modifier = 0
	/// How much more waste heat and gas the SM generates.
	var/heat_penalty = 0
	/// How extra hot the SM can run before taking damage
	var/heat_resistance = 0
	/// Lets the sm generate extra power from heat. Yeah...
	var/powermix = 0
	/// How much powerloss do we get rid of.
	var/powerloss_inhibition = 0

/datum/sm_gas/proc/extra_effects(obj/machinery/power/supermatter_crystal/sm, datum/gas_mixture/env)
	return

/datum/sm_gas/oxygen
	gas_path = /datum/gas/oxygen
	heat_penalty = 1
	transmit_modifier = 1.5
	powermix = 1

/datum/sm_gas/nitrogen
	gas_path = /datum/gas/nitrogen
	heat_penalty = -1.5
	powermix = -1

/datum/sm_gas/carbon_dioxide
	gas_path = /datum/gas/carbon_dioxide
	heat_penalty = 2
	powermix = 1
	powerloss_inhibition = 1

/// Can be on Oxygen or CO2, but better lump it here since CO2 is rarer.
/datum/sm_gas/carbon_dioxide/extra_effects(obj/machinery/power/supermatter_crystal/sm, datum/gas_mixture/env)
	if(!(sm.gas_percentage[/datum/gas/carbon_dioxide] && sm.gas_percentage[/datum/gas/oxygen]))
		return
	var/co2_pp = env.return_pressure() * sm.gas_percentage[/datum/gas/carbon_dioxide]
	/// Our consumption ratio, not the actual ratio in SM we already have that.
	/// This var is a fucking lie, we only consume half of it.
	var/co2_ratio = (co2_pp - CO2_CONSUMPTION_PP) / (co2_pp + CO2_PRESSURE_SCALING)
	co2_ratio = clamp(co2_ratio, 0, 1)
	var/consumed_co2 = sm.absorbed_gasmix.gases[/datum/gas/carbon_dioxide][MOLES] * co2_ratio
	consumed_co2 = min(
		consumed_co2,
		sm.absorbed_gasmix.gases[/datum/gas/carbon_dioxide][MOLES] * INVERSE(0.5), 
		sm.absorbed_gasmix.gases[/datum/gas/oxygen][MOLES] * INVERSE(0.5)
	)
	if(!consumed_co2)
		return
	sm.absorbed_gasmix.gases[/datum/gas/carbon_dioxide][MOLES] -= consumed_co2 * 0.5
	sm.absorbed_gasmix.gases[/datum/gas/oxygen][MOLES] -= consumed_co2 * 0.5
	ASSERT_GAS(/datum/gas/pluoxium, sm.absorbed_gasmix)
	sm.absorbed_gasmix.gases[/datum/gas/pluoxium][MOLES] += consumed_co2 * 0.25

/datum/sm_gas/plasma
	gas_path = /datum/gas/plasma
	heat_penalty = 15
	transmit_modifier = 4
	powermix = 1

/datum/sm_gas/water_vapor
	gas_path = /datum/gas/water_vapor
	heat_penalty = 12
	transmit_modifier = -2.5
	powermix = 1

/datum/sm_gas/hypernoblium
	gas_path = /datum/gas/hypernoblium
	heat_penalty = -13
	transmit_modifier = 3
	powermix = -1

/datum/sm_gas/nitrous_oxide
	gas_path = /datum/gas/nitrous_oxide
	heat_resistance = 6

/datum/sm_gas/nitrium
	gas_path = /datum/gas/nitrium

/datum/sm_gas/tritium
	gas_path = /datum/gas/tritium
	heat_penalty = 10
	transmit_modifier = 30
	powermix = 1

/datum/sm_gas/bz
	gas_path = /datum/gas/bz
	heat_penalty = 5
	transmit_modifier = -2
	powermix = 1

/// Start to emit radballs at a maximum of 30% chance per tick
/datum/sm_gas/bz/extra_effects(obj/machinery/power/supermatter_crystal/sm, datum/gas_mixture/env)
	if(sm.gas_percentage[/datum/gas/bz] >= 0.4 && prob(30 * sm.gas_percentage[/datum/gas/bz]))
		sm.fire_nuclear_particle()

/datum/sm_gas/pluoxium
	gas_path = /datum/gas/pluoxium
	heat_penalty = -0.5
	transmit_modifier = -5
	powermix = 1

/datum/sm_gas/miasma
	gas_path = /datum/gas/miasma
	powermix = 0.5

///Miasma is really just microscopic particulate. It gets consumed like anything else that touches the crystal.
/datum/sm_gas/miasma/extra_effects(obj/machinery/power/supermatter_crystal/sm, datum/gas_mixture/env)
	if(!sm.gas_percentage[/datum/gas/miasma])
		return
	var/miasma_pp = env.return_pressure() * sm.gas_percentage[/datum/gas/miasma]
	/// Our consumption ratio, not the actual ratio in SM we already have that.
	var/miasma_ratio = ((miasma_pp - MIASMA_CONSUMPTION_PP) / (miasma_pp + MIASMA_PRESSURE_SCALING)) * (1 + (sm.gasmix_power_ratio * MIASMA_GASMIX_SCALING))
	miasma_ratio = clamp(miasma_ratio, 0, 1)
	var/consumed_miasma = sm.absorbed_gasmix.gases[/datum/gas/miasma][MOLES] * miasma_ratio
	if(!consumed_miasma)
		return
	sm.absorbed_gasmix.gases[/datum/gas/miasma][MOLES] -= consumed_miasma
	sm.matter_power += consumed_miasma * MIASMA_POWER_GAIN

/datum/sm_gas/freon
	gas_path = /datum/gas/freon
	heat_penalty = -10
	transmit_modifier = -30
	powermix = 1

/datum/sm_gas/hydrogen
	gas_path = /datum/gas/hydrogen
	heat_penalty = 10
	transmit_modifier = 25
	heat_resistance = 2
	powermix = 1

/datum/sm_gas/healium
	gas_path = /datum/gas/healium
	heat_penalty = 4
	transmit_modifier = 2.4
	powermix = 1

/datum/sm_gas/proto_nitrate
	gas_path = /datum/gas/proto_nitrate
	heat_penalty = -3
	transmit_modifier = 15
	heat_resistance = 5
	powermix = 1

/datum/sm_gas/zauker
	gas_path = /datum/gas/zauker
	heat_penalty = 8
	transmit_modifier = 20
	powermix = 1

/datum/sm_gas/zauker/extra_effects(obj/machinery/power/supermatter_crystal/sm, datum/gas_mixture/env)
	if(!prob(sm.gas_percentage[/datum/gas/zauker]))
		return
	playsound(sm.loc, 'sound/weapons/emitter2.ogg', 100, TRUE, extrarange = 10)
	sm.supermatter_zap(
		sm, 
		range = 6, 
		zap_str = clamp(sm.power * 2, 4000, 20000), 
		zap_flags = ZAP_MOB_STUN, 
		zap_cutoff = sm.zap_cutoff, 
		power_level = sm.power, 
		zap_icon = sm.zap_icon
	)

/datum/sm_gas/halon
	gas_path = /datum/gas/halon

/datum/sm_gas/helium
	gas_path = /datum/gas/helium

/datum/sm_gas/antinoblium
	gas_path = /datum/gas/antinoblium
	transmit_modifier = -5
	heat_penalty = 15
	powermix = 1
