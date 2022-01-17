///a reaction chamber for plumbing. pretty much everything can react, but this one keeps the reagents separated and only reacts under your given terms
/obj/machinery/plumbing/reaction_chamber
	name = "reaction chamber"
	desc = "Keeps chemicals separated until given conditions are met."
	icon_state = "reaction_chamber"
	buffer = 200
	reagent_flags = TRANSPARENT | NO_REACT

	/**
	* list of set reagents that the reaction_chamber allows in, and must all be present before mixing is enabled.
	* example: list(/datum/reagent/water = 20, /datum/reagent/fuel/oil = 50)
	*/
	var/list/required_reagents = list()
	///If above this pH, we start dumping buffer into it
	var/acidic_limit = 9
	///If below this pH, we start dumping buffer into it
	var/alkaline_limit = 5
	///our reagent goal has been reached, so now we lock our inputs and start emptying
	var/emptying = FALSE

	///towards which temperature do we build (except during draining)?
	var/target_temperature = 300
	///cool/heat power
	var/heater_coefficient = 0.05 //same lvl as acclimator
	///Beaker that holds the acidic buffer. I don't want to deal with snowflaking so it's just a separate thing. It's a small (50u) beaker
	var/obj/item/reagent_containers/glass/beaker/acidic_beaker
	///beaker that holds the alkaline buffer.
	var/obj/item/reagent_containers/glass/beaker/alkaline_beaker

/obj/machinery/plumbing/reaction_chamber/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/reaction_chamber, bolt, layer)

	acidic_beaker = new (src)
	alkaline_beaker = new (src)

	AddComponent(/datum/component/plumbing/acidic_input, bolt, custom_receiver = acidic_beaker)
	AddComponent(/datum/component/plumbing/alkaline_input, bolt, custom_receiver = alkaline_beaker)

/// Make sure beakers are deleted when being deconstructed
/obj/machinery/plumbing/reaction_chamber/Destroy()
	QDEL_NULL(acidic_beaker)
	QDEL_NULL(alkaline_beaker)
	. = ..()

/obj/machinery/plumbing/reaction_chamber/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignal(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED), .proc/on_reagent_change)
	RegisterSignal(reagents, COMSIG_PARENT_QDELETING, .proc/on_reagents_del)

/// Handles properly detaching signal hooks.
/obj/machinery/plumbing/reaction_chamber/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER
	UnregisterSignal(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED, COMSIG_PARENT_QDELETING))
	return NONE


/// Handles stopping the emptying process when the chamber empties.
/obj/machinery/plumbing/reaction_chamber/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER
	if(holder.total_volume == 0 && emptying) //we were emptying, but now we aren't
		emptying = FALSE
		holder.flags |= NO_REACT
	return NONE

/obj/machinery/plumbing/reaction_chamber/process(delta_time)
	if(reagents.is_reacting && reagents.ph < alkaline_limit)
		alkaline_beaker.reagents.trans_to(reagents, 1 * delta_time)
	if(reagents.is_reacting && reagents.ph > acidic_limit)
		acidic_beaker.reagents.trans_to(reagents, 1 * delta_time)

	if(!emptying || reagents.is_reacting) //suspend heating/cooling during emptying phase
		reagents.adjust_thermal_energy((target_temperature - reagents.chem_temp) * heater_coefficient * delta_time * SPECIFIC_HEAT_DEFAULT * reagents.total_volume) //keep constant with chem heater
		reagents.handle_reactions()

/obj/machinery/plumbing/reaction_chamber/power_change()
	. = ..()
	if(use_power != NO_POWER_USE)
		icon_state = initial(icon_state) + "_on"
	else
		icon_state = initial(icon_state)

/obj/machinery/plumbing/reaction_chamber/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemReactionChamber", name)
		ui.open()

/obj/machinery/plumbing/reaction_chamber/ui_data(mob/user)
	var/list/data = list()

	var/list/reagents_data = list()
	for(var/datum/reagent/required_reagent as anything in required_reagents) //make a list where the key is text, because that looks alot better in the ui than a typepath
		var/list/reagent_data = list()
		reagent_data["name"] = initial(required_reagent.name)
		reagent_data["required_reagent"] = required_reagents[required_reagent]
		reagents_data += list(reagent_data)

	data["reagents"] = reagents_data
	data["emptying"] = emptying
	data["temperature"] = round(reagents.chem_temp, 0.1)
	data["ph"] = round(reagents.ph, 0.01)
	data["targetTemp"] = target_temperature
	data["isReacting"] = reagents.is_reacting
	data["reagentAcidic"] = acidic_limit
	data["reagentAlkaline"] = alkaline_limit
	return data

/obj/machinery/plumbing/reaction_chamber/ui_act(action, params)
	. = ..()
	if(.)
		return
	. = TRUE
	switch(action)
		if("remove")
			var/reagent = get_chem_id(params["chem"])
			if(reagent)
				required_reagents.Remove(reagent)
		if("add")
			var/input_reagent = get_chem_id(params["chem"])
			if(input_reagent && !required_reagents.Find(input_reagent))
				var/input_amount = text2num(params["amount"])
				if(input_amount)
					required_reagents[input_reagent] = input_amount
		if("temperature")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				target_temperature = clamp(target, 0, 1000)
		if("acidic")
			acidic_limit = round(text2num(params["target"]))
		if("alkaline")
			alkaline_limit = round(text2num(params["target"]))

