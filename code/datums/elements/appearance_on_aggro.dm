/**
 * Element gave to basic creatures to allow them to change appearance when find a target
 */
/datum/element/appearance_on_aggro
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// the target key
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// path of the overlay to apply
	var/mutable_appearance/overlay_path

/datum/element/appearance_on_aggro/Attach(datum/target, overlay_icon, overlay_state)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	src.overlay_path = mutable_appearance(overlay_icon, overlay_state)
	RegisterSignal(target, COMSIG_AI_BLACKBOARD_KEY_SET(target_key), PROC_REF(add_overlay))
	RegisterSignal(target, COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key), PROC_REF(remove_overlay))

/datum/element/appearance_on_aggro/proc/remove_overlay(mob/living/source)
	SIGNAL_HANDLER

	source.cut_overlay(overlay_path)

/datum/element/appearance_on_aggro/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_AI_BLACKBOARD_KEY_SET(target_key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key)))

/datum/element/appearance_on_aggro/proc/add_overlay(mob/living/source)
	SIGNAL_HANDLER
	var/atom/target = source.ai_controller.blackboard[target_key]
	if(isnull(target))
		return
	source.add_overlay(overlay_path)
