/**
 * ## Spy uplink
 *
 * Applied to items similar to traitor uplinks.
 *
 * Used for spies to complete bounties.
 */
/datum/component/spy_uplink
	/// Weakref to the spy which owns this uplink
	var/datum/weakref/spy_ref
	/// The handler which manages all bounties across all spies.
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
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user)
	return NONE

/datum/component/spy_uplink/proc/on_pre_attack_secondary(obj/item/source, atom/target, mob/living/user, params)
	SIGNAL_HANDLER

	if(!IS_WEAKREF_OF(user, spy_ref))
		return NONE

	if(try_steal(target, user))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	return NONE

/// Checks if the passed atom is something that can be stolen according to one of the active bounties.
/// If so, starts the stealing process.
/datum/component/spy_uplink/proc/try_steal(atom/stealing, mob/living/spy)
	for(var/datum/spy_bounty/bounty as anything in handler.get_all_bounties())
		if(bounty.claimed)
			continue
		if(bounty.is_stealable(stealing))
			INVOKE_ASYNC(src, PROC_REF(start_stealing), stealing, spy, bounty)
			return TRUE

	return FALSE

/// Attempts to steal the passed atom in accordance with the passed bounty.
/// If successful, proceeds to complete the bounty.
/datum/component/spy_uplink/proc/start_stealing(atom/stealing, mob/living/spy, datum/spy_bounty/bounty)
	stealing.visible_message(
		span_warning("[spy] starts scanning [stealing] with a strange device..."),
		span_notice("You start scanning [stealing], preparing it for extraction."),
	)
	if(!do_after(spy, bounty.theft_time, stealing))
		return
	if(bounty.claimed)
		to_chat(spy, span_warning("The bounty for [stealing] has been claimed by another spy!"))
		return

	bounty.clean_up_stolen_item(stealing, spy)
	bounty.claimed = TRUE

	var/obj/item/reward = new bounty.reward_item.item(spy.loc)
	spy.put_in_hands(reward)
	to_chat(spy, span_notice("Bounty complete! You have been rewarded with \a [reward].\
		[reward.loc == spy ? "" : " <i>Find it at your feet.</i>"]"))

	playsound(parent, 'sound/machines/wewewew.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/datum/component/spy_uplink/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpyUplink")
		ui.open()

/datum/component/spy_uplink/ui_data(mob/user)
	var/list/data = list()

	data["bounties"] = list()
	for(var/datum/spy_bounty/bounty as anything in handler.get_all_bounties())
		UNTYPED_LIST_ADD(data["bounties"], bounty.to_ui_data())
	data["time_left"] = timeleft(handler.refresh_timer)

	return data
