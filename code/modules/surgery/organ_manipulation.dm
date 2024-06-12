/datum/surgery/organ_manipulation
	name = "Organ manipulation"
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB | SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs/internal,
		/datum/surgery_step/close,
	)

/datum/surgery/organ_manipulation/soft
	possible_locs = list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/manipulate_organs/internal,
		/datum/surgery_step/close,
	)

/datum/surgery/organ_manipulation/external
	name = "Feature manipulation"
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/manipulate_organs/external,
		/datum/surgery_step/close,
	)

/datum/surgery/organ_manipulation/alien
	name = "Alien organ manipulation"
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	target_mobtypes = list(/mob/living/carbon/alien/adult)
	steps = list(
		/datum/surgery_step/saw,
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/manipulate_organs/internal,
		/datum/surgery_step/close,
	)

/datum/surgery/organ_manipulation/mechanic
	name = "Prosthesis organ manipulation"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	surgery_flags = SURGERY_SELF_OPERABLE | SURGERY_REQUIRE_LIMB
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs/internal/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/organ_manipulation/mechanic/next_step(mob/living/user, modifiers)
	if(location != user.zone_selected)
		return FALSE
	if(user.combat_mode)
		return FALSE
	if(step_in_progress)
		return TRUE

	var/try_to_fail = FALSE
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		try_to_fail = TRUE

	var/datum/surgery_step/step = get_surgery_step()
	if(isnull(step))
		return FALSE
	var/obj/item/tool = user.get_active_held_item()
	if(step.try_op(user, target, user.zone_selected, tool, src, try_to_fail))
		return TRUE
	if(tool && tool.tool_behaviour) //Mechanic organ manipulation isn't done with just surgery tools
		to_chat(user, span_warning("This step requires a different tool!"))
		return TRUE

	return FALSE

/datum/surgery/organ_manipulation/mechanic/soft
	possible_locs = list(
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_PRECISE_EYES,
		BODY_ZONE_PRECISE_MOUTH,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
	)
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs/internal/mechanic,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/organ_manipulation/mechanic/external
	name = "Prosthetic feature manipulation"
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)
	steps = list( //not shorter than soft prosthetic manip because I dunno what steps could be cut here
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/prepare_electronics,
		/datum/surgery_step/manipulate_organs/external/mechanic,
		/datum/surgery_step/mechanic_close,
	)

///Organ manipulation base class. Do not use, it wont work. Use it's subtypes
/datum/surgery_step/manipulate_organs
	name = "manipulate organs"
	repeatable = TRUE
	implements = list(
		/obj/item/organ = 100,
		/obj/item/borg/apparatus/organ_storage = 100)
	preop_sound = 'sound/surgery/organ2.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

	var/implements_extract = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 55, /obj/item/kitchen/fork = 35)
	var/current_type
	var/obj/item/organ/target_organ

/datum/surgery_step/manipulate_organs/New()
	..()
	implements = implements + implements_extract

