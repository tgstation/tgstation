/**
 * # Compare Health State Component
 *
 * Returns true when state matches entity.
 */

/obj/item/circuit_component/compare/health_state
	display_name = "Compare Health State"
	desc = "A component that compares the health state of an organism, and returns true or false."
	category = "Entity"

	/// The input port
	var/datum/port/input/input_port

	/// Compare state option
	var/datum/port/input/option/state_option

	var/max_range = 5

/obj/item/circuit_component/compare/health_state/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/compare/health_state/populate_options()
	input_port = add_input_port("Organism", PORT_TYPE_ATOM)

	var/static/component_options = list(
		"Alive",
		"Asleep",
		"Critical",
		"Unconscious",
		"Deceased",
	)
	state_option = add_option_port("Comparison Option", component_options)

/obj/item/circuit_component/compare/health_state/do_comparisons()
	var/mob/living/organism = input_port.value
	var/turf/current_turf = get_location()
	var/turf/target_location = get_turf(organism)
	if(!istype(organism) || current_turf.z != target_location.z || get_dist(current_turf, target_location) > max_range)
		return FALSE

	var/current_option = state_option.value
	var/state = organism.stat
	switch(current_option)
		if("Alive")
			return state != DEAD
		if("Asleep")
			return !!organism.IsSleeping() && !organism.IsUnconscious()
		if("Critical")
			return state == SOFT_CRIT || state == HARD_CRIT
		if("Unconscious")
			return state == UNCONSCIOUS || state == HARD_CRIT || !!organism.IsUnconscious()
		if("Deceased")
			return state == DEAD
	//Unknown state, something fucked up really bad - just return false
	return FALSE
