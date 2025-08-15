/obj/machinery/chem_heater
	name = "reaction chamber" //Maybe this name is more accurate?
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "mixer0b"
	base_icon_state = "mixer"
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.4
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_heater

	/// The beaker inside this machine
	var/obj/item/reagent_containers/beaker = null
	/// The temperature this heater is trying to acheive
	var/target_temperature = 300
	/// The energy used by the heater to achieve the target temperature
	var/heater_coefficient = 0.05
	/// Is the heater on or off
	var/on = FALSE
	/// How much buffer are we transferig per click
	var/dispense_volume = 1

/obj/machinery/chem_heater/Initialize(mapload)
	. = ..()
	create_reagents(200, NO_REACT)
	register_context()

/obj/machinery/chem_heater/Destroy()
	if(beaker)
		UnregisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP)
		QDEL_NULL(beaker)
	return ..()

/obj/machinery/chem_heater/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == beaker)
		UnregisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP)
		beaker = null
		update_appearance()

/obj/machinery/chem_heater/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item) || (held_item.item_flags & ABSTRACT) || (held_item.flags_1 & HOLOGRAM_1))
		return NONE

	if(!QDELETED(beaker))
		if(istype(held_item, /obj/item/reagent_containers/dropper) || istype(held_item, /obj/item/reagent_containers/syringe))
			context[SCREENTIP_CONTEXT_LMB] = "Inject"
			return CONTEXTUAL_SCREENTIP_SET
		if(is_reagent_container(held_item)  && held_item.is_open_container())
			context[SCREENTIP_CONTEXT_LMB] = "Replace beaker"
			return CONTEXTUAL_SCREENTIP_SET
	else if(is_reagent_container(held_item)  && held_item.is_open_container())
		context[SCREENTIP_CONTEXT_LMB] = "Insert beaker"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "Open panel"
		return CONTEXTUAL_SCREENTIP_SET
	else if(panel_open && held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/machinery/chem_heater/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Heating reagents at <b>[heater_coefficient * 1000]%</b> speed.")
		if(!QDELETED(beaker))
			. += span_notice("It has a beaker of [beaker.reagents.total_volume] units capacity.")
			if(beaker.reagents.is_reacting)
				. += span_notice("Its contents are currently reacting.")
		else
			. += span_warning("There is no beaker inserted.")
		. += span_notice("Its heating is turned [on ? "On" : "Off"].")
		. += span_notice("The status display reads: Heating reagents at <b>[heater_coefficient * 1000]%</b> speed.")
		if(panel_open)
			. += span_notice("Its panel is open and can now be [EXAMINE_HINT("pried")] apart.")
		else
			. += span_notice("Its panel can be [EXAMINE_HINT("pried")] open")

/obj/machinery/chem_heater/update_icon_state()
	icon_state = "[base_icon_state][beaker ? 1 : 0]b"
	return ..()

/obj/machinery/chem_heater/RefreshParts()
	. = ..()
	heater_coefficient = 0.1
	for(var/datum/stock_part/micro_laser/micro_laser in component_parts)
		heater_coefficient *= micro_laser.tier

/obj/machinery/chem_heater/item_interaction(mob/living/user, obj/item/held_item, list/modifiers)
	if(user.combat_mode || (held_item.item_flags & ABSTRACT) || (held_item.flags_1 & HOLOGRAM_1) || !user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return NONE

	if(!QDELETED(beaker))
		if(istype(held_item, /obj/item/reagent_containers/dropper) || istype(held_item, /obj/item/reagent_containers/syringe))
			var/obj/item/reagent_containers/injector = held_item
			injector.interact_with_atom(beaker, user, modifiers)
			return ITEM_INTERACT_SUCCESS

	if(is_reagent_container(held_item)  && held_item.is_open_container())
		if(replace_beaker(user, held_item))
			ui_interact(user)
		balloon_alert(user, "beaker added")
		return ITEM_INTERACT_SUCCESS

	return NONE

/obj/machinery/chem_heater/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/chem_heater/screwdriver_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, "mixer0b", "[base_icon_state][beaker ? 1 : 0]b", tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/chem_heater/crowbar_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS

/obj/machinery/chem_heater/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!user.can_perform_action(src, ALLOW_SILICON_REACH | FORBID_TELEKINESIS_REACH))
		return
	replace_beaker(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/chem_heater/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_heater/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/**
 * Replace or eject the beaker inside this machine
 * Arguments
 * * mob/living/user - the player operating this machine
 * * obj/item/reagent_containers/new_beaker - the new beaker to replace the current one if not null else it will just eject
 */
/obj/machinery/chem_heater/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	PRIVATE_PROC(TRUE)

	if(!QDELETED(beaker))
		try_put_in_hand(beaker, user)

	if(!QDELETED(new_beaker))
		if(!user.transferItemToLoc(new_beaker, src))
			update_appearance()
			return FALSE
		beaker = new_beaker
		RegisterSignal(beaker.reagents, COMSIG_REAGENTS_REACTION_STEP, PROC_REF(on_reaction_step))

	update_appearance()

	return TRUE

/**
 * Heats the reagents of the currently inserted beaker only if machine is on & beaker has some reagents inside
 * Arguments
 * * seconds_per_tick - passed from process() or from reaction_step()
 */
/obj/machinery/chem_heater/proc/heat_reagents(seconds_per_tick)
	PRIVATE_PROC(TRUE)

	//must be on and beaker must have something inside to heat
	if(!on || !is_operational || QDELETED(beaker) || !beaker.reagents.total_volume)
		return FALSE

	//heat the beaker and use some power. we want to use only a small amount of power since this proc gets called frequently
	var/energy = (target_temperature - beaker.reagents.chem_temp) * heater_coefficient * seconds_per_tick * beaker.reagents.heat_capacity()
	beaker.reagents.adjust_thermal_energy(energy)
	use_energy(active_power_usage + abs(ROUND_UP(energy) / 120))
	return TRUE

/obj/machinery/chem_heater/proc/on_reaction_step(datum/reagents/holder, num_reactions, seconds_per_tick)
	SIGNAL_HANDLER

	//adjust temp
	heat_reagents(seconds_per_tick)

	//send updates to ui. faster than SStgui.update_uis
	for(var/datum/tgui/ui in src.open_uis)
		ui.send_update()

/obj/machinery/chem_heater/process(seconds_per_tick)
	//is_reacting is handled in reaction_step()
	if(QDELETED(beaker) || beaker.reagents.is_reacting)
		return

	if(heat_reagents(seconds_per_tick))
		//create new reactions after temperature adjust
		beaker.reagents.handle_reactions()

	//send updates to ui. faster than SStgui.update_uis
	for(var/datum/tgui/ui in src.open_uis)
		ui.send_update()

/obj/machinery/chem_heater/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemHeater", name)
		ui.open()

/obj/machinery/chem_heater/ui_data(mob/user)
	. = list()
	.["targetTemp"] = target_temperature
	.["isActive"] = on
	.["upgradeLevel"] = heater_coefficient * 10

	var/list/beaker_data = null
	var/chem_temp = 0
	if(!QDELETED(beaker))
		beaker_data = list()
		beaker_data["maxVolume"] = beaker.volume
		beaker_data["pH"] = round(beaker.reagents.ph, 0.01)
		beaker_data["currentVolume"] = beaker.reagents.total_volume
		var/list/beakerContents = list()
		if(length(beaker.reagents.reagent_list))
			for(var/datum/reagent/reagent in beaker.reagents.reagent_list)
				beakerContents += list(list("name" = reagent.name, "volume" = round(reagent.volume, CHEMICAL_VOLUME_ROUNDING))) // list in a list because Byond merges the first list...
		beaker_data["contents"] = beakerContents
		chem_temp = beaker.reagents.chem_temp
	.["beaker"] = beaker_data
	.["currentTemp"] = chem_temp

	var/list/active_reactions = list()
	var/flashing = DISABLE_FLASHING //for use with alertAfter - since there is no alertBefore, I set the after to 0 if true, or to the max value if false
	for(var/datum/equilibrium/equilibrium as anything in beaker?.reagents.reaction_list)
		if(!equilibrium.reaction.results)//Incase of no result reactions
			continue
		var/datum/reagents/beaker_reagents = beaker.reagents
		var/datum/reagent/reagent = beaker_reagents.has_reagent(equilibrium.reaction.results[1]) //Reactions are named after their primary products
		if(!reagent)
			continue

		//check for danger levels primirarly overheating
		var/overheat = FALSE
		var/danger = FALSE
		var/purity_alert = 2 //same as flashing
		if(reagent.purity < equilibrium.reaction.purity_min)
			purity_alert = ENABLE_FLASHING//Because 0 is seen as null
			danger = TRUE
		if(flashing != ENABLE_FLASHING)//So that the pH meter flashes for ANY reactions out of optimal
			if(equilibrium.reaction.optimal_ph_min > beaker_reagents.ph || equilibrium.reaction.optimal_ph_max < beaker_reagents.ph)
				flashing = ENABLE_FLASHING
		if(equilibrium.reaction.is_cold_recipe)
			if(equilibrium.reaction.overheat_temp > beaker_reagents.chem_temp && equilibrium.reaction.overheat_temp != NO_OVERHEAT)
				danger = TRUE
				overheat = TRUE
		else
			if(equilibrium.reaction.overheat_temp < beaker_reagents.chem_temp)
				danger = TRUE
				overheat = TRUE

		//create ui data
		active_reactions += list(list(
			"name" = reagent.name,
			"danger" = danger,
			"overheat" = overheat,
			"purityAlert" = purity_alert,
			"quality" = equilibrium.reaction_quality,
			"inverse" = reagent.inverse_chem_val,
			"minPure" = equilibrium.reaction.purity_min,
			"reactedVol" = equilibrium.reacted_vol,
			"targetVol" = round(equilibrium.target_vol, 1)
			)
		)

		//additional data for competitive reactions
		if(equilibrium.reaction.reaction_flags & REACTION_COMPETITIVE) //We have a compeitive reaction - concatenate the results for the different reactions
			for(var/entry in active_reactions)
				if(entry["name"] == reagent.name) //If we have multiple reaction methods for the same result - combine them
					entry["reactedVol"] = equilibrium.reacted_vol
					entry["targetVol"] = round(equilibrium.target_vol, 1)//Use the first result reagent to name the reaction detected
					entry["quality"] = (entry["quality"] + equilibrium.reaction_quality) /2
					continue
	.["activeReactions"] = active_reactions

	.["isFlashing"] = flashing
	.["acidicBufferVol"] = reagents.get_reagent_amount(/datum/reagent/reaction_agent/acidic_buffer)
	.["basicBufferVol"] = reagents.get_reagent_amount(/datum/reagent/reaction_agent/basic_buffer)
	.["dispenseVolume"] = dispense_volume

/obj/machinery/chem_heater/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("power")
			on = !on
			return TRUE

		if("temperature")
			var/target = params["target"]
			if(isnull(target))
				return FALSE

			target = text2num(target)
			if(isnull(target))
				return FALSE

			target_temperature = clamp(target, 0, 1000)
			return TRUE

		if("eject")
			//Eject doesn't turn it off, so you can preheat for beaker swapping
			return replace_beaker(ui.user)

		if("acidBuffer")
			var/target = params["target"]
			if(!target)
				return FALSE

			target = text2num(target)
			if(isnull(target))
				return FALSE

			return move_buffer(/datum/reagent/reaction_agent/acidic_buffer, target)
		if("basicBuffer")
			var/target = params["target"]
			if(!target)
				return FALSE

			target = text2num(target)
			if(isnull(target))
				return FALSE

			return move_buffer(/datum/reagent/reaction_agent/basic_buffer, target)
		if("disp_vol")
			var/target = params["target"]
			if(!target)
				return FALSE

			target = text2num(target)
			if(isnull(target))
				return FALSE

			dispense_volume = target
			return TRUE

/**
 * Injects either acid/base buffer into the beaker
 * Arguments
 * * datum/reagent/buffer_type - the type of buffer[acid, base] to inject/withdraw
 * * volume - how much to volume to inject -ve values means withdraw
 */
/obj/machinery/chem_heater/proc/move_buffer(datum/reagent/buffer_type, volume)
	PRIVATE_PROC(TRUE)

	//no beaker
	if(QDELETED(beaker))
		say("No beaker found!")
		return FALSE

	//trying to absorb buffer from currently inserted beaker
	if(volume < 0)
		if(!beaker.reagents.has_reagent(buffer_type))
			var/name = initial(buffer_type.name)
			say("Unable to find [name] in beaker to draw from! Please insert a beaker containing [name].")
			return FALSE
		beaker.reagents.trans_to(src, (reagents.maximum_volume / 2) - reagents.get_reagent_amount(buffer_type), target_id = buffer_type)
		return TRUE

	//trying to inject buffer into currently inserted beaker
	reagents.trans_to(beaker, dispense_volume, target_id = buffer_type)
	return TRUE

//Has a lot of buffer and is upgraded
/obj/machinery/chem_heater/debug
	name = "Debug Reaction Chamber"
	desc = "Now with even more buffers!"

/obj/machinery/chem_heater/debug/Initialize(mapload)
	. = ..()
	reagents.maximum_volume = 2000
	reagents.add_reagent(/datum/reagent/reaction_agent/basic_buffer, 1000)
	reagents.add_reagent(/datum/reagent/reaction_agent/acidic_buffer, 1000)
	heater_coefficient = 0.4 //hack way to upgrade

//map load types
/obj/machinery/chem_heater/withbuffer
	desc = "This Reaction Chamber comes with a bit of buffer to help get you started."

/obj/machinery/chem_heater/withbuffer/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/reaction_agent/basic_buffer, 20)
	reagents.add_reagent(/datum/reagent/reaction_agent/acidic_buffer, 20)
