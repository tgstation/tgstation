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
	name ="Speed Catalyst Agent"

/datum/reagent/catalyst_agent/speed/consider_catalyst(datum/equilibrium/equilibrium)
	. = ..()
	if(.)
		equilibrium.speed_mod = creation_purity*modifier //So a purity 1 = the modifier, and a purity 0 = the inverse modifier. For this we don't want a negative speed_mod (I have no idea what happens if we do)
		equilibrium.time_deficit += (creation_purity)*(0.05 * modifier) //give the reaction a little boost too (40% faster)

/datum/reagent/catalyst_agent/ph
	name ="pH Catalyst Agent"

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
///Note from confused guy: It looks like this makes endothermic reactions suddenly become violently exothermic and visa versa at low purities. Wacky.

///Catalyst precursors (oh boy here i go competing again). P is the harder one to make, (ie. requires a good heater or some extra materials), because it is probably more useful
/datum/reagent/catalyst_precursor_ph
	name = "Catalysium P"
	description = "A close chemical relative of the prefactors, this reagent is a precursor to Ionic Modulator, and will react with stable plasma to create it."
	color = "#bafa69"
	ph = 7

/datum/reagent/catalyst_precursor_temp
	name = "Catalysium T"
	description = "A close chemical relative of the prefactors, this reagent is a precursor to Thermic Modulator, and will react with stable plasma to create it."
	color = "#c91a1a"
	ph = 7



///General catalysts
/datum/reagent/catalyst_agent/ph/generic
	name = "Ionic Modulator"
	target_reagent_type = /datum/reagent
	modifier = 0.5
	description = "This catalyst reagent will stabilize reactions in its beaker, reducing the changes in pH caused by reacting chemicals."
	ph = 7 //perfectly balanced, as all things should be. (also it's a ph moderator so this makes sense)
	color = "#84e30b" //green = neutrality on a ph strip so a neutrality enforcing chem is bright green. logic.

/datum/reagent/catalyst_agent/temperature/generic
	name = "Thermic Modulator"
	target_reagent_type = /datum/reagent
	modifier = 0.5
	description = "This catalyst reagent will stabilize reactions in its beaker, reducing their endo/exo-thermicity."
	ph = 7 //perfectly balanced, as all things should be. (also it's a nonreactive catalyst so this makes sense)
	color = "#84e30b"




///These affect medicines
/datum/reagent/catalyst_agent/speed/medicine
	name = "Palladium Synthate Catalyst"
	description = "This catalyst reagent will speed up all medicine reactions that it shares a beaker with by a dramatic amount."
	target_reagent_type = /datum/reagent/medicine
	modifier = 2
	ph = 2 //drift towards acidity
	color = "#b1b1b1"
