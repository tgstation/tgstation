
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
	/// do we currently have a target
	var/atom/current_target

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
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(change_overlays))
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_SET(target_key), PROC_REF(on_set_target))
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key), PROC_REF(on_clear_target))

/datum/component/appearance_on_aggro/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_AI_BLACKBOARD_KEY_SET(target_key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key)))

/datum/component/appearance_on_aggro/proc/on_set_target(mob/living/source)
	SIGNAL_HANDLER

	var/atom/target = source.ai_controller.blackboard[target_key]
	if(isnull(target))
		return
	current_target = target
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_clear_target))
	if(overlay_path)
		source.update_appearance(UPDATE_OVERLAYS)
	if(alpha_on_aggro)
		animate(source, alpha = alpha_on_aggro, time = 2 SECONDS)

/datum/component/appearance_on_aggro/Destroy()
	if(current_target)
		revert_appearance(parent)
	return ..()

/datum/component/appearance_on_aggro/proc/on_clear_target(atom/source)
	SIGNAL_HANDLER

	revert_appearance(parent)

/datum/component/appearance_on_aggro/proc/revert_appearance(mob/living/source)
	UnregisterSignal(current_target, COMSIG_QDELETING)
	current_target = null
	if(overlay_path)
		source.update_appearance(UPDATE_OVERLAYS)
	if(alpha_on_deaggro)
		animate(source, alpha = alpha_on_deaggro, time = 2 SECONDS)

/datum/component/appearance_on_aggro/proc/change_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(isnull(current_target))
		return

	overlays += overlay_path
