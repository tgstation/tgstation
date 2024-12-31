#define MIN_PROGRESS_AMOUNT 3
#define MIN_DEVIATION_RATE 0.90
#define MAX_DEVIATION_RATE 1.1
#define HIGH_CONDUCTIVITY_RATIO 0.95

/obj/machinery/atmospherics/components/binary/crystallizer
	icon = 'icons/obj/machines/atmospherics/machines.dmi'
	icon_state = "crystallizer-off"
	base_icon_state = "crystallizer"
	name = "crystallizer"
	desc = "Used to crystallize or solidify gases."
	layer = ABOVE_MOB_LAYER
	density = TRUE
	max_integrity = 300
	armor_type = /datum/armor/binary_crystallizer
	circuit = /obj/item/circuitboard/machine/crystallizer
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	vent_movement = NONE

	///Internal Gas mix used for processing the gases that have been put in
	var/datum/gas_mixture/internal
	///Var that controls how much gas gets injected in moles per tick
	var/gas_input = 0
	///Saves the progress during the processing of the items
	var/progress_bar = 0
	///Stores the amount of lost quality
	var/quality_loss = 0
	///Stores the recipe selected by the user in the GUI
	var/datum/gas_recipe/selected_recipe = null
	///Stores the total amount of moles needed for the current recipe
	var/total_recipe_moles = 0

/datum/armor/binary_crystallizer
	energy = 100
	fire = 80
	acid = 30

/obj/machinery/atmospherics/components/binary/crystallizer/Initialize(mapload)
	. = ..()
	internal = new
	register_context()

/obj/machinery/atmospherics/components/binary/crystallizer/on_deconstruction(disassembled)
	var/turf/local_turf = get_turf(loc)
	if(internal.total_moles())
		local_turf.assume_air(internal)
	return ..()

/obj/machinery/atmospherics/components/binary/crystallizer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Turn [on ? "off" : "on"]"
	if(!held_item)
		return CONTEXTUAL_SCREENTIP_SET
	switch(held_item.tool_behaviour)
		if(TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] panel"
		if(TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_RMB] = "Rotate"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/atmospherics/components/binary/crystallizer/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, "[base_icon_state]-open", "[base_icon_state]-off", I))
			return
	if(default_change_direction_wrench(user, I))
		return
	return ..()

/obj/machinery/atmospherics/components/binary/crystallizer/crowbar_act(mob/living/user, obj/item/tool)
	return crowbar_deconstruction_act(user, tool, internal.return_pressure())

/obj/machinery/atmospherics/components/binary/crystallizer/update_overlays()
	. = ..()
	cut_overlays()
	var/mutable_appearance/pipe_appearance1 = mutable_appearance('icons/obj/pipes_n_cables/pipe_underlays.dmi', "intact_[dir]_[piping_layer]", layer = GAS_SCRUBBER_LAYER)
	pipe_appearance1.color = COLOR_LIME
	var/mutable_appearance/pipe_appearance2 = mutable_appearance('icons/obj/pipes_n_cables/pipe_underlays.dmi', "intact_[REVERSE_DIR(dir)]_[piping_layer]", layer = GAS_SCRUBBER_LAYER)
	pipe_appearance2.color = COLOR_MOSTLY_PURE_RED
	. += pipe_appearance1
	. += pipe_appearance2

/obj/machinery/atmospherics/components/binary/crystallizer/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "[base_icon_state]-open"
	else if(on && is_operational)
		icon_state = "[base_icon_state]-on"
	else
		icon_state = "[base_icon_state]-off"

/obj/machinery/atmospherics/components/binary/crystallizer/click_ctrl(mob/user)
	if(!is_operational)
		return CLICK_ACTION_BLOCKING
	if(panel_open)
		balloon_alert(user, "close panel!")
		return CLICK_ACTION_BLOCKING
	on = !on
	balloon_alert(user, "turned [on ? "on" : "off"]")
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	update_icon()
	return CLICK_ACTION_SUCCESS

///Checks if the reaction temperature is inside the range of temperature + a little deviation
/obj/machinery/atmospherics/components/binary/crystallizer/proc/check_temp_requirements()
	if(internal.temperature >= selected_recipe.min_temp * MIN_DEVIATION_RATE && internal.temperature <= selected_recipe.max_temp * MAX_DEVIATION_RATE)
		return TRUE
	return FALSE

///Injects the gases from the input inside the internal gasmix, the amount is dependent on the gas_input var
/obj/machinery/atmospherics/components/binary/crystallizer/proc/inject_gases()
	var/datum/gas_mixture/contents = airs[2]
	for(var/gas_type in selected_recipe.requirements)
		if(!contents.gases[gas_type] || !contents.gases[gas_type][MOLES])
			continue
		if(internal.gases[gas_type] && internal.gases[gas_type][MOLES] >= selected_recipe.requirements[gas_type] * 2)
			continue
		internal.merge(contents.remove_specific(gas_type, contents.gases[gas_type][MOLES] * gas_input))

