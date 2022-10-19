/**
 * # Save Shell Component
 *
 * A component that saves and loads a shell for the integrated circuit.
 */
/obj/item/circuit_component/save_shell
	display_name = "Save Shell"
	desc = "A component that saves a shell."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_ADMIN

	/// Returns the output from the proccall
	var/datum/port/output/on_loaded

	var/atom/movable/loaded_shell

/obj/item/circuit_component/save_shell/populate_ports()
	on_loaded = add_output_port("On Loaded", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/save_shell/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	RegisterSignal(added_to, COMSIG_CIRCUIT_POST_LOAD, .proc/on_post_load)
	RegisterSignal(added_to, COMSIG_CIRCUIT_PRE_SAVE_TO_JSON, .proc/on_pre_save_to_json)

/obj/item/circuit_component/save_shell/removed_from(obj/item/integrated_circuit/removed_from)
	UnregisterSignal(removed_from, list(COMSIG_CIRCUIT_POST_LOAD, COMSIG_CIRCUIT_PRE_SAVE_TO_JSON))
	return ..()

/obj/item/circuit_component/save_shell/proc/on_post_load(datum/source)
	SIGNAL_HANDLER
	var/datum/component/shell/shell_component = loaded_shell.GetComponent(/datum/component/shell)
	if(!istype(shell_component))
		loaded_shell.AddComponent(/datum/component/shell, starting_circuit = parent)
	else
		QDEL_NULL(shell_component.attached_circuit)
		shell_component.attach_circuit(parent)
	on_loaded.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/save_shell/proc/on_pre_save_to_json(datum/source, list/general_data)
	SIGNAL_HANDLER
	// We're custom saving the shell, disable any USB cable connections and default shell components.
	general_data["external_objects"] = list()

/obj/item/circuit_component/save_shell/save_data_to_list(list/component_data)
	. = ..()
	var/atom/movable/shell = parent.shell
	component_data["shell_type"] = shell.type

/obj/item/circuit_component/save_shell/load_data_from_list(list/component_data)
	if(parent.shell)
		return

	var/shell_type = text2path(component_data["shell_type"])
	if(!shell_type || !ispath(shell_type, /atom))
		return ..()

	loaded_shell = new shell_type(drop_location())
	log_admin_circuit("[parent.get_creator()] spawned in [shell_type] at [ADMIN_COORDJMP(loaded_shell)].")
	if(!loaded_shell)
		return
	loaded_shell.datum_flags |= DF_VAR_EDITED
	return ..()
