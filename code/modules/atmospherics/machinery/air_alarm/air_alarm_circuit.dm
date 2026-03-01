/obj/item/circuit_component/air_alarm_general
	display_name = "Air Alarm"
	desc = "Outputs basic information that the air alarm has recorded"

	var/obj/machinery/airalarm/connected_alarm

	/// Enables the fire alarm
	var/datum/port/input/enable_fire_alarm
	/// Disables the fire alarm
	var/datum/port/input/disable_fire_alarm

	/// The mode to set the air alarm to
	var/datum/port/input/option/mode
	/// The trigger to set the mode
	var/datum/port/input/set_mode

	/// Whether the fire alarm is enabled or not
	var/datum/port/output/fire_alarm_enabled
	/// The current set mode
	var/datum/port/output/current_mode

	var/static/list/options_map

/obj/item/circuit_component/air_alarm_general/populate_options()
	if(!options_map)
		options_map = list()
		for(var/mode_path in GLOB.air_alarm_modes)
			var/datum/air_alarm_mode/mode = GLOB.air_alarm_modes[mode_path]
			if(!mode.emag)
				options_map[mode.name] = mode.type

/obj/item/circuit_component/air_alarm_general/populate_ports()
	mode = add_option_port("Mode", options_map, order = 1)
	set_mode = add_input_port("Set Mode", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_mode))
	enable_fire_alarm = add_input_port("Enable Alarm", PORT_TYPE_SIGNAL, trigger = PROC_REF(trigger_alarm))
	disable_fire_alarm = add_input_port("Disable Alarm", PORT_TYPE_SIGNAL, trigger = PROC_REF(trigger_alarm))

	fire_alarm_enabled = add_output_port("Alarm Enabled", PORT_TYPE_NUMBER)
	current_mode = add_output_port("Current Mode", PORT_TYPE_STRING)

/obj/item/circuit_component/air_alarm_general/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/airalarm))
		connected_alarm = shell
		RegisterSignal(connected_alarm.alarm_manager, COMSIG_ALARM_TRIGGERED, PROC_REF(on_alarm_triggered))
		RegisterSignal(connected_alarm.alarm_manager, COMSIG_ALARM_CLEARED, PROC_REF(on_alarm_cleared))
		RegisterSignal(shell, COMSIG_AIRALARM_UPDATE_MODE, PROC_REF(on_mode_updated))
		current_mode.set_value(connected_alarm.selected_mode.name)

/obj/item/circuit_component/air_alarm_general/unregister_usb_parent(atom/movable/shell)
	if(connected_alarm)
		UnregisterSignal(connected_alarm.alarm_manager, list(
			COMSIG_ALARM_TRIGGERED,
			COMSIG_ALARM_CLEARED,
		))
	connected_alarm = null

	UnregisterSignal(shell, list(
		COMSIG_AIRALARM_UPDATE_MODE,
	))
	return ..()

/obj/item/circuit_component/air_alarm_general/proc/on_mode_updated(obj/machinery/airalarm/alarm, datum/signal_source)
	SIGNAL_HANDLER
	current_mode.set_value(alarm.selected_mode.name)

/obj/item/circuit_component/air_alarm_general/proc/on_alarm_triggered(datum/source, alarm_type, area/location)
	SIGNAL_HANDLER
	if(alarm_type == ALARM_ATMOS)
		fire_alarm_enabled.set_output(TRUE)

/obj/item/circuit_component/air_alarm_general/proc/on_alarm_cleared(datum/source, alarm_type, area/location)
	SIGNAL_HANDLER
	if(alarm_type == ALARM_ATMOS)
		fire_alarm_enabled.set_output(FALSE)


/obj/item/circuit_component/air_alarm_general/proc/trigger_alarm(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!connected_alarm || connected_alarm.locked)
		return

	if(port == enable_fire_alarm)
		if(connected_alarm.alarm_manager.send_alarm(ALARM_ATMOS))
			connected_alarm.danger_level = AIR_ALARM_ALERT_HAZARD
	else
		if(connected_alarm.alarm_manager.clear_alarm(ALARM_ATMOS))
			connected_alarm.danger_level = AIR_ALARM_ALERT_NONE

