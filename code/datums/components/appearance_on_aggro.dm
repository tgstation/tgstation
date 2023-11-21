
/**
 * component gave to basic creatures to allow them to change appearance when find a target
 */
/datum/component/appearance_on_aggro
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// path of the overlay to apply
	var/mutable_appearance/overlay_path
	/// visibility of our icon when aggroed
	var/alpha_on_aggro
	/// visibility of our icon when deaggroed
	var/alpha_on_deaggro

/datum/component/appearance_on_aggro/Initialize(overlay_icon, overlay_state, alpha_on_aggro, alpha_on_deaggro)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(overlay_icon && overlay_state)
		src.overlay_path = mutable_appearance(overlay_icon, overlay_state)
	if(!alpha_on_aggro || !alpha_on_deaggro)
		return
	src.alpha_on_aggro = alpha_on_aggro
	src.alpha_on_deaggro = alpha_on_deaggro

/datum/component/appearance_on_aggro/RegisterWithParent()
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_SET(target_key), PROC_REF(change_appearance))
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key), PROC_REF(revert_appearance))

/datum/component/appearance_on_aggro/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_AI_BLACKBOARD_KEY_SET(target_key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key)))

/datum/component/appearance_on_aggro/proc/change_appearance(mob/living/source)
	SIGNAL_HANDLER

	var/atom/target = source.ai_controller.blackboard[target_key]
	if(isnull(target))
		return
	if(overlay_path)
		source.add_overlay(overlay_path)
	if(alpha_on_aggro)
		animate(source, alpha = alpha_on_aggro, time = 2 SECONDS)

/datum/component/appearance_on_aggro/proc/revert_appearance(mob/living/source)
	SIGNAL_HANDLER

	if(overlay_path)
		source.cut_overlay(overlay_path)
	if(alpha_on_deaggro)
		animate(source, alpha = alpha_on_deaggro, time = 2 SECONDS)
