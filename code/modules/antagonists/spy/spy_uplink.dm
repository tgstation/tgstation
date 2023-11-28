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
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_pre_attack_secondary))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))

	if(istype(parent, /obj/item/modular_computer/pda))
		RegisterSignal(parent, COMSIG_TABLET_CHANGE_ID, PROC_REF(new_ringtone))
		parent.AddElement(/datum/element/pda_bomb_proof)
	if(istype(parent, /obj/item/radio))
		RegisterSignal(parent, COMSIG_RADIO_NEW_MESSAGE, PROC_REF(new_message))
	if(istype(parent, /obj/item/pen))
		RegisterSignal(parent, COMSIG_PEN_ROTATED, PROC_REF(pen_rotation))

/datum/component/spy_uplink/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY)
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(parent, list(COMSIG_TABLET_CHANGE_ID, COMSIG_RADIO_NEW_MESSAGE, COMSIG_PEN_ROTATED))

/datum/component/spy_uplink/proc/new_ringtone()

/datum/component/spy_uplink/proc/new_message()

/datum/component/spy_uplink/proc/pen_rotation()

/datum/component/spy_uplink/proc/on_attack_self(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(IS_WEAKREF_OF(user, spy_ref))
		ui_interact(user)
	return NONE

/datum/component/spy_uplink/proc/on_pre_attack_secondary(obj/item/source, atom/target, mob/living/user, params)
	SIGNAL_HANDLER

	if(!IS_WEAKREF_OF(user, spy_ref))
		return NONE

	if(try_steal(target, user))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	return NONE

/datum/component/spy_uplink/proc/try_steal(atom/stealing, mob/living/spy)
	for(var/datum/spy_bounty/bounty as anything in handler.get_all_bounties())
		if(bounty.is_stealable(stealing))
			start_stealing(stealing, spy, bounty)
			return TRUE

	return FALSE

/datum/component/spy_uplink/proc/start_stealing(atom/stealing, mob/living/spy, datum/spy_bounty/bounty)
	set waitfor = FALSE

	stealing.visible_message(
		span_warning("[spy] starts scanning [stealing] with a strange device..."),
		span_notice("You start scanning [stealing], preparing it for extraction."),
	)
	if(!do_after(spy, bounty.theft_time, stealing))
		return
	handler.complete_bounty(stealing, spy, bounty)
