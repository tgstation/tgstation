/datum/surgery_operation/limb/prosthetic_replacement
	name = "prosthetic replacement"
	desc = "Replace a missing limb with a prosthetic or arbitrary item."
	implements = list(
		/obj/item/bodypart = 1,
		/obj/item = 1,
	)
	time = 3.2 SECONDS
	operation_flags = OPERATION_STANDING_ALLOWED
	/// List of items that are always allowed to be an arm replacement, even if they fail another requirement.
	var/list/always_accepted_prosthetics = list(
		/obj/item/chainsaw, // the OG, too large otherwise
		/obj/item/melee/synthetic_arm_blade, // also too large otherwise
		/obj/item/food/pizzaslice, // he's turning her into a papa john's
	)

/datum/surgery_operation/prosthetic_replacement/get_operation_target(mob/living/surgeon, mob/living/patient, obj/item/tool = IMPLEMENT_HAND)
	// We always operate on the chest even if we're targeting left leg or w/e
	return patient.get_bodypart(BODY_ZONE_CHEST)

/datum/operation/prosthetic_replacement/is_available(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool)
	if(!HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED))
		return FALSE
	// While we are operating on chest, we need to make sure the actual missing limb is missing
	if(limb.owner.get_bodypart(deprecise_zone(surgeon.zone_selected)))
		return FALSE
	// check bodyshape compatibility for real bodyparts
	if(isbodypart(tool))
		var/obj/item/bodypart/new_limb = tool
		if(!new_limb.can_attach_limb(limb.owner))
			return FALSE
	// arbitrary prosthetics can only be used on arms for now
	else if(limb.body_zone != BODY_ZONE_L_ARM && limb.body_zone != BODY_ZONE_R_ARM)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/prosthetic_replacement/tool_check(obj/item/bodypart/tool)
	if(HAS_TRAIT(tool, TRAIT_NODROP) || (tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM)))
		return FALSE
	if(isbodypart(tool))
		return TRUE // auto pass - "intended" use case
	if(is_type_in_list(tool, always_accepted_prosthetics))
		return TRUE // auto pass - soulful prosthetics
	if(tool.w_class < WEIGHT_CLASS_NORMAL || tool.w_class > WEIGHT_CLASS_BULKY)
		return FALSE // too large or too small items don't make sense as a limb replacement
	if(HAS_TRAIT(tool, TRAIT_WIELDED))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/prosthetic_replacement/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/target_zone = deprecise_zone(surgeon.zone_selected)
	// Save this for later
	operation_args["target_zone"] = target_zone

	// purposefully doesn't use plaintext zone for more context on what is being replaced with what
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to replace [limb.owner]'s missing [parse_zone(target_zone)] with [tool]..."),
		span_notice("[surgeon] begins to replace [limb.owner]'s missing [parse_zone(target_zone)] with [tool]."),
		span_notice("[surgeon] begins to replace [limb.owner]'s missing [parse_zone(target_zone)]."),
	)
	display_pain(limb.owner, "You feel an uncomfortable sensation where your [parse_zone(target_zone)] should be!")

	operation_args["tox_damage"] = 10
	if(isbodypart(tool))
		var/obj/item/bodypart/new_limb = tool
		if(IS_ROBOTIC_LIMB(new_limb))
			operation_args["tox_damage"] = 0
		else if(new_limb.check_for_frankenstein(limb.owner))
			operation_args["tox_damage"] = 30

/datum/surgery_operation/limb/prosthetic_replacement/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(!surgeon.temporarilyRemoveItemFromInventory(tool))
		return // should never happen
	if(operation_args["tox_damage"] > 0)
		limb.owner.apply_damage(operation_args["tox_damage"], TOX)
	if(isbodypart(tool))
		handle_bodypart(limb.owner, surgeon, tool)
		return
	handle_arbitrary_prosthetic(limb.owner, surgeon, tool, operation_args["target_zone"])

/datum/surgery_operation/limb/prosthetic_replacement/proc/handle_bodypart(mob/living/carbon/patient, mob/living/surgeon, obj/item/bodypart/bodypart_to_attach)
	bodypart_to_attach.try_attach_limb(patient)
	if(bodypart_to_attach.check_for_frankenstein(patient))
		bodypart_to_attach.bodypart_flags |= BODYPART_IMPLANTED
	display_results(
		surgeon, patient,
		span_notice("You succeed in replacing [patient]'s [bodypart_to_attach.plaintext_zone]."),
		span_notice("[surgeon] successfully replaces [patient]'s [bodypart_to_attach.plaintext_zone] with [bodypart_to_attach]!"),
		span_notice("[surgeon] successfully replaces [patient]'s [bodypart_to_attach.plaintext_zone]!"),
	)
	display_pain(patient, "You feel synthetic sensation wash from your [bodypart_to_attach.plaintext_zone], which you can feel again!", TRUE)

/datum/surgery_operation/limb/prosthetic_replacement/proc/handle_arbitrary_prosthetic(mob/living/carbon/patient, mob/living/surgeon, obj/item/thing_to_attach, target_zone)
	SSblackbox.record_feedback("tally", "arbitrary_prosthetic", 1, initial(thing_to_attach.name))
	var/obj/item/bodypart/new_limb = patient.make_item_prosthetic(thing_to_attach, target_zone, 80)
	new_limb.surgery_state |= SURGERY_PROSTHETIC_UNSECURED
	display_results(
		surgeon, patient,
		span_notice("You attach [thing_to_attach]."),
		span_notice("[surgeon] finishes attaching [thing_to_attach]!"),
		span_notice("[surgeon] finishes the attachment procedure!"),
	)
	display_pain(patient, "You feel a strange sensation as [thing_to_attach] takes place of an arm!", TRUE)

/datum/surgery_operation/limb/secure_arbitrary_prosthetic
	name = "secure prosthetic"
	desc = "Ensure that an arbitrary prosthetic is properly attached to a patient's body."
	implements = list(
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/sticky_tape/surgical = 1.25,
		/obj/item/stack/sticky_tape = 2,
	)
	time = 4.8 SECONDS

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/state_check(obj/item/bodypart/limb)
	return HAS_SURGERY_STATE(limb, SURGERY_PROSTHETIC_UNSECURED)

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/stack/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to [tool.singular_name] [limb] to [limb.owner]'s body."),
		span_notice("[surgeon] begins to [tool.singular_name] [limb] to [limb.owner]'s body."),
		span_notice("[surgeon] begins to [tool.singular_name] something to [limb.owner]'s body."),
	)
	var/obj/item/bodypart/chest = limb.owner.get_bodypart(BODY_ZONE_CHEST)
	display_pain(limb.owner, "[surgeon] begins to [tool.singular_name] [limb] to your body!", IS_ROBOTIC_LIMB(chest))

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/stack/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You finish [tool.singular_name]ing [limb] to [limb.owner]'s body."),
		span_notice("[surgeon] finishes [tool.singular_name]ing [limb] to [limb.owner]'s body."),
		span_notice("[surgeon] finishes the [tool.singular_name]ing procedure!"),
	)
	var/obj/item/bodypart/chest = limb.owner.get_bodypart(BODY_ZONE_CHEST)
	display_pain(limb.owner, "You feel more secure as your prosthetic is firmly attached to your body!", IS_ROBOTIC_LIMB(chest))
	limb.surgery_state &= ~SURGERY_PROSTHETIC_UNSECURED
	limb.AddComponent(/datum/component/item_as_prosthetic_limb, null, 0) // updates drop probability to zero
	tool.use(1)
