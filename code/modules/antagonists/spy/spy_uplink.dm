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
	RegisterSignal(parent, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(block_pda_bombs))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_pre_attack_secondary))

/datum/component/spy_uplink/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PRE_ATTACK_SECONDARY,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_TABLET_CHECK_DETONATE,
	))

/datum/component/spy_uplink/proc/block_pda_bombs(obj/item/source)
	SIGNAL_HANDLER

	return COMPONENT_TABLET_NO_DETONATE

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
