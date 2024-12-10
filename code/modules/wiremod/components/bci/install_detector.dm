/**
 * # Install Detector Component
 *
 * Detects when a BCI is installed/removed.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/install_detector
	display_name = "Install Detector"
	desc = "A component that detects when a BCI is installed or removed from its user."
	category = "BCI"

	required_shells = list(/obj/item/organ/cyberimp/bci)

	var/datum/port/output/implanted
	var/datum/port/output/removed
	var/datum/port/output/current_state

	var/obj/item/organ/cyberimp/bci/bci

/obj/item/circuit_component/install_detector/populate_ports()
	. = ..()
	current_state = add_output_port("Current State", PORT_TYPE_NUMBER)
	implanted = add_output_port("Implanted", PORT_TYPE_SIGNAL)
	removed = add_output_port("Removed", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/install_detector/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/organ/cyberimp/bci))
		bci = shell
		RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
		RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/obj/item/circuit_component/install_detector/unregister_shell(atom/movable/shell)
	. = ..()
	bci = null
	UnregisterSignal(shell, list(
		COMSIG_ORGAN_IMPLANTED,
		COMSIG_ORGAN_REMOVED,
	))

/obj/item/circuit_component/install_detector/proc/on_organ_implanted(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	current_state.set_output(TRUE)
	implanted.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/install_detector/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER
	current_state.set_output(FALSE)
	removed.set_output(COMPONENT_SIGNAL)
