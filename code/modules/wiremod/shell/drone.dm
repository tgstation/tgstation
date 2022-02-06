/**
 * # Drone
 *
 * A movable mob that can be fed inputs on which direction to travel.
 */
/mob/living/circuit_drone
	name = "drone"
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "setup_medium_med"
	living_flags = 0
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_on = FALSE

/mob/living/circuit_drone/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/bot_circuit()
	), SHELL_CAPACITY_LARGE)

/mob/living/circuit_drone/updatehealth()
	. = ..()
	if(health < 0)
		gib(no_brain = TRUE, no_organs = TRUE, no_bodyparts = TRUE)

/mob/living/circuit_drone/spawn_gibs()
	new /obj/effect/gibspawner/robot(drop_location(), src, get_static_viruses())

/obj/item/circuit_component/bot_circuit
	display_name = "Drone"
	desc = "Used to send movement output signals to the drone shell."

	/// The inputs to allow for the drone to move
	var/datum/port/input/north
	var/datum/port/input/east
	var/datum/port/input/south
	var/datum/port/input/west

	// Done like this so that travelling diagonally is more simple
	COOLDOWN_DECLARE(north_delay)
	COOLDOWN_DECLARE(east_delay)
	COOLDOWN_DECLARE(south_delay)
	COOLDOWN_DECLARE(west_delay)

	/// Delay between each movement
	var/move_delay = 0.2 SECONDS

/obj/item/circuit_component/bot_circuit/populate_ports()
	north = add_input_port("Move North", PORT_TYPE_SIGNAL)
	east = add_input_port("Move East", PORT_TYPE_SIGNAL)
	south = add_input_port("Move South", PORT_TYPE_SIGNAL)
	west = add_input_port("Move West", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/bot_circuit/input_received(datum/port/input/port)

	var/mob/living/shell = parent.shell
	if(!istype(shell) || shell.stat)
		return

	var/direction

	if(COMPONENT_TRIGGERED_BY(north, port) && COOLDOWN_FINISHED(src, north_delay))
		direction = NORTH
		COOLDOWN_START(src, north_delay, move_delay)
	else if(COMPONENT_TRIGGERED_BY(east, port) && COOLDOWN_FINISHED(src, east_delay))
		direction = EAST
		COOLDOWN_START(src, east_delay, move_delay)
	else if(COMPONENT_TRIGGERED_BY(south, port) && COOLDOWN_FINISHED(src, south_delay))
		direction = SOUTH
		COOLDOWN_START(src, south_delay, move_delay)
	else if(COMPONENT_TRIGGERED_BY(west, port) && COOLDOWN_FINISHED(src, west_delay))
		direction = WEST
		COOLDOWN_START(src, west_delay, move_delay)

	if(!direction)
		return

	if(shell.Process_Spacemove(direction))
		shell.Move(get_step(shell, direction), direction)
