/**
 * # Install Detector Component
 *
 * Detects when a BCI, implant, or similar such circuit is installed/removed.
 * Requires a shell that gets inserted into a mob, such as a BCI or implant.
 */

/obj/item/circuit_component/install_detector
	display_name = "Install Detector"
	desc = "A component that detects when the circuit is installed or removed from its user."
	category = "Entity"

	required_shells = list(/obj/item/organ/cyberimp/bci, /obj/item/implant)

	var/datum/port/output/implanted
	var/datum/port/output/removed
	var/datum/port/output/current_state

/obj/item/circuit_component/install_detector/populate_ports()
	. = ..()
	current_state = add_output_port("Current State", PORT_TYPE_NUMBER)
	implanted = add_output_port("Implanted", PORT_TYPE_SIGNAL)
	removed = add_output_port("Removed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/install_detector/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/organ/cyberimp/bci))
		RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, PROC_REF(implanted))
		RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(removed))
	if(istype(shell, /obj/item/implant))
		RegisterSignal(shell, COMSIG_IMPLANT_IMPLANTED, PROC_REF(implanted))
		RegisterSignal(shell, COMSIG_IMPLANT_REMOVED, PROC_REF(removed))

/obj/item/circuit_component/install_detector/unregister_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/organ/cyberimp/bci))
		UnregisterSignal(shell, list(
			COMSIG_ORGAN_IMPLANTED,
			COMSIG_ORGAN_REMOVED,
		))
	if(istype(shell, /obj/item/implant))
		UnregisterSignal(shell, list(
			COMSIG_IMPLANT_IMPLANTED,
			COMSIG_IMPLANT_REMOVED,
		))

/obj/item/circuit_component/install_detector/proc/implanted(datum/source, mob/living/owner)
	SIGNAL_HANDLER
	current_state.set_output(TRUE)
	implanted.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/install_detector/proc/removed(datum/source, mob/living/owner)
	SIGNAL_HANDLER
	current_state.set_output(FALSE)
	removed.set_output(COMPONENT_SIGNAL)
