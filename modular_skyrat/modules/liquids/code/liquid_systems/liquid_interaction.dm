///This element allows for items to interact with liquids on turfs.
/datum/element/liquids_interaction
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	///Callback interaction called when the turf has some liquids on it
	var/datum/callback/interaction_callback

/datum/element/liquids_interaction/Attach(obj/item/target, on_interaction_callback)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	if(!src.interaction_callback)
		src.interaction_callback = CALLBACK(target, on_interaction_callback)

	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, .proc/AfterAttack) //The only signal allowing item -> turf interaction

/datum/element/liquids_interaction/Detach(mob/living/target)
	UnregisterSignal(target, COMSIG_ITEM_AFTERATTACK)

/datum/element/liquids_interaction/proc/AfterAttack(obj/item/target, atom/target2, mob/user)
	SIGNAL_HANDLER
	if(!isturf(target2))
		return
	var/turf/T = target2
	if(!T.liquids)
		return
	if(interaction_callback.Invoke(target, target2, user, T.liquids))
		return COMPONENT_CANCEL_ATTACK_CHAIN