/obj/item/circuit_component/air_alarm_general/proc/set_mode(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!connected_alarm || connected_alarm.locked)
		return

	if(!mode.value)
		return

	connected_alarm.select_mode(parent.get_creator(), options_map[mode.value])
	connected_alarm.investigate_log("was turned to [connected_alarm.selected_mode.name] by [parent.get_creator()]", INVESTIGATE_ATMOS)

/obj/item/circuit_component/air_alarm
	display_name = "Air Alarm Core Control"
	desc = "Controls levels of gases and their temperature as well as all vents and scrubbers in the room."

	var/datum/port/input/option/air_alarm_options

	var/datum/port/input/min_2
	var/datum/port/input/min_1
	var/datum/port/input/max_1
	var/datum/port/input/max_2

	var/datum/port/input/set_data
	var/datum/port/input/request_data

	var/datum/port/output/pressure
	var/datum/port/output/temperature
	var/datum/port/output/gas_amount
	var/datum/port/output/update_received

	var/obj/machinery/airalarm/connected_alarm
	var/list/options_map

	ui_buttons = list(
		"plus" = "add_new_component"
	)

	var/list/alarm_duplicates = list()
	var/max_alarm_duplicates = 20

/obj/item/circuit_component/air_alarm/ui_perform_action(mob/user, action)
	if(length(alarm_duplicates) >= max_alarm_duplicates)
		return

	if(action == "add_new_component")
		var/obj/item/circuit_component/air_alarm/component = new /obj/item/circuit_component/air_alarm/duplicate(parent)
		parent.add_component(component)
		RegisterSignal(component, COMSIG_QDELETING, PROC_REF(on_duplicate_removed))
		component.connected_alarm = connected_alarm
		alarm_duplicates += component

/obj/item/circuit_component/air_alarm/proc/on_duplicate_removed(datum/source)
	SIGNAL_HANDLER
	alarm_duplicates -= source

/obj/item/circuit_component/air_alarm/populate_ports()
	min_2 = add_input_port("Hazard Minimum", PORT_TYPE_NUMBER, trigger = null)
	min_1 = add_input_port("Warning Minimum", PORT_TYPE_NUMBER, trigger = null)
	max_1 = add_input_port("Warning Maximum", PORT_TYPE_NUMBER, trigger = null)
	max_2 = add_input_port("Hazard Maximum", PORT_TYPE_NUMBER, trigger = null)
	set_data = add_input_port("Set Limits", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_limits))
	request_data = add_input_port("Request Data", PORT_TYPE_SIGNAL)

	pressure = add_output_port("Pressure", PORT_TYPE_NUMBER)
	temperature = add_output_port("Temperature", PORT_TYPE_NUMBER)
	gas_amount = add_output_port("Chosen Gas Amount", PORT_TYPE_NUMBER)
	update_received = add_output_port("Update Received", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/air_alarm/populate_options()
	var/static/list/component_options

	if(!component_options)
		component_options = list(
			"Pressure" = "pressure",
			"Temperature" = "temperature"
		)

		for(var/gas_id in GLOB.meta_gas_info)
			component_options[GLOB.meta_gas_info[gas_id][META_GAS_NAME]] = gas_id2path(gas_id)

	air_alarm_options = add_option_port("Air Alarm Options", component_options)
	options_map = component_options

/obj/item/circuit_component/air_alarm/duplicate
	display_name = "Air Alarm Control"

	circuit_size = 0
	ui_buttons = list()

/obj/item/circuit_component/air_alarm/duplicate/removed_from(obj/item/integrated_circuit/removed_from)
	if(!QDELING(src))
		qdel(src)
	return ..()

/obj/item/circuit_component/air_alarm/duplicate/Destroy()
	connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm/removed_from(obj/item/integrated_circuit/removed_from)
	QDEL_LIST(alarm_duplicates)
	return ..()

/obj/item/circuit_component/air_alarm/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/airalarm))
		connected_alarm = shell

/obj/item/circuit_component/air_alarm/unregister_usb_parent(atom/movable/shell)
	connected_alarm = null
	for(var/obj/item/circuit_component/air_alarm/alarm as anything in alarm_duplicates)
		alarm.connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm/proc/set_limits()
	CIRCUIT_TRIGGER
	if(!connected_alarm || connected_alarm.locked)
		return

	var/current_option = air_alarm_options.value

	if(!current_option)
		return

	var/datum/tlv/settings = connected_alarm.tlv_collection[options_map[current_option]]
	if(min_2.value != null)
		settings.hazard_min = min_2.value
	if(min_1.value != null)
		settings.warning_min = min_1.value
	if(max_1.value != null)
		settings.warning_max = max_1.value
	if(max_2.value != null)
		settings.hazard_max = max_2.value

