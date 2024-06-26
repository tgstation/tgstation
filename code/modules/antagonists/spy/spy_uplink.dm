/**
 * ## Spy uplink
 *
 * Applied to items similar to traitor uplinks.
 *
 * Used for spies to complete bounties.
 */
/datum/component/spy_uplink
	/// Weakref to the spy antag datum which owns this uplink
	var/datum/weakref/spy_ref
	/// The handler which manages all bounties across all spies.
	var/static/datum/spy_bounty_handler/handler

/datum/component/spy_uplink/Initialize(datum/antagonist/spy/spy)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	spy_ref = WEAKREF(spy)

	if(isnull(handler))
		handler = new()

/datum/component/spy_uplink/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_pre_attack_secondary))
	RegisterSignal(parent, COMSIG_TABLET_CHECK_DETONATE, PROC_REF(block_pda_bombs))

/datum/component/spy_uplink/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ITEM_PRE_ATTACK_SECONDARY,
		COMSIG_TABLET_CHECK_DETONATE,
	))

/// Checks that the passed mob is the owner of this uplink.
/datum/component/spy_uplink/proc/is_our_spy(mob/whoever)
	var/datum/antagonist/spy/spy_datum = spy_ref?.resolve()
	return spy_datum?.owner.current == whoever

/datum/component/spy_uplink/proc/on_examine(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!is_our_spy(user))
		return
	examine_list += span_notice("You recognize this as your <i>spy uplink</i>.")
	examine_list += span_notice("- [EXAMINE_HINT("Use it in hand")] to view your bounty list.")
	examine_list += span_notice("- [EXAMINE_HINT("Right click")] with it on a bounty target to claim it.")

/datum/component/spy_uplink/proc/block_pda_bombs(obj/item/source)
	SIGNAL_HANDLER

	return COMPONENT_TABLET_NO_DETONATE

/datum/component/spy_uplink/proc/on_attack_self(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if(IS_SPY(user))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/datum, ui_interact), user)
	return NONE

/datum/component/spy_uplink/proc/on_pre_attack_secondary(obj/item/source, atom/target, mob/living/user, params)
	SIGNAL_HANDLER

	if(!ismovable(target))
		return NONE
	if(!IS_SPY(user))
		return NONE
	if(!try_steal(target, user))
		return NONE
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Checks if the passed atom is something that can be stolen according to one of the active bounties.
/// If so, starts the stealing process.
/datum/component/spy_uplink/proc/try_steal(atom/movable/stealing, mob/living/spy)
	for(var/datum/spy_bounty/bounty as anything in handler.get_all_bounties())
		if(!bounty.can_claim(spy))
			continue
		if(!bounty.is_stealable(stealing))
			continue
		if(bounty.claimed)
			stealing.balloon_alert(spy, "bounty already claimed!")
			return TRUE
		if(DOING_INTERACTION(spy, REF(src)))
			spy.balloon_alert(spy, "already scanning!") // Only shown if they're trying to scan two valid targets
			return TRUE
		SEND_SIGNAL(stealing, COMSIG_MOVABLE_SPY_STEALING, spy, bounty)
		INVOKE_ASYNC(src, PROC_REF(start_stealing), stealing, spy, bounty)
		return TRUE

	return FALSE

/// Wraps the stealing process in a scanning effect.
/datum/component/spy_uplink/proc/start_stealing(atom/movable/stealing, mob/living/spy, datum/spy_bounty/bounty)
	if(!isturf(stealing.loc) && stealing.loc != spy)
		to_chat(spy, span_warning("Your uplinks blinks red: [stealing] cannot be extracted from there."))
		return FALSE

	log_combat(spy, stealing, "started stealing", parent, "(spy bounty)")
	playsound(stealing, 'sound/items/pshoom.ogg', 33, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.33, ignore_walls = FALSE)

	var/obj/effect/scan_effect/active_scan_effect = new(stealing.loc)
	active_scan_effect.appearance = stealing.appearance
	active_scan_effect.dir = stealing.dir
	active_scan_effect.makeHologram()
	SET_PLANE_EXPLICIT(active_scan_effect, stealing.plane, stealing)
	active_scan_effect.layer = stealing.layer + 0.1

	var/obj/effect/scan_effect/cone/active_scan_cone
	if(isturf(stealing.loc) && isturf(spy.loc)) // Cone doesn't make sense if its being held or something
		active_scan_cone = new(spy.loc)
		var/angle = round(get_angle(spy, stealing), 10)
		if(angle > 180 && angle < 360)
			active_scan_cone.pixel_x -= 16
		else if(angle < 180 && angle > 0)
			active_scan_cone.pixel_x += 16
		if(angle > 90 && angle < 270)
			active_scan_cone.pixel_y -= 16
		else if(angle < 90 || angle > 270)
			active_scan_cone.pixel_y += 16
		active_scan_cone.transform = active_scan_cone.transform.Turn(angle)
		active_scan_cone.alpha = 0
		animate(active_scan_cone, time = 0.5 SECONDS, alpha = initial(active_scan_cone.alpha))

	. = steal_process(stealing, spy, bounty)
	qdel(active_scan_effect)
	qdel(active_scan_cone)
	return .

