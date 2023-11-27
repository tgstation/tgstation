/datum/component/spy_uplink
	var/datum/weakref/spy_ref

	var/static/datum/spy_bounty_handler/handler

/datum/component/spy_uplink/Initialize(mob/living/spy)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	spy_ref = WEAKREF(spy)

	if(isnull(handler))
		handler = new()

/datum/component/spy_uplink/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_pre_attack))

	if(istype(parent, /obj/item/modular_computer/pda))
		RegisterSignal(parent, COMSIG_TABLET_CHANGE_ID, PROC_REF(new_ringtone))
		parent.AddElement(/datum/element/pda_bomb_proof)
	if(istype(parent, /obj/item/radio))
		RegisterSignal(parent, COMSIG_RADIO_NEW_MESSAGE, PROC_REF(new_message))
	if(istype(parent, /obj/item/pen))
		RegisterSignal(parent, COMSIG_PEN_ROTATED, PROC_REF(pen_rotation))

/datum/component/spy_uplink/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY)
	UnregisterSignal(parent, list(COMSIG_TABLET_CHANGE_ID, COMSIG_RADIO_NEW_MESSAGE, COMSIG_PEN_ROTATED))

/datum/component/spy_uplink/proc/on_pre_attack(obj/item/source, atom/target, mob/living/user, params)
	SIGNAL_HANDLER

	if(!IS_WEAKREF_OF(user, spy_ref))
		return NONE

	if(try_steal(target, user))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	return NONE
