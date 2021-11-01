#define COMP_ANIMATE_ATOM "Object"
#define COMP_ANIMATE_FILTER "Filter"

/obj/item/circuit_component/begin_animation
	display_name = "Begin Animation"
	desc = "Begins an animation on the target. Create animation steps by chaining \"Animation Step\" components off of the \"Perform Animation\" port."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_INSTANT|CIRCUIT_FLAG_ADMIN

	/// Whether we are animating an atom or a filter on the atom
	var/datum/port/input/option/atom_or_filter

	/// The filter to animate
	var/datum/port/input/filter_target
	/// The target to animate
	var/datum/port/input/target
	/// The amount of times this animation will loop
	var/datum/port/input/animation_loops
	/// Used to determine if the animation runs in parallel or not.
	var/datum/port/input/parallel
	/// Called to stop all animations on this object
	var/datum/port/input/stop_all_animations
	/// Called when performing the animation.
	var/datum/port/output/animate_event

/obj/item/circuit_component/begin_animation/populate_options()
	var/static/list/component_options = list(
		COMP_ANIMATE_ATOM,
		COMP_ANIMATE_FILTER,
	)

	atom_or_filter = add_option_port("Target Options", component_options)

/obj/item/circuit_component/begin_animation/populate_ports()
	target = add_input_port("Target", PORT_TYPE_ATOM)
	parallel = add_input_port("Parallel", PORT_TYPE_NUMBER, default = 1)
	animation_loops = add_input_port("Loops", PORT_TYPE_NUMBER)
	stop_all_animations = add_input_port("Stop All Animations", PORT_TYPE_SIGNAL, trigger = .proc/stop_animations)
	animate_event = add_output_port("Perform Animation", PORT_TYPE_INSTANT_SIGNAL)

/obj/item/circuit_component/begin_animation/pre_input_received(datum/port/input/port)
	if(port == atom_or_filter)
		if(filter_target)
			remove_input_port(filter_target)
			filter_target = null

		if(atom_or_filter.value == COMP_ANIMATE_FILTER)
			filter_target = add_input_port("Filter Name", PORT_TYPE_STRING, order = 0.5)

/obj/item/circuit_component/begin_animation/proc/stop_animations(datum/port/input/port)
	CIRCUIT_TRIGGER
	if(!target.value)
		return
	animate(target.value, null)

/obj/item/circuit_component/begin_animation/input_received(datum/port/input/port, list/return_values)
	if(!target.value)
		return

	SScircuit_component.queue_instant_run()
	animate_event.set_output(COMPONENT_SIGNAL)
	var/list/result = SScircuit_component.execute_instant_run()

	if(!result || !result["animation_steps"])
		return

	var/atom/target_atom = target.value
	if(!isatom(target_atom))
		return

	var/target_for_animation = target_atom
	if(atom_or_filter.value == COMP_ANIMATE_FILTER)
		target_for_animation = target_atom.get_filter(filter_target.value)

	if(!target_for_animation)
		return

	if(!isatom(target_atom))
		return
	target_atom.datum_flags |= DF_VAR_EDITED

	var/extra_flags = NONE
	if(parallel.value)
		extra_flags |= ANIMATION_PARALLEL

	var/list/first_step = popleft(result["animation_steps"])
	animate(target_for_animation, time = first_step["time"], first_step["vars"], loop = animation_loops.value, easing = first_step["easing"], flags = first_step["flags"]|extra_flags)
	for(var/list/step as anything in result["animation_steps"])
		animate(time = step["time"], step["vars"], easing = step["easing"], flags = step["flags"])
		if(atom_or_filter.value == COMP_ANIMATE_FILTER)
			var/list/filter_params = target_atom.filter_data[filter_target.value]
			for(var/param in step["vars"])
				if(filter_params.Find(param))
					filter_params[param] = step["vars"][param]

/obj/item/circuit_component/animation_step
	display_name = "Animation Step"
	desc = "Perform a single animation step. The input of this component should be connected, directly or indirectly, to the \"Perform Animation\" port of a \"Begin Animation\" component."
	category = "Admin"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	var/datum/port/input/animation_variables

	var/datum/port/input/animation_time
	var/datum/port/input/animation_easing
	var/datum/port/input/animation_flags

/obj/item/circuit_component/animation_step/populate_ports()
	animation_variables = add_input_port("Variables", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY), order = 1.66)
	animation_time = add_input_port("Time", PORT_TYPE_NUMBER, order = 1.66)
	animation_easing = add_input_port("Easing", PORT_TYPE_NUMBER, order = 1.66)
	animation_flags = add_input_port("Flags", PORT_TYPE_NUMBER, order = 1.66)

/obj/item/circuit_component/animation_step/input_received(datum/port/input/port, list/return_values)
	if(!return_values)
		return

	if(!return_values["animation_steps"])
		return_values["animation_steps"] = list()

	var/list/variables = animation_variables.value

	if(!variables)
		return

	var/list/step = list(
		"vars" = variables.Copy(),
		"time" = animation_time.value * (1 SECONDS),
		"easing" = animation_easing.value,
		"flags" = animation_flags.value
	)

	return_values["animation_steps"] += list(step)

#undef COMP_ANIMATE_ATOM
#undef COMP_ANIMATE_FILTER
