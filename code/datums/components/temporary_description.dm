/**
 * Adds examine text to something which is removed when receiving specified signals, by default the revive signal.
 * The default settings are set up to be applied to a corpse to add some kind of immersive storytelling text which goes away upon revival.
 */
/datum/component/temporary_description
	/// What do we display on examine?
	var/description_text = ""
	/// What do we display if examined by a clown? Usually only applied if this is put on a corpse, but go nuts.
	var/naive_description = ""
	/// When are we removed?
	var/list/removal_signals

/datum/component/temporary_description/Initialize(
	description_text = "There's something unusual about them.",
	naive_description = "",
	list/removal_signals = list(COMSIG_LIVING_REVIVE),
)
	. = ..()
	if (!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if (!description_text)
		stack_trace("[type] applied to [parent] with empty description, which is pointless.")
	src.description_text = description_text
	src.naive_description = naive_description
	if (length(removal_signals))
		src.removal_signals = removal_signals

/datum/component/temporary_description/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignals(parent, removal_signals, PROC_REF(remove_component))

/datum/component/temporary_description/UnregisterFromParent()
	UnregisterSignal(parent, removal_signals + COMSIG_ATOM_EXAMINE)

/datum/component/temporary_description/proc/on_examined(atom/corpse, mob/thing_inspector, list/examine_list)
	SIGNAL_HANDLER
	if (naive_description && HAS_MIND_TRAIT(thing_inspector, TRAIT_NAIVE))
		examine_list += span_notice(naive_description)
		return
	examine_list += span_notice(description_text)

/datum/component/temporary_description/proc/remove_component()
	SIGNAL_HANDLER
	qdel(src) // It wouldn't be immersive if the circumstances of my grisly death remained after I was revived
