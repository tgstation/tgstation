GLOBAL_LIST_INIT(wiremod_filter_info, list(
	"alpha" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
		"icon" = PORT_TYPE_STRING,
		"render_source" = PORT_TYPE_STRING,
		"flags" = PORT_TYPE_NUMBER,
	),
	"angular_blur" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
		"size" = PORT_TYPE_NUMBER,
	),
	"displace" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
		"size" = PORT_TYPE_NUMBER,
		"icon" = PORT_TYPE_STRING,
		"render_source" = PORT_TYPE_NUMBER,
	),
	"drop_shadow" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
		"size" = PORT_TYPE_NUMBER,
		"offset" = PORT_TYPE_NUMBER,
		"color" = PORT_TYPE_STRING,
	),
	"blur" = list(
		"size" = PORT_TYPE_NUMBER,
	),
	"layer" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
		"icon" = PORT_TYPE_STRING,
		"render_source" = PORT_TYPE_STRING,
		"flags" = PORT_TYPE_NUMBER,
		"color" = PORT_TYPE_STRING,
		"transform" = PORT_TYPE_LIST(PORT_TYPE_ANY),
		"blend_mode" = PORT_TYPE_NUMBER,
	),
	"motion_blur" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
	),
	"outline" = list(
		"size" = PORT_TYPE_NUMBER,
		"color" = PORT_TYPE_STRING,
		"flags" = PORT_TYPE_NUMBER,
	),
	"radial_blur" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
		"size" = PORT_TYPE_NUMBER,
	),
	"rays" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
		"size" = PORT_TYPE_NUMBER,
		"color" = PORT_TYPE_STRING,
		"offset" = PORT_TYPE_NUMBER,
		"density" = PORT_TYPE_NUMBER,
		"threshold" = PORT_TYPE_NUMBER,
		"factor" = PORT_TYPE_NUMBER,
		"flags" = PORT_TYPE_NUMBER,
	),
	"ripple" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
		"size" = PORT_TYPE_NUMBER,
		"repeat" = PORT_TYPE_NUMBER,
		"radius" = PORT_TYPE_NUMBER,
		"falloff" = PORT_TYPE_NUMBER,
		"flags" = PORT_TYPE_NUMBER,
	),
	"wave" = list(
		"x" = PORT_TYPE_NUMBER,
		"y" = PORT_TYPE_NUMBER,
		"size" = PORT_TYPE_NUMBER,
		"offset" = PORT_TYPE_NUMBER,
		"flags" = PORT_TYPE_NUMBER,
	),
))

