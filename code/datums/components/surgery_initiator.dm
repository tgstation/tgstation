/// Allows an item to  be used to initiate surgeries.
/datum/component/surgery_initiator
	/// The currently selected target that the user is proposing a surgery on
	var/datum/weakref/surgery_target_ref

	/// The currently selected body zone
	// MOTHBLOCKS TODO: Update when the user changes their own body zone
	var/selected_zone

/datum/component/surgery_initiator/Initialize()
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/surgery_initiator/Destroy(force, silent)
	surgery_target_ref = null

	return ..()

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/initiate_surgery_moment)

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)

/// Does the surgery initiation.
/datum/component/surgery_initiator/proc/initiate_surgery_moment(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	INVOKE_ASYNC(src, .proc/do_initiate_surgery_moment, source, target, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/surgery_initiator/proc/do_initiate_surgery_moment(datum/source, mob/living/target, mob/user)
	selected_zone = user.zone_selected

	var/datum/surgery/current_surgery

	for(var/i_one in target.surgeries)
		var/datum/surgery/surgeryloop = i_one
		if(surgeryloop.location == selected_zone)
			current_surgery = surgeryloop

	if (current_surgery?.step_in_progress)
		attempt_cancel_surgery(current_surgery, target, user)
		return

	var/list/available_surgeries = get_available_surgeries(user, target)

	if(!length(available_surgeries))
		if (target.body_position == LYING_DOWN)
			target.balloon_alert(user, "no surgeries available!")
		else
			target.balloon_alert(user, "make them lie down!")

		return

	surgery_target_ref = WEAKREF(target)
	ui_interact(user)

/datum/component/surgery_initiator/proc/get_available_surgeries(mob/user, mob/living/target)
	var/list/available_surgeries = list()

	var/mob/living/carbon/carbon_target
	var/obj/item/bodypart/affecting
	if (iscarbon(target))
		carbon_target = target
		affecting = carbon_target.get_bodypart(check_zone(selected_zone))

	for(var/datum/surgery/surgery as anything in GLOB.surgeries_list)
		if(!surgery.possible_locs.Find(selected_zone))
			continue
		if(affecting)
			if(!surgery.requires_bodypart)
				continue
			if(surgery.requires_bodypart_type && affecting.status != surgery.requires_bodypart_type)
				continue
			if(surgery.requires_real_bodypart && affecting.is_pseudopart)
				continue
		else if(carbon_target && surgery.requires_bodypart) //mob with no limb in surgery zone when we need a limb
			continue
		if(surgery.lying_required && target.body_position != LYING_DOWN)
			continue
		if(!surgery.can_start(user, target))
			continue
		for(var/path in surgery.target_mobtypes)
			if(istype(target, path))
				available_surgeries[surgery.name] = surgery
				break

	return available_surgeries

/// Does the surgery de-initiation.
/datum/component/surgery_initiator/proc/attempt_cancel_surgery(datum/surgery/the_surgery, mob/living/patient, mob/user)
	var/selected_zone = user.zone_selected

	if(the_surgery.status == 1)
		patient.surgeries -= the_surgery
		REMOVE_TRAIT(patient, TRAIT_ALLOWED_HONORBOUND_ATTACK, type)
		user.visible_message(
			span_notice("[user] removes [parent] from [patient]'s [parse_zone(selected_zone)]."),
			span_notice("You remove [parent] from [patient]'s [parse_zone(selected_zone)]."),
		)

		qdel(the_surgery)
		return

	if(!the_surgery.can_cancel)
		return

	var/required_tool_type = TOOL_CAUTERY
	var/obj/item/close_tool = user.get_inactive_held_item()
	var/is_robotic = the_surgery.requires_bodypart_type == BODYPART_ROBOTIC

	if(is_robotic)
		required_tool_type = TOOL_SCREWDRIVER

	if(iscyborg(user))
		close_tool = locate(/obj/item/cautery) in user.held_items
		if(!close_tool)
			patient.balloon_alert(user, "need a cautery in an inactive slot to stop the surgery!")
			return
	else if(!close_tool || close_tool.tool_behaviour != required_tool_type)
		patient.balloon_alert(user, "need a [is_robotic ? "screwdriver": "cautery"] in your inactive hand to stop the surgery!")
		return

	if(the_surgery.operated_bodypart)
		the_surgery.operated_bodypart.generic_bleedstacks -= 5

	patient.surgeries -= the_surgery
	REMOVE_TRAIT(patient, TRAIT_ALLOWED_HONORBOUND_ATTACK, ELEMENT_TRAIT(type))
	user.visible_message(span_notice("[user] closes [patient]'s [parse_zone(selected_zone)] with [close_tool] and removes [parent]."), \
		span_notice("You close [patient]'s [parse_zone(selected_zone)] with [close_tool] and remove [parent]."))
	qdel(the_surgery)

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
			if (isnull(slot2body_zone(zone)))
				return TRUE

			selected_zone = zone
			return TRUE
		if ("start_surgery")
			for (var/datum/surgery/surgery as anything in get_available_surgeries(user, surgery_target))
				if (surgery.name == params["surgery_name"])
					try_choose_surgery(user, surgery_target, surgery)
					return TRUE

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
		"selected_zone" = selected_zone,
		"target_name" = surgery_target?.name,
		"surgeries" = surgeries,
	)

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
	// MOTHBLOCKS TODO: Throw a balloon alert here, USE A SIGNAL!!!
	for (var/datum/surgery/surgery in target.surgeries)
		if (surgery.location == selected_zone)
			return FALSE

	return TRUE

/datum/component/surgery_initiator/proc/try_choose_surgery(mob/user, mob/living/target, datum/surgery/surgery)
	if (!can_start_surgery(user, target))
		// This could have a more detailed message, but the UI closes when this is true anyway, so
		// if it ever comes up, it'll be because of lag.
		target.balloon_alert(user, "can't start the surgery!")
		return

	var/obj/item/bodypart/affecting_limb

	if (iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		affecting_limb = carbon_target.get_bodypart(check_zone(selected_zone))

	if (surgery.requires_bodypart == isnull(affecting_limb))
		if (surgery.requires_bodypart)
			target.balloon_alert(user, "patient has no [parse_zone(selected_zone)]!")
		else
			target.balloon_alert(user, "patient has \a [parse_zone(selected_zone)]!")

		return

	if (!isnull(affecting_limb) && surgery.requires_bodypart_type && affecting_limb.status != surgery.requires_bodypart_type)
		target.balloon_alert(user, "not the right type of limb!")
		return

	if (surgery.lying_required && target.body_position != LYING_DOWN)
		target.balloon_alert(user, "patient is not lying down!")
		return

	if (!surgery.can_start(user, target))
		target.balloon_alert(user, "can't start the surgery!")
		return

	if (surgery_needs_exposure(surgery, target))
		target.balloon_alert(user, "expose [target.p_their()] [parse_zone(selected_zone)]!")
		return

	var/datum/surgery/procedure = new surgery.type(target, selected_zone, affecting_limb)
	ADD_TRAIT(target, TRAIT_ALLOWED_HONORBOUND_ATTACK, type)

	target.balloon_alert(user, "starting \"[lowertext(procedure.name)]\"")

	user.visible_message(
		span_notice("[user] drapes [parent] over [target]'s [parse_zone(selected_zone)] to prepare for surgery."),
		span_notice("You drape [parent] over [target]'s [parse_zone(selected_zone)] to prepare for \an [procedure.name]."),
	)

	log_combat(user, target, "operated on", null, "(OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")

	ui_close()

/datum/component/surgery_initiator/proc/surgery_needs_exposure(datum/surgery/surgery, mob/living/target)
	return !surgery.ignore_clothes && get_location_accessible(target, selected_zone)
