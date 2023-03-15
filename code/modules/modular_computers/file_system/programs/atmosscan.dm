#define ANALYZER_MODE_SURROUNDINGS 0
#define ANALYZER_MODE_TARGET 1
#define ANALYZER_HISTORY_SIZE 30
#define ANALYZER_HISTORY_MODE_KPA "kpa"
#define ANALYZER_HISTORY_MODE_MOL "mol"

/datum/computer_file/program/atmosscan
	filename = "atmosscan"
	filedesc = "AtmoZphere"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "air"
	extended_desc = "A small built-in sensor reads out the atmospheric conditions around the device."
	size = 4
	tgui_id = "NtosGasAnalyzer"
	program_icon = "thermometer-half"

	var/list/last_gasmix_data
	var/list/history_gasmix_data
	var/history_gasmix_index = 0
	var/history_view_mode = ANALYZER_HISTORY_MODE_KPA
	var/scan_range = 1
	var/auto_updating = TRUE
	var/target_mode = ANALYZER_MODE_SURROUNDINGS
	var/atom/scan_target

/// Keep this in sync with it's tool based counterpart [/obj/proc/analyzer_act] and [/atom/proc/tool_act]
/datum/computer_file/program/atmosscan/tap(atom/target, mob/living/user, params)
	if(!can_see(user, target, scan_range))
		on_analyze(source=computer, target=get_turf(computer), save_data=!auto_updating)
		return
	target_mode = ANALYZER_MODE_TARGET
	if(target == user || target == user.loc)
		target_mode = ANALYZER_MODE_SURROUNDINGS
	atmos_scan(user, target=(target.return_analyzable_air() ? target : get_turf(target)), print=FALSE)
	on_analyze(source=computer, target=(target.return_analyzable_air() ? target : get_turf(target)), save_data=!auto_updating)
	return TRUE

/datum/computer_file/program/atmosscan/proc/on_analyze(datum/source, atom/target, save_data=TRUE)
	LAZYINITLIST(history_gasmix_data)
	switch(target_mode)
		if(ANALYZER_MODE_SURROUNDINGS)
			scan_target = get_turf(source)
		if(ANALYZER_MODE_TARGET)
			scan_target = target
			if(!can_see(source, target, scan_range))
				target_mode = ANALYZER_MODE_SURROUNDINGS
				scan_target = get_turf(source)
			if(!scan_target)
				target_mode = ANALYZER_MODE_SURROUNDINGS
				scan_target = get_turf(source)

	var/mixture = scan_target.return_analyzable_air()
	if(!mixture)
		return FALSE
	var/list/airs = islist(mixture) ? mixture : list(mixture)
	var/list/new_gasmix_data = list()
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(lowertext(scan_target.name))
		if(scan_target == get_turf(source))
			mix_name = "Location Reading"
		if(airs.len != 1) //not a unary gas mixture
			mix_name += " - Node [airs.Find(air)]"
		new_gasmix_data += list(gas_mixture_parser(air, mix_name))
	last_gasmix_data = new_gasmix_data
	history_gasmix_index = 0
	if(save_data)
		if(length(history_gasmix_data) >= ANALYZER_HISTORY_SIZE)
			history_gasmix_data.Cut(ANALYZER_HISTORY_SIZE, length(history_gasmix_data) + 1)
		history_gasmix_data.Insert(1, list(new_gasmix_data))

/datum/computer_file/program/atmosscan/ui_static_data(mob/user)
	return return_atmos_handbooks()

/datum/computer_file/program/atmosscan/ui_data(mob/user)
	var/list/data = list()
	if(auto_updating)
		on_analyze(source=computer, target=scan_target)
	LAZYINITLIST(last_gasmix_data)
	LAZYINITLIST(history_gasmix_data)
	data["gasmixes"] = last_gasmix_data
	data["autoUpdating"] = auto_updating
	data["historyGasmixes"] = history_gasmix_data
	data["historyViewMode"] = history_view_mode
	data["historyIndex"] = history_gasmix_index
	return data

/datum/computer_file/program/atmosscan/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("autoscantoggle")
			auto_updating = !auto_updating
			return TRUE
		if("input")
			if(!length(history_gasmix_data))
				return TRUE
			var/target = params["target"]
			auto_updating = FALSE
			last_gasmix_data = history_gasmix_data[target]
			history_gasmix_index = target
			return TRUE
		if("clearhistory")
			history_gasmix_data = list()
			return TRUE
		if("modekpa")
			history_view_mode = ANALYZER_HISTORY_MODE_KPA
			return TRUE
		if("modemol")
			history_view_mode = ANALYZER_HISTORY_MODE_MOL
			return TRUE

#undef ANALYZER_MODE_SURROUNDINGS
#undef ANALYZER_MODE_TARGET
#undef ANALYZER_HISTORY_SIZE
#undef ANALYZER_HISTORY_MODE_KPA
#undef ANALYZER_HISTORY_MODE_MOL
