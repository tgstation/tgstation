#define COMP_PROC_GLOBAL "Global"
#define COMP_PROC_OBJECT "Object"


/**
 * # Proc Call Component
 *
 * A component that calls a proc on an object and outputs the return value
 */
/obj/item/circuit_component/proccall
	display_name = "Proc Call"
	desc = "A component that calls a proc on an object."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	var/datum/port/input/option/proccall_options

	/// Entity to proccall on
	var/datum/port/input/entity

	/// Proc to call
	var/datum/port/input/proc_name

	/// A list of arguments
	var/list/datum/port/input/arguments = list()

	/// Returns the output from the proccall
	var/datum/port/output/output_value

	/// Whether we resolve all the weakrefs passed as arguments
	var/resolve_weakref = TRUE

	ui_buttons = list(
		"cog" = "configure",
	)

/obj/item/circuit_component/proccall/ui_perform_action(mob/user, action)
	if(action == "configure")
		interact(user)

/obj/item/circuit_component/proccall/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ProcCallMenu", "ProcCall Configuration Menu")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/circuit_component/proccall/populate_options()
	var/static/list/component_options = list(
		COMP_PROC_OBJECT,
		COMP_PROC_GLOBAL,
	)

	proccall_options = add_option_port("Proccall Options", component_options)

/obj/item/circuit_component/proccall/populate_ports()
	entity = add_input_port("Target", PORT_TYPE_DATUM, order = 0.5)
	proc_name = add_input_port("Proc Name", PORT_TYPE_STRING)

	output_value = add_output_port("Output Value", PORT_TYPE_ANY)

/obj/item/circuit_component/proccall/pre_input_received(datum/port/input/port)
	if(proccall_options.value == COMP_PROC_GLOBAL)
		if(entity)
			remove_input_port(entity)
			entity = null
	else
		if(!entity)
			entity = add_input_port("Target", PORT_TYPE_DATUM, order = 0.5)

/obj/item/circuit_component/proccall/ui_data(mob/user)
	. = list()
	var/list/input_ports = list()
	for(var/datum/port/input/port as anything in arguments)
		input_ports += list(list(
			"name" = port.name,
			"color" = port.color,
			"datatype" = port.datatype,
		))
	.["input_ports"] = input_ports

	.["expected_output"] = output_value.datatype
	.["expected_output_color"] = output_value.color

	.["resolve_weakref"] = resolve_weakref

/obj/item/circuit_component/proccall/ui_static_data(mob/user)
	. = list()
	.["possible_types"] = GLOB.wiremod_fundamental_types

/obj/item/circuit_component/proccall/ui_state(mob/user)
	return GLOB.admin_state

/obj/item/circuit_component/proccall/save_data_to_list(list/component_data)
	. = ..()
	var/list/input_ports = list()
	for(var/datum/port/input/port as anything in arguments)
		input_ports += list(list(
			"name" = port.name,
			"datatype" = port.datatype,
		))
	component_data["input_ports"] = input_ports
	component_data["expected_output_type"] = output_value.datatype
	component_data["resolve_weakref"] = resolve_weakref

/obj/item/circuit_component/proccall/load_data_from_list(list/component_data)
	if(component_data["resolve_weakref"] != null)
		resolve_weakref = component_data["resolve_weakref"]
	if(component_data["expected_output_type"])
		output_value.set_datatype(component_data["expected_output_type"])
	for(var/list/data as anything in component_data["input_ports"])
		arguments += add_input_port(data["name"], data["datatype"])
	return ..()

/obj/item/circuit_component/proccall/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	. = TRUE
	switch(action)
		if("set_expected_output")
			var/new_type = params["datatype"]
			if(!(new_type in GLOB.wiremod_fundamental_types))
				return
			output_value.set_datatype(new_type)
		if("resolve_weakref")
			resolve_weakref = !resolve_weakref
		if("add_argument")
			arguments += add_input_port("Port [length(arguments)]", PORT_TYPE_ANY)
		if("remove_argument")
			var/index = params["index"]
			if(index < 1 || index > length(arguments))
				return
			remove_input_port(arguments[index])
			arguments.Splice(index, index+1)
		if("rename_argument")
			var/index = params["index"]
			if(index < 1 || index > length(arguments))
				return
			var/datum/port/input/argument = arguments[index]
			argument.name = trim(copytext(params["name"], 1, PORT_MAX_NAME_LENGTH))
			SStgui.update_uis(parent)
		if("set_argument_datatype")
			var/index = params["index"]
			if(index < 1 || index > length(arguments))
				return
			var/datum/port/input/argument = arguments[index]
			var/new_type = params["datatype"]
			if(!(new_type in GLOB.wiremod_fundamental_types))
				return
			argument.set_datatype(new_type)



/obj/item/circuit_component/proccall/input_received(datum/port/input/port)
	var/called_on
	if(proccall_options.value == COMP_PROC_OBJECT)
		called_on = entity.value
	else
		called_on = GLOBAL_PROC

	if(!called_on)
		return

	var/to_invoke = proc_name.value
	var/list/params = list()
	for(var/datum/port/input/argument_port as anything in arguments)
		params += list(argument_port.value)

	if(!to_invoke)
		return

	if(called_on != GLOBAL_PROC && !hascall(called_on, to_invoke))
		return

	if(resolve_weakref)
		params = recursive_list_resolve(params)

	INVOKE_ASYNC(src, .proc/do_proccall, called_on, to_invoke, recursive_list_resolve(params))

/obj/item/circuit_component/proccall/proc/do_proccall(called_on, to_invoke, params)
	var/result = HandleUserlessProcCall(parent.get_creator(), called_on, to_invoke, params)
	output_value.set_output(result)

#undef COMP_PROC_GLOBAL
#undef COMP_PROC_OBJECT
