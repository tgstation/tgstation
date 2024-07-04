/datum/element/clockwork_description
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2

	/// Text to add to the description of the parent
	var/text_to_add = ""
	/// Text to add if we are on reebe
	var/reebe_desc = ""

/datum/element/clockwork_description/Attach(datum/target, parent_text, reebe_text)
	. = ..()

	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(add_examine))
	// Don't perform the assignment if there is nothing to assign, or if we already have something for this bespoke element
	if(parent_text && !text_to_add)
		text_to_add = parent_text

	if(reebe_text && !reebe_desc)
		reebe_desc = reebe_text

/datum/element/clockwork_description/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_EXAMINE)

/**
 *
 * This proc is called when the user examines an object with the associated element. This adds the text to the description in a new line, wrapped with span_brass()
 *
 * Arguments:
 * 	* source - Object being examined, cast into an item variable
 *  * user - Unused
 *  * examine_texts - The output text list of the original examine function
 */

/datum/element/clockwork_description/proc/add_examine(atom/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	if(IS_CLOCK(user) || isobserver(user))
		examine_texts += span_brass(text_to_add)
		if(reebe_desc && on_reebe(source))
			examine_texts += span_brass(reebe_desc)
