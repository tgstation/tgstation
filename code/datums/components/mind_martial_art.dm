/// A martial art that is owned by this mind and will transfer as mind moves
/datum/component/mindbound_martial_arts
	dupe_mode = COMPONENT_DUPE_SELECTIVE
	/// The style transferred between minds
	var/datum/martial_art/style

/datum/component/mindbound_martial_arts/Initialize(style_type)
	if(!istype(parent, /datum/mind))
		return COMPONENT_INCOMPATIBLE

	style = new style_type(src)

/datum/component/mindbound_martial_arts/CheckDupeComponent(datum/component/new_comp, new_style_type)
	return style.type == new_style_type

/datum/component/mindbound_martial_arts/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MIND_TRANSFERRED, PROC_REF(mind_transferred))

	var/datum/mind/mind = parent
	style.teach(mind.current)

/datum/component/mindbound_martial_arts/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MIND_TRANSFERRED)

	var/datum/mind/mind = parent
	style.unlearn(mind.current)

/datum/component/mindbound_martial_arts/Destroy()
	QDEL_NULL(style)
	return ..()

/// Signal proc for [COMSIG_MOB_MIND_TRANSFERRED_OUT_OF] to pass martial arts between bodies on mind transfer
/// By this point the martial art's holder is the old body, but the mind that owns it is in the new body
/datum/component/mindbound_martial_arts/proc/mind_transferred(datum/mind/source, mob/living/old_body)
	SIGNAL_HANDLER

	style.unlearn(old_body)
	style.teach(source.current)
