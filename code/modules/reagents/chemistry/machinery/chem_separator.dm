/obj/structure/chem_separator
	name = "distillation apparatus"
	desc = "A device that performs chemical separation by distillation."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "separator"
	light_power = 1

	///Is the mixture currently boiling
	var/boiling = FALSE
	/// Has the sound loop animation started
	var/loop_started = FALSE
	/// Sound during separation
	var/datum/looping_sound/boiling/soundloop
	/// The container for transferring distilled reagents into
	var/obj/item/reagent_containers/distilled_container
	/// The container for holding the fuel source for the bunset burner
	var/obj/item/reagent_containers/burner_fuel_container
	/// Is the bunset burner currenrly switched on/off
	var/burner_on = FALSE
	/// Knob setting on the burner
	var/burner_knob = 1

/obj/structure/chem_separator/Initialize(mapload)
	. = ..()
	create_reagents(300, TRANSPARENT | INJECTABLE)
	soundloop = new(src)
	register_context()

/obj/structure/chem_separator/Destroy()
	QDEL_NULL(distilled_container)
	QDEL_NULL(burner_fuel_container)
	QDEL_NULL(soundloop)
	return ..()

/obj/structure/chem_separator/atom_deconstruct(disassembled)
	var/atom/drop = drop_location()

	if(!QDELETED(distilled_container))
		distilled_container.forceMove(drop)

	if(!QDELETED(burner_fuel_container))
		burner_fuel_container.forceMove(drop)

/obj/structure/chem_separator/Exited(atom/movable/gone, direction)
	. = ..()
	if(distilled_container == gone)
		distilled_container = null
		update_appearance(UPDATE_OVERLAYS)
	if(burner_fuel_container == gone)
		burner_fuel_container = null
		update_appearance(UPDATE_OVERLAYS)

/obj/structure/chem_separator/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		if(!QDELETED(distilled_container))
			context[SCREENTIP_CONTEXT_LMB] = "Remove beaker"
			. = CONTEXTUAL_SCREENTIP_SET
		if(!QDELETED(burner_fuel_container))
			context[SCREENTIP_CONTEXT_RMB] = "Remove fuel"
			. = CONTEXTUAL_SCREENTIP_SET
		if(burner_on)
			context[SCREENTIP_CONTEXT_ALT_LMB] = "Off burner"
			. = CONTEXTUAL_SCREENTIP_SET
		return

	if(is_reagent_container(held_item) && held_item.is_open_container())
		if(QDELETED(distilled_container))
			context[SCREENTIP_CONTEXT_LMB] = "Insert beaker"
			return CONTEXTUAL_SCREENTIP_SET
		if(QDELETED(burner_fuel_container))
			context[SCREENTIP_CONTEXT_LMB] = "Insert fuel"
			return CONTEXTUAL_SCREENTIP_SET

/obj/structure/chem_separator/examine(mob/user)
	. = ..()

	if(reagents.total_volume)
		. += span_notice("The distilation flask reads <b>[reagents.total_volume]/[reagents.maximum_volume]u</b>.")
	if(!QDELETED(distilled_container))
		. += span_notice("The distilation beaker reads <b>[distilled_container.reagents.total_volume]/[distilled_container.reagents.maximum_volume]u</b>.")
		. += span_notice("Remove beaker with [EXAMINE_HINT("LMB")].")
	else
		. += span_warning("Its missing a distilation container")
	if(!QDELETED(burner_fuel_container))
		. += span_notice("The burner fuel container reads <b>[burner_fuel_container.reagents.total_volume]/[burner_fuel_container.reagents.maximum_volume]u</b>.")
		. += span_notice("Remove fuel with [EXAMINE_HINT("RMB")].")
	else
		. += span_warning("Its missing a beaker containing fuel for the burner.")
	if(burner_on)
		. += span_notice("Off burner with [EXAMINE_HINT("ALT LMB")].")
	else
		. += span_notice("You can start a flame with an combustible device.")

	. += span_notice("You can [EXAMINE_HINT("examine more")] to see reagent boiling points & fuel properties.")

