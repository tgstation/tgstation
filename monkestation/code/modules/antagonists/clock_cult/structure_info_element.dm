/datum/element/clockwork_structure_info
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY


/datum/element/clockwork_structure_info/Attach(datum/target, list/slots_to_count)
	. = ..()

	if(!istype(target, /obj/structure/destructible/clockwork/gear_base))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(print_info))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))


/datum/element/clockwork_structure_info/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_AFTER_ATTACKEDBY)

/**
 *
 * This proc is called when the user hits the target with an item, which checks for it being a clockwork slab.
 *
 * Arguments:
 * 	* source - The structure that was attacked
 *  * weapon - The item that attacked the structure
 * 	* user - The one who attacked the structure
 */
/datum/element/clockwork_structure_info/proc/print_info(obj/structure/destructible/clockwork/gear_base/source, obj/item/weapon, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!IS_CLOCK(user) || !istype(weapon, /obj/item/clockwork/clockwork_slab))
		return

	var/assembled_string = ""

	assembled_string += "<b>[source]</b><br>"
	assembled_string += "This structure is currently <b>[source.anchored ? "anchored" : "unanchored"]</b>.<br>"

	if(istype(source, /obj/structure/destructible/clockwork/gear_base/powered))
		var/obj/structure/destructible/clockwork/gear_base/powered/powered_source = source
		assembled_string += "This structure is currently toggled <b>[powered_source.enabled ? "on" : "off"]</b>, and is <b>[powered_source.processing ? "running" : "not running"]</b>.<br>"
		assembled_string += "This structure consumes <b>[powered_source.passive_consumption]</b> W every 2 seconds while enabled.<br>"
		assembled_string += "This structure is connected to <b>[LAZYLEN(powered_source.transmission_sigils)]</b> transmission sigil[LAZYLEN(powered_source.transmission_sigils) == 1 ? "" : "s"]."

	to_chat(user, span_brass(assembled_string))

/**
 *
 * This proc is called when a mob examines the structure
 *
 * Arguments:
 * 	* source - The structure that was examined
 * 	* user - The one who attacked the structure
 *  * examine_text - The list of text to send the examiner
 */
/datum/element/clockwork_structure_info/proc/on_examine(obj/structure/destructible/clockwork/gear_base/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(!IS_CLOCK(examiner))
		return

	examine_text += span_brass("You can gain more information by using a <b>Clockwork Slab</b>.")
