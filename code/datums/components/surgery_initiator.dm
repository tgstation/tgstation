/// Allows an item to  be used to initiate surgeries.
/datum/component/surgery_initiator
	/// The currently selected target that the user is proposing a surgery on
	var/datum/weakref/surgery_target_ref

	/// The last user, as a weakref
	var/datum/weakref/last_user_ref

/datum/component/surgery_initiator/Initialize()
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/surgery_tool = parent
	surgery_tool.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS

/datum/component/surgery_initiator/Destroy(force)
	last_user_ref = null
	surgery_target_ref = null

	return ..()

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(initiate_surgery_moment))
	RegisterSignal(parent, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(add_item_context))

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET)
	unregister_signals()

/datum/component/surgery_initiator/proc/unregister_signals()
	var/mob/living/last_user = last_user_ref?.resolve()
	if (!isnull(last_user_ref))
		UnregisterSignal(last_user, COMSIG_MOB_SELECTED_ZONE_SET)

	var/mob/living/surgery_target = surgery_target_ref?.resolve()
	if (!isnull(surgery_target_ref))
		UnregisterSignal(surgery_target, COMSIG_MOB_SURGERY_STARTED)

/// Does the surgery initiation.
/datum/component/surgery_initiator/proc/initiate_surgery_moment(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	INVOKE_ASYNC(src, PROC_REF(do_initiate_surgery_moment), target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/surgery_initiator/proc/do_initiate_surgery_moment(mob/living/target, mob/user)
	var/datum/surgery/current_surgery

	for(var/i_one in target.surgeries)
		var/datum/surgery/surgeryloop = i_one
		if(surgeryloop.location == user.zone_selected)
			current_surgery = surgeryloop
			break

	if (!isnull(current_surgery) && !current_surgery.step_in_progress)
		attempt_cancel_surgery(current_surgery, target, user)
		return

	var/list/available_surgeries = get_available_surgeries(user, target)

	if(!length(available_surgeries))
		if (target.body_position == LYING_DOWN || !(target.mobility_flags & MOBILITY_LIEDOWN))
			target.balloon_alert(user, "no surgeries available!")
		else
			target.balloon_alert(user, "make them lie down!")

		return

	unregister_signals()

	last_user_ref = WEAKREF(user)
	surgery_target_ref = WEAKREF(target)

	RegisterSignal(user, COMSIG_MOB_SELECTED_ZONE_SET, PROC_REF(on_set_selected_zone))
	RegisterSignal(target, COMSIG_MOB_SURGERY_STARTED, PROC_REF(on_mob_surgery_started))

	ui_interact(user)

/datum/component/surgery_initiator/proc/get_available_surgeries(mob/user, mob/living/target)
	var/list/available_surgeries = list()

	var/obj/item/bodypart/affecting = target.get_bodypart(check_zone(user.zone_selected))

	for(var/datum/surgery/surgery as anything in GLOB.surgeries_list)
		if(!surgery.possible_locs.Find(user.zone_selected))
			continue
		if(!is_type_in_list(target, surgery.target_mobtypes))
			continue
		if(user == target && !(surgery.surgery_flags & SURGERY_SELF_OPERABLE))
			continue

		if(isnull(affecting))
			if(surgery.surgery_flags & SURGERY_REQUIRE_LIMB)
				continue
		else
			if(surgery.requires_bodypart_type && !(affecting.bodytype & surgery.requires_bodypart_type))
				continue
			if(surgery.targetable_wound && !affecting.get_wound_type(surgery.targetable_wound))
				continue
			if((surgery.surgery_flags & SURGERY_REQUIRES_REAL_LIMB) && (affecting.bodypart_flags & BODYPART_PSEUDOPART))
				continue

		if(IS_IN_INVALID_SURGICAL_POSITION(target, surgery))
			continue
		if(!surgery.can_start(user, target))
			continue

		available_surgeries += surgery

	return available_surgeries

/// Does the surgery de-initiation.
/datum/component/surgery_initiator/proc/attempt_cancel_surgery(datum/surgery/the_surgery, mob/living/patient, mob/user)
	var/selected_zone = user.zone_selected

	if(the_surgery.status == 1)
		patient.surgeries -= the_surgery
		REMOVE_TRAIT(patient, TRAIT_ALLOWED_HONORBOUND_ATTACK, type)
		user.visible_message(
			span_notice("[user] removes [parent] from [patient]'s [patient.parse_zone_with_bodypart(selected_zone)]."),
			span_notice("You remove [parent] from [patient]'s [patient.parse_zone_with_bodypart(selected_zone)]."),
		)

		patient.balloon_alert(user, "stopped work on [patient.parse_zone_with_bodypart(selected_zone)]")

		qdel(the_surgery)
		return

	var/required_tool_type = TOOL_CAUTERY
	var/obj/item/close_tool = user.get_inactive_held_item()
	var/is_robotic = the_surgery.requires_bodypart_type == BODYTYPE_ROBOTIC
	if(is_robotic)
		required_tool_type = TOOL_SCREWDRIVER

	if(iscyborg(user))
		var/has_cautery = FALSE
		for(var/obj/item/borg/cyborg_omnitool/toolarm in user.held_items)
			if(toolarm.selected && istype(toolarm.selected, /obj/item/cautery))
				has_cautery = TRUE
		if(!has_cautery)
			patient.balloon_alert(user, "need a cautery in an inactive slot to stop the surgery!")
			return
	else if(!close_tool || close_tool.tool_behaviour != required_tool_type)
		patient.balloon_alert(user, "need a [is_robotic ? "screwdriver": "cautery"] in your inactive hand to stop the surgery!")
		return

	if(the_surgery.operated_bodypart)
		the_surgery.operated_bodypart.adjustBleedStacks(-5)

	patient.surgeries -= the_surgery
	REMOVE_TRAIT(patient, TRAIT_ALLOWED_HONORBOUND_ATTACK, ELEMENT_TRAIT(type))

	user.visible_message(
		span_notice("[user] closes [patient]'s [patient.parse_zone_with_bodypart(selected_zone)] with [close_tool] and removes [parent]."),
		span_notice("You close [patient]'s [patient.parse_zone_with_bodypart(selected_zone)] with [close_tool] and remove [parent]."),
	)

	patient.balloon_alert(user, "closed up [patient.parse_zone_with_bodypart(selected_zone)]")

	qdel(the_surgery)

/datum/component/surgery_initiator/proc/on_mob_surgery_started(mob/source, datum/surgery/surgery, surgery_location)
	SIGNAL_HANDLER

	var/mob/living/last_user = last_user_ref.resolve()

	if (surgery_location != last_user.zone_selected)
		return

	if (!isnull(last_user))
		source.balloon_alert(last_user, "someone else started a surgery!")

	ui_close()

/datum/component/surgery_initiator/proc/on_set_selected_zone(mob/source, new_zone)
	ui_interact(source)

/datum/component/surgery_initiator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SurgeryInitiator")
		ui.open()

/datum/component/surgery_initiator/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return .

	var/mob/user = usr
	var/mob/living/surgery_target = surgery_target_ref.resolve()

	if (isnull(surgery_target))
		return TRUE

	switch (action)
		if ("change_zone")
			var/zone = params["new_zone"]
			if (!(zone in list(
				BODY_ZONE_HEAD,
				BODY_ZONE_CHEST,
				BODY_ZONE_L_ARM,
				BODY_ZONE_R_ARM,
				BODY_ZONE_L_LEG,
				BODY_ZONE_R_LEG,
				BODY_ZONE_PRECISE_EYES,
				BODY_ZONE_PRECISE_MOUTH,
				BODY_ZONE_PRECISE_GROIN,
			)))
				return TRUE

			var/atom/movable/screen/zone_sel/zone_selector = user.hud_used?.zone_select
			zone_selector?.set_selected_zone(zone, user, should_log = FALSE)

			return TRUE
		if ("start_surgery")
			for (var/datum/surgery/surgery as anything in get_available_surgeries(user, surgery_target))
				if (surgery.name == params["surgery_name"])
					try_choose_surgery(user, surgery_target, surgery)
					return TRUE

/datum/component/surgery_initiator/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/body_zones),
	)

