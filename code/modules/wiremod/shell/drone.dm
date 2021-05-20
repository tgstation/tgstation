/**
 * # Drone
 *
 * A movable mob that can be fed inputs on which direction to travel.
 */
/mob/living/simple_animal/bot/circuit
	name = "drone"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_medium_med"
	living_flags = 0
	light_system = MOVABLE_LIGHT_DIRECTIONAL

/mob/living/simple_animal/bot/circuit/Initialize()
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/component/bot_circuit()
	), SHELL_CAPACITY_LARGE)

/obj/item/component/bot_circuit
	display_name = "Drone"

	/// The inputs to allow for the drone to move
	var/datum/port/input/north
	var/datum/port/input/east
	var/datum/port/input/south
	var/datum/port/input/west

/obj/item/component/bot_circuit/Initialize()
	. = ..()
	north = add_input_port("Move North", PORT_TYPE_NUMBER)
	east = add_input_port("Move East", PORT_TYPE_NUMBER)
	south = add_input_port("Move South", PORT_TYPE_NUMBER)
	west = add_input_port("Move West", PORT_TYPE_NUMBER)

/obj/item/component/bot_circuit/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/mob/living/B = parent.shell
	if(!istype(B))
		return

	var/direction

	if(COMPONENT_TRIGGERED_BY(north))
		direction = NORTH
	else if(COMPONENT_TRIGGERED_BY(east))
		direction = EAST
	else if(COMPONENT_TRIGGERED_BY(south))
		direction = SOUTH
	else if(COMPONENT_TRIGGERED_BY(west))
		direction = WEST

	if(!direction)
		return

	if(B.Process_Spacemove(direction))
		B.Move(get_step(B, direction), direction)