///Checks if the gases required are all inside
/obj/machinery/atmospherics/components/binary/crystallizer/proc/internal_check()
	var/gas_check = 0
	for(var/gas_type in selected_recipe.requirements)
		if(!internal.gases[gas_type] || !internal.gases[gas_type][MOLES])
			return FALSE
		if(internal.gases[gas_type][MOLES] >= selected_recipe.requirements[gas_type])
			gas_check++
	if(gas_check == selected_recipe.requirements.len)
		return TRUE
	return FALSE

///Calculation for the heat of the various gas mixes and controls the quality of the item
/obj/machinery/atmospherics/components/binary/crystallizer/proc/heat_calculations()
	var/progress_amount_to_quality = MIN_PROGRESS_AMOUNT * 4.5 / (round(log(10, total_recipe_moles * 0.1), 0.01))
	if((internal.temperature >= (selected_recipe.min_temp * MIN_DEVIATION_RATE) && internal.temperature <= selected_recipe.min_temp) || \
		(internal.temperature >= selected_recipe.max_temp && internal.temperature <= (selected_recipe.max_temp * MAX_DEVIATION_RATE)))
		quality_loss = min(quality_loss + progress_amount_to_quality, 100)

	var/median_temperature = (selected_recipe.max_temp + selected_recipe.min_temp) / 2
	if(internal.temperature >= (median_temperature * MIN_DEVIATION_RATE) && internal.temperature <= (median_temperature * MAX_DEVIATION_RATE))
		quality_loss = max(quality_loss - progress_amount_to_quality, -85)

	internal.temperature = max(internal.temperature + (selected_recipe.energy_release / internal.heat_capacity()), TCMB)
	update_parents()

///Conduction between the internal gasmix and the moderating (cooling/heating) gasmix.
/obj/machinery/atmospherics/components/binary/crystallizer/proc/heat_conduction()
	var/datum/gas_mixture/cooling_port = airs[1]
	if(cooling_port.total_moles() > MINIMUM_MOLE_COUNT)
		if(internal.total_moles() > 0)
			var/coolant_temperature_delta = cooling_port.temperature - internal.temperature
			var/cooling_heat_capacity = cooling_port.heat_capacity()
			var/internal_heat_capacity = internal.heat_capacity()
			var/cooling_heat_amount = HIGH_CONDUCTIVITY_RATIO * coolant_temperature_delta * (cooling_heat_capacity * internal_heat_capacity / (cooling_heat_capacity + internal_heat_capacity))
			cooling_port.temperature = max(cooling_port.temperature - cooling_heat_amount / cooling_heat_capacity, TCMB)
			internal.temperature = max(internal.temperature + cooling_heat_amount / internal_heat_capacity, TCMB)
			update_parents()

///Calculate the total moles needed for the recipe
/obj/machinery/atmospherics/components/binary/crystallizer/proc/moles_calculations()
	var/amounts = 0
	for(var/gas_type in selected_recipe.requirements)
		amounts += selected_recipe.requirements[gas_type]
	total_recipe_moles = amounts

///Removes the gases from the internal gasmix when the recipe is changed
/obj/machinery/atmospherics/components/binary/crystallizer/proc/dump_gases()
	var/datum/gas_mixture/remove = internal.remove(internal.total_moles())
	airs[2].merge(remove)
	internal.garbage_collect()

