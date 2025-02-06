///The maximum number of settings on a burner knob
#define MAX_BURNER_KNOB_SETTINGS 10

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
	var/obj/item/reagent_containers/fuel_container
	/// Is the bunset burner currenrly switched on/off
	var/burner_on = FALSE
	/// Do we have a condenser installed for forced cooling
	var/condenser_installed = FALSE
	/// Is the condenser on
	var/condenser_on = FALSE
	/// Knob setting on the burner
	var/burner_knob = 1

/obj/structure/chem_separator/Initialize(mapload)
	. = ..()
	create_reagents(100, TRANSPARENT | INJECTABLE)
	soundloop = new(src)
	register_context()

/obj/structure/chem_separator/Destroy()
	QDEL_NULL(distilled_container)
	QDEL_NULL(fuel_container)
	QDEL_NULL(soundloop)
	return ..()

/obj/structure/chem_separator/atom_deconstruct(disassembled)
	var/atom/drop = drop_location()

	new /obj/item/stack/sheet/mineral/wood(drop, 1)

	new /obj/item/thermometer(drop)

	new /obj/item/burner(drop)

	if(condenser_installed)
		new /obj/item/assembly/igniter/condenser(drop)

	if(!QDELETED(distilled_container))
		distilled_container.forceMove(drop)

	if(!QDELETED(fuel_container))
		fuel_container.forceMove(drop)

/obj/structure/chem_separator/Exited(atom/movable/gone, direction)
	. = ..()
	if(distilled_container == gone)
		distilled_container = null
		update_appearance(UPDATE_OVERLAYS)
	if(fuel_container == gone)
		toggle_burner(FALSE)
		fuel_container = null
		update_appearance(UPDATE_OVERLAYS)

/obj/structure/chem_separator/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(isnull(held_item))
		if(!QDELETED(distilled_container))
			context[SCREENTIP_CONTEXT_LMB] = "Remove beaker"
			. = CONTEXTUAL_SCREENTIP_SET
		if(!QDELETED(fuel_container))
			context[SCREENTIP_CONTEXT_RMB] = "Remove fuel"
			. = CONTEXTUAL_SCREENTIP_SET
		if(burner_on)
			context[SCREENTIP_CONTEXT_ALT_LMB] = "Off burner"
			. = CONTEXTUAL_SCREENTIP_SET
		return

	if(!condenser_installed && istype(held_item, /obj/item/assembly/igniter/condenser))
		context[SCREENTIP_CONTEXT_LMB] = "Installer cooler"
		return CONTEXTUAL_SCREENTIP_SET

	if(is_reagent_container(held_item) && held_item.is_open_container())
		if(QDELETED(distilled_container))
			context[SCREENTIP_CONTEXT_LMB] = "[QDELETED(distilled_container) ? "Insert" : "Replace"] beaker"
			return CONTEXTUAL_SCREENTIP_SET
		if(QDELETED(fuel_container))
			context[SCREENTIP_CONTEXT_RMB] = "[QDELETED(fuel_container) ? "Insert" : "Replace"] fuel"
			return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

/obj/structure/chem_separator/examine(mob/user)
	. = ..()

	if(reagents.total_volume)
		. += span_notice("The distilation flask reads <b>[reagents.total_volume]/[reagents.maximum_volume]u</b>.")
	if(!QDELETED(distilled_container))
		. += span_notice("The distilation beaker reads <b>[distilled_container.reagents.total_volume]/[distilled_container.reagents.maximum_volume]u</b>.")
		. += span_notice("Remove beaker with [EXAMINE_HINT("LMB")].")
	else
		. += span_warning("Its missing a distilation container, insert with [EXAMINE_HINT("LMB")]")
	if(!QDELETED(fuel_container))
		. += span_notice("The burner fuel container reads <b>[fuel_container.reagents.total_volume]/[fuel_container.reagents.maximum_volume]u</b>.")
		. += span_notice("Remove fuel with [EXAMINE_HINT("RMB")].")
	else
		. += span_warning("Its missing a beaker containing fuel for the burner, insert with [EXAMINE_HINT("RMB")]")
	if(burner_on)
		. += span_notice("Off burner with [EXAMINE_HINT("ALT LMB")].")
	else
		. += span_notice("You can start a flame with a combustible device.")

	if(condenser_installed)
		. += span_notice("The in-built condenser can facilitate faster cooling but consumes fuel.")
	else
		. += span_notice("You could install a [EXAMINE_HINT("condenser")] for fater cooling.")

	. += span_notice("You can [EXAMINE_HINT("examine more")] to see reagent boiling points & fuel properties.")
	. += span_notice("The whole aparatus can be [EXAMINE_HINT("pried")] apart.")