/obj/item/circuit_component/air_alarm/input_received(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/current_option = air_alarm_options.value

	var/datum/gas_mixture/environment = connected_alarm.get_enviroment()
	pressure.set_output(round(environment.return_pressure()))
	temperature.set_output(round(environment.temperature))
	if(ispath(options_map[current_option]))
		gas_amount.set_output(round(environment.gases[options_map[current_option]][MOLES]))

	update_received.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/air_alarm_scrubbers
	display_name = "Air Alarm Scrubber Core Control"
	desc = "Controls the scrubbers in the room."

	var/datum/port/input/option/scrubbers

	/// Enables the scrubber
	var/datum/port/input/enable
	/// Disables the scrubber
	var/datum/port/input/disable

	/// Enables siphoning
	var/datum/port/input/enable_siphon
	/// Disables siphoning
	var/datum/port/input/disable_siphon
	/// Enables extended range
	var/datum/port/input/enable_extended_range
	/// Disables extended range
	var/datum/port/input/disable_extended_range
	/// Gas to filter using the scrubber
	var/datum/port/input/gas_filter
	/// Sets the filter
	var/datum/port/input/set_gas_filter
	/// Requests an update of the data
	var/datum/port/input/request_update


	/// Whether the scrubber is enabled or not
	var/datum/port/output/enabled
	/// Whether the scrubber is siphoning or not
	var/datum/port/output/is_siphoning
	/// Information based on what the scrubber is filtering. Outputs null if the scrubber is siphoning
	var/datum/port/output/filtering
	/// Sent when an update is received
	var/datum/port/output/update_received

	var/obj/machinery/airalarm/connected_alarm

	ui_buttons = list(
		"plus" = "add_new_component"
	)

	var/static/list/filtering_map = list()

	var/max_scrubber_duplicates = 20
	var/list/scrubber_duplicates = list()

/obj/item/circuit_component/air_alarm_scrubbers/ui_perform_action(mob/user, action)
	if(length(scrubber_duplicates) >= max_scrubber_duplicates)
		return

	if(action == "add_new_component")
		var/obj/item/circuit_component/air_alarm_scrubbers/component = new /obj/item/circuit_component/air_alarm_scrubbers/duplicate(parent)
		parent.add_component(component)
		RegisterSignal(component, COMSIG_QDELETING, PROC_REF(on_duplicate_removed))
		component.connected_alarm = connected_alarm
		component.scrubbers.possible_options = extract_id_tags(connected_alarm.my_area.air_scrubbers)
		scrubber_duplicates += component

/obj/item/circuit_component/air_alarm_scrubbers/proc/on_duplicate_removed(datum/source)
	SIGNAL_HANDLER
	scrubber_duplicates -= source

/obj/item/circuit_component/air_alarm_scrubbers/populate_options()
	scrubbers = add_option_port("Scrubber", null)

/obj/item/circuit_component/air_alarm_scrubbers/populate_ports()
	gas_filter = add_input_port("Gas To Filter", PORT_TYPE_LIST(PORT_TYPE_STRING), trigger = null)
	set_gas_filter = add_input_port("Set Filter", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_gas_to_filter))
	enable_extended_range = add_input_port("Enable Extra Range", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_range))
	disable_extended_range = add_input_port("Disable Extra Range", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_range))
	enable_siphon = add_input_port("Enable Siphon", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_siphon))
	disable_siphon = add_input_port("Disable Siphon", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_siphon))
	enable = add_input_port("Enable", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_scrubber))
	disable = add_input_port("Disable", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_scrubber))
	request_update = add_input_port("Request Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(update_data))

	enabled = add_output_port("Enabled", PORT_TYPE_NUMBER)
	is_siphoning = add_output_port("Siphoning", PORT_TYPE_NUMBER)
	filtering = add_output_port("Filtered Gases", PORT_TYPE_LIST(PORT_TYPE_STRING))
	update_received = add_output_port("Update Received", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/air_alarm_scrubbers/duplicate
	display_name = "Air Alarm Scrubber Control"
	circuit_size = 0
	ui_buttons = list()

/obj/item/circuit_component/air_alarm_scrubbers/duplicate/Destroy()
	connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm_scrubbers/duplicate/removed_from(obj/item/integrated_circuit/removed_from)
	if(!QDELING(src))
		qdel(src)
	return ..()

/obj/item/circuit_component/air_alarm_scrubbers/removed_from(obj/item/integrated_circuit/removed_from)
	QDEL_LIST(scrubber_duplicates)
	return ..()

/obj/item/circuit_component/air_alarm_scrubbers/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/airalarm))
		connected_alarm = shell
		scrubbers.possible_options = extract_id_tags(connected_alarm.my_area.air_scrubbers)

/obj/item/circuit_component/air_alarm_scrubbers/unregister_usb_parent(atom/movable/shell)
	connected_alarm = null
	scrubbers.possible_options = null
	for(var/obj/item/circuit_component/air_alarm_scrubbers/scrubber as anything in scrubber_duplicates)
		scrubber.connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm_scrubbers/get_ui_notices()
	. = ..()
	var/static/list/meta_data = list()
	if(length(meta_data) == 0)
		for(var/typepath in GLOB.meta_gas_info)
			meta_data += GLOB.meta_gas_info[typepath][META_GAS_ID]
	. += create_table_notices(meta_data, column_name = "Gas", column_name_plural = "Gases")

/obj/item/circuit_component/air_alarm_scrubbers/proc/set_gas_to_filter(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(set_gas_filter_async), port)

/obj/item/circuit_component/air_alarm_scrubbers/proc/set_gas_filter_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/list/valid_filters = list()
	for(var/info in gas_filter.value)
		var/gas_type = gas_id2path(info)
		if(!gas_type)
			continue
		valid_filters += gas_type

	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = find_by_id_tag(connected_alarm.my_area.air_scrubbers, scrubbers.value)
	if(isnull(scrubber))
		return

	scrubber.filter_types = valid_filters

/obj/item/circuit_component/air_alarm_scrubbers/proc/toggle_scrubber(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(toggle_scrubber_async), port)

/obj/item/circuit_component/air_alarm_scrubbers/proc/toggle_scrubber_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	// var/scrubber_id = scrubbers.value
	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = find_by_id_tag(connected_alarm.my_area.air_scrubbers, scrubbers.value)
	if (isnull(scrubber))
		return

	scrubber.on = (port == enable)
	scrubber.update_appearance(UPDATE_ICON)

/obj/item/circuit_component/air_alarm_scrubbers/proc/toggle_range(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(toggle_range_async), port)

/obj/item/circuit_component/air_alarm_scrubbers/proc/toggle_range_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = find_by_id_tag(connected_alarm.my_area.air_scrubbers, scrubbers.value)
	if(isnull(scrubber))
		return

	scrubber.widenet = (port == enable_extended_range)
	scrubber.update_appearance(UPDATE_ICON)

/obj/item/circuit_component/air_alarm_scrubbers/proc/toggle_siphon(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(toggle_siphon_async), port)

/obj/item/circuit_component/air_alarm_scrubbers/proc/toggle_siphon_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = find_by_id_tag(connected_alarm.my_area.air_scrubbers, scrubbers.value)
	if(isnull(scrubber))
		return

	scrubber.scrubbing = (port != enable_siphon)
	scrubber.update_appearance(UPDATE_ICON)

/obj/item/circuit_component/air_alarm_scrubbers/proc/update_data()
	CIRCUIT_TRIGGER
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber = find_by_id_tag(connected_alarm.my_area.air_scrubbers, scrubbers.value)
	if(isnull(scrubber))
		return

	enabled.set_value(scrubber.on)
	is_siphoning.set_value(scrubber.scrubbing == ATMOS_DIRECTION_SCRUBBING)

	var/list/filtered = list()

	for(var/datum/gas/gas_type as anything in scrubber.filter_types)
		filtered += initial(gas_type.id)

	filtering.set_value(filtered)

	update_received.set_value(COMPONENT_SIGNAL)

