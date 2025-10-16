/// A simple element for adding additional lore to things. Examine more? More like examine *lore*.
/// Yes, the name's a pun, I'm sorry, I thought it was funny at the moment.
/datum/element/examine_lore
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The message we add to items to denote that we have cool lore to read.
	var/lore_hint
	/// Our lore. In order to match descriptions on items, this should be considered to be pre-italicized.
	var/lore

/datum/element/examine_lore/Attach(datum/target, lore_hint, lore)
	. = ..()

	src.lore_hint = lore_hint
	src.lore = lore

	if(!lore_hint || !lore)
		stack_trace("[type] initialized without lore or a lore hint! Double-check element addition?")
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))


/datum/element/examine_lore/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_EXAMINE_MORE,
	))

/datum/element/examine_lore/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += lore_hint

/datum/element/examine_lore/proc/on_examine_more(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<i>[lore]</i>"
