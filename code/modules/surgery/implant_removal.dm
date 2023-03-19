/datum/surgery/implant_removal
	name = "Implant extraction/destruction"
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/search_for_implants,
		/datum/surgery_step/destroy_extract_implant,
		/datum/surgery_step/close,
	)
	var/list/discovered_implants = list()

/datum/surgery_step/search_for_implants
	name = "search for implants (hand/t-ray)"
	accept_hand = TRUE
	implements = list(
		/obj/item/t_scanner = 100,
	)
	time = 12.8 SECONDS
	repeatable = TRUE
	var/detection_prob = list(
		"" = 10, // empty string is no tool, so hand.
		/obj/item/t_scanner = 20,
	)

/datum/surgery_step/search_for_implants/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start searching [target]'s [parse_zone(target_zone)] for any implants."),
		span_notice("[user] starts searching [target]'s [parse_zone(target_zone)] for any implants."),
		span_notice("[user] looks for something in [target]'s [parse_zone(target_zone)]."),
	)
	display_pain(target, "You feel a serious pain in your [parse_zone(target_zone)]!")

/datum/surgery_step/search_for_implants/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/implant_removal/surgery, default_display_results = FALSE)
	var/obj/item/discovery = null

	var/discovery_chance = detection_prob[""]
	for(var/key in detection_prob)
		if(ispath(key) && istype(tool, key))
			discovery_chance = detection_prob[key]

	for(var/obj/item/object in target.implants)
		if(object in surgery.discovered_implants)
			continue
		if(prob(discovery_chance))
			discovery = object
			break

	if(discovery)
		display_results(
			user,
			target,
			span_notice("You discover \a [discovery.name] in [target]'s [target_zone]."),
			span_notice("[user] discovers \a [discovery] in [target]'s [target_zone]!"),
			span_notice("[user] discovers something in [target]'s [target_zone]!"),
		)
		surgery.discovered_implants += discovery
	else
		display_results(
			user,
			target,
			span_notice("You don't find anything in [target]'s [target_zone]."),
			span_notice("[user] doesn't find anything in [target]'s [target_zone]!"),
			span_notice("[user] doesn't find anything in [target]'s [target_zone]!"),
		)

	return ..()

//extract implant
/datum/surgery_step/destroy_extract_implant
	name = "destroy/extract implant (drill/hemostat)"
	repeatable = TRUE

	// Destruction tools
	implements = list(
		TOOL_DRILL = 100,
		/obj/item/screwdriver/power = 80,
		/obj/item/pickaxe/drill = 60,
		TOOL_SCREWDRIVER = 25,
	)
	var/implements_extract = list(
		TOOL_HEMOSTAT = 100,
		TOOL_CROWBAR = 55,
		/obj/item/kitchen/fork = 35,
		/obj/item/kitchen/spoon = 20,
	)
	time = 6.4 SECONDS
	success_sound = 'sound/surgery/hemostat1.ogg'
	var/obj/item/implant/target_implant
	var/obj/item/implantcase/target_case

/datum/surgery_step/destroy_extract_implant/New()
	..()
	implements = implements + implements_extract

