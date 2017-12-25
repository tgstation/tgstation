#define PLASMA_BINDING_ENERGY 3000000

/datum/gas_reaction/hippie_fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "plasmafusion"

/datum/gas_reaction/hippie_fusion/init_reqs()
	min_requirements = list(
		"ENER" = PLASMA_BINDING_ENERGY_HIPPIE,
		/datum/gas/plasma = MINIMUM_HEAT_CAPACITY,
		/datum/gas/carbon_dioxide = MINIMUM_HEAT_CAPACITY
	)

/datum/gas_reaction/hippie_fusion/react(datum/gas_mixture/air, atom/location)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/reaction_energy = THERMAL_ENERGY(air)

	if((cached_gases[/datum/gas/plasma][MOLES]+cached_gases[/datum/gas/carbon_dioxide][MOLES])/air.total_moles() < FUSION_PURITY_THRESHOLD_HIPPIE || reaction_energy < PLASMA_BINDING_ENERGY_HIPPIE)
		//Fusion wont occur if the level of impurities is too high.
		return FALSE

	else
		var/moles_impurities = (cached_gases[/datum/gas/plasma][MOLES]+cached_gases[/datum/gas/carbon_dioxide][MOLES])/air.total_moles()//more plasma+carbon = higher chance of collision regardless of actual thermal energy
		var/carbon_plasma_ratio = min(cached_gases[/datum/gas/carbon_dioxide][MOLES] / cached_gases[/datum/gas/plasma][MOLES], MAX_CARBON_EFFICENCY_HIPPIE)//more carbon = more fusion
		var/plasma_fused = max((PLASMA_FUSED_COEFFICENT_HIPPIE * (reaction_energy / PLASMA_BINDING_ENERGY_HIPPIE) * moles_impurities * carbon_plasma_ratio), 0)
		var/carbon_catalyzed = max(plasma_fused * CARBON_CATALYST_COEFFICENT_HIPPIE, 0)
		var/oxygen_added = carbon_catalyzed
		var/nitrogen_added = plasma_fused-oxygen_added
		var/mass_fused = carbon_catalyzed + plasma_fused
		var/mass_created = oxygen_added + nitrogen_added
		var/energy_released = (mass_fused - mass_created) * PLASMA_FUSION_ENERGY_HIPPIE

		air.assert_gases(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)

		cached_gases[/datum/gas/plasma][MOLES] -= plasma_fused
		cached_gases[/datum/gas/carbon_dioxide][MOLES] -= carbon_catalyzed
		cached_gases[/datum/gas/oxygen][MOLES] += oxygen_added
		cached_gases[/datum/gas/nitrogen][MOLES] += nitrogen_added

		if(energy_released > 0)
			if(air.heat_capacity() > MINIMUM_HEAT_CAPACITY)
				air.temperature = temperature + max(energy_released / air.heat_capacity(), TCMB)// energy released is thermal energy so we convert back to kelvin via division
				//Prevents whatever mechanism is causing it to hit negative temperatures.
			if(!isnull(location))
				location.set_light(4, 30)
				location.light_color = LIGHT_COLOR_GREEN
				radiation_pulse(location, 8, energy_released * FUSION_POWER_GENERATION_COEFFICIENT_HIPPIE)//set to an arbitrary value for now because radiation scaling with reaction energy is insane

				addtimer(CALLBACK(location, .atom/proc/set_light, 0, 0), 30)
			return TRUE

		return FALSE
