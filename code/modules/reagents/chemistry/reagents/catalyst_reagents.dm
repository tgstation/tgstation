///These alter reaction conditions while they're in the beaker
/datum/reagent/catalyst_agent
	name ="Catalyst agent"
	///The typepath of the reagent they that they affect
	var/target_reagent_type
	///The minimumvolume required in the beaker for them to have an effect
	var/min_volume = 10 
	///The value in which the associated type is modified
	var/modifier = 1

/datum/reagent/catalyst_agent/proc/consider_catalyst(datum/equilibrium/equilibrium)
	for(var/_product in equilibrium.reaction.results)
		if(ispath(_product, target_reagent_type))
			return TRUE
	return FALSE

/datum/reagent/catalyst_agent/speed
	name ="Speed catalyst agent"

/datum/reagent/catalyst_agent/speed/consider_catalyst(datum/equilibrium/equilibrium)
	. = ..()
	if(.)
		equilibrium.speed_mod = creation_purity*modifier //So a purity 1 = the modifier, and a purity 0 = the inverse modifier. For this we don't want a negative speed_mod (I have no idea what happens if we do)
		equilibrium.time_deficit += (creation_purity)*(0.05 * modifier) //give the reaction a little boost too (40% faster)

/datum/reagent/catalyst_agent/ph
	name ="pH catalyst agent"

/datum/reagent/catalyst_agent/ph/consider_catalyst(datum/equilibrium/equilibrium)
	. = ..()
	if(.)
		equilibrium.h_ion_mod = ((creation_purity-0.5)*2)*modifier //So a purity 1 = the modifier, and a purity 0 = the inverse modifier

/datum/reagent/catalyst_agent/temperature
	name = "Temperature Catalyst Agent"

/datum/reagent/catalyst_agent/temperature/consider_catalyst(datum/equilibrium/equilibrium)
	. = ..()
	if(.)
		equilibrium.thermic_mod = ((creation_purity-0.5)*2)*modifier //So a purity 1 = the modifier, and a purity 0 = the inverse modifier

///These affect medicines
/datum/reagent/catalyst_agent/speed/medicine
	name = "Palladium Synthate Catalyst"
	description = "This catalyst reagent will speed up all medicine reactions that it shares a beaker with by a dramatic amount."
	target_reagent_type = /datum/reagent/medicine
	modifier = 2
	ph = 2 //drift towards acidity
	color = "#b1b1b1"