/obj/item/circuit_component/air_alarm_vents
	display_name = "Air Alarm Vent Core Control"
	desc = "Controls the vents in the room."

	var/datum/port/input/option/vents

	/// Enables the vent
	var/datum/port/input/enable
	/// Disables the vent
	var/datum/port/input/disable

	/// Enables siphoning
	var/datum/port/input/enable_siphon
	/// Disables siphoning
	var/datum/port/input/disable_siphon
	/// Enables external
	var/datum/port/input/enable_external
	/// Disables external
	var/datum/port/input/disable_external
	/// External target pressure
	var/datum/port/input/external_pressure
	/// Enables internal
	var/datum/port/input/enable_internal
	/// Disables internal
	var/datum/port/input/disable_internal
	/// Internal target pressure
	var/datum/port/input/internal_pressure
	/// Requests an update of the data
	var/datum/port/input/request_update


	/// Whether the scrubber is enabled or not
	var/datum/port/output/enabled
	/// Whether the scrubber is siphoning or not
	var/datum/port/output/is_siphoning
	/// Whether internal pressure is on or not
	var/datum/port/output/internal_on
	/// Whether external pressure is on or not
	var/datum/port/output/external_on
	/// Reported external pressure
	var/datum/port/output/current_external_pressure
	/// Reported internal pressure
	var/datum/port/output/current_internal_pressure
	/// Sent when an update is received
	var/datum/port/output/update_received

	var/obj/machinery/airalarm/connected_alarm

	ui_buttons = list(
		"plus" = "add_new_component"
	)

	var/static/list/filtering_map = list()

	var/max_vent_duplicates = 20
	var/list/vent_duplicates = list()

/obj/item/circuit_component/air_alarm_vents/ui_perform_action(mob/user, action)
	if(length(vent_duplicates) >= max_vent_duplicates)
		return

	if(action == "add_new_component")
		var/obj/item/circuit_component/air_alarm_vents/component = new /obj/item/circuit_component/air_alarm_vents/duplicate(parent)
		parent.add_component(component)
		RegisterSignal(component, COMSIG_QDELETING, PROC_REF(on_duplicate_removed))
		vent_duplicates += component
		component.connected_alarm = connected_alarm
		component.vents.possible_options = extract_id_tags(connected_alarm.my_area.air_vents)

/obj/item/circuit_component/air_alarm_vents/proc/on_duplicate_removed(datum/source)
	SIGNAL_HANDLER
	vent_duplicates -= source

/obj/item/circuit_component/air_alarm_vents/populate_options()
	vents = add_option_port("Vent", null)

/obj/item/circuit_component/air_alarm_vents/populate_ports()
	external_pressure = add_input_port("External Pressure", PORT_TYPE_NUMBER, trigger = PROC_REF(set_external_pressure))
	internal_pressure = add_input_port("Internal Pressure", PORT_TYPE_NUMBER, trigger = PROC_REF(set_internal_pressure))

	enable_external = add_input_port("Enable External", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_external))
	disable_external = add_input_port("Disable External", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_external))
	enable_internal = add_input_port("Enable Internal", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_internal))
	disable_internal = add_input_port("Disable Internal", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_internal))

	enable_siphon = add_input_port("Enable Siphon", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_siphon))
	disable_siphon = add_input_port("Disable Siphon", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_siphon))
	enable = add_input_port("Enable", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_vent))
	disable = add_input_port("Disable", PORT_TYPE_SIGNAL, trigger = PROC_REF(toggle_vent))
	request_update = add_input_port("Request Data", PORT_TYPE_SIGNAL, trigger = PROC_REF(update_data))

	enabled = add_output_port("Enabled", PORT_TYPE_NUMBER)
	is_siphoning = add_output_port("Siphoning", PORT_TYPE_NUMBER)
	external_on = add_output_port("External On", PORT_TYPE_NUMBER)
	internal_on = add_output_port("Internal On", PORT_TYPE_NUMBER)
	current_external_pressure = add_output_port("External Pressure", PORT_TYPE_NUMBER)
	current_internal_pressure = add_output_port("Internal Pressure", PORT_TYPE_NUMBER)
	update_received = add_output_port("Update Received", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/air_alarm_vents/duplicate
	display_name = "Air Alarm Vent Control"

	circuit_size = 0
	ui_buttons = list()

/obj/item/circuit_component/air_alarm_vents/duplicate/removed_from(obj/item/integrated_circuit/removed_from)
	if(!QDELING(src))
		qdel(src)
	return ..()

/obj/item/circuit_component/air_alarm_vents/duplicate/Destroy()
	connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm_vents/removed_from(obj/item/integrated_circuit/removed_from)
	QDEL_LIST(vent_duplicates)
	return ..()

/obj/item/circuit_component/air_alarm_vents/register_usb_parent(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/airalarm))
		connected_alarm = shell
		vents.possible_options = extract_id_tags(connected_alarm.my_area.air_vents)

