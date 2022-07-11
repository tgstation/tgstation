/**
 * # laser pointer Component
 *
 * Points a laser at a tile or mob
 */
/obj/item/circuit_component/laserpointer
	display_name = "Laser Pointer"
	desc = "A component that shines a high powered light at a target."
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The input port
	var/datum/port/input/target_input
	var/datum/port/input/image_pixel_x = 0
	var/datum/port/input/image_pixel_y = 0

	var/max_range = 7

	var/datum/port/input/option/lasercolour_option


/obj/item/circuit_component/laserpointer/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/laserpointer/populate_options()
	var/static/component_options = list(
		"red",
		"green",
		"blue",
		"purple",
	)
	lasercolour_option = add_option_port("Laser Colour", component_options)


/obj/item/circuit_component/laserpointer/populate_ports()
	target_input = add_input_port("Target", PORT_TYPE_ATOM)
	image_pixel_x = add_input_port("X-Axis Shift", PORT_TYPE_NUMBER)
	image_pixel_y = add_input_port("Y-Axis Shift", PORT_TYPE_NUMBER)


/obj/item/circuit_component/laserpointer/input_received(datum/port/input/port)

	var/atom/target = target_input.value
	var/atom/movable/shell = parent.shell
	var/turf/target_location = get_turf(target)


	var/pointer_icon_state = lasercolour_option.value

	var/turf/current_turf = get_location()
	if(get_dist(current_turf, target) > max_range || current_turf.z != target.z)
		return

	// only has cyborg flashing since felinid moving spikes time dilation when spammed and the other two features of laserpointers would be unbalanced when spammed
	if(iscyborg(target))
		var/mob/living/silicon/silicon = target
		log_combat(shell, silicon, "shone in the sensors", src)
		silicon.flash_act(affect_silicon = TRUE) /// no stunning, just a blind
		to_chat(silicon, span_danger("Your sensors were overloaded by a weakened laser shone by [shell]!"))

	var/image/laser_location = image('icons/obj/guns/projectiles.dmi',target_location,"[pointer_icon_state]_laser",10)

	laser_location.pixel_x = clamp(target.pixel_x + image_pixel_x.value,-15,15)
	laser_location.pixel_y = clamp(target.pixel_y + image_pixel_y.value,-15,15)

	target_location.add_overlay(laser_location)
	addtimer(CALLBACK(target_location, /atom/proc/cut_overlay, laser_location), 1 SECONDS)
