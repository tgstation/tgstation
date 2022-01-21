/datum/surgery/organ_manipulation
	name = "Organ manipulation"
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_real_bodypart = TRUE
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs, //there should be bone fixing
		/datum/surgery_step/close)

/datum/surgery/organ_manipulation/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close)

/datum/surgery/organ_manipulation/alien
	name = "Alien organ manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	target_mobtypes = list(/mob/living/carbon/alien/humanoid)
	steps = list(
		/datum/surgery_step/saw,
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close)

/datum/surgery/organ_manipulation/mechanic
	name = "Prosthesis organ manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	requires_bodypart_type = BODYPART_ROBOTIC
	lying_required = FALSE
	self_operable = TRUE
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close)

/datum/surgery/organ_manipulation/mechanic/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/mechanic_close)

/datum/surgery_step/manipulate_organs
	time = 64
	name = "manipulate organs"
	repeatable = TRUE
	implements = list(
		/obj/item/organ = 100,
		/obj/item/borg/apparatus/organ_storage = 100)
	var/implements_extract = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 55, /obj/item/kitchen/fork = 35)
	var/current_type
	var/obj/item/organ/target_organ

/datum/surgery_step/manipulate_organs/New()
	..()
	implements = implements + implements_extract

/datum/surgery_step/manipulate_organs/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target_organ = null
	if(istype(tool, /obj/item/borg/apparatus/organ_storage))
		if(!length(tool.contents))
			to_chat(user, span_warning("There is nothing inside [tool]!"))
			return -1
		target_organ = tool.contents[1]
		if(!isorgan(target_organ))
			if (target_zone == BODY_ZONE_PRECISE_EYES)
				target_zone = check_zone(target_zone)
			to_chat(user, span_warning("You cannot put [target_organ] into [target]'s [parse_zone(target_zone)]!"))
			return -1
		tool = target_organ
	if(isorgan(tool))
		current_type = "insert"
		target_organ = tool
		if(target_zone != target_organ.zone || target.getorganslot(target_organ.slot))
			to_chat(user, span_warning("There is no room for [target_organ] in [target]'s [parse_zone(target_zone)]!"))
			return -1
		var/obj/item/organ/meatslab = tool
		if(!meatslab.useable)
			to_chat(user, span_warning("[target_organ] seems to have been chewed on, you can't use this!"))
			return -1
		if (target_zone == BODY_ZONE_PRECISE_EYES)
			target_zone = check_zone(target_zone)
		display_results(user, target, span_notice("You begin to insert [tool] into [target]'s [parse_zone(target_zone)]..."),
			span_notice("[user] begins to insert [tool] into [target]'s [parse_zone(target_zone)]."),
			span_notice("[user] begins to insert something into [target]'s [parse_zone(target_zone)]."),
			playsound(get_turf(target), 'sound/surgery/organ2.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1))
		display_pain(target, "You can feel your something being placed in your [parse_zone(target_zone)]!")


	else if(implement_type in implements_extract)
		current_type = "extract"
		var/list/organs = target.getorganszone(target_zone)
		if (target_zone == BODY_ZONE_PRECISE_EYES)
			target_zone = check_zone(target_zone)
		if(!length(organs))
			to_chat(user, span_warning("There are no removable organs in [target]'s [parse_zone(target_zone)]!"))
			return -1
		else
			for(var/obj/item/organ/organ in organs)
				organ.on_find(user)
				organs -= organ
				organs[organ.name] = organ

			var/chosen_organ = tgui_input_list(user, "Remove which organ?", "Surgery", sort_list(organs))
			if(isnull(chosen_organ))
				return -1
			target_organ = chosen_organ
			if(user && target && user.Adjacent(target) && user.get_active_held_item() == tool)
				target_organ = organs[target_organ]
				if(!target_organ)
					return -1
				if(target_organ.organ_flags & ORGAN_UNREMOVABLE)
					to_chat(user, span_warning("[target_organ] is too well connected to take out!"))
					return -1
				display_results(user, target, span_notice("You begin to extract [target_organ] from [target]'s [parse_zone(target_zone)]..."),
					span_notice("[user] begins to extract [target_organ] from [target]'s [parse_zone(target_zone)]."),
					span_notice("[user] begins to extract something from [target]'s [parse_zone(target_zone)]."),
					playsound(get_turf(target), 'sound/surgery/hemostat1.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1))
				display_pain(target, "You can feel your [target_organ] being removed from your [parse_zone(target_zone)]!")
			else
				return -1


/datum/surgery_step/manipulate_organs/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	if (target_zone == BODY_ZONE_PRECISE_EYES)
		target_zone = check_zone(target_zone)
	if(current_type == "insert")
		if(istype(tool, /obj/item/borg/apparatus/organ_storage))
			target_organ = tool.contents[1]
			tool.icon_state = initial(tool.icon_state)
			tool.desc = initial(tool.desc)
			tool.cut_overlays()
			tool = target_organ
		else
			target_organ = tool
		user.temporarilyRemoveItemFromInventory(target_organ, TRUE)
		target_organ.Insert(target)
		display_results(user, target, span_notice("You insert [tool] into [target]'s [parse_zone(target_zone)]."),
			span_notice("[user] inserts [tool] into [target]'s [parse_zone(target_zone)]!"),
			span_notice("[user] inserts something into [target]'s [parse_zone(target_zone)]!"),
			playsound(get_turf(target), 'sound/surgery/organ1.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1))
		display_pain(target, "Your [parse_zone(target_zone)] throbs with pain as your new [tool] comes to life!")

	else if(current_type == "extract")
		if(target_organ && target_organ.owner == target)
			display_results(user, target, span_notice("You successfully extract [target_organ] from [target]'s [parse_zone(target_zone)]."),
				span_notice("[user] successfully extracts [target_organ] from [target]'s [parse_zone(target_zone)]!"),
				span_notice("[user] successfully extracts something from [target]'s [parse_zone(target_zone)]!"),
				playsound(get_turf(target), 'sound/surgery/organ2.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1))
			display_pain(target, "Your [parse_zone(target_zone)] throbs with pain, you can't feel your [target_organ] anymore!")
			log_combat(user, target, "surgically removed [target_organ.name] from", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
			target_organ.Remove(target)
			target_organ.forceMove(get_turf(target))
		else
			display_results(user, target, span_warning("You can't extract anything from [target]'s [parse_zone(target_zone)]!"),
				span_notice("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!"),
				span_notice("[user] can't seem to extract anything from [target]'s [parse_zone(target_zone)]!"))
	return FALSE