/obj/structure/chem_separator/examine_more(mob/user)
	. = ..()

	. += span_notice("For burner fuel Oil > Welding Fuel > Ethanol > Monkey Energy")

	. += span_notice("Upon cross examining the flasks reagents contents with its chart you see the boiling points of each reagent present.")
	for(var/datum/reagent/reg as anything in reagents.reagent_list)
		. += span_notice("[reg.name] [get_boiling_point(reg)]K")

/obj/structure/chem_separator/update_overlays()
	. = ..()

	//burner overlays
	if(burner_on)
		. += mutable_appearance('icons/obj/medical/chemical.dmi', "separator_burn")
		. += emissive_appearance('icons/obj/medical/chemical.dmi', "separator_burn", src)

	var/static/list/fill_icon_thresholds = list(1, 30, 80)

	//distilation flask overlays
	if(reagents.total_volume)
		var/mutable_appearance/overlay = reagent_threshold_overlay(reagents, 'icons/obj/medical/reagent_fillings.dmi', "separator_m_", fill_icon_thresholds)
		if(!isnull(overlay))
			. += overlay

	//dripping overlay
	if(boiling)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/medical/reagent_fillings.dmi', "separator_dripping")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling

	//distilation beaker overlays
	if(!QDELETED(distilled_container))
		. += "separator_beaker"
		var/mutable_appearance/overlay = reagent_threshold_overlay(distilled_container.reagents, 'icons/obj/medical/reagent_fillings.dmi', "separator_b_", fill_icon_thresholds)
		if(!isnull(overlay))
			. += overlay

	//thermometer overlay
	var/static/list/temperature_icon_thresholds = list(0, 50, 100)
	var/threshold = null
	for(var/i in 1 to temperature_icon_thresholds.len)
		if(ROUND_UP(reagents.chem_temp - T0C) >= temperature_icon_thresholds[i])
			threshold = i
	if(threshold)
		var/fill_name = "separator_temp_[temperature_icon_thresholds[threshold]]"
		var/mutable_appearance/filling = mutable_appearance('icons/obj/medical/chemical.dmi', fill_name)
		. += filling

/**
 * Computes the boiling point of the reagent based on its mass. heaiver reagents obviously needs higher temps
 * Arguments
 *
 * * datum/reagent/reg - the reagent whos boiling point we are trying to compute
 */
/obj/structure/chem_separator/proc/get_boiling_point(datum/reagent/reg)
	PRIVATE_PROC(TRUE)

	//reagents masses can vary between 10->800
	var/normalized_coord = (reg.mass - 10) / 790

	//return a boiling point anywhere between 400->900 k. Change if you want more varity
	return 400 + (500 * normalized_coord)

/**
 * Computes the coefficient of burning(the ability of the reagent mixture to burn) of the burner fuel container
 * reagents can affect the intensity of the flame in different ways. A -ve value the mixture can not combust
 * whereas a +ve value(<= 1) means the flame can burn at maximum efficiency
 */
/obj/structure/chem_separator/proc/get_ignition_coefficient()
	PRIVATE_PROC(TRUE)

	if(QDELETED(burner_fuel_container))
		return 0

	//map of reagents & how much burning potential they all have
	var/static/list/reagent_coefficients = list(
		/datum/reagent/fuel/oil = 0.8,
		/datum/reagent/fuel = 0.7,
		/datum/reagent/consumable/ethanol = 0.6,
		/datum/reagent/consumable/monkey_energy = 0.5,
		/datum/reagent/water = - 0.7
	)

	var/total_coefficient = 0
	for(var/datum/reagent/reg as anything in burner_fuel_container.reagents.reagent_list)
		var/coefficient = reagent_coefficients[reg.type]
		if(!coefficient) //any fuel that is not on the list acts as an inhibitor
			coefficient = - 1
		total_coefficient += coefficient

	return clamp(total_coefficient, 0, 1)

/**
 * Toggles the burner on(only for a good fuel composition) or off
 * Arguments
 *
 * * state - on or off
 */