/// Attempts to steal the passed atom in accordance with the passed bounty.
/// If successful, proceeds to complete the bounty.
/datum/component/spy_uplink/proc/steal_process(atom/movable/stealing, mob/living/spy, datum/spy_bounty/bounty)
	spy.visible_message(
		span_warning("[spy] starts scanning [stealing] with a strange device..."),
		span_notice("You start scanning [stealing], preparing it for extraction."),
	)

	if(!do_after(spy, bounty.theft_time, stealing, interaction_key = REF(src), hidden = TRUE))
		return FALSE
	if(bounty.claimed)
		to_chat(spy, span_warning("Your uplinks blinks red: The bounty for [stealing] has been claimed by another spy!"))
		return FALSE
	if(spy.is_holding(stealing) && !spy.dropItemToGround(stealing))
		to_chat(spy, span_warning("Your uplinks blinks red: [stealing] seems stuck to your hand!"))
		return FALSE

	var/bounty_key = bounty.get_dupe_protection_key(stealing)
	handler.all_claimed_bounty_types[bounty_key] += 1
	handler.claimed_bounties_from_last_pool[bounty_key] = TRUE

	bounty.clean_up_stolen_item(stealing, spy, handler)
	bounty.claimed = TRUE

	var/atom/movable/reward = bounty.reward_item.spawn_item_for_generic_use(spy)
	if(isitem(reward))
		spy.put_in_hands(reward)

	to_chat(spy, span_notice("Bounty complete! You have been rewarded with \a [reward].\
		[reward.loc == spy ? "" : " <i>Find it at your feet.</i>"]"))

	playsound(parent, 'sound/machines/wewewew.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	log_combat(spy, stealing, "stole", parent, "(spy bounty)")
	log_spy("[key_name(spy)] completed the bounty [bounty.name] of difficulty [bounty.difficulty] by stealing [stealing] for \a [reward].")
	SSblackbox.record_feedback("nested tally", "spy_bounty", 1, list("[stealing.type]", "[bounty.type]", "[bounty.difficulty]", "[bounty.reward_item.type]"))

	var/datum/antagonist/spy/spy_datum = spy_ref?.resolve()
	if(!isnull(spy_datum))
		// "When" TGUI roundend is finished, a list of all bounties complete and their rewards should be put in a collapsible,
		// otherwise it's just too much information to display cleanly. (That's why we're only displaying number and rewards)
		spy_datum.bounties_claimed += 1
		spy_datum.all_loot += bounty.reward_item.name

	return TRUE

/datum/component/spy_uplink/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpyUplink")
		ui.open()

/datum/component/spy_uplink/ui_data(mob/user)
	var/list/data = list()

	data["bounties"] = list()
	for(var/datum/spy_bounty/bounty as anything in handler.get_all_bounties())
		UNTYPED_LIST_ADD(data["bounties"], bounty.to_ui_data(user))
	data["time_left"] = timeleft(handler.refresh_timer)

	return data

/datum/component/spy_uplink/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user) && user.client?.holder)
		return UI_UPDATE
	return ..()

/obj/effect/scan_effect
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/scan_effect/cone
	name = "holoray"
	icon = 'icons/effects/effects.dmi'
	icon_state = "scan_beam"
	color = "#3ba0ff"
	alpha = 200
