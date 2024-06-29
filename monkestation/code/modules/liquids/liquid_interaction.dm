///This element allows for items to interact with liquids on turfs.
/datum/component/liquids_interaction
	///Callback interaction called when the turf has some liquids on it
	var/datum/callback/interaction_callback

/datum/component/liquids_interaction/Initialize(on_interaction_callback)
	. = ..()

	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE

	interaction_callback = CALLBACK(parent, on_interaction_callback)

/datum/component/liquids_interaction/Destroy(force, silent)
	interaction_callback = null
	return ..()

/datum/component/liquids_interaction/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(AfterAttack)) //The only signal allowing item -> turf interaction

/datum/component/liquids_interaction/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)

/datum/component/liquids_interaction/proc/AfterAttack(datum/source, atom/victim, mob/caster, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	var/turf/turf_target = victim

	if(!isturf(turf_target) || !turf_target.liquids)
		return NONE

	if(interaction_callback.Invoke(parent, victim, caster, turf_target.liquids))
		return COMPONENT_CANCEL_ATTACK_CHAIN
