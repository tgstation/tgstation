/obj/item/mod/module/circuit
	name = "MOD circuit adapter module"
	desc = "A module shell that allows a circuit to be inserted into, and interface with, a MODsuit."
	module_type = MODULE_USABLE
	complexity = 3
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/circuit)
	cooldown_time = 0.5 SECONDS
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
	RegisterSignal(shell?.attached_circuit, COMSIG_CIRCUIT_PRE_POWER_USAGE, .proc/override_power_usage)

/obj/item/mod/module/circuit/on_uninstall()
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
	var/datum/port/input/module_to_select
	
	/// The signal to toggle the suit
	var/datum/port/input/toggle_suit
	
	/// The signal to select a module
	var/datum/port/input/select_module

	/// A reference to the wearer of the MODsuit
	var/datum/port/output/wearer
	
	/// The name of the last selected module
	var/datum/port/output/selected_module

/obj/item/circuit_component/mod_adapter_core/populate_ports()
	// Input Signals
	module_to_select = add_input_port("Module to Select", PORT_TYPE_STRING)
	toggle_suit = add_input_port("Toggle Suit", PORT_TYPE_SIGNAL)
	select_module = add_input_port("Select Module", PORT_TYPE_SIGNAL)
	// States
	wearer = add_output_port("Wearer", PORT_TYPE_ATOM)
	selected_module = add_output_port("Selected Module", PORT_TYPE_STRING)

/obj/item/circuit_component/mod_adapter_core/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/mod/module))
		attached_module = shell
	RegisterSignal(attached_module, COMSIG_MOVABLE_MOVED, .proc/on_move)

/obj/item/circuit_component/mod_adapter_core/unregister_shell(atom/movable/shell)
	UnregisterSignal(attached_module, COMSIG_MOVABLE_MOVED)
	attached_module = null

/obj/item/circuit_component/mod_adapter_core/input_received(datum/port/input/port)
	var/obj/item/mod/module/module
	for(var/obj/item/mod/module/potential_module as anything in attached_module.mod.modules)
		if(potential_module.name == module_to_select.value)
			module = potential_module
	if(COMPONENT_TRIGGERED_BY(toggle_suit, port))
		INVOKE_ASYNC(attached_module.mod, /obj/item/mod/control.proc/toggle_activate, attached_module.mod.wearer)
	if(attached_module.mod.active && module && COMPONENT_TRIGGERED_BY(select_module, port))
		INVOKE_ASYNC(module, /obj/item/mod/module.proc/on_select)

/obj/item/circuit_component/mod_adapter_core/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(istype(source.loc, /obj/item/mod/control))
		RegisterSignal(source.loc, COMSIG_MOD_MODULE_SELECTED, .proc/on_module_select)
		RegisterSignal(source.loc, COMSIG_ITEM_EQUIPPED, .proc/equip_check)
		equip_check()
	else if(istype(old_loc, /obj/item/mod/control))
		UnregisterSignal(old_loc, list(COMSIG_MOD_MODULE_SELECTED, COMSIG_ITEM_EQUIPPED))
		selected_module.set_output(null)
		wearer.set_output(null)

/obj/item/circuit_component/mod_adapter_core/proc/on_module_select()
	SIGNAL_HANDLER
	selected_module.set_output(attached_module.mod.selected_module.name)


/obj/item/circuit_component/mod_adapter_core/proc/equip_check()
	SIGNAL_HANDLER

	if(!attached_module.mod?.wearer)
		return
	wearer.set_output(attached_module.mod.wearer)

/obj/item/circuit_component/equipment_action/mod
	display_name = "MOD action"
	desc = "Represents an action the user can take when wearing the MODsuit."
	required_shells = list(/obj/item/mod/module/circuit)