/datum/surgery_step/manipulate_organs/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target_organ = null
	if(istype(tool, /obj/item/borg/apparatus/organ_storage))
		preop_sound = initial(preop_sound)
		success_sound = initial(success_sound)
		if(!length(tool.contents))
			to_chat(user, span_warning("There is nothing inside [tool]!"))
			return SURGERY_STEP_FAIL
		target_organ = tool.contents[1]
		if(!isorgan(target_organ))
			if (target_zone == BODY_ZONE_PRECISE_EYES)
				target_zone = check_zone(target_zone)
			to_chat(user, span_warning("You cannot put [target_organ] into [target]'s [target.parse_zone_with_bodypart(target_zone)]!"))
			return SURGERY_STEP_FAIL
		tool = target_organ
	if(isorgan(tool))
		current_type = "insert"
		preop_sound = 'sound/surgery/hemostat1.ogg'
		success_sound = 'sound/surgery/organ2.ogg'
		target_organ = tool
		if(target_zone != target_organ.zone || target.get_organ_slot(target_organ.slot))
			to_chat(user, span_warning("There is no room for [target_organ] in [target]'s [target.parse_zone_with_bodypart(target_zone)]!"))
			return SURGERY_STEP_FAIL
		var/obj/item/organ/meatslab = tool
		if(!meatslab.useable)
			to_chat(user, span_warning("[target_organ] seems to have been chewed on, you can't use this!"))
			return SURGERY_STEP_FAIL

		if(!can_use_organ(user, meatslab))
			return SURGERY_STEP_FAIL

		if (target_zone == BODY_ZONE_PRECISE_EYES)
			target_zone = check_zone(target_zone)
		display_results(
			user,
			target,
			span_notice("You begin to insert [tool] into [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
			span_notice("[user] begins to insert [tool] into [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
			span_notice("[user] begins to insert something into [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		)
		display_pain(target, "You can feel something being placed in your [target.parse_zone_with_bodypart(target_zone)]!")


	else if(implement_type in implements_extract)
		current_type = "extract"
		var/list/unfiltered_organs = target.get_organs_for_zone(target_zone)
		var/list/organs = list()
		for(var/organ in unfiltered_organs)
			if(can_use_organ(user, organ))
				organs.Add(organ)
		if (target_zone == BODY_ZONE_PRECISE_EYES)
			target_zone = check_zone(target_zone)
		if(!length(organs))
			to_chat(user, span_warning("There are no removable organs in [target]'s [target.parse_zone_with_bodypart(target_zone)]!"))
			return SURGERY_STEP_FAIL
		else
			for(var/obj/item/organ/organ in organs)
				organ.on_find(user)
				organs -= organ
				organs[organ.name] = organ

			var/chosen_organ = tgui_input_list(user, "Remove which organ?", "Surgery", sort_list(organs))
			if(isnull(chosen_organ))
				return SURGERY_STEP_FAIL
			target_organ = chosen_organ
			if(user && target && user.Adjacent(target) && user.get_active_held_item() == tool)
				target_organ = organs[target_organ]
				if(!target_organ)
					return SURGERY_STEP_FAIL
				if(target_organ.organ_flags & ORGAN_UNREMOVABLE)
					to_chat(user, span_warning("[target_organ] is too well connected to take out!"))
					return SURGERY_STEP_FAIL
				display_results(
					user,
					target,
					span_notice("You begin to extract [target_organ] from [target]'s [target.parse_zone_with_bodypart(target_zone)]..."),
					span_notice("[user] begins to extract [target_organ] from [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
					span_notice("[user] begins to extract something from [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
				)
				display_pain(target, "You can feel your [target_organ.name] being removed from your [target.parse_zone_with_bodypart(target_zone)]!")
			else
				return SURGERY_STEP_FAIL

/datum/surgery_step/manipulate_organs/success(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if (target_zone == BODY_ZONE_PRECISE_EYES)
		target_zone = check_zone(target_zone)
	if(current_type == "insert")
		var/obj/item/apparatus
		if(istype(tool, /obj/item/borg/apparatus/organ_storage))
			apparatus = tool
			tool = tool.contents[1]
		target_organ = tool
		user.temporarilyRemoveItemFromInventory(target_organ, TRUE)
		if(target_organ.Insert(target))
			if(apparatus)
				apparatus.icon_state = initial(apparatus.icon_state)
				apparatus.desc = initial(apparatus.desc)
				apparatus.cut_overlays()
			display_results(
				user,
				target,
				span_notice("You insert [tool] into [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
				span_notice("[user] inserts [tool] into [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
				span_notice("[user] inserts something into [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
			)
			display_pain(target, "Your [target.parse_zone_with_bodypart(target_zone)] throbs with pain as your new [tool.name] comes to life!")
			target_organ.on_surgical_insertion(user, target, target_zone, tool)
		else
			target_organ.forceMove(target.loc)

	else if(current_type == "extract")
		if(target_organ && target_organ.owner == target)
			display_results(
				user,
				target,
				span_notice("You successfully extract [target_organ] from [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
				span_notice("[user] successfully extracts [target_organ] from [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
				span_notice("[user] successfully extracts something from [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
			)
			display_pain(target, "Your [target.parse_zone_with_bodypart(target_zone)] throbs with pain, you can't feel your [target_organ.name] anymore!")
			log_combat(user, target, "surgically removed [target_organ.name] from", addition="COMBAT MODE: [uppertext(user.combat_mode)]")
			target_organ.Remove(target)
			target_organ.forceMove(get_turf(target))
			target_organ.on_surgical_removal(user, target, target_zone, tool)
		else
			display_results(
				user,
				target,
				span_warning("You can't extract anything from [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
				span_notice("[user] can't seem to extract anything from [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
				span_notice("[user] can't seem to extract anything from [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
			)
	if(HAS_MIND_TRAIT(user, TRAIT_MORBID) && ishuman(user))
		var/mob/living/carbon/human/morbid_weirdo = user
		morbid_weirdo.add_mood_event("morbid_abominable_surgery_success", /datum/mood_event/morbid_abominable_surgery_success)
	return ..()

///You can never use this MUHAHAHAHAHAHAH (because its the byond version of abstract)
/datum/surgery_step/manipulate_organs/proc/can_use_organ(mob/user, obj/item/organ/organ)
	return FALSE

///Surgery step for internal organs, like hearts and brains
/datum/surgery_step/manipulate_organs/internal
	time = 6.4 SECONDS
	name = "manipulate organs (hemostat/organ)"

///only operate on internal organs
/datum/surgery_step/manipulate_organs/internal/can_use_organ(mob/user, obj/item/organ/organ)
	return isinternalorgan(organ)

///prosthetic surgery gives full effectiveness to crowbars (and hemostats)
/datum/surgery_step/manipulate_organs/internal/mechanic
	implements_extract = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 100, /obj/item/kitchen/fork = 35)
	name = "manipulate prosthetic organs (hemostat or crowbar/organ)"

///Surgery step for external organs/features, like tails, frills, wings etc
/datum/surgery_step/manipulate_organs/external
	time = 3.2 SECONDS
	name = "manipulate features (hemostat/feature)"

///Only operate on external organs
/datum/surgery_step/manipulate_organs/external/can_use_organ(mob/user, obj/item/organ/organ)
	return isexternalorgan(organ)

///prosthetic surgery gives full effectiveness to crowbars (and hemostats)
/datum/surgery_step/manipulate_organs/external/mechanic
	implements_extract = list(TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 100, /obj/item/kitchen/fork = 35)
	name = "manipulate prosthetic features (hemostat or crowbar/feature)"
