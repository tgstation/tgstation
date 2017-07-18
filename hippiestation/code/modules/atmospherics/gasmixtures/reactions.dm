#define NO_REACTION	0
#define REACTING	1


/datum/gas_reaction/hippie_fusion
	exclude = FALSE
	priority = 2
	name = "Plasmic Fusion"
	id = "plasmafusion"

/datum/gas_reaction/hippie_fusion/react(datum/gas_mixture/air, atom/location)
	var/list/cached_gases = air.gases
	var/temperature = air.temperature
	var/reaction_energy = air.thermal_energy()

	if((cached_gases["plasma"][MOLES]+cached_gases["co2"][MOLES])/air.total_moles() < FUSION_PURITY_THRESHOLD_HIPPIE || reaction_energy < PLASMA_BINDING_ENERGY_HIPPIE)
		//Fusion wont occur if the level of impurities is too high.
		return NO_REACTION

	else
		//to_chat(world, "pre [temperature, [cached_gases["plasma"][MOLES]], [cached_gases["co2"][MOLES]])
		var/moles_impurities = (cached_gases["plasma"][MOLES]+cached_gases["co2"][MOLES])/air.total_moles()//more plasma+carbon = higher chance of collision regardless of actual thermal energy
		var/carbon_plasma_ratio = min(cached_gases["co2"][MOLES]/cached_gases["plasma"][MOLES],MAX_CARBON_EFFICENCY_HIPPIE)//more carbon = more fusion
		var/plasma_fused = max((PLASMA_FUSED_COEFFICENT_HIPPIE*(reaction_energy/PLASMA_BINDING_ENERGY_HIPPIE) * moles_impurities * carbon_plasma_ratio), 0)
		var/carbon_catalyzed = max(plasma_fused*CARBON_CATALYST_COEFFICENT_HIPPIE, 0)
		var/oxygen_added = carbon_catalyzed
		var/nitrogen_added = carbon_catalyzed + oxygen_added
		var/mass_fused = carbon_catalyzed + plasma_fused
		var/mass_created = oxygen_added + nitrogen_added
		var/energy_released = (mass_fused - mass_created)*PLASMA_FUSION_ENERGY_HIPPIE

		air.assert_gases("o2", "n2", "co2", "plasma")

		cached_gases["plasma"][MOLES] -= plasma_fused
		cached_gases["co2"][MOLES] -= carbon_catalyzed
		cached_gases["o2"][MOLES] += oxygen_added
		cached_gases["n2"][MOLES] += nitrogen_added

		if(energy_released > 0)
			if(air.heat_capacity() > MINIMUM_HEAT_CAPACITY)
				air.temperature = temperature + max(energy_released / air.heat_capacity(), TCMB)// energy released is thermal energy so we convert back to kelvin via division
				//Prevents whatever mechanism is causing it to hit negative temperatures.
			//to_chat(world, "PLASMA [cached_gases["plasma"][MOLES]], CO2 [cached_gases["co2"][MOLES]], FUSED [plasma_fused], ENERGY [energy_released], MASS FUSED [mass_fused], MASS CREATED [oxygen_added + nitrogen_added] REACTING")
			if(!isnull(location))
				location.set_light(4, 30)
				location.light_color = LIGHT_COLOR_GREEN
				radiation_pulse(location, 8, 15, 5)//set to an arbitrary value for now because radiation scaling with reaction energy is insane
				addtimer(CALLBACK(location, .atom/proc/set_light, 0, 0), 30)
			return REACTING

		return NO_REACTION