/obj/item/mod/module/circuit
	name = "MOD circuit adapter module"
	desc = "A module shell that allows a circuit to be inserted into, and interface with, a MODsuit."
	module_type = MODULE_USABLE
	complexity = 3
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/circuit)
	cooldown_time = 0.5 SECONDS

	/// A reference to the shell component, used to access the shell and its attached circuit
	var/datum/component/shell/shell

/obj/item/mod/module/circuit/Initialize(mapload)
	. = ..()
	shell = AddComponent(/datum/component/shell, \
		list(new /obj/item/circuit_component/mod_adapter_core()), \
		capacity = SHELL_CAPACITY_LARGE, \
	)

/obj/item/mod/module/circuit/proc/override_power_usage(datum/source, amount)
	SIGNAL_HANDLER
	if(drain_power(amount))
		. = COMPONENT_OVERRIDE_POWER_USAGE

/obj/item/mod/module/circuit/on_install()
	if(!shell?.attached_circuit)
		return
	RegisterSignal(shell?.attached_circuit, COMSIG_CIRCUIT_PRE_POWER_USAGE, PROC_REF(override_power_usage))

/obj/item/mod/module/circuit/on_uninstall(deleting = FALSE)
	if(!shell?.attached_circuit)
		return
	UnregisterSignal(shell?.attached_circuit, COMSIG_CIRCUIT_PRE_POWER_USAGE)

/obj/item/mod/module/circuit/on_use()
	. = ..()
	if(!.)
		return
	if(!shell.attached_circuit)
		return
	var/list/action_components = shell.attached_circuit.get_all_contents_type(/obj/item/circuit_component/equipment_action/mod)
	if(!action_components.len)
		shell.attached_circuit.interact(mod.wearer)
		return
	var/list/repeat_name_counts = list("Access Circuit" = 1)
	var/list/display_names = list()
	var/list/radial_options = list()
	for(var/obj/item/circuit_component/equipment_action/mod/action_component in action_components)
		var/action_name = action_component.button_name.value
		if(!repeat_name_counts[action_name])
			repeat_name_counts[action_name] = 0
		repeat_name_counts[action_name]++
		if(repeat_name_counts[action_name] > 1)
			action_name += " ([repeat_name_counts[action_name]])"
		display_names[action_name] = REF(action_component)
		var/option_icon_state = "bci_[replacetextEx(lowertext(action_component.icon_options.value), " ", "_")]"
		radial_options += list("[action_name]" = image('icons/mob/actions/actions_items.dmi', option_icon_state))
	radial_options += list("Access Circuit" = image(shell.attached_circuit))
	var/selected_option = show_radial_menu(mod.wearer, src, radial_options, custom_check = FALSE, require_near = TRUE)
	if(!selected_option)
		return
	if(!mod || !mod.wearer || !mod.active || mod.activating)
		return
	if(selected_option == "Access Circuit")
		shell.attached_circuit?.interact(mod.wearer)
	else
		var/component_reference = display_names[selected_option]
		var/obj/item/circuit_component/equipment_action/mod/selected_component = locate(component_reference) in shell.attached_circuit.contents
		if(!istype(selected_component))
			return
		selected_component.signal.set_output(COMPONENT_SIGNAL)


/obj/item/circuit_component/mod_adapter_core
	display_name = "MOD circuit adapter core"
	desc = "Provides a reference to the MODsuit's occupant and allows the circuit to toggle the MODsuit."

	/// The MODsuit module this circuit is associated with
	var/obj/item/mod/module/attached_module

	/// The name of the module to select
	var/datum/port/input/option/module_to_select

	/// The signal to toggle deployment of the modsuit
	var/datum/port/input/toggle_deploy

	/// The signal to toggle the suit
	var/datum/port/input/toggle_suit

	/// The signal to select a module
	var/datum/port/input/select_module

	/// A reference to the wearer of the MODsuit
	var/datum/port/output/wearer

	/// Whether or not the suit is deployed
	var/datum/port/output/deployed

	/// Whether or not the suit is activated
	var/datum/port/output/activated

	/// The name of the last selected module
	var/datum/port/output/selected_module

	/// A list of the names of all currently deployed parts
	var/datum/port/output/deployed_parts

	/// The signal that is triggered when a module is selected
	var/datum/port/output/on_module_selected

	/// The signal that is triggered when the suit is deployed by a signal
	var/datum/port/output/on_deploy

	/// The signal that is triggered when the suit has finished toggling itself after being activated by a signal
	var/datum/port/output/on_toggle_finish

/obj/item/circuit_component/mod_adapter_core/populate_options()
	module_to_select = add_option_port("Module to Select", list())

/obj/item/circuit_component/mod_adapter_core/populate_ports()
	// Input Signals
	toggle_deploy = add_input_port("Toggle Deployment", PORT_TYPE_SIGNAL)
	toggle_suit = add_input_port("Toggle Suit", PORT_TYPE_SIGNAL)
	select_module = add_input_port("Select Module", PORT_TYPE_SIGNAL)
	// States
	wearer = add_output_port("Wearer", PORT_TYPE_ATOM)
	deployed = add_output_port("Deployed", PORT_TYPE_NUMBER)
	activated = add_output_port("Activated", PORT_TYPE_NUMBER)
	selected_module = add_output_port("Selected Module", PORT_TYPE_STRING)
	deployed_parts = add_output_port("Deployed Parts", PORT_TYPE_LIST(PORT_TYPE_STRING))
	// Output Signals
	on_module_selected = add_output_port("On Module Selected", PORT_TYPE_SIGNAL)
	on_deploy = add_output_port("On Deploy", PORT_TYPE_SIGNAL)
	on_toggle_finish = add_output_port("Finished Toggling", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mod_adapter_core/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/mod/module))
		attached_module = shell
		RegisterSignal(attached_module, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/obj/item/circuit_component/mod_adapter_core/unregister_shell(atom/movable/shell)
	if(attached_module)
		UnregisterSignal(attached_module, COMSIG_MOVABLE_MOVED)
		attached_module = null
	return ..()

/obj/item/circuit_component/mod_adapter_core/input_received(datum/port/input/port)
	if(!attached_module?.mod)
		return
	var/obj/item/mod/module/module
	for(var/obj/item/mod/module/potential_module as anything in attached_module.mod.modules)
		if(potential_module.name == module_to_select.value)
			module = potential_module
	if(COMPONENT_TRIGGERED_BY(toggle_suit, port))
		INVOKE_ASYNC(attached_module.mod, TYPE_PROC_REF(/obj/item/mod/control, toggle_activate), attached_module.mod.wearer)
	if(COMPONENT_TRIGGERED_BY(toggle_deploy, port))
		INVOKE_ASYNC(attached_module.mod, TYPE_PROC_REF(/obj/item/mod/control, quick_deploy), attached_module.mod.wearer)
	if(attached_module.mod.active && module && COMPONENT_TRIGGERED_BY(select_module, port))
		INVOKE_ASYNC(module, TYPE_PROC_REF(/obj/item/mod/module, on_select))

/obj/item/circuit_component/mod_adapter_core/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(istype(source.loc, /obj/item/mod/control))
		var/obj/item/mod/control/mod = source.loc
		RegisterSignal(mod, COMSIG_MOD_MODULE_SELECTED, PROC_REF(on_module_select))
		RegisterSignal(mod, COMSIG_MOD_DEPLOYED, PROC_REF(on_mod_part_toggled))
		RegisterSignal(mod, COMSIG_MOD_RETRACTED, PROC_REF(on_mod_part_toggled))
		RegisterSignal(mod, COMSIG_MOD_TOGGLED, PROC_REF(on_mod_toggled))
		RegisterSignal(mod, COMSIG_MOD_MODULE_ADDED, PROC_REF(on_module_changed))
		RegisterSignal(mod, COMSIG_MOD_MODULE_REMOVED, PROC_REF(on_module_changed))
		RegisterSignal(mod, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_check))
		wearer.set_output(mod.wearer)
		var/modules_list = list()
		for(var/obj/item/mod/module/module in mod.modules)
			if(module.module_type != MODULE_PASSIVE)
				modules_list += module.name
		module_to_select.possible_options = modules_list
		if (module_to_select.possible_options.len)
			module_to_select.set_value(module_to_select.possible_options[1])
	else if(istype(old_loc, /obj/item/mod/control))
		UnregisterSignal(old_loc, list(COMSIG_MOD_MODULE_SELECTED, COMSIG_ITEM_EQUIPPED))
		UnregisterSignal(old_loc, COMSIG_MOD_DEPLOYED)
		UnregisterSignal(old_loc, COMSIG_MOD_RETRACTED)
		UnregisterSignal(old_loc, COMSIG_MOD_TOGGLED)
		UnregisterSignal(old_loc, COMSIG_MOD_MODULE_ADDED)
		UnregisterSignal(old_loc, COMSIG_MOD_MODULE_REMOVED)
		selected_module.set_output(null)
		wearer.set_output(null)
		deployed.set_output(FALSE)
		activated.set_output(FALSE)

/obj/item/circuit_component/mod_adapter_core/proc/on_module_select(datum/source, obj/item/mod/module/module)
	SIGNAL_HANDLER
	selected_module.set_output(module.name)
	on_module_selected.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_adapter_core/proc/on_module_changed()
	SIGNAL_HANDLER
	var/modules_list = list()
	for(var/obj/item/mod/module/module in attached_module.mod.modules)
		if(module.module_type != MODULE_PASSIVE)
			modules_list += module.name
	module_to_select.possible_options = modules_list
	if (module_to_select.possible_options.len)
		module_to_select.set_value(module_to_select.possible_options[1])

/obj/item/circuit_component/mod_adapter_core/proc/on_mod_part_toggled()
	SIGNAL_HANDLER
	var/string_list = list()
	var/is_deployed = TRUE
	for(var/obj/item/part as anything in attached_module.mod.mod_parts)
		if(part.loc == attached_module.mod)
			is_deployed = FALSE
		else
			var/part_name = "Undefined"
			if(istype(part, /obj/item/clothing/head/mod))
				part_name = "Helmet"
			if(istype(part, /obj/item/clothing/suit/mod))
				part_name = "Chestplate"
			if(istype(part, /obj/item/clothing/gloves/mod))
				part_name = "Gloves"
			if(istype(part, /obj/item/clothing/shoes/mod))
				part_name = "Boots"
			string_list += part_name
	deployed_parts.set_output(string_list)
	deployed.set_output(is_deployed)
	on_deploy.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_adapter_core/proc/on_mod_toggled()
	SIGNAL_HANDLER
	activated.set_output(attached_module.mod.active)
	on_toggle_finish.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_adapter_core/proc/equip_check()
	SIGNAL_HANDLER
	if(!attached_module.mod?.wearer)
		return
	wearer.set_output(attached_module.mod.wearer)

/obj/item/circuit_component/equipment_action/mod
	display_name = "MOD action"
	desc = "Represents an action the user can take when wearing the MODsuit."
	required_shells = list(/obj/item/mod/module/circuit)
