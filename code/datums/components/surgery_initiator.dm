/**
  *
  * Allows parent (obj) to initiate surgeries.
  *
  */
/datum/component/surgery_initiator
	dupe_mode = COMPONENT_DUPE_UNIQUE
	//allows for post-selection manipulation of parent
	var/datum/callback/after_select_cb

/datum/component/surgery_initiator/Initialize(_after_select_cb)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	after_select_cb = _after_select_cb

/datum/component/surgery_initiator/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/initiate_surgery_moment)

/datum/component/surgery_initiator/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK)


	/**
	  *
	  * Does the surgery initiation.
	  *
	  */
/datum/component/surgery_initiator/proc/initiate_surgery_moment(datum/source, atom/target, mob/user)
	if(!isliving(target))
		return
	var/mob/living/M = target
	var/mob/living/carbon/C
	var/obj/item/bodypart/affecting
	var/selected_zone = user.zone_selected
	. = COMPONENT_ITEM_NO_ATTACK

	if(iscarbon(M))
		C = M
		affecting = C.get_bodypart(check_zone(selected_zone))

	var/datum/surgery/current_surgery

	for(var/datum/surgery/S in M.surgeries)
		if(S.location == selected_zone)
			current_surgery = S

	if(!current_surgery)
		var/list/all_surgeries = GLOB.surgeries_list.Copy()
		var/list/available_surgeries = list()

		for(var/datum/surgery/S in all_surgeries)
			if(!S.possible_locs.Find(selected_zone))
				continue
			if(affecting)
				if(!S.requires_bodypart)
					continue
				if(S.requires_bodypart_type && affecting.status != S.requires_bodypart_type)
					continue
				if(S.requires_real_bodypart && affecting.is_pseudopart)
					continue
			else if(C && S.requires_bodypart) //mob with no limb in surgery zone when we need a limb
				continue
			if(S.lying_required && (M.mobility_flags & MOBILITY_STAND))
				continue
			if(!S.can_start(user, M))
				continue
			for(var/path in S.target_mobtypes)
				if(istype(M, path))
					available_surgeries[S.name] = S
					break

		if(!available_surgeries.len)
			return

		var/P = input("Begin which procedure?", "Surgery", null, null) as null|anything in sortList(available_surgeries)
		if(P && user?.Adjacent(M) && (parent in user))
			var/datum/surgery/S = available_surgeries[P]

			for(var/datum/surgery/other in M.surgeries)
				if(other.location == selected_zone)
					return //during the input() another surgery was started at the same location.

			//we check that the surgery is still doable after the input() wait.
			if(C)
				affecting = C.get_bodypart(check_zone(selected_zone))
			if(affecting)
				if(!S.requires_bodypart)
					return
				if(S.requires_bodypart_type && affecting.status != S.requires_bodypart_type)
					return
			else if(C && S.requires_bodypart)
				return
			if(S.lying_required && (M.mobility_flags & MOBILITY_STAND))
				return
			if(!S.can_start(user, M))
				return

			if(S.ignore_clothes || get_location_accessible(M, selected_zone))
				var/datum/surgery/procedure = new S.type(M, selected_zone, affecting)
				user.visible_message("<span class='notice'>[user] drapes [parent] over [M]'s [parse_zone(selected_zone)] to prepare for surgery.</span>", \
					"<span class='notice'>You drape [parent] over [M]'s [parse_zone(selected_zone)] to prepare for \an [procedure.name].</span>")

				log_combat(user, M, "operated on", null, "(OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")
				after_select_cb?.Invoke()
			else
				to_chat(user, "<span class='warning'>You need to expose [M]'s [parse_zone(selected_zone)] first!</span>")

	else if(!current_surgery.step_in_progress)
		attempt_cancel_surgery(current_surgery, parent, M, user)


/datum/component/surgery_initiator/proc/attempt_cancel_surgery(datum/surgery/S, obj/item/I, mob/living/M, mob/user)
	var/selected_zone = user.zone_selected

	if(S.status == 1)
		M.surgeries -= S
		user.visible_message("<span class='notice'>[user] removes [I] from [M]'s [parse_zone(selected_zone)].</span>", \
			"<span class='notice'>You remove [I] from [M]'s [parse_zone(selected_zone)].</span>")
		qdel(S)
		return

	if(S.can_cancel)
		var/required_tool_type = TOOL_CAUTERY
		var/obj/item/close_tool = user.get_inactive_held_item()
		var/is_robotic = S.requires_bodypart_type == BODYPART_ROBOTIC

		if(is_robotic)
			required_tool_type = TOOL_SCREWDRIVER

		if(iscyborg(user))
			close_tool = locate(/obj/item/cautery) in user.held_items
			if(!close_tool)
				to_chat(user, "<span class='warning'>You need to equip a cautery in an inactive slot to stop [M]'s surgery!</span>")
				return
		else if(!close_tool || close_tool.tool_behaviour != required_tool_type)
			to_chat(user, "<span class='warning'>You need to hold a [is_robotic ? "screwdriver" : "cautery"] in your inactive hand to stop [M]'s surgery!</span>")
			return

		if(S.operated_bodypart)
			S.operated_bodypart.generic_bleedstacks -= 5

		M.surgeries -= S
		user.visible_message("<span class='notice'>[user] closes [M]'s [parse_zone(selected_zone)] with [close_tool] and removes [I].</span>", \
			"<span class='notice'>You close [M]'s [parse_zone(selected_zone)] with [close_tool] and remove [I].</span>")
		qdel(S)
