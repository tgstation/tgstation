///a reaction chamber for plumbing. pretty much everything can react, but this one keeps the reagents separated and only reacts under your given terms

/// coefficient to convert temperature to joules. same lvl as acclimator
#define HEATER_COEFFICIENT 0.05

/obj/machinery/plumbing/reaction_chamber
	name = "mixing chamber"
	desc = "Keeps chemicals separated until given conditions are met."
	icon_state = "reaction_chamber"
	buffer = 200
	reagent_flags = TRANSPARENT | NO_REACT

	/**
	* list of set reagents that the reaction_chamber allows in, and must all be present before mixing is enabled.
	* example: list(/datum/reagent/water = 20, /datum/reagent/fuel/oil = 50)
	*/
	var/list/required_reagents = list()

	///our reagent goal has been reached, so now we lock our inputs and start emptying
	var/emptying = FALSE

	///towards which temperature do we build (except during draining)?
	var/target_temperature = 300

/obj/machinery/plumbing/reaction_chamber/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/reaction_chamber, bolt, layer)

/obj/machinery/plumbing/reaction_chamber/create_reagents(max_vol, flags)
	. = ..()
	RegisterSignals(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED), PROC_REF(on_reagent_change))
	RegisterSignal(reagents, COMSIG_QDELETING, PROC_REF(on_reagents_del))

/// Handles properly detaching signal hooks.
/obj/machinery/plumbing/reaction_chamber/proc/on_reagents_del(datum/reagents/reagents)
	SIGNAL_HANDLER

	UnregisterSignal(reagents, list(COMSIG_REAGENTS_REM_REAGENT, COMSIG_REAGENTS_DEL_REAGENT, COMSIG_REAGENTS_CLEAR_REAGENTS, COMSIG_REAGENTS_REACTED, COMSIG_QDELETING))
	return NONE

/// Handles stopping the emptying process when the chamber empties.
/obj/machinery/plumbing/reaction_chamber/proc/on_reagent_change(datum/reagents/holder, ...)
	SIGNAL_HANDLER

	if(!holder.total_volume && emptying) //we were emptying, but now we aren't
		emptying = FALSE
		holder.flags |= NO_REACT
	return NONE

/obj/machinery/plumbing/reaction_chamber/process(seconds_per_tick)
	if(!is_operational || !reagents.total_volume)
		return

	if(!emptying || reagents.is_reacting)
		//adjust temperature of final solution
		var/energy = (target_temperature - reagents.chem_temp) * HEATER_COEFFICIENT * seconds_per_tick * reagents.heat_capacity()
		reagents.adjust_thermal_energy(energy)
		use_energy(active_power_usage + abs(ROUND_UP(energy) / 120))

		//do other stuff with final solution
		handle_reagents(seconds_per_tick)

///For subtypes that want to do additional reagent handling
/obj/machinery/plumbing/reaction_chamber/proc/handle_reagents(seconds_per_tick)
	return

/obj/machinery/plumbing/reaction_chamber/power_change()
	. = ..()

	icon_state = initial(icon_state) + "[use_power != NO_POWER_USE ? "_on" : ""]"

/obj/machinery/plumbing/reaction_chamber/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMixingChamber", name)
		ui.open()

/obj/machinery/plumbing/reaction_chamber/ui_data(mob/user)
	. = list()

	var/list/reagents_data = list()
	for(var/datum/reagent/required_reagent as anything in required_reagents) //make a list where the key is text, because that looks alot better in the ui than a typepath
		var/list/reagent_data = list()
		reagent_data["name"] = initial(required_reagent.name)
		reagent_data["volume"] = required_reagents[required_reagent]
		reagents_data += list(reagent_data)

	.["reagents"] = reagents_data
	.["emptying"] = emptying
	.["temperature"] = round(reagents.chem_temp, 0.1)
	.["targetTemp"] = target_temperature
	.["isReacting"] = reagents.is_reacting

