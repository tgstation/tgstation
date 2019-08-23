//we cant use defines in tgui, so use a string instead of magic numbers
#define COOLING "Cooling"
#define HEATING "Heating"
#define NEUTRAL "Neutral"

///this the plumbing version of a heater/freezer.
/obj/machinery/plumbing/acclimator
	name = "chemical acclimator"
	desc = "An efficient cooler and heater for the perfect showering temperature or illicit chemical factory."

	icon_state = "acclimator"
	buffer = 200

	///towards wich temperature do we build?
	var/target_temperature = 300
	///I cant find a good name for this. Basically if target is 300, and this is 10, it will still target 300 but will start emptying itself at 290 and 310.
	var/allowed_temperature_difference = 0
	///cool/heat power
	var/heater_coefficient = 0.1
	///Are we turned on or off? this is from the on and off button
	var/enabled = TRUE
	///COOLING, HEATING or NEUTRAL. We track this for change, so we dont needlessly update our icon
	var/acclimate_state

	ui_x = 300
	ui_y = 260

/obj/machinery/plumbing/acclimator/Initialize()
	. = ..()
	AddComponent(/datum/component/plumbing/acclimator)

/obj/machinery/plumbing/acclimator/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/plumbing/acclimator/process()
	if(stat & NOPOWER || !enabled || !reagents.total_volume || reagents.chem_temp == target_temperature)
		if(acclimate_state != NEUTRAL)
			acclimate_state = NEUTRAL
			update_icon()
		return

	if(reagents.chem_temp < target_temperature && acclimate_state != HEATING) //note that we check if the temperature is the same at the start
		acclimate_state = HEATING
		update_icon()
	else if(reagents.chem_temp > target_temperature && acclimate_state != COOLING)
		acclimate_state = COOLING
		update_icon()

	reagents.adjust_thermal_energy((target_temperature - reagents.chem_temp) * heater_coefficient * SPECIFIC_HEAT_DEFAULT * reagents.total_volume) //keep constant with chem heater
	reagents.handle_reactions()

/obj/machinery/plumbing/acclimator/update_icon()
	icon_state = initial(icon_state)
	switch(acclimate_state)
		if(COOLING)
			icon_state += "_cold"
		if(HEATING)
			icon_state += "_hot"

/obj/machinery/plumbing/acclimator/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "acclimator", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/plumbing/acclimator/ui_data(mob/user)
	var/list/data = list()

	data["enabled"] = enabled
	data["chem_temp"] = reagents.chem_temp
	data["target_temperature"] = target_temperature
	data["allowed_temperature_difference"] = allowed_temperature_difference
	data["acclimate_state"] = acclimate_state
	return data

/obj/machinery/plumbing/acclimator/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("set_target_temperature")
			var/target = input("New target temperature:", name, target_temperature) as num|null
			target_temperature = CLAMP(target, 0, 1000)
		if("set_allowed_temperature_difference")
			var/target = input("New acceptable difference:", name, allowed_temperature_difference) as num|null
			allowed_temperature_difference = CLAMP(target, 0, 1000)
		if("turn_on")
			enabled = TRUE
		if("turn_off")
			enabled = FALSE
#undef COOLING
#undef HEATING
#undef NEUTRAL