/obj/structure/chem_separator/proc/toggle_burner(state)
	PRIVATE_PROC(TRUE)

	if(!state)
		burner_on = FALSE
		set_light(0)
	else
		if(!get_ignition_coefficient()) //no proper fuel
			return
		if(!reagents.total_volume) //no reagents to distill
			return
		if(QDELETED(distilled_container)) //no beaker to receive distilled reagents
			return
		burner_on = TRUE
		set_light(ROUND_UP(2 * (burner_knob / 5)))
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/chem_separator/fire_act(exposed_temperature, exposed_volume)
	toggle_burner(TRUE)

/obj/structure/chem_separator/extinguish()
	. = ..()
	toggle_burner(FALSE)

/obj/structure/chem_separator/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(user.combat_mode || tool.item_flags & ABSTRACT || tool.flags_1 & HOLOGRAM_1 || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return ITEM_INTERACT_SKIP_TO_ATTACK

	///Add the distilation flask
	if(is_reagent_container(tool) && tool.is_open_container())
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck in your hand"))
			return ITEM_INTERACT_BLOCKING
		distilled_container = tool
		ui_interact(user)
		balloon_alert(user, "distillation container added")
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS

	///Try & ignite the bunset burner with this item
	var/ignition_message = tool.ignition_effect(src, user)
	if(!ignition_message)
		return NONE
	user.visible_message(ignition_message)
	toggle_burner(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/chem_separator/attack_hand(mob/living/user, list/modifiers)
	if(!QDELETED(distilled_container))
		if(!SStgui.get_open_ui(user, src)) //for convinience open ui first then interact with beakers if you still want to
			ui_interact(user)
			return TRUE

		if(user.put_in_hands(distilled_container))
			to_chat(user, span_notice("you take out the distilation flask"))
		return TRUE

	return ..()

/obj/structure/chem_separator/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(user.combat_mode || tool.item_flags & ABSTRACT || tool.flags_1 & HOLOGRAM_1 || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(is_reagent_container(tool) && tool.is_open_container())
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck in your hand"))
			return ITEM_INTERACT_BLOCKING
		burner_fuel_container = tool
		ui_interact(user)
		balloon_alert(user, "burner fuel container added")
		return ITEM_INTERACT_SUCCESS

/obj/structure/chem_separator/attack_hand_secondary(mob/user, list/modifiers)
	if(!QDELETED(burner_fuel_container))
		if(!SStgui.get_open_ui(user, src)) //for convinience open ui first then interact with beakers if you still want to
			ui_interact(user)
			return TRUE

		if(user.put_in_hands(burner_fuel_container))
			to_chat(user, span_notice("you take out the burner fuel container"))
			toggle_burner(FALSE)
		return TRUE

	return ..()

/obj/structure/chem_separator/process(seconds_per_tick)
	if(!reagents.total_volume)
		toggle_burner(FALSE)
		return PROCESS_KILL

	//if burner in on attempt to heat the reagents
	if(burner_on)
		var/can_process = TRUE

		//do we have good quality fuel to burn
		var/fuel_coefficient = get_ignition_coefficient()
		if(!fuel_coefficient)
			can_process = FALSE
			toggle_burner(FALSE)


		var/knob_ratio = burner_knob / 5

		//consume some air after we have validated we have some good fuel
		if(can_process)
			var/datum/gas_mixture/air = return_air()
			if(!air.remove_specific(/datum/gas/oxygen, 0.01 + (0.04 * knob_ratio))) //can burn anywhere between 0.01 & 0.05 moles of air based on the knob settings
				can_process = FALSE
				toggle_burner(FALSE)

		//burn some fuel if we combusted some air
		if(can_process)
			var/datum/reagents/fuel = burner_fuel_container.reagents
			if(!fuel.remove_all(0.01 + (0.24 * knob_ratio))) //can burn anywhere between 0.01 & 0.25 units of fuel based on the knob settings
				can_process = FALSE
				toggle_burner(FALSE)

		//finally heat the mixture
		if(can_process)
			reagents.adjust_thermal_energy((1000 - reagents.chem_temp) * seconds_per_tick * SPECIFIC_HEAT_DEFAULT * (0.1 + (0.3 * knob_ratio)) * fuel_coefficient)
			reagents.handle_reactions()
	else if(reagents.chem_temp > DEFAULT_REAGENT_TEMPERATURE) //the container cools down if there is no flame heating it till it reaches room temps
		reagents.adjust_thermal_energy((DEFAULT_REAGENT_TEMPERATURE - reagents.chem_temp) * seconds_per_tick * SPECIFIC_HEAT_DEFAULT * 0.05)
		reagents.handle_reactions()

	//the distilation process checks the individual boiling point of each reagent based on their mass for seperation
	boiling = FALSE
	for(var/datum/reagent/reg in reagents.reagent_list)
		var/bp = get_boiling_point(reg)
		//we can now distil this
		if(reagents.chem_temp > bp)
			//distilation rate increases as temps go up peaking at 12 units per tick(at 200k above boiling point)
			var/amount = 2 + ((reagents.chem_temp - bp) / 200) * 10
			if(!QDELETED(distilled_container))
				reagents.trans_to(distilled_container.reagents, amount, target_id = reg.type)
			else //no target container means reagents vanish into thin air i.e leak out
				reagents.remove_reagent(reg.type, amount)
			boiling = TRUE

		//boiling sound effect
		if(boiling)
			if(!loop_started)
				soundloop.start()
				loop_started = TRUE
		else
			soundloop.stop()
			loop_started = FALSE

/obj/structure/chem_separator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemSeparator", name)
		ui.open()

/obj/structure/chem_separator/ui_data(mob/user)
	. = list()

	//distilation flask data
	var/list/flask_data = list()
	flask_data["total_volume"] = reagents.total_volume
	flask_data["maximum_volume"] = reagents.maximum_volume
	flask_data["temp"] = reagents.chem_temp
	flask_data["color"] = mix_color_from_reagents(reagents.reagent_list)
	.["flask"] = flask_data

	//distilled beaker data
	var/list/distilled_data = null
	if(!QDELETED(distilled_container))
		var/datum/reagents/distilled_reagents = distilled_container.reagents

		distilled_data = list()
		distilled_data["total_volume"] = distilled_reagents.total_volume
		distilled_data["maximum_volume"] = distilled_reagents.maximum_volume
		distilled_data["temp"] = distilled_reagents.chem_temp
		distilled_data["color"] = mix_color_from_reagents(distilled_reagents.reagent_list)
	.["beaker"] = distilled_data

	//burner fuel data
	var/list/fuel_data = null
	if(!QDELETED(burner_fuel_container))
		var/datum/reagents/fuel_reagents = burner_fuel_container.reagents

		fuel_data = list()
		fuel_data["total_volume"] = fuel_reagents.total_volume
		fuel_data["maximum_volume"] = fuel_reagents.maximum_volume
		fuel_data["temp"] = fuel_reagents.chem_temp
		fuel_data["color"] = mix_color_from_reagents(fuel_reagents.reagent_list)
	.["fuel"] = fuel_data

	//Knob setting
	.["knob"] = burner_knob

/obj/structure/chem_separator/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("drain")
			if(QDELETED(distilled_container) || !reagents.total_volume)
				return FALSE

			if(reagents.trans_to(distilled_container.reagents, reagents.maximum_volume))
				STOP_PROCESSING(SSobj, src)
				toggle_burner(FALSE)
				return TRUE

		if("filter")
			if(QDELETED(distilled_container) || !distilled_container.reagents.total_volume)
				return FALSE

			if(distilled_container.reagents.trans_to(reagents, reagents.maximum_volume))
				START_PROCESSING(SSobj, src)
				update_appearance(UPDATE_OVERLAYS)
				return TRUE

		if("knob")
			var/setting = params["amount"]
			if(isnull(setting))
				return FALSE

			setting = text2num(setting)
			if(!setting)
				return FALSE

			burner_knob = clamp(setting, 1, 5)
			set_light(ROUND_UP(2 * (burner_knob / 5)))
			return TRUE

/obj/structure/chem_separator/click_alt(mob/user)
	if(!burner_on)
		return CLICK_ACTION_BLOCKING

	toggle_burner(FALSE)
	return CLICK_ACTION_SUCCESS