/datum/component/surgery_initiator/ui_data(mob/user)
	var/mob/living/surgery_target = surgery_target_ref.resolve()

	var/list/surgeries = list()
	if (!isnull(surgery_target))
		for (var/datum/surgery/surgery as anything in get_available_surgeries(user, surgery_target))
			var/list/surgery_info = list(
				"name" = surgery.name,
			)

			if (surgery_needs_exposure(surgery, surgery_target))
				surgery_info["blocked"] = TRUE

			surgeries += list(surgery_info)

	return list(
		"selected_zone" = user.zone_selected,
		"target_name" = surgery_target?.name,
		"surgeries" = surgeries,
	)

/datum/component/surgery_initiator/ui_close(mob/user)
	unregister_signals()
	surgery_target_ref = null

	return ..()

/datum/component/surgery_initiator/ui_status(mob/user, datum/ui_state/state)
	var/obj/item/item_parent = parent
	if (user != item_parent.loc)
		return UI_CLOSE

	var/mob/living/surgery_target = surgery_target_ref?.resolve()
	if (isnull(surgery_target))
		return UI_CLOSE

	if (!can_start_surgery(user, surgery_target))
		return UI_CLOSE

	return ..()

/datum/component/surgery_initiator/proc/can_start_surgery(mob/user, mob/living/target)
	if (!user.Adjacent(target))
		return FALSE

	// The item was moved somewhere else
	if (!(parent in user))
		return FALSE

	// While we were choosing, another surgery was started at the same location
	for (var/datum/surgery/surgery in target.surgeries)
		if (surgery.location == user.zone_selected)
			return FALSE

	return TRUE

