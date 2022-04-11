
/**
 * # laser pointer Component
 *
 * Points a laser at a tile or mob
 */
/obj/item/circuit_component/laserpointer
	display_name = "Laser Pointer"
	desc = "A component that shines a high powered light at a target."
	category = "Entity"

	/// The Laser Pointer Variables
  	var/pointer_icon_state
  	var/turf/pointer_loc

	var/effectchance = 100 /// same as a tier 4 laser pointer (technically thats 120), which is offset by the large time investment and difficulty in using circuits.

	/// The input port
	var/datum/port/input/target
	var/datum/port/input/image_pixel_x
	var/datum/port/input/image_pixel_y

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/max_range = 7

	var/datum/port/input/option/lasercolour_option


/obj/item/circuit_component/laserpointer/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/laserpointer/populate_options()
	var/static/component_options = list(
		"Red" = "red_laser",
		"Green" = "green_laser",
		"Blue" = "blue_laser",
		"Purple" = "purple_laser",
	)
	lasercolour_option = add_option_port("Laser Colour", component_options)

pointer_icon_state = lasercolour_option

/obj/item/circuit_component/laserpointer/populate_ports()
	target = add_input_port("Target", PORT_TYPE_ATOM)
	image_pixel_x = add_input_port("X-Axis Shift", PORT_TYPE_NUMBER)
	image_pixel_y = add_input_port("Y-Axis Shift", PORT_TYPE_NUMBER)
	
	
/obj/item/circuit_component/laserpointer/input_received(datum/port/input/port)
	
	var/turf/targloc = get_turf(target)
	var/outmsg
	var/atom/target = input_port.value
	var/turf/current_turf = get_location()
	if(get_dist(current_turf, target) > max_range || current_turf.z != target.z)
		return
	
	/// only will effect silicons so you cant use these to constantly grief felinids or blind people. silicons deserve it though
	if(iscyborg(target))
		var/mob/living/silicon/silicon = target
		log_combat(user, silicon, "shone in the sensors", src)
		if(prob(effectchance))
			silicon.flash_act(affect_silicon = 1)
			silicon.Paralyze(rand(10,20)) /// WAYYY less time since ciruits are spammable
			to_chat(silicon, span_danger("Your sensors were overloaded by a laser!"))
			outmsg = span_notice("[silicon]'s sensors are overloaded by a weakened circuit-powered laserpointer.") /// wont be able to see where it comes from (especially in the case of within-backpack or brain circuits), might as well let them know what it came from
			
	
	///laserpointer image
	var/image/laser_location = image('icons/obj/guns/projectiles.dmi',targloc,pointer_icon_state,10)
	
	if(image_pixel_x.value != null)
		laser_location.pixel_x = image_pixel_x.value
	else
		laser_location.pixel_x = target.pixel_x + rand(-5,5)
		
	if(image_pixel_y.value != null)
		laser_location.pixel_y = image_pixel_y.value
	else
		laser_location.pixel_y = target.pixel_y + rand(-5,5)		
	
	flick_overlay_view(laser_location, targloc, 10)

	if(outmsg)
		to_chat(user, outmsg) ///only send a message to the chat if the laser actually does something to prevent chat spam from a light show
	
