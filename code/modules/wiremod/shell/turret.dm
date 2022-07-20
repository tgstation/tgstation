/obj/machinery/porta_turret/circuit_shell
	name = "turret shell"

/obj/machinery/porta_turret/circuit_shell/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/porta_turret), \
		capacity = SHELL_CAPACITY_LARGE, \
		shell_flags = SHELL_FLAG_ALLOW_FAILURE_ACTION|SHELL_FLAG_REQUIRE_ANCHOR \
	)

/obj/machinery/porta_turret/circuit_shell/ui_status(mob/user)
	return UI_CLOSE

/obj/machinery/porta_turret/circuit_shell/process()
	return PROCESS_KILL

/obj/item/circuit_component/porta_turret
	display_name = "Turret"
	desc = "The general interface for a turret. Includes statuses about the turret."

	/// The shell, if it is an airlock.
	var/obj/machinery/porta_turret/attached_turret

	/// Target to fire at
	var/datum/port/input/target
	/// Fires at the target
	var/datum/port/input/fire

	/// Determines whether the porta turret is broken or not
	var/datum/port/output/is_broken
	/// Determines whether the porta turret is powered or not
	var/datum/port/output/is_powered

	/// Sent if the shot is successfully fired
	var/datum/port/output/successful_fire
	/// Sent if the shot is unsuccessfully fired
	var/datum/port/output/unsuccessful_fire

/obj/item/circuit_component/porta_turret/populate_ports()
	// Input Signals
	target = add_input_port("Target", PORT_TYPE_ATOM)
	fire = add_input_port("Fire", PORT_TYPE_SIGNAL, trigger = .proc/fire_turret)
	// States
	is_broken = add_output_port("Is Broken", PORT_TYPE_NUMBER)
	is_powered = add_output_port("Is Powered", PORT_TYPE_NUMBER)
	// Output Signals
	successful_fire = add_output_port("Fired", PORT_TYPE_SIGNAL)
	unsuccessful_fire = add_output_port("Failed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/porta_turret/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/machinery/porta_turret))
		attached_turret = shell
		RegisterSignal(shell, COMSIG_MACHINERY_POWER_LOST, .proc/on_power_lost)
		RegisterSignal(shell, COMSIG_MACHINERY_POWER_RESTORED, .proc/on_power_restored)
		RegisterSignal(shell, COMSIG_MACHINERY_STAT_CHANGE, .proc/on_stat_change)

/obj/item/circuit_component/porta_turret/unregister_shell(atom/movable/shell)
	attached_turret = null
	UnregisterSignal(shell, list(
		COMSIG_MACHINERY_POWER_LOST,
		COMSIG_MACHINERY_POWER_LOST,
		COMSIG_MACHINERY_STAT_CHANGE,
	))
	return ..()

/obj/item/circuit_component/porta_turret/proc/on_power_lost()
	SIGNAL_HANDLER
	is_powered.set_value(FALSE)

/obj/item/circuit_component/porta_turret/proc/on_power_restored()
	SIGNAL_HANDLER
	is_powered.set_value(TRUE)

/obj/item/circuit_component/porta_turret/proc/on_stat_change(obj/machinery/porta_turret/turret, old_stat)
	SIGNAL_HANDLER
	if((old_stat & BROKEN) && !(turret.machine_stat & BROKEN))
		is_broken.set_value(FALSE)
	else if(!(old_stat & BROKEN) && (turret.machine_stat & BROKEN))
		is_broken.set_value(TRUE)

/obj/item/circuit_component/porta_turret/proc/fire_turret(datum/port/input/port, list/return_values)
	CIRCUIT_TRIGGER

	var/atom/target_atom = target.value

	if(!target_atom || !attached_turret)
		unsuccessful_fire.set_value(COMPONENT_SIGNAL)
		return

	INVOKE_ASYNC(src, .proc/fire_turret_async, target_atom)

/obj/item/circuit_component/porta_turret/proc/fire_turret_async(atom/target_atom)
	var/fired = attached_turret.target(target_atom, should_return_successful = TRUE)
	if(fired)
		successful_fire.set_value(COMPONENT_SIGNAL)
	else
		unsuccessful_fire.set_value(COMPONENT_SIGNAL)
