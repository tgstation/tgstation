#define COMP_COLOUR_RED "red"
#define COMP_COLOUR_GREEN "green"
#define COMP_COLOUR_BLUE "blue"
#define COMP_COLOUR_PURPLE "purple"

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
	var/energy = 10
	var/max_energy = 10
	var/effectchance = 100 /// same as a tier 4 laser pointer (technically thats 120), which is offset by the large time investment and difficulty in using circuits.

	/// The input port
	var/datum/port/input/input_port

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/max_range = 5

  var/datum/port/input/option/lasercolour_option

/obj/item/circuit_component/laserpointer/get_ui_notices()
	. = ..()
	. += create_ui_notice("Maximum Range: [max_range] tiles", "orange", "info")

/obj/item/circuit_component/laserpointer/populate_options()
	var/static/component_options = list(
		COMP_COLOUR_RED,
		COMP_COLOUR_GREEN,
		COMP_COLOUR_BLUE,
		COMP_COLOUR_PURPLE,
	)
	lasercolour_option = add_option_port("Laser Colour", component_options)

pointer_icon_state = lasercolour_option

/obj/item/circuit_component/laserpointer/populate_ports()
	input_port = add_input_port("Target", PORT_TYPE_ATOM)
