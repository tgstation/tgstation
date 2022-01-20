///Atoms with this component can call it in order to get a scan of surrounding atmospherics sent to a specific mob.
/datum/component/gas_analyzer
	var/visible = TRUE

/datum/component/gas_analyzer/Initialize(...)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/gas_analyzer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_GAS_ENVIRONMENT_SCAN, .proc/analyzer_scan)

/datum/component/gas_analyzer/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_GAS_ENVIRONMENT_SCAN)

/datum/component/gas_analyzer/proc/analyzer_scan(datum/source, mob/user, visible)
	SIGNAL_HANDLER
	if (visible && (user.stat || user.is_blind())) //check if it requires visibility and if the user is you know, blind.
		return

	var/turf/location = user.loc
	if(!istype(location))
		return

	var/render_list = list()
	var/datum/gas_mixture/environment = location.return_air()
	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()

	render_list += "[span_info("<B>Results:</B>")]\
				\n<span class='[abs(pressure - ONE_ATMOSPHERE) < 10 ? "info" : "alert"]'>Pressure: [round(pressure, 0.01)] kPa</span>\n"
	if(total_moles)
		var/list/env_gases = environment.gases

		environment.assert_gases(arglist(GLOB.hardcoded_gases))
		var/o2_concentration = env_gases[/datum/gas/oxygen][MOLES]/total_moles
		var/n2_concentration = env_gases[/datum/gas/nitrogen][MOLES]/total_moles
		var/co2_concentration = env_gases[/datum/gas/carbon_dioxide][MOLES]/total_moles
		var/plasma_concentration = env_gases[/datum/gas/plasma][MOLES]/total_moles

		render_list += "<span class='[abs(n2_concentration - N2STANDARD) < 20 ? "info" : "alert"]'>Nitrogen: [round(n2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/nitrogen][MOLES], 0.01)] mol)</span>\
			\n<span class='[abs(o2_concentration - O2STANDARD) < 2 ? "info" : "alert"]'>Oxygen: [round(o2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/oxygen][MOLES], 0.01)] mol)</span>\
			\n<span class='[co2_concentration > 0.01 ? "alert" : "info"]'>CO2: [round(co2_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/carbon_dioxide][MOLES], 0.01)] mol)</span>\
			\n<span class='[plasma_concentration > 0.005 ? "alert" : "info"]'>Plasma: [round(plasma_concentration*100, 0.01)] % ([round(env_gases[/datum/gas/plasma][MOLES], 0.01)] mol)</span>\n"

		environment.garbage_collect()

		for(var/id in env_gases)
			if(id in GLOB.hardcoded_gases)
				continue
			var/gas_concentration = env_gases[id][MOLES]/total_moles
			render_list += "[span_alert("[env_gases[id][GAS_META][META_GAS_NAME]]: [round(gas_concentration*100, 0.01)] % ([round(env_gases[id][MOLES], 0.01)] mol)")]\n"
		render_list += "[span_info("Temperature: [round(environment.temperature-T0C, 0.01)] &deg;C ([round(environment.temperature, 0.01)] K)")]\n"
	// we handled the last <br> so we don't need handholding
	to_chat(user, jointext(render_list, ""), trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