/obj/structure/chem_separator/examine_more(mob/user)
	. = ..()

	. += span_notice("For burner fuel Plasma > Oil > Welding Fuel = Oxygen > Ethanol > Monkey Energy")

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

	//use the constant mass set on init
	reg = GLOB.chemical_reagents_list[reg.type]

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

	if(QDELETED(fuel_container))
		return 0

	//map of reagents & how much burning potential they all have
	var/static/list/reagent_coefficients = list(
		/datum/reagent/toxin/plasma = 1,
		/datum/reagent/fuel/oil = 0.9,
		/datum/reagent/fuel = 0.8,
		/datum/reagent/oxygen = 0.8,
		/datum/reagent/consumable/ethanol = 0.7,
		/datum/reagent/consumable/monkey_energy = 0.6,
		/datum/reagent/water = - 0.7
	)

	var/total_coefficient = 0
	for(var/datum/reagent/reg as anything in fuel_container.reagents.reagent_list)
		var/coefficient = -1 //any fuel that is not on the list acts as an inhibitor
		for(var/datum/reagent/fuel as anything in reagent_coefficients)
			if(istype(reg, fuel))
				coefficient = reagent_coefficients[fuel]
				break
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
		//transfer old container
		if(!QDELETED(distilled_container))
			user.put_in_hands(distilled_container)

		//add new container
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck in your hand."))
			return ITEM_INTERACT_BLOCKING
		distilled_container = tool

		START_PROCESSING(SSobj, src)
		balloon_alert(user, "distillation container added.")

		ui_interact(user)
		update_appearance(UPDATE_OVERLAYS)
		return ITEM_INTERACT_SUCCESS
	else if(istype(tool, /obj/item/assembly/igniter/condenser))
		if(!user.temporarilyRemoveItemFromInventory(tool))
			to_chat(user, span_warning("[tool] is stuck in your hand."))
			return ITEM_INTERACT_BLOCKING
		condenser_installed = TRUE
		update_static_data_for_all_viewers()
		qdel(tool)
		balloon_alert(user, "condenser installed.")
		return ITEM_INTERACT_SUCCESS

	///Try & ignite the bunset burner with this item
	var/ignition_message = tool.ignition_effect(src, user)
	if(!ignition_message)
		return NONE
	user.visible_message(ignition_message)
	toggle_burner(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/chem_separator/crowbar_act(mob/living/user, obj/item/tool)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/chem_separator/attack_hand(mob/living/user, list/modifiers)
	if(!QDELETED(distilled_container))
		if(!SStgui.get_open_ui(user, src)) //for convinience open ui first then interact with beakers if you still want to
			ui_interact(user)
			return TRUE

		if(user.put_in_hands(distilled_container))
			to_chat(user, span_notice("you take out the output flask."))
			update_appearance(UPDATE_OVERLAYS)
		return TRUE

	return ..()

/obj/structure/chem_separator/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	. = NONE
	if(user.combat_mode || tool.item_flags & ABSTRACT || tool.flags_1 & HOLOGRAM_1 || !user.can_perform_action(src, ALLOW_SILICON_REACH))
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(is_reagent_container(tool) && tool.is_open_container())
		//transfer old container
		if(!QDELETED(fuel_container))
			user.put_in_hands(fuel_container)

		//add new container
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck in your hand."))
			return ITEM_INTERACT_BLOCKING
		fuel_container = tool
		balloon_alert(user, "fuel container added.")

		ui_interact(user)
		return ITEM_INTERACT_SUCCESS

/obj/structure/chem_separator/attack_hand_secondary(mob/user, list/modifiers)
	if(!QDELETED(fuel_container))
		if(!SStgui.get_open_ui(user, src)) //for convinience open ui first then interact with beakers if you still want to
			ui_interact(user)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

		if(user.put_in_hands(fuel_container))
			to_chat(user, span_notice("you take out the burner fuel container"))
			toggle_burner(FALSE)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	return ..()

///Returns the coefficient of cooling of reagents, taking into consideration the condenser
/obj/structure/chem_separator/proc/get_cool_coefficient()
	PRIVATE_PROC(TRUE)

	var/coefficient = 0.2

	var/fuel_coefficient = get_ignition_coefficient()
	if(condenser_installed && condenser_on && fuel_coefficient > 0)
		var/datum/reagents/fuel = fuel_container.reagents
		if(fuel.remove_all(0.15))
			coefficient += fuel_coefficient
		else
			condenser_on = FALSE

	return coefficient

/obj/structure/chem_separator/process(seconds_per_tick)
	if(!reagents.total_volume)
		if(QDELETED(distilled_container) || !distilled_container.reagents.total_volume)
			boiling = FALSE
			soundloop.stop()
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

		var/knob_ratio = burner_knob / MAX_BURNER_KNOB_SETTINGS
		var/datum/reagents/fuel = fuel_container.reagents

		//consume some air after we have validated we have some good fuel. Only if we don't already use O2 as a fuel
		if(can_process && !fuel.has_reagent(/datum/reagent/oxygen))
			var/datum/gas_mixture/air = return_air()
			if(!air.remove_specific(/datum/gas/oxygen, 0.01 + (0.04 * knob_ratio))) //can burn anywhere between 0.01 & 0.05 moles of air based on the knob settings
				can_process = FALSE
				toggle_burner(FALSE)

		//burn some fuel if we combusted some air
		if(can_process)
			if(!fuel.remove_all(0.01 + (0.19 * knob_ratio))) //can burn anywhere between 0.01 & 0.2 units of fuel based on the knob settings
				can_process = FALSE
				toggle_burner(FALSE)

		//finally heat the mixture
		if(can_process)
			reagents.adjust_thermal_energy((1000 - reagents.chem_temp) * seconds_per_tick * SPECIFIC_HEAT_DEFAULT * (0.05 + (0.45 * knob_ratio)) * fuel_coefficient)
			reagents.handle_reactions()
	else if(reagents.chem_temp > DEFAULT_REAGENT_TEMPERATURE) //the container cools down if there is no flame heating it till it reaches room temps
		reagents.adjust_thermal_energy((DEFAULT_REAGENT_TEMPERATURE - reagents.chem_temp) * seconds_per_tick * SPECIFIC_HEAT_DEFAULT * get_cool_coefficient())
		reagents.handle_reactions()

	//the target distilation beaker also cools down
	if(!QDELETED(distilled_container) && distilled_container.reagents.chem_temp > DEFAULT_REAGENT_TEMPERATURE)
		var/datum/reagents/distiled_reagents = distilled_container.reagents
		distiled_reagents.adjust_thermal_energy((DEFAULT_REAGENT_TEMPERATURE - distiled_reagents.chem_temp) * seconds_per_tick * SPECIFIC_HEAT_DEFAULT * get_cool_coefficient())
		distiled_reagents.handle_reactions()

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
			update_appearance(UPDATE_OVERLAYS)
	else
		soundloop.stop()
		loop_started = FALSE
		update_appearance(UPDATE_OVERLAYS)

/obj/structure/chem_separator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemSeparator", name)
		ui.open()

/obj/structure/chem_separator/ui_static_data(mob/user)
	return list(
		"condenser_installed" = condenser_installed,
		"max_burner_knob_settings" = MAX_BURNER_KNOB_SETTINGS,
	)

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
	if(!QDELETED(fuel_container))
		var/datum/reagents/fuel_reagents = fuel_container.reagents

		fuel_data = list()
		fuel_data["total_volume"] = fuel_reagents.total_volume
		fuel_data["maximum_volume"] = fuel_reagents.maximum_volume
		fuel_data["temp"] = fuel_reagents.chem_temp
		fuel_data["color"] = mix_color_from_reagents(fuel_reagents.reagent_list)
	.["fuel"] = fuel_data

	//Knob setting
	.["burner_on"] = burner_on
	.["knob"] = burner_knob

	//Condenser setting
	.["condenser_on"] = condenser_on

/obj/structure/chem_separator/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("drain")
			if(QDELETED(distilled_container) || !reagents.total_volume)
				return FALSE

			if(reagents.trans_to(distilled_container.reagents, reagents.maximum_volume))
				toggle_burner(FALSE)
				return TRUE

		if("filter")
			if(QDELETED(distilled_container) || !distilled_container.reagents.total_volume)
				return FALSE

			if(distilled_container.reagents.trans_to(reagents, reagents.maximum_volume))
				update_appearance(UPDATE_OVERLAYS)
				return TRUE

		if("knob")
			var/setting = params["amount"]
			if(isnull(setting))
				return FALSE

			setting = text2num(setting)
			if(!setting)
				return FALSE

			burner_knob = clamp(setting, 1, MAX_BURNER_KNOB_SETTINGS)
			if(burner_on)
				set_light(ROUND_UP(2 * (burner_knob / MAX_BURNER_KNOB_SETTINGS)))
			return TRUE

		if("cool")
			if(!condenser_installed)
				return FALSE

			condenser_on = !condenser_on
			return TRUE

/obj/structure/chem_separator/click_alt(mob/user)
	if(!burner_on)
		return CLICK_ACTION_BLOCKING

	toggle_burner(FALSE)
	return CLICK_ACTION_SUCCESS

#undef MAX_BURNER_KNOB_SETTINGS
