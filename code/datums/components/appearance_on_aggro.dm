
/**
 * Changes visuals of the attached mob while it has a target
 */
/datum/component/appearance_on_aggro
	/// Blackboardey to search for a target
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// Icon state to use when we have a target
	var/aggro_state
	/// path of the overlay to apply
	var/mutable_appearance/aggro_overlay
	/// visibility of our icon when aggroed
	var/alpha_on_aggro
	/// visibility of our icon when deaggroed
	var/alpha_on_deaggro

/datum/component/appearance_on_aggro/Initialize(aggro_state, overlay_icon, overlay_state, alpha_on_aggro, alpha_on_deaggro)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.aggro_state = aggro_state
	src.alpha_on_aggro = alpha_on_aggro
	src.alpha_on_deaggro = alpha_on_deaggro
	if (!isnull(overlay_icon) && !isnull(overlay_state))
		aggro_overlay = mutable_appearance(overlay_icon, overlay_state)

/datum/component/appearance_on_aggro/RegisterWithParent()
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_SET(target_key), PROC_REF(on_set_target))
	RegisterSignals(parent, list(COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key), COMSIG_LIVING_DEATH, COMSIG_MOB_LOGIN), PROC_REF(revert_appearance))
	if (!isnull(aggro_state))
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_icon_state_updated))
	if (!isnull(aggro_overlay))
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlays_updated))

/datum/component/appearance_on_aggro/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_AI_BLACKBOARD_KEY_SET(target_key),
		COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key),
		COMSIG_LIVING_DEATH,
		COMSIG_MOB_LOGIN,
	))

/datum/component/appearance_on_aggro/proc/on_set_target(mob/living/source)
	SIGNAL_HANDLER

	var/atom/target = source.ai_controller?.blackboard[target_key]
	if (QDELETED(target))
		return

	if (!isnull(aggro_overlay) || !isnull(aggro_state))
		source.update_appearance(UPDATE_ICON)
	if (!isnull(alpha_on_aggro))
		animate(source, alpha = alpha_on_aggro, time = 2 SECONDS)

/datum/component/appearance_on_aggro/Destroy()
	revert_appearance(parent)
	return ..()

/datum/component/appearance_on_aggro/proc/revert_appearance(mob/living/source)
	SIGNAL_HANDLER
	if (!isnull(aggro_overlay) || !isnull(aggro_state))
		source.update_appearance(UPDATE_ICON)
	if (!isnull(alpha_on_deaggro))
		animate(source, alpha = alpha_on_deaggro, time = 2 SECONDS)

/datum/component/appearance_on_aggro/proc/on_icon_state_updated(mob/living/source)
	SIGNAL_HANDLER
	if (source.stat == DEAD)
		return
	source.icon_state = source.ai_controller?.blackboard_key_exists(target_key) ? aggro_state : initial(source.icon_state)

/datum/component/appearance_on_aggro/proc/on_overlays_updated(mob/living/basic/source, list/overlays)
	SIGNAL_HANDLER

	if(!(source.ai_controller?.blackboard_key_exists(target_key)))
		return
	overlays += aggro_overlay