/datum/component/surgery_initiator/proc/try_choose_surgery(mob/user, mob/living/target, datum/surgery/surgery)
	if (!can_start_surgery(user, target))
		// This could have a more detailed message, but the UI closes when this is true anyway, so
		// if it ever comes up, it'll be because of lag.
		target.balloon_alert(user, "can't start the surgery!")
		return

	var/selected_zone = user.zone_selected
	var/obj/item/bodypart/affecting_limb = target.get_bodypart(check_zone(selected_zone))

	if ((surgery.surgery_flags & SURGERY_REQUIRE_LIMB) && isnull(affecting_limb))
		target.balloon_alert(user, "patient has no [parse_zone(selected_zone)]!")
		return

	if (!isnull(affecting_limb))
		if(surgery.requires_bodypart_type && !(affecting_limb.bodytype & surgery.requires_bodypart_type))
			target.balloon_alert(user, "not the right type of limb!")
			return
		if(surgery.targetable_wound && !affecting_limb.get_wound_type(surgery.targetable_wound))
			target.balloon_alert(user, "no wound to operate on!")
			return

	if (IS_IN_INVALID_SURGICAL_POSITION(target, surgery))
		target.balloon_alert(user, "patient is not lying down!")
		return

	if (!surgery.can_start(user, target))
		target.balloon_alert(user, "can't start the surgery!")
		return

	if (surgery_needs_exposure(surgery, target))
		target.balloon_alert(user, "expose [target.p_their()] [target.parse_zone_with_bodypart(selected_zone)]!")
		return

	ui_close()

	var/datum/surgery/procedure = new surgery.type(target, selected_zone, affecting_limb)
	ADD_TRAIT(target, TRAIT_ALLOWED_HONORBOUND_ATTACK, type)

	target.balloon_alert(user, "starting \"[LOWER_TEXT(procedure.name)]\"")

	user.visible_message(
		span_notice("[user] drapes [parent] over [target]'s [target.parse_zone_with_bodypart(selected_zone)] to prepare for surgery."),
		span_notice("You drape [parent] over [target]'s [target.parse_zone_with_bodypart(selected_zone)] to prepare for \an [procedure.name]."),
	)

	log_combat(user, target, "operated on", null, "(OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")

/datum/component/surgery_initiator/proc/surgery_needs_exposure(datum/surgery/surgery, mob/living/target)
	var/mob/living/user = last_user_ref?.resolve()
	if (isnull(user))
		return FALSE
	if(surgery.surgery_flags & SURGERY_IGNORE_CLOTHES)
		return FALSE

	return !get_location_accessible(target, user.zone_selected)

/**
 * Adds context sensitivy directly to the surgery initator file for screentips
 * Arguments:
 * * source - the surgery drapes, cloak, or bedsheet calling surgery initator
 * * context - Preparing Surgery, the component has a lot of ballon alerts to deal with most contexts
 * * target - the living target mob you are doing surgery on
 * * user - refers to user who will see the screentip when the drapes are on a living target
 */
/datum/component/surgery_initiator/proc/add_item_context(obj/item/source, list/context, atom/target, mob/living/user,)
	SIGNAL_HANDLER

	if(!isliving(target))
		return NONE

	context[SCREENTIP_CONTEXT_LMB] = "Prepare Surgery"
	return CONTEXTUAL_SCREENTIP_SET
