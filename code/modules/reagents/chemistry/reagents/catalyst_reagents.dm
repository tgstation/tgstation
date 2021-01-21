///These alter reaction conditions while they're in the beaker
/datum/reagent/catalyst_agent
	name ="Catalyst agent"
	///The typepath of the reagent they that they affect
	var/target_reagent_type
	///The minimumvolume required in the beaker for them to have an effect
	var/min_volume = 15 
	///The value in which the associated type is modified
	var/modifier = 1

/datum/reagent/catalyst_agent/proc/consider_catalyst(datum/equilibrium/reaction)
	for(var/_reactant in reaction.holder)
		if(istype(_reactant, target_reagent_type))
			return TRUE
	return FALSE

/datum/reagent/catalyst_agent/speed
	name ="Speed catalyst agent"

/datum/reagent/catalyst_agent/speed/consider_catalyst(datum/equilibrium/reaction)
	. = ..()
	if(.)
		reaction.speed_mod = ((creation_purity-0.5)*2)*modifier //So a purity 1 = the modifier, and a purity 0 = the inverse

/datum/reagent/catalyst_agent/ph
	name ="pH catalyst agent"

/datum/reagent/catalyst_agent/ph/consider_catalyst(datum/equilibrium/reaction)
	. = ..()
	if(.)
		reaction.h_ion_mod = ((creation_purity-0.5)*2)*modifier //So a purity 1 = the modifier, and a purity 0 = the inverse

/datum/reagent/catalyst_agent/temperature
	name = "Temperature catalyst agent"

/datum/reagent/catalyst_agent/temperature/consider_catalyst(datum/equilibrium/reaction)
	. = ..()
	if(.)
		reaction.thermic_mod = ((creation_purity-0.5)*2)*modifier //So a purity 1 = the modifier, and a purity 0 = the inverse

///These affect medicines
/datum/reagent/catalyst_agent/speed/medicine
	name = "Palladium synthate catalyst"
	target_reagent_type = /datum/reagent/medicine
	modifier = 1.5
