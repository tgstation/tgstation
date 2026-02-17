///Same as a tier 1 chem heater
#define HEATER_COFFICIENT 0.1
///Decimal point in rounding temperature
#define TEMP_ROUNDING 0.01
///Minimal allowed difference temperature range
#define TEMP_DIFF 0.5

/obj/machinery/plumbing/acclimator
	name = "chemical acclimator"
	desc = "An efficient cooler and heater for the perfect showering temperature or illicit chemical factory."
	icon_state = "acclimator"
	base_icon_state = "acclimator"
	buffer = 200
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2

	///towards wich temperature do we build?
	var/target_temperature = 300
	///See code/__DEFINES/plumbing.dm
	var/acclimate_state = AC_FILLING
	///Maximum volume intake before processing
	var/max_volume = 200

/obj/machinery/plumbing/acclimator/Initialize(mapload, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/acclimator, layer)
	RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(clear))

/obj/machinery/plumbing/acclimator/update_icon_state()
	. = ..()

	icon_state = base_icon_state
	if(!is_operational || !anchored)
		return

	switch(acclimate_state)
		if(AC_FILLING)
			icon_state += "_fill"
		if(AC_HEATING)
			icon_state += "_hot"
		if(AC_COOLING)
			icon_state += "_cold"
		if(AC_EMPTYING)
			icon_state += "_empty"

/obj/machinery/plumbing/acclimator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(. == ITEM_INTERACT_SUCCESS)
		acclimate_state = AC_FILLING
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/acclimator/plunger_act(obj/item/plunger/attacking_plunger, mob/living/user, reinforced)
	. = ..()
	if(.)
		acclimate_state = AC_FILLING
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/acclimator/process(seconds_per_tick)
	if(!is_operational || !reagents.total_volume || acclimate_state == AC_FILLING || acclimate_state == AC_EMPTYING)
		return

	var/new_state = reagents.chem_temp > target_temperature ? AC_COOLING : AC_HEATING
	if(acclimate_state != new_state)
		acclimate_state = new_state
		update_appearance(UPDATE_ICON_STATE)

	var/energy = (target_temperature - reagents.chem_temp) * HEATER_COFFICIENT * seconds_per_tick * reagents.heat_capacity()
	reagents.adjust_thermal_energy(energy)
	reagents.handle_reactions()
	use_energy(active_power_usage + abs(ROUND_UP(energy) / 120))

	if(reagents.is_reacting)
		return

	var/temp = round(reagents.chem_temp, TEMP_ROUNDING)
	if(temp >= target_temperature - TEMP_DIFF && temp <= target_temperature + TEMP_DIFF)
		reagents.set_temperature(target_temperature)
		acclimate_state = AC_EMPTYING
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/acclimator/proc/clear()
	SIGNAL_HANDLER

	if(acclimate_state == AC_EMPTYING && !reagents.total_volume)
		acclimate_state = AC_FILLING
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/plumbing/acclimator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemAcclimator", name)
		ui.open()

/obj/machinery/plumbing/acclimator/ui_data(mob/user)
	return list(
		chem_temp = round(reagents.chem_temp, TEMP_ROUNDING),
		target_temperature = target_temperature,
		max_volume = max_volume,
		acclimate_state = acclimate_state
	)

/obj/machinery/plumbing/acclimator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_target_temperature")
			var/value = text2num(params["temperature"])
			if(!value)
				return FALSE

			target_temperature = round(clamp(value, 1, 1000), TEMP_ROUNDING)
			return TRUE

		if("change_volume")
			var/value = text2num(params["volume"])
			if(!value)
				return FALSE

			max_volume = round(clamp(value, 1, buffer), CHEMICAL_VOLUME_ROUNDING)
			return TRUE

#undef HEATER_COFFICIENT
#undef TEMP_ROUNDING
#undef TEMP_DIFF
