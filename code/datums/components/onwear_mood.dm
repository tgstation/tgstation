// Add to clothing to give the wearer a mood buff and a unique examine str

/datum/component/onwear_mood
	/// the event the wearer experiences
	var/datum/mood_event/saved_event
	/// examine string added to examine
	var/examine_string
	/// the wearer themself
	var/mob/wearer

/datum/component/onwear_mood/Initialize(clear_after, datum/mood_event/saved_event, examine_string)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	if(istype(saved_event))
		src.saved_event = saved_event

	src.examine_string = examine_string

	if(isnum(clear_after))
		QDEL_IN(src, clear_after)

/datum/component/onwear_mood/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/affect_wearer)

/datum/component/onwear_mood/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)

	if(wearer)
		clear_effects()

/datum/component/onwear_mood/proc/affect_wearer(mob/target)
	SIGNAL_HANDLER
	wearer = target
	wearer.add_mood_event(REF(src), saved_event)
	RegisterSignal(wearer, COMSIG_MOB_UNEQUIPPED_ITEM, .proc/clear_effects)
	RegisterSignal(wearer, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/onwear_mood/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice(examine_string)

/// clears the effects on the wearer
/datum/component/onwear_mood/proc/clear_effects()
	SIGNAL_HANDLER
	if(!wearer)
		return

	UnregisterSignal(wearer, list(COMSIG_MOB_UNEQUIPPED_ITEM, COMSIG_PARENT_EXAMINE))
	wearer.clear_mood_event("onwear")
	wearer = null

/datum/component/onwear_mood/Destroy(force, silent)
	clear_effects()
	. = ..()
