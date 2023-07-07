/// Add to clothing to give the wearer a mood buff and a unique examine text
/datum/component/onwear_mood
	/// the event the wearer experiences
	var/datum/mood_event/saved_event_type
	/// examine string added to examine
	var/examine_string
	/// what slots it needs to be equipped to to work
	var/slot_equip

/datum/component/onwear_mood/Initialize(datum/mood_event/saved_event_type, examine_string, slot_equip = ITEM_SLOT_ON_BODY)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.saved_event_type = saved_event_type
	src.examine_string = examine_string
	if(!isnum(slot_equip))
		stack_trace("Attempted to initialize onwear component with improper slot_equip [slot_equip]")
		slot_equip = ITEM_SLOT_ON_BODY
	src.slot_equip = slot_equip

/datum/component/onwear_mood/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(affect_wearer))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/onwear_mood/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ATOM_EXAMINE))
	clear_effects()

/datum/component/onwear_mood/proc/affect_wearer(datum/source, mob/living/target, slot)
	SIGNAL_HANDLER
	if(!(slot & slot_equip))
		return  // only affects "worn" slots by default

	target.add_mood_event(REF(src), saved_event_type)
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(clear_effects))

/datum/component/onwear_mood/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice(examine_string)

/// clears the effects on the wearer
/datum/component/onwear_mood/proc/clear_effects(mob/living/source, obj/item/dropped_item)
	SIGNAL_HANDLER
	var/obj/item/clothing = parent
	// if called from a signal, check clothing
	if(dropped_item && dropped_item != clothing)
		return
	source ||= clothing.loc
	if(!istype(source))
		return
	UnregisterSignal(source, list(COMSIG_ATOM_EXAMINE, COMSIG_MOB_UNEQUIPPED_ITEM))
	source.clear_mood_event(REF(src))
