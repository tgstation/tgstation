/// Item can be applied to mobs to prepare them for surgery (allowing people to operate on them)
/datum/element/surgery_aid
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// The name of the aid, for examine and messages, in plural form
	var/aid_name

/datum/element/surgery_aid/Attach(datum/target, aid_name = "things")
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.aid_name = aid_name
	RegisterSignal(target, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(on_context))
	RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_item_interaction))

	var/obj/item/realtarget = target
	realtarget.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS

/datum/element/surgery_aid/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_INTERACTING_WITH_ATOM, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET))

/datum/element/surgery_aid/proc/on_context(obj/item/source, list/context, atom/target, mob/living/user)
	SIGNAL_HANDLER

	if(!isliving(target))
		return NONE

	var/mob/living/target_mob = target
	if(!target_mob.has_limbs)
		context[SCREENTIP_CONTEXT_LMB] = HAS_TRAIT(source, TRAIT_READY_TO_OPERATE) ? "Remove [aid_name]" : "Prepare for surgery"
		return CONTEXTUAL_SCREENTIP_SET

	var/obj/item/bodypart/precise_part = target_mob.get_bodypart(deprecise_zone(user.zone_selected)) || target_mob.get_bodypart(BODY_ZONE_CHEST)
	context[SCREENTIP_CONTEXT_LMB] = HAS_TRAIT(precise_part, TRAIT_READY_TO_OPERATE) ? "Remove [aid_name]" : "Prepare [precise_part.plaintext_zone] for surgery"
	return CONTEXTUAL_SCREENTIP_SET

/datum/element/surgery_aid/proc/on_item_interaction(datum/source, mob/living/user, atom/target, ...)
	SIGNAL_HANDLER

	if(!isliving(target))
		return NONE

	var/mob/living/target_mob = target
	var/obj/item/bodypart/precise_part = target_mob.get_bodypart(deprecise_zone(user.zone_selected)) || target_mob.get_bodypart(BODY_ZONE_CHEST)
	surgery_prep(target_mob, user, precise_part?.body_zone || BODY_ZONE_CHEST, aid_name)
	return ITEM_INTERACT_SUCCESS

/datum/element/surgery_aid/proc/surgery_prep(mob/living/target_mob, mob/living/surgeon, body_zone)
	var/datum/status_effect/surgery_prepped/prep = target_mob.has_status_effect(__IMPLIED_TYPE__)
	if(isnull(prep) || !(body_zone in prep.zones))
		target_mob.apply_status_effect(/datum/status_effect/surgery_prepped, body_zone, aid_name)
		target_mob.balloon_alert(surgeon, "[parse_zone(body_zone)] surgery prepared")
		return
	prep.untrack_surgery(body_zone)
	target_mob.balloon_alert(surgeon, "surgery cleared")

/// Tracks which body zones have been prepped for surgery
/datum/status_effect/surgery_prepped
	id = "surgery_prepped"
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	tick_interval = 2 SECONDS

	/// Lazylist of zones being prepped, if empty we should not exist
	var/list/zones
	/// Lazylist of the names of all surgical aids used, for examine
	var/list/surgical_aids
	/// Counts movements while standing up - removes the effect if we move too much
	var/movement_counter = 0

/datum/status_effect/surgery_prepped/on_creation(mob/living/new_owner, target_zone, aid_name = "things")
	. = ..()
	track_surgery(target_zone)
	LAZYOR(surgical_aids, aid_name)
	ADD_TRAIT(owner, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id)) // needs to happen after tracking starts

/datum/status_effect/surgery_prepped/refresh(mob/living/new_owner, target_zone, aid_name = "things")
	track_surgery(target_zone)
	LAZYOR(surgical_aids, aid_name)

/datum/status_effect/surgery_prepped/on_apply()
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_attach_limb))
	RegisterSignal(owner, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(on_detach_limb))
	return TRUE

/datum/status_effect/surgery_prepped/on_remove()
	for(var/zone in zones)
		untrack_surgery(zone)
	REMOVE_TRAIT(owner, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_POST_ATTACH_LIMB, COMSIG_CARBON_POST_REMOVE_LIMB))

/datum/status_effect/surgery_prepped/get_examine_text()
	var/list/zones_readable = list()
	// give the body zones a consistent order, the same order as GLOB.all_body_zones
	for(var/zone in GLOB.all_body_zones & zones)
		zones_readable += parse_zone(zone)

	var/list/aid_readable = list()
	for(var/aid in surgical_aids)
		aid_readable += copytext_char(aid, -1) == "s" ? aid : "\a [aid]"

	// "They have surgial drapes and a bedsheet adorning their chest, arms, and legs."
	return "[owner.p_They()] [owner.p_have()] [english_list(aid_readable)] adorning [owner.p_their()] [english_list(zones_readable)]."

/datum/status_effect/surgery_prepped/proc/on_move(datum/source, ...)
	SIGNAL_HANDLER

	if(owner.body_position == STANDING_UP)
		movement_counter += 1
	if(movement_counter < 4)
		return
	// "The surgical drapes and bedsheets adorning John fall off!"
	owner.visible_message(span_warning("The [english_list(surgical_aids)] adorning [owner] fall off!"))
	qdel(src)

/datum/status_effect/surgery_prepped/proc/on_attach_limb(datum/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	if(limb.body_zone in zones)
		ADD_TRAIT(limb, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/surgery_prepped/proc/on_detach_limb(datum/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	REMOVE_TRAIT(limb, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/surgery_prepped/tick(seconds_between_ticks)
	if(owner.body_position == LYING_DOWN && movement_counter > 0)
		movement_counter -= 1

/datum/status_effect/surgery_prepped/proc/track_surgery(body_zone)
	LAZYADD(zones, body_zone)
	if(iscarbon(owner))
		var/obj/item/bodypart/precise_part = owner.get_bodypart(body_zone)
		if(precise_part)
			ADD_TRAIT(precise_part, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id))
	else if(body_zone != BODY_ZONE_CHEST)
		stack_trace("Attempting to track surgery on a non-carbon mob with a non-chest body zone! This should not happen.")

/datum/status_effect/surgery_prepped/proc/untrack_surgery(body_zone)
	LAZYREMOVE(zones, body_zone)
	if(iscarbon(owner))
		var/obj/item/bodypart/precise_part = owner.get_bodypart(body_zone)
		if(precise_part)
			REMOVE_TRAIT(precise_part, TRAIT_READY_TO_OPERATE, TRAIT_STATUS_EFFECT(id))
	if(!LAZYLEN(zones) && !QDELETED(src))
		qdel(src) // no more zones to track, remove the status effect