GLOBAL_LIST_INIT(wiremod_flag_info, list(
	"Animation Easing" = list(
		"Easing Type" = list(
			"LINEAR_EASING" = LINEAR_EASING,
			"SINE_EASING" = SINE_EASING,
			"CIRCULAR_EASING" = CIRCULAR_EASING,
			"QUAD_EASING" = QUAD_EASING,
			"CUBIC_EASING" = CUBIC_EASING,
			"BOUNCE_EASING" = BOUNCE_EASING,
			"ELASTIC_EASING" = ELASTIC_EASING,
			"BACK_EASING" = BACK_EASING,
			"JUMP_EASING" = JUMP_EASING,
		),
		"EASE_IN" = EASE_IN,
		"EASE_OUT" = EASE_OUT,
	),
	"Animation Flags" = list(
		"ANIMATION_END_NOW" = ANIMATION_END_NOW,
		"ANIMATION_LINEAR_TRANSFORM" = ANIMATION_LINEAR_TRANSFORM,
		"ANIMATION_PARALLEL" = ANIMATION_PARALLEL,
		"ANIMATION_RELATIVE" = ANIMATION_RELATIVE,
	),
	"Alpha Filter Flags" = list(
		"MASK_INVERSE" = MASK_INVERSE,
		"MASK_SWAP" = MASK_SWAP,
	),
	"Color Space" = list("_" = list(
		"COLORSPACE_RGB" = COLORSPACE_RGB,
		"COLORSPACE_HSV" = COLORSPACE_HSV,
		"COLORSPACE_HSL" = COLORSPACE_HSL,
		"COLORSPACE_HCY" = COLORSPACE_HCY,
	)),
	"Layering Flags" = list("_" = list(
		"FILTER_OVERLAY" = FILTER_OVERLAY,
		"FILTER_UNDERLAY" = FILTER_UNDERLAY,
	)),
	"Layering Blend Mode" = list("_" = list(
		"BLEND_OVERLAY" = BLEND_OVERLAY,
		"BLEND_ADD" = BLEND_ADD,
		"BLEND_SUBTRACT" = BLEND_SUBTRACT,
		"BLEND_MULTIPLY" = BLEND_MULTIPLY,
		"BLEND_INSET_OVERLAY" = BLEND_INSET_OVERLAY,
	)),
	"Outline Flags" = list(
		"OUTLINE_SHARP" = OUTLINE_SHARP,
		"OUTLINE_SQUARE" = OUTLINE_SQUARE,
	),
	"Ray Flags" = list(
		"FILTER_OVERLAY" = FILTER_OVERLAY,
		"FILTER_UNDERLAY" = FILTER_UNDERLAY,
	),
	"Ripple Flags" = list(
		"WAVE_BOUNDED" = WAVE_BOUNDED,
	),
	"Wave Flags" = list(
		"WAVE_BOUNDED" = WAVE_BOUNDED,
		"WAVE_SIDEWAYS" = WAVE_SIDEWAYS,
	),
))

/obj/item/circuit_component/filter_helper
	display_name = "Filter Parameter Helper"
	desc = "Constructs a list of filter parameters from the inputs."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	var/datum/port/input/option/filter_type_port
	var/current_filter_type

	var/list/filter_params = list()

	var/datum/port/output/output_params

/obj/item/circuit_component/filter_helper/populate_options()
	filter_type_port = add_option_port("Filter Type", assoc_to_keys(GLOB.wiremod_filter_info))

/obj/item/circuit_component/filter_helper/populate_ports()
	current_filter_type = filter_type_port.value
	output_params = add_output_port("Parameters", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY))
	handle_filter_type_changed()

/obj/item/circuit_component/filter_helper/pre_input_received(datum/port/input/port)
	if((port == filter_type_port) && filter_type_port.value != current_filter_type)
		current_filter_type = filter_type_port.value
		handle_filter_type_changed()

/obj/item/circuit_component/filter_helper/proc/handle_filter_type_changed()
	for(var/param_name in filter_params)
		remove_input_port(filter_params[param_name])
	filter_params.Cut()
	for(var/param_name in GLOB.wiremod_filter_info[current_filter_type])
		filter_params[param_name] = add_input_port(param_name,
			GLOB.wiremod_filter_info[current_filter_type][param_name],
			default = GLOB.master_filter_info?[current_filter_type]["defaults"][param_name])

/obj/item/circuit_component/filter_helper/input_received(datum/port/input/port, list/return_values)
	var/list/new_params = list()
	for(var/param_name in filter_params)
		var/datum/port/input/param_port = filter_params[param_name]
		if(!isnull(param_port.value))
			new_params[param_name] = param_port.value

	output_params.set_value(new_params)

/obj/item/circuit_component/filter_adder
	display_name = "Add Filter"
	desc = "Adds a filter to the target atom."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	var/datum/port/input/target_port
	var/datum/port/input/filter_name
	var/datum/port/input/filter_priority
	var/datum/port/input/option/filter_type_port
	var/current_filter_type

	var/list/filter_params = list()

/obj/item/circuit_component/filter_adder/populate_options()
	filter_type_port = add_option_port("Filter Type", assoc_to_keys(GLOB.wiremod_filter_info))

/obj/item/circuit_component/filter_adder/populate_ports()
	current_filter_type = filter_type_port.value
	target_port = add_input_port("Target", PORT_TYPE_ATOM)
	filter_name = add_input_port("Filter Name", PORT_TYPE_STRING)
	filter_priority = add_input_port("Priority", PORT_TYPE_NUMBER)
	handle_filter_type_changed()