/obj/machinery/plumbing/reaction_chamber/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return TRUE

	switch(action)
		if("add")
			var/selected_reagent = tgui_input_list(ui.user, "Select reagent", "Reagent", GLOB.name2reagent)
			if(!selected_reagent)
				return FALSE
			if(QDELETED(ui) || ui.status != UI_INTERACTIVE)
				return FALSE

			var/datum/reagent/input_reagent = GLOB.name2reagent[selected_reagent]
			if(!input_reagent)
				return FALSE

			if(!required_reagents.Find(input_reagent))
				var/input_amount = text2num(params["amount"])
				if(!isnull(input_amount))
					required_reagents[input_reagent] = input_amount
					return TRUE
			return FALSE

		if("remove")
			var/reagent = get_chem_id(params["chem"])
			if(reagent)
				required_reagents.Remove(reagent)
				return TRUE
			return FALSE

		if("temperature")
			var/target = text2num(params["target"])
			if(!isnull(target))
				target_temperature = clamp(target, 0, 1000)
				return TRUE
			return FALSE

	var/result = handle_ui_act(action, params, ui, state)
	if(isnull(result))
		result = FALSE
	return result

/// For custom handling of ui actions from inside a subtype
/obj/machinery/plumbing/reaction_chamber/proc/handle_ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	return null

///Chemistry version of reaction chamber that allows for acid and base buffers to be used while reacting
/obj/machinery/plumbing/reaction_chamber/chem
	name = "reaction chamber"

	///If below this pH, we start dumping buffer into it
	var/acidic_limit = 5
	///If above this pH, we start dumping acid into it
	var/alkaline_limit = 9

	///beaker that holds the acidic buffer(50u)
	var/obj/item/reagent_containers/cup/beaker/acidic_beaker
	///beaker that holds the alkaline buffer(50u).
	var/obj/item/reagent_containers/cup/beaker/alkaline_beaker

/obj/machinery/plumbing/reaction_chamber/chem/Initialize(mapload, bolt, layer)
	. = ..()

	acidic_beaker = new (src)
	alkaline_beaker = new (src)

	AddComponent(/datum/component/plumbing/acidic_input, bolt, custom_receiver = acidic_beaker)
	AddComponent(/datum/component/plumbing/alkaline_input, bolt, custom_receiver = alkaline_beaker)

/// Make sure beakers are deleted when being deconstructed
/obj/machinery/plumbing/reaction_chamber/chem/Destroy()
	QDEL_NULL(acidic_beaker)
	QDEL_NULL(alkaline_beaker)
	return ..()

/obj/machinery/plumbing/reaction_chamber/chem/handle_reagents(seconds_per_tick)
	if(reagents.ph < acidic_limit || reagents.ph > alkaline_limit)
		//no power
		if(machine_stat & NOPOWER)
			return

		//nothing to react with
		var/num_of_reagents = length(reagents.reagent_list)
		if(!num_of_reagents)
			return

		/**
		 * figure out which buffer to transfer to restore balance
		 * if solution is getting too basic(high ph) add some acid to lower it's value
		 * else if solution is getting too acidic(low ph) add some base to increase it's value
		 */
		var/datum/reagents/buffer = reagents.ph > alkaline_limit ? acidic_beaker.reagents : alkaline_beaker.reagents
		if(!buffer.total_volume)
			return

		//transfer buffer and handle reactions
		var/ph_change = max((reagents.ph > alkaline_limit ? (reagents.ph - alkaline_limit) : (acidic_limit - reagents.ph)), 0.25)
		var/buffer_amount = ((ph_change * reagents.total_volume) / (BUFFER_IONIZING_STRENGTH * num_of_reagents)) * seconds_per_tick
		if(!buffer.trans_to(reagents, buffer_amount))
			return

		//some power for accurate ph balancing & keep track of attempts made
		use_energy(active_power_usage * 0.03 * buffer_amount)

/obj/machinery/plumbing/reaction_chamber/chem/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemReactionChamber", name)
		ui.open()

/obj/machinery/plumbing/reaction_chamber/chem/ui_data(mob/user)
	. = ..()
	.["ph"] = round(reagents.ph, 0.01)
	.["reagentAcidic"] = acidic_limit
	.["reagentAlkaline"] = alkaline_limit

/obj/machinery/plumbing/reaction_chamber/chem/handle_ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = TRUE

	switch(action)
		if("acidic")
			acidic_limit = clamp(round(text2num(params["target"])), CHEMICAL_MIN_PH, alkaline_limit - 1)
		if("alkaline")
			alkaline_limit = clamp(round(text2num(params["target"])), acidic_limit + 1, CHEMICAL_MAX_PH)
		else
			return FALSE

#undef HEATER_COEFFICIENT
