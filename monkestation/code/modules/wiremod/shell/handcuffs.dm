/**
 * # Handcuffs
 *
 * Shell that can detect when someone is breaking out, or let them free early.
 */

/*
Port of a closed /tg/station PR
Port: #65210
*/

/obj/item/restraints/handcuffs/circuit
	name = "circuit handcuffs"
	icon = 'monkestation/icons/obj/wiremod.dmi'
	icon_state = "circuit_cuffs"
	breakouttime = 30 SECONDS //Same as cable cuffs
	density = FALSE
	light_range = FALSE

/obj/item/restraints/handcuffs/circuit/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/shell, \
		unremovable_circuit_components = list(new /obj/item/circuit_component/handcuffs), \
		capacity = SHELL_CAPACITY_SMALL, \
	)


//Circuit Component//

/obj/item/circuit_component/handcuffs
	display_name = "Handcuffs"
	display_desc = "Allows you to get data about anyone restrained by these cuffs."

	/// The person held captive.
	var/datum/port/output/captive
	/// When someone is cuffed.
	var/datum/port/output/cuffed
	/// When someone is uncuffed or breaks out.
	var/datum/port/output/uncuffed
	/// When someone is attempting to take off the cuffs.
	var/datum/port/output/resisting

/obj/item/circuit_component/handcuffs/Initialize(mapload)
	. = ..()
	captive = add_output_port("Captive", PORT_TYPE_ATOM)
	cuffed = add_output_port("Cuffed", PORT_TYPE_SIGNAL)
	uncuffed = add_output_port("Uncuffed", PORT_TYPE_SIGNAL)
	resisting = add_output_port("Resisting", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/handcuffs/register_shell(atom/movable/shell)
	RegisterSignal(shell, COMSIG_CIRCUIT_CUFFS_APPLIED, .proc/on_cuffed)
	RegisterSignal(shell, COMSIG_CIRCUIT_CUFFS_REMOVED, .proc/on_uncuffed)
	RegisterSignal(shell, COMSIG_CIRCUIT_CUFFS_RESISTED, .proc/on_resist)

/obj/item/circuit_component/handcuffs/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, COMSIG_CIRCUIT_CUFFS_APPLIED)
	UnregisterSignal(shell, COMSIG_CIRCUIT_CUFFS_REMOVED)
	UnregisterSignal(shell, COMSIG_CIRCUIT_CUFFS_RESISTED)

/obj/item/circuit_component/handcuffs/proc/on_cuffed(mob/target)
	SIGNAL_HANDLER
	captive.set_output(target)
	cuffed.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/handcuffs/proc/on_uncuffed()
	SIGNAL_HANDLER
	captive.set_output(null)
	uncuffed.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/handcuffs/proc/on_resist()
	SIGNAL_HANDLER
	resisting.set_output(COMPONENT_SIGNAL)