/obj/item/circuit_component/filter_adder/pre_input_received(datum/port/input/port)
	if((port == filter_type_port) && filter_type_port.value != current_filter_type)
		current_filter_type = filter_type_port.value
		handle_filter_type_changed()

/obj/item/circuit_component/filter_adder/proc/handle_filter_type_changed()
	for(var/param_name in filter_params)
		remove_input_port(filter_params[param_name])
	filter_params.Cut()
	for(var/param_name in GLOB.wiremod_filter_info[current_filter_type])
		filter_params[param_name] = add_input_port(param_name,
			GLOB.wiremod_filter_info[current_filter_type][param_name],
			order = 1.5,
			default = GLOB.master_filter_info?[current_filter_type]["defaults"][param_name])

/obj/item/circuit_component/filter_adder/input_received(datum/port/input/port, list/return_values)
	var/atom/target_atom = target_port.value
	if(!target_atom)
		return

	var/list/new_params = list()
	new_params["type"] = current_filter_type
	for(var/param_name in filter_params)
		var/datum/port/input/param_port = filter_params[param_name]
		new_params[param_name] = param_port.value

	target_atom.add_filter(filter_name.value, filter_priority.value, new_params)

/obj/item/circuit_component/filter_remover
	display_name = "Filter Remover"
	desc = "Removes the specified filter from the target."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	var/datum/port/input/target_port
	var/datum/port/input/filter_name

/obj/item/circuit_component/filter_remover/populate_ports()
	target_port = add_input_port("Target", PORT_TYPE_ATOM)
	filter_name = add_input_port("Filter Name", PORT_TYPE_STRING)

/obj/item/circuit_component/filter_remover/input_received(datum/port/input/port)
	var/atom/target_atom = target_port.value
	if(!target_atom)
		return

	target_atom.remove_filter(filter_name.value)

/obj/item/circuit_component/bitflag_helper
	display_name = "Animation & Filter Bitflag Helper"
	category = "Admin"
	desc = "Allows you to construct bitflags for BYOND animation and filter parameters without having to manually search for the corresponding values."

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	var/datum/port/input/option/bitflag_port
	var/current_bitflag

	var/list/flag_ports = list()

	var/datum/port/output/output_bitflag

/obj/item/circuit_component/bitflag_helper/populate_options()
	bitflag_port = add_option_port("Bitflag Type", assoc_to_keys(GLOB.wiremod_flag_info))

/obj/item/circuit_component/bitflag_helper/populate_ports()
	current_bitflag = bitflag_port.value
	handle_bitflag_type_changed()
	output_bitflag = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/bitflag_helper/pre_input_received(datum/port/input/port)
	if(port == bitflag_port && bitflag_port.value != current_bitflag)
		current_bitflag = bitflag_port.value
		handle_bitflag_type_changed()

/obj/item/circuit_component/bitflag_helper/proc/handle_bitflag_type_changed()
	for(var/flag_name in flag_ports)
		remove_input_port(flag_ports[flag_name])
	flag_ports.Cut()

	var/list/flags = GLOB.wiremod_flag_info[current_bitflag]
	for(var/flag in flags)
		if(islist(flags[flag]))
			flag_ports[flag] = add_option_port(flag == "_" ? current_bitflag : flag, flags[flag])
		else
			flag_ports[flag] = add_input_port(flag, PORT_TYPE_NUMBER)

/obj/item/circuit_component/bitflag_helper/input_received(datum/port/input/port)
	var/new_output = 0
	var/list/flags = GLOB.wiremod_flag_info[current_bitflag]
	for(var/flag in flags)
		if(!flag_ports[flag])
			continue
		else
			var/datum/port/input/flag_port = flag_ports[flag]
			if(islist(flags[flag]))
				var/list/flag_options = flags[flag]
				new_output += flag_options[flag_port.value]
			else if(flag_port.value)
				new_output += flags[flag]

	output_bitflag.set_output(new_output)
