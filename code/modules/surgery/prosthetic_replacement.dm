/datum/surgery/prosthetic_replacement
	name = "Prosthetic replacement"
	surgery_flags = NONE
	requires_bodypart_type = NONE
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/add_prosthetic,
	)

/datum/surgery/prosthetic_replacement/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(!carbon_target.get_bodypart(user.zone_selected) && carbon_target.should_have_limb(user.zone_selected)) //can only start if limb is missing
		return TRUE
	return FALSE



/datum/surgery_step/add_prosthetic
	name = "add prosthetic"
	implements = list(
		/obj/item/bodypart = 100,
		/obj/item/borg/apparatus/organ_storage = 100,
		/obj/item = 100,
	)
	time = 3.2 SECONDS
	/// Toxin damage incurred by the target if an organic limb is attached
	VAR_FINAL/organ_rejection_dam = 0
	/// List of items that are always allowed to be an arm replacement, even if they fail another requirement.
	var/list/always_accepted_prosthetics = list(
		/obj/item/chainsaw, // the OG, too large otherwise
		/obj/item/melee/synthetic_arm_blade, // also too large otherwise
		/obj/item/food/pizzaslice, // he's turning her into a papa john's
	)

/datum/surgery_step/add_prosthetic/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/borg/apparatus/organ_storage))
		if(!length(tool.contents))
			return FALSE
		tool = tool.contents[1]
	if(tool.item_flags & (ABSTRACT|HAND_ITEM|DROPDEL))
		return FALSE
	if(isbodypart(tool))
		return TRUE // auto pass - "intended" use case
	if(is_type_in_list(tool, always_accepted_prosthetics))
		return TRUE // auto pass - soulful prosthetics
	if(tool.w_class < WEIGHT_CLASS_NORMAL || tool.w_class > WEIGHT_CLASS_BULKY)
		return FALSE // too large or too small items don't make sense as a limb replacement
	if(HAS_TRAIT(tool, TRAIT_WIELDED))
		return FALSE // prevents exploits from weird edge cases - either unwield or get out
	return TRUE

