/// Scan the turf where the computer is on.
#define ATMOZPHERE_SCAN_ENV "env"
/// Scan the objects that the tablet clicks.
#define ATMOZPHERE_SCAN_CLICK "click"

/datum/computer_file/program/atmosscan
	filename = "atmosscan"
	filedesc = "AtmoZphere"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "air"
	extended_desc = "A small built-in sensor reads out the atmospheric conditions around the device."
	size = 4
	tgui_id = "NtosGasAnalyzer"
	program_icon = "thermometer-half"

	var/atmozphere_mode = ATMOZPHERE_SCAN_ENV
	var/list/last_gasmix_data

/// Secondary attack self.
/datum/computer_file/program/atmosscan/proc/turf_analyze(datum/source, mob/user)
	SIGNAL_HANDLER
	atmos_scan(user=user, target=get_turf(computer), silent=FALSE)
	on_analyze(source=source, target=get_turf(computer))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Updates our gasmix data if on click mode.
/datum/computer_file/program/atmosscan/proc/on_analyze(datum/source, atom/target)
	SIGNAL_HANDLER
	var/mixture = target.return_analyzable_air()
	if(!mixture)
		return FALSE
	var/list/airs = islist(mixture) ? mixture : list(mixture)
	var/list/new_gasmix_data = list()
	for(var/datum/gas_mixture/air as anything in airs)
		var/mix_name = capitalize(lowertext(target.name))
		if(airs.len != 1) //not a unary gas mixture
			mix_name += " - Node [airs.Find(air)]"
		new_gasmix_data += list(gas_mixture_parser(air, mix_name))
	last_gasmix_data = new_gasmix_data

/datum/computer_file/program/atmosscan/ui_static_data(mob/user)
	return return_atmos_handbooks()

/datum/computer_file/program/atmosscan/ui_data(mob/user)
	var/list/data = get_header_data()
	var/turf/turf = get_turf(computer)
	data["atmozphereMode"] = atmozphere_mode
	data["clickAtmozphereCompatible"] = computer.hardware_flag == PROGRAM_TABLET
	switch (atmozphere_mode) //Null air wont cause errors, don't worry.
		if(ATMOZPHERE_SCAN_ENV)
			var/datum/gas_mixture/air = turf?.return_air()
			data["gasmixes"] = list(gas_mixture_parser(air, "Location Reading"))
		if(ATMOZPHERE_SCAN_CLICK)
			LAZYINITLIST(last_gasmix_data)
			data["gasmixes"] = last_gasmix_data
	return data

/datum/computer_file/program/atmosscan/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	switch(action)
		if("scantoggle")
			if(atmozphere_mode == ATMOZPHERE_SCAN_CLICK)
				atmozphere_mode = ATMOZPHERE_SCAN_ENV
				if(computer.tool_behaviour == TOOL_ANALYZER)
					computer.tool_behaviour = NONE
					UnregisterSignal(computer, COMSIG_TOOL_ATOM_ACTED_PRIMARY(TOOL_ANALYZER))
					UnregisterSignal(computer, COMSIG_ITEM_ATTACK_SELF_SECONDARY)
				return TRUE
			if(computer.hardware_flag != PROGRAM_TABLET)
				computer.say("Device incompatible for scanning objects!")
				return FALSE
			atmozphere_mode = ATMOZPHERE_SCAN_CLICK
			computer.tool_behaviour = TOOL_ANALYZER
			RegisterSignal(computer, COMSIG_TOOL_ATOM_ACTED_PRIMARY(TOOL_ANALYZER), .proc/on_analyze)
			RegisterSignal(computer, COMSIG_ITEM_ATTACK_SELF_SECONDARY, .proc/turf_analyze)
			var/turf/turf = get_turf(computer)
			last_gasmix_data = list(gas_mixture_parser(turf?.return_air(), "Location Reading"))