/obj/item/circuit_component/air_alarm_vents/unregister_usb_parent(atom/movable/shell)
	connected_alarm = null
	vents.possible_options = null
	for(var/obj/item/circuit_component/air_alarm_vents/vent as anything in vent_duplicates)
		vent.connected_alarm = null
	return ..()

/obj/item/circuit_component/air_alarm_vents/proc/toggle_vent(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(toggle_vent_async), port)

/obj/item/circuit_component/air_alarm_vents/proc/toggle_vent_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = find_by_id_tag(connected_alarm.my_area.air_vents, vents.value)
	if(isnull(vent))
		return

	vent.on = (port == enable)
	vent.update_appearance(UPDATE_ICON)

/obj/item/circuit_component/air_alarm_vents/proc/toggle_external(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(toggle_external_async), port)

/obj/item/circuit_component/air_alarm_vents/proc/toggle_external_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = find_by_id_tag(connected_alarm.my_area.air_vents, vents.value)
	if(isnull(vent))
		return

	if(port == enable_external)
		vent.pressure_checks |= ATMOS_EXTERNAL_BOUND
	else
		vent.pressure_checks &= ~ATMOS_EXTERNAL_BOUND

/obj/item/circuit_component/air_alarm_vents/proc/toggle_internal(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(toggle_internal_async), port)

/obj/item/circuit_component/air_alarm_vents/proc/toggle_internal_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = find_by_id_tag(connected_alarm.my_area.air_vents, vents.value)
	if(isnull(vent))
		return

	if(port == enable_internal)
		vent.pressure_checks |= ATMOS_INTERNAL_BOUND
	else
		vent.pressure_checks &= ~ATMOS_INTERNAL_BOUND

/obj/item/circuit_component/air_alarm_vents/proc/set_internal_pressure(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(set_internal_pressure_async), port)

/obj/item/circuit_component/air_alarm_vents/proc/set_internal_pressure_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = find_by_id_tag(connected_alarm.my_area.air_vents, vents.value)
	if(isnull(vent))
		return

	vent.internal_pressure_bound = clamp(internal_pressure.value, 0, ATMOS_PUMP_MAX_PRESSURE)

/obj/item/circuit_component/air_alarm_vents/proc/set_external_pressure(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(set_external_pressure_async), port)

/obj/item/circuit_component/air_alarm_vents/proc/set_external_pressure_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = find_by_id_tag(connected_alarm.my_area.air_vents, vents.value)
	if(isnull(vent))
		return

	vent.internal_pressure_bound = clamp(external_pressure.value, 0, ATMOS_PUMP_MAX_PRESSURE)

/obj/item/circuit_component/air_alarm_vents/proc/toggle_siphon(datum/port/input/port)
	CIRCUIT_TRIGGER
	INVOKE_ASYNC(src, PROC_REF(toggle_siphon_async), port)

/obj/item/circuit_component/air_alarm_vents/proc/toggle_siphon_async(datum/port/input/port)
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = find_by_id_tag(connected_alarm.my_area.air_vents, vents.value)
	if(isnull(vent))
		return

	vent.pump_direction = (port == enable_siphon) ? ATMOS_DIRECTION_SIPHONING : ATMOS_DIRECTION_RELEASING

/obj/item/circuit_component/air_alarm_vents/proc/update_data()
	CIRCUIT_TRIGGER
	if(!connected_alarm || connected_alarm.locked)
		return

	var/obj/machinery/atmospherics/components/unary/vent_pump/vent = find_by_id_tag(connected_alarm.my_area.air_vents, vents.value)
	if(isnull(vent))
		return

	enabled.set_value(vent.on)
	is_siphoning.set_value(vent.pump_direction == ATMOS_DIRECTION_SIPHONING)
	internal_on.set_value(!!(vent.pressure_checks & ATMOS_INTERNAL_BOUND))
	current_internal_pressure.set_value(vent.internal_pressure_bound)
	external_on.set_value(!!(vent.pressure_checks & ATMOS_EXTERNAL_BOUND))
	current_external_pressure.set_value(vent.external_pressure_bound)
	update_received.set_value(COMPONENT_SIGNAL)
