
/**
 * A lift indicator aka an elevator hall lantern w/ floor number
 */
/obj/machinery/lift_indicator
	name = "elevator indicator"
	desc = "Indicates what floor the elevator is at and which way it's going."
	icon = 'icons/obj/machines/lift_indicator.dmi'
	icon_state = "lift_indo-base"
	base_icon_state = "lift_indo-"
	max_integrity = 500
	integrity_failure = 0.25
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.02
	anchored = TRUE
	density = FALSE

	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_DARK_BLUE
	luminosity = 1

	maptext_x = 17
	maptext_y = 21
	maptext_width = 4
	maptext_height = 8

	/// What specific_lift_id do we link with?
	var/linked_elevator_id

	// = (real lowest floor's z-level) - (what we want to display)
	var/lowest_floor_offset = 1

	/// Weakref to the lift.
	var/datum/weakref/lift_ref
	/// The lowest floor number. Determined by lift init.
	var/lowest_floor_num = 1
	/// Positive for going up, negative going down, 0 for stopped
	var/current_lift_direction = 0
	/// The lift's current floor relative to its lowest floor being 1
	var/current_lift_floor = 1

/obj/machinery/lift_indicator/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/lift_indicator/LateInitialize()
	. = ..()

	for(var/datum/lift_master/possible_match as anything in GLOB.active_lifts_by_type[BASIC_LIFT_ID])
		if(possible_match.specific_lift_id != linked_elevator_id)
			continue

		lift_ref = WEAKREF(possible_match)
		RegisterSignal(possible_match, COMSIG_LIFT_SET_DIRECTION, PROC_REF(on_lift_direction))

/obj/machinery/lift_indicator/examine(mob/user)
	. = ..()

	if(!is_operational)
		. += span_notice("The display is dark.")
		return

	var/dirtext
	switch(current_lift_direction)
		if(UP)
			dirtext = "travelling upwards"
		if(DOWN)
			dirtext = "travelling downwards"
		else
			dirtext = "stopped"

	. += span_notice("The elevator is at floor [current_lift_floor], [dirtext].")

/**
 * Update state, and only process if lift is moving.
 */
/obj/machinery/lift_indicator/proc/on_lift_direction(datum/source, direction)
	SIGNAL_HANDLER

	var/datum/lift_master/lift = lift_ref?.resolve()
	if(!lift)
		return

	set_lift_state(direction, current_lift_floor)
	update_operating()

/obj/machinery/lift_indicator/on_set_is_operational()
	. = ..()

	update_operating()

/**
 * Update processing state.
 *
 * Returns whether we are still processing.
 */
/obj/machinery/lift_indicator/proc/update_operating()
	// Let process() figure it out to have the logic in one place.
	var/should_process = process() != PROCESS_KILL
	if(should_process)
		begin_processing()
		return
	end_processing()

/obj/machinery/lift_indicator/process()
	var/datum/lift_master/lift = lift_ref?.resolve()

	// Check for stopped states.
	if(!lift || !is_operational)
		// Lift missing, or we lost power.
		set_lift_state(0, 0, force = !is_operational)
		return PROCESS_KILL

	use_power(active_power_usage)

	var/obj/structure/industrial_lift/lift_part = lift.lift_platforms[1]

	if(QDELETED(lift_part))
		set_lift_state(0, 0, force = !is_operational)
		return PROCESS_KILL

	// Update
	set_lift_state(current_lift_direction, lift.lift_platforms[1].z - lowest_floor_offset)

	// Lift's not moving, we're done; we just had to update the floor number one last time.
	if(!current_lift_direction)
		return PROCESS_KILL

/**
 * Set the state and update appearance.
 *
 * Arguments:
 * new_direction - new arrow state: UP, DOWN, or 0
 * new_floor - set the floor number, eg. 1, 2, 3
 * force_update - force appearance to update even if state didn't change.
 */
/obj/machinery/lift_indicator/proc/set_lift_state(new_direction, new_floor, force = FALSE)
	if(new_direction == current_lift_direction && new_floor == current_lift_floor && !force)
		return

	current_lift_direction = new_direction
	current_lift_floor = new_floor
	update_appearance()

/obj/machinery/lift_indicator/update_appearance(updates)
	. = ..()

	if(!is_operational)
		set_light(l_on = FALSE)
		maptext = ""
		return

	set_light(l_on = TRUE)
	maptext = {"<div style="font:5pt 'Small Fonts';color:[LIGHT_COLOR_DARK_BLUE]">[current_lift_floor]</div>"}

/obj/machinery/lift_indicator/update_overlays()
	. = ..()

	if(!is_operational)
		return

	. += emissive_appearance(icon, "[base_icon_state]e", offset_spokesman = src, alpha = src.alpha)

	if(!current_lift_direction)
		return

	var/arrow_icon_state = "[base_icon_state][current_lift_direction == UP ? "up" : "down"]"

	. += mutable_appearance(icon, arrow_icon_state)
	. += emissive_appearance(icon, "[arrow_icon_state]e", offset_spokesman = src, alpha = src.alpha)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/lift_indicator, 32)
