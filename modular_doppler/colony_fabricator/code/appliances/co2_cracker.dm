// We can't just use electrolyzer reactions, because that'd let electrolyzers do co2 cracking

GLOBAL_LIST_INIT(cracker_reactions, cracker_reactions_list())

/// Global proc to build up the list of co2 cracker reactions
/proc/cracker_reactions_list()
	var/list/built_reaction_list = list()
	for(var/reaction_path in subtypesof(/datum/cracker_reaction))
		var/datum/cracker_reaction/reaction = new reaction_path()

		built_reaction_list[reaction.id] = reaction

	return built_reaction_list

/datum/cracker_reaction
	var/list/requirements
	var/name = "reaction"
	var/id = "r"
	var/desc = ""
	var/list/factor

/// Called when the co2 cracker reaction is run, should be where the code for actually changing gasses around is run
/datum/cracker_reaction/proc/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	return

/// Checks if this reaction can actually be run
/datum/cracker_reaction/proc/reaction_check(datum/gas_mixture/air_mixture)
	var/temp = air_mixture.temperature
	var/list/cached_gases = air_mixture.gases
	if((requirements["MIN_TEMP"] && temp < requirements["MIN_TEMP"]) || (requirements["MAX_TEMP"] && temp > requirements["MAX_TEMP"]))
		return FALSE
	for(var/id in requirements)
		if(id == "MIN_TEMP" || id == "MAX_TEMP")
			continue
		if(!cached_gases[id] || cached_gases[id][MOLES] < requirements[id])
			return FALSE
	return TRUE

/datum/cracker_reaction/co2_cracking
	name = "CO2 Cracking"
	id = "co2_cracking"
	desc = "Conversion of CO2 into equal amounts of O2"
	requirements = list(
		/datum/gas/carbon_dioxide = MINIMUM_MOLE_COUNT,
	)
	factor = list(
		/datum/gas/carbon_dioxide = "1 mole of CO2 gets consumed",
		/datum/gas/oxygen = "1 mole of O2 gets produced",
		"Location" = "Can only happen on turfs with an active CO2 cracker.",
	)

/datum/cracker_reaction/co2_cracking/react(turf/location, datum/gas_mixture/air_mixture, working_power)
	var/old_heat_capacity = air_mixture.heat_capacity()
	air_mixture.assert_gases(/datum/gas/water_vapor, /datum/gas/oxygen)
	var/proportion = min(air_mixture.gases[/datum/gas/carbon_dioxide][MOLES] * INVERSE(2), (2.5 * (working_power ** 2)))
	air_mixture.gases[/datum/gas/carbon_dioxide][MOLES] -= proportion
	air_mixture.gases[/datum/gas/oxygen][MOLES] += proportion
	var/new_heat_capacity = air_mixture.heat_capacity()
	if(new_heat_capacity > MINIMUM_HEAT_CAPACITY)
		air_mixture.temperature = max(air_mixture.temperature * old_heat_capacity / new_heat_capacity, TCMB)

// CO2 cracker machine itself

/obj/machinery/electrolyzer/co2_cracker
	name = "portable CO2 cracker"
	desc = "A portable device that is the savior of many a colony on the frontier. Performing similarly to an electrolyzer, \
		it takes in nearby gasses and breaks them into different gasses. The big draw of this one? It can crack carbon dioxide \
		into breathable oxygen. Handy for places where CO2 is all too common, and oxygen is all too hard to find."
	icon = 'modular_doppler/colony_fabricator/icons/portable_machines.dmi'
	circuit = null
	working_power = 1
	/// Soundloop for while the thermomachine is turned on
	var/datum/looping_sound/conditioner_running/soundloop
	/// What this repacks into
	var/repacked_type = /obj/item/flatpacked_machine/co2_cracker

/obj/machinery/electrolyzer/co2_cracker/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	AddElement(/datum/element/repackable, repacked_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/machinery/electrolyzer/co2_cracker/process_atmos()
	if(on && !soundloop.loop_started)
		soundloop.start()
	else if(soundloop.loop_started)
		soundloop.stop()
	return ..()

/obj/machinery/electrolyzer/co2_cracker/call_reactions(datum/gas_mixture/env)
	for(var/reaction in GLOB.cracker_reactions)
		var/datum/cracker_reaction/current_reaction = GLOB.cracker_reactions[reaction]

		if(!current_reaction.reaction_check(env))
			continue

		current_reaction.react(loc, env, working_power)

	env.garbage_collect()

/obj/machinery/electrolyzer/co2_cracker/RefreshParts()
	. = ..()
	working_power = 2
	efficiency = 1

/obj/machinery/electrolyzer/co2_cracker/crowbar_act(mob/living/user, obj/item/tool)
	return

// "parts kit" for buying these from cargo

/obj/item/flatpacked_machine/co2_cracker
	name = "CO2 cracker parts kit"
	icon = 'modular_doppler/colony_fabricator/icons/parts_kits.dmi'
	icon_state = "co2_cracker"
	type_to_deploy = /obj/machinery/electrolyzer/co2_cracker
	deploy_time = 2 SECONDS
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/plasma = HALF_SHEET_MATERIAL_AMOUNT, // We're gonna pretend plasma is the catalyst for co2 cracking
	)