/datum/surgery_step/destroy_extract_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/implant_removal/surgery)
	if(!length(surgery.discovered_implants))
		to_chat(user, span_warning("No implants in [target]'s [parse_zone(target_zone)] have been discovered, or they've all been destroyed/extracted!"))
		return SURGERY_STEP_FAIL

	for(var/obj/item/discovered in surgery.discovered_implants)
		if(!(discovered in target.implants))
			surgery.discovered_implants -= discovered

	if(implement_type in implements_extract)
		var/obj/item/implantcase/case
		for(var/obj/item/implantcase/implant_case in user.held_items)
			if(!implant_case.imp)
				case = implant_case
				break
		if(!case)
			for(var/obj/item/implantcase/implant_case in range(1, user))
				if(!implant_case.imp)
					case = implant_case
					break
		if(!case)
			to_chat(user, span_warning("You have no implant case in-hand or nearby to store extracted implants from [target]. Did you mean to destroy the implant?"))
			return SURGERY_STEP_FAIL

		var/chosen_implant = tgui_input_list(user, "Extract which implant?", "Surgery", sort_list(surgery.discovered_implants))
		if(isnull(chosen_implant) || !(chosen_implant in target.implants))
			return SURGERY_STEP_FAIL
		if(user && target && user.Adjacent(target) && user.get_active_held_item() == tool && case && user.Adjacent(case) && !case.imp)
			target_implant = chosen_implant
			target_case = case
			display_results(
				user,
				target,
				span_notice("You begin to extract [chosen_implant] from [target]'s [parse_zone(target_zone)]..."),
				span_notice("[user] begins to extract [chosen_implant] from [target]'s [parse_zone(target_zone)]."),
				span_notice("[user] begins to extract something from [target]'s [parse_zone(target_zone)]."),
			)
			// I'm sorry, but you cannot tell what type of implants is being removed from sensation alone.
			display_pain(target, "You can feel an implant being removed from your [parse_zone(target_zone)]!")
		else
			return SURGERY_STEP_FAIL

	else
		// We don't care about salvage, we just destroying the implant!
		var/chosen_implant = tgui_input_list(user, "Destroy which implant?", "Surgery", sort_list(surgery.discovered_implants))
		if(isnull(chosen_implant))
			return SURGERY_STEP_FAIL
		if(user && target && user.Adjacent(target) && user.get_active_held_item() == tool)
			target_implant = chosen_implant
			display_results(
				user,
				target,
				span_notice("You begin to destroy [chosen_implant] in [target]'s [parse_zone(target_zone)]..."),
				span_notice("[user] begins to destroy [chosen_implant] in [target]'s [parse_zone(target_zone)]."),
				span_notice("[user] begins to destroy something in [target]'s [parse_zone(target_zone)]."),
			)
			// I'm sorry, but you cannot tell what type of implants is being removed from sensation alone.
			display_pain(target, "You can feel an implant being destroyed in your [parse_zone(target_zone)]!")
		else
			return SURGERY_STEP_FAIL

/datum/surgery_step/destroy_extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/implant_removal/surgery, default_display_results = FALSE)
	if(!target_implant || !(target_implant in target.implants))
		to_chat(user, span_warning("You can't find what you were looking for in [target]'s [target_zone]!"))
	else if(implement_type in implements_extract)
		if(!target_case || !user.Adjacent(target_case) || target_case.imp)
			to_chat(user, span_warning("You don't have the implant case nearby!"))
		else
			display_results(
				user,
				target,
				span_notice("You successfully remove [target_implant] from [target]'s [target_zone] and put it into [target_case]."),
				span_notice("[user] successfully removes [target_implant] from [target]'s [target_zone] and puts it into [target_case]!"),
				span_notice("[user] successfully removes something from [target]'s [target_zone] and puts it into [target_case]!"),
			)
			display_pain(target, "You can feel something pulled out of you!")

			surgery.discovered_implants -= target_implant
			target_implant.removed(target)
			target_case.imp = target_implant
			target_implant.forceMove(target_case)
			target_case.update_appearance()
	else
		display_results(
			user,
			target,
			span_notice("You successfully destroy [target_implant] in [target]'s [parse_zone(target_zone)]."),
			span_notice("[user] successfully destroys [target_implant] in [target]'s [parse_zone(target_zone)]."),
			span_notice("[user] successfully destroy something in [target]'s [parse_zone(target_zone)]."),
		)
		display_pain(target, "You feel something snap inside your [parse_zone(target_zone)]!")

		// And off it goes to the abyss.
		surgery.discovered_implants -= target_implant
		qdel(target_implant)

	return ..()

/datum/surgery/implant_removal/mechanic
	name = "implant removal"
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/search_for_implants,
		/datum/surgery_step/destroy_extract_implant,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close)
