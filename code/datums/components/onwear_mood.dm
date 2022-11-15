/// Add to clothing to give the wearer a mood buff and a unique examine text
/datum/component/onwear_mood
	/// the event the wearer experiences
	var/datum/mood_event/saved_event
	/// examine string added to examine
	var/examine_string

/datum/component/onwear_mood/Initialize(datum/mood_event/saved_event, examine_string)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.saved_event = saved_event
	src.examine_string = examine_string

/datum/component/onwear_mood/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(affect_wearer))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/onwear_mood/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_PARENT_EXAMINE))
	clear_effects()

/datum/component/onwear_mood/proc/affect_wearer(datum/source, mob/living/target, slot)
	SIGNAL_HANDLER
	if(!(slot & ITEM_SLOT_ON_BODY))
		return  // only affects "worn" slots

	target.add_mood_event(REF(src), saved_event)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(clear_effects))

/datum/component/onwear_mood/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice(examine_string)

/// clears the effects on the wearer
/datum/component/onwear_mood/proc/clear_effects(mob/living/source, obj/item/dropped_item)
	SIGNAL_HANDLER
	var/obj/item/clothing = parent
	if(dropped_item != clothing && source)
		return
	source = source || clothing.loc
	if(!istype(source))
		return
	UnregisterSignal(source, list(COMSIG_PARENT_EXAMINE, COMSIG_MOB_UNEQUIPPED_ITEM))
	target.clear_mood_event(REF(src))

/datum/component/onwear_mood/Destroy(force, silent)
	clear_effects()
	return ..()