/datum/surgery_step/add_prosthetic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(istype(tool, /obj/item/borg/apparatus/organ_storage))
		if(!tool.contents.len)
			to_chat(user, span_warning("There is nothing inside [tool]!"))
			return SURGERY_STEP_FAIL
		var/obj/item/organ_storage_contents = tool.contents[1]
		if(!isbodypart(organ_storage_contents))
			to_chat(user, span_warning("[organ_storage_contents] cannot be attached!"))
			return SURGERY_STEP_FAIL
		tool = organ_storage_contents
	if(isbodypart(tool))
		var/obj/item/bodypart/bodypart_to_attach = tool
		if(IS_ORGANIC_LIMB(bodypart_to_attach))
			organ_rejection_dam = 10
			if(ishuman(target))
				var/mob/living/carbon/human/human_target = target
				var/obj/item/bodypart/chest/target_chest = human_target.get_bodypart(BODY_ZONE_CHEST)
				if((!(bodypart_to_attach.bodyshape & target_chest.acceptable_bodyshape)) && (!(bodypart_to_attach.bodytype & target_chest.acceptable_bodytype)))
					to_chat(user, span_warning("[bodypart_to_attach] doesn't match the patient's morphology."))
					return SURGERY_STEP_FAIL
				if(bodypart_to_attach.check_for_frankenstein(target))
					organ_rejection_dam = 30

		if(!bodypart_to_attach.can_attach_limb(target))
			target.balloon_alert(user, "that doesn't go on the [target.parse_zone_with_bodypart(target_zone)]!")
			return SURGERY_STEP_FAIL

		if(target_zone == bodypart_to_attach.body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
			display_results(
				user,
				target,
				span_notice("You begin to replace [target]'s [target.parse_zone_with_bodypart(target_zone)] with [tool]..."),
				span_notice("[user] begins to replace [target]'s [target.parse_zone_with_bodypart(target_zone)] with [tool]."),
				span_notice("[user] begins to replace [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
			)
		else
			to_chat(user, span_warning("[tool] isn't the right type for [target.parse_zone_with_bodypart(target_zone)]."))
			return SURGERY_STEP_FAIL
	else if(target_zone == BODY_ZONE_L_ARM || target_zone == BODY_ZONE_R_ARM)
		display_results(
			user,
			target,
			span_notice("You begin to attach [tool] onto [target]..."),
			span_notice("[user] begins to attach [tool] onto [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
			span_notice("[user] begins to attach something onto [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		)
	else
		to_chat(user, span_warning("[tool] must be attached to an arm socket."))
		return SURGERY_STEP_FAIL

/datum/surgery_step/add_prosthetic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(istype(tool, /obj/item/borg/apparatus/organ_storage))
		tool.icon_state = initial(tool.icon_state)
		tool.desc = initial(tool.desc)
		tool.cut_overlays()
		tool = tool.contents[1]
	else if(!user.temporarilyRemoveItemFromInventory(tool))
		to_chat(user, span_warning("You can't seem to part with [tool]!"))
		return FALSE

	. = ..()
	if(isbodypart(tool))
		handle_bodypart(user, target, tool, target_zone)
		return
	handle_arbitrary_prosthetic(user, target, tool, target_zone)
	surgery.steps += /datum/surgery_step/secure_arbitrary_prosthetic

/datum/surgery_step/add_prosthetic/proc/handle_bodypart(mob/user, mob/living/carbon/target, obj/item/bodypart/bodypart_to_attach, target_zone)
	bodypart_to_attach.try_attach_limb(target)
	if(bodypart_to_attach.check_for_frankenstein(target))
		bodypart_to_attach.bodypart_flags |= BODYPART_IMPLANTED
	if(organ_rejection_dam)
		target.adjustToxLoss(organ_rejection_dam)
	display_results(
		user, target,
		span_notice("You succeed in replacing [target]'s [target.parse_zone_with_bodypart(target_zone)]."),
		span_notice("[user] successfully replaces [target]'s [target.parse_zone_with_bodypart(target_zone)] with [bodypart_to_attach]!"),
		span_notice("[user] successfully replaces [target]'s [target.parse_zone_with_bodypart(target_zone)]!"),
	)
	display_pain(target, "You feel synthetic sensation wash from your [target.parse_zone_with_bodypart(target_zone)], which you can feel again!", TRUE)

/datum/surgery_step/add_prosthetic/proc/handle_arbitrary_prosthetic(mob/user, mob/living/carbon/target, obj/item/thing_to_attach, target_zone)
	target.make_item_prosthetic(thing_to_attach, target_zone, 80)
	display_results(
		user, target,
		span_notice("You attach [thing_to_attach]."),
		span_notice("[user] finishes attaching [thing_to_attach]!"),
		span_notice("[user] finishes the attachment procedure!"),
	)
	display_pain(target, "You feel a strange sensation as [thing_to_attach] takes place of an arm!", TRUE)

/datum/surgery_step/secure_arbitrary_prosthetic
	name = "secure prosthetic (suture/tape)"
	implements = list(
		/obj/item/stack/medical/suture = 100,
		/obj/item/stack/sticky_tape/surgical = 80,
		/obj/item/stack/sticky_tape = 50,
	)
	time = 4.8 SECONDS

/datum/surgery_step/secure_arbitrary_prosthetic/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/limb = target.get_bodypart(target_zone)
	var/obj/item/stack/thing = tool
	display_results(
		user, target,
		span_notice("You begin to [thing.singular_name] [limb] to [target]'s body."),
		span_notice("[user] begins to [thing.singular_name] [limb] to [target]'s body."),
		span_notice("[user] begins to [thing.singular_name] something to [target]'s body."),
	)
	display_pain(target, "[user] begins to [thing.singular_name] [limb] to your body!", TRUE)

/datum/surgery_step/secure_arbitrary_prosthetic/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/obj/limb = target.get_bodypart(target_zone)
	var/obj/item/stack/thing = tool
	thing.use(1)
	limb.AddComponent(/datum/component/item_as_prosthetic_limb, null, 0) // updates drop probability to zero
	display_results(
		user, target,
		span_notice("You [thing.singular_name] [limb] to [target]'s body."),
		span_notice("[user] [thing.singular_name] [limb] to [target]'s body!"),
		span_notice("[user] [thing.singular_name][plural_s(thing.singular_name)] something to [target]'s body!"),
	)
	display_pain(target, "[user] [thing.singular_name][plural_s(thing.singular_name)] [limb] to your body!", TRUE)
	return TRUE