/obj/machinery/atmospherics/components/binary/crystallizer/process_atmos()
	if(!on || !is_operational || selected_recipe == null)
		return

	inject_gases()

	if(!internal.total_moles())
		return

	heat_conduction()

	if(internal_check())
		if(check_temp_requirements())
			heat_calculations()
			progress_bar = min(progress_bar + (MIN_PROGRESS_AMOUNT * 5 / (round(log(10, total_recipe_moles * 0.1), 0.01))), 100)
		else
			quality_loss = min(quality_loss + 0.5, 100)
			progress_bar = max(progress_bar - 1, 0)
	if(progress_bar != 100)
		update_parents()
		return
	progress_bar = 0

	for(var/gas_type in selected_recipe.requirements)
		var/required_gas_moles = selected_recipe.requirements[gas_type]
		var/amount_consumed = required_gas_moles + (required_gas_moles * (quality_loss * 0.01))
		if(internal.gases[gas_type][MOLES] < amount_consumed)
			quality_loss = min(quality_loss + 10, 100)
		internal.remove_specific(gas_type, amount_consumed)

	var/total_quality = clamp(50 - quality_loss, 0, 100)
	var/quality_control
	switch(total_quality)
		if(100)
			quality_control = "Masterwork"
		if(95 to 99)
			quality_control = "Supreme"
		if(75 to 94)
			quality_control = "Good"
		if(65 to 74)
			quality_control = "Decent"
		if(55 to 64)
			quality_control = "Average"
		if(35 to 54)
			quality_control = "Ok"
		if(15 to 34)
			quality_control = "Poor"
		if(5 to 14)
			quality_control = "Ugly"
		if(1 to 4)
			quality_control = "Cracked"
		if(0)
			quality_control = "Oh God why"

	for(var/path in selected_recipe.products)
		var/amount_produced = selected_recipe.products[path]
		for(var/i in 1 to amount_produced)
			var/obj/creation = new path(get_step(src, SOUTH))
			creation.name = "[quality_control] [creation.name]"
			if(selected_recipe.dangerous)
				investigate_log("[creation.name] has been created in the crystallizer.", INVESTIGATE_ENGINE)
				message_admins("[creation.name] has been created in the crystallizer [ADMIN_JMP(src)].")


	quality_loss = 0
	update_parents()

/obj/machinery/atmospherics/components/binary/crystallizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Crystallizer", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/crystallizer/ui_static_data()
	var/data = list()
	data["selected_recipes"] = list(list("name" = "Nothing", "id" = ""))
	for(var/path in GLOB.gas_recipe_meta)
		var/datum/gas_recipe/recipe = GLOB.gas_recipe_meta[path]
		if(recipe.machine_type != "Crystallizer")
			continue
		data["selected_recipes"] += list(list("name" = recipe.name, "id" = recipe.id))
	return data

/obj/machinery/atmospherics/components/binary/crystallizer/ui_data()
	var/data = list()
	data["on"] = on

	if(selected_recipe)
		data["selected"] = selected_recipe.id
	else
		data["selected"] = ""

	var/list/internal_gas_data = list()
	if(internal.total_moles())
		for(var/gasid in internal.gases)
			internal_gas_data.Add(list(list(
			"name"= internal.gases[gasid][GAS_META][META_GAS_NAME],
			"id" = internal.gases[gasid][GAS_META][META_GAS_ID],
			"amount" = round(internal.gases[gasid][MOLES], 0.01),
			)))
	else
		for(var/gasid in internal.gases)
			internal_gas_data.Add(list(list(
				"name"= internal.gases[gasid][GAS_META][META_GAS_NAME],
				"id" = internal.gases[gasid][GAS_META][META_GAS_ID],
				"amount" = 0,
				)))
	data["internal_gas_data"] = internal_gas_data

	var/list/requirements
	if(!selected_recipe)
		requirements = list("Select a recipe to see the requirements")
	else
		requirements = list("To create [selected_recipe.name] you will need:")
		for(var/gas_type in selected_recipe.requirements)
			var/datum/gas/gas_required = gas_type
			var/amount_consumed = selected_recipe.requirements[gas_type]
			requirements += "-[amount_consumed] moles of [initial(gas_required.name)]"
		requirements += "In a temperature range between [selected_recipe.min_temp] K and [selected_recipe.max_temp] K"
		requirements += "The crystallization reaction will be [selected_recipe.energy_release ? (selected_recipe.energy_release > 0 ? "exothermic" : "endothermic") : "thermally neutral"]"
	data["requirements"] = requirements.Join("\n")

	var/temperature
	if(internal.total_moles())
		temperature = internal.temperature
	else
		temperature = 0
	data["internal_temperature"] = temperature
	data["progress_bar"] = progress_bar
	data["gas_input"] = gas_input
	return data

/obj/machinery/atmospherics/components/binary/crystallizer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("recipe")
			selected_recipe = null
			var/recipe_name = "nothing"
			var/datum/gas_recipe/recipe = GLOB.gas_recipe_meta[params["mode"]]
			if(internal.total_moles())
				dump_gases()
			quality_loss = 0
			progress_bar = 0
			if(recipe && recipe.id != "")
				selected_recipe = recipe
				recipe_name = recipe.name
				update_parents() //prevent the machine from stopping because of the recipe change and the pipenet not updating
				moles_calculations()
			investigate_log("was set to recipe [recipe_name ? recipe_name : "null"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			. = TRUE
		if("gas_input")
			var/_gas_input = params["gas_input"]
			gas_input = clamp(_gas_input, 0, 250)
	update_icon()

/obj/machinery/atmospherics/components/binary/crystallizer/update_layer()
	return

#undef MIN_PROGRESS_AMOUNT
#undef MIN_DEVIATION_RATE
#undef MAX_DEVIATION_RATE
#undef HIGH_CONDUCTIVITY_RATIO
