/**
 * # Drone
 *
 * A movable mob that can be fed inputs on which direction to travel.
 */
/mob/living/circuit_drone
	name = "drone"
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "setup_medium_med"
	maxHealth = 300
	health = 300
	mob_biotypes = MOB_ROBOTIC
	living_flags = NONE
	light_system = OVERLAY_LIGHT_DIRECTIONAL
	light_on = FALSE

/mob/living/circuit_drone/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/bot_circuit(),
		new /obj/item/circuit_component/remotecam/drone()
	), SHELL_CAPACITY_LARGE)

/mob/living/circuit_drone/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		if(health > maxHealth/3)
			. += "[src]'s parts look loose."
		else
			. += "[src]'s parts look very loose!"
	else
		. += "[src] is in pristine condition."

/mob/living/circuit_drone/updatehealth()
	. = ..()
	if(health < 0)
		gib()

/mob/living/circuit_drone/welder_act(mob/living/user, obj/item/tool)
	. = ..()
	if(health == maxHealth)
		balloon_alert(user, "already at maximum integrity!")
		return TRUE
	if(tool.use_tool(src, user, 1 SECONDS, volume = 50))
		heal_overall_damage(50, 50)
	return TRUE

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

/obj/item/circuit_component/bot_circuit/register_shell(atom/movable/shell)
	. = ..()
	if(ismob(shell))
		RegisterSignal(shell, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))

/obj/item/circuit_component/bot_circuit/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	return ..()

/obj/item/circuit_component/bot_circuit/proc/on_borg_charge(datum/source, datum/callback/charge_cell, seconds_per_tick)
	SIGNAL_HANDLER
	if (isnull(parent.cell))
		return
	charge_cell.Invoke(parent.cell, seconds_per_tick)

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

	if(ismovable(shell.loc)) //Inside an object, tell it we moved
		var/atom/loc_atom = shell.loc
		loc_atom.relaymove(shell, direction)
		return

	if(shell.Process_Spacemove(direction))
		shell.Move(get_step(shell, direction), direction)
