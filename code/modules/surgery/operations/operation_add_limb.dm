#define OPERATION_REJECTION_DAMAGE "tox_damage"

// This surgery is so snowflake that it doesn't use any of the operation subtypes, it forges its own path
/datum/surgery_operation/limb/prosthetic_replacement
	name = "prosthetic replacement"
	desc = "Replace a missing limb with a prosthetic (or arbitrary) item."
	implements = list(
		/obj/item/bodypart = 1,
		/obj/item = 1,
	)
	time = 3.2 SECONDS
	operation_flags = OPERATION_STANDING_ALLOWED | OPERATION_PRIORITY_NEXT_STEP | OPERATION_NOTABLE | OPERATION_IGNORE_CLOTHES
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	allow_stumps = TRUE
	/// List of items that are always allowed to be an arm replacement, even if they fail another requirement.
	var/list/always_accepted_prosthetics = list(
		/obj/item/chainsaw, // the OG, too large otherwise
		/obj/item/melee/synthetic_arm_blade, // also too large otherwise
		/obj/item/food/pizzaslice, // he's turning her into a papa john's
	)
	/// Radial slice datums for every augment type
	VAR_PRIVATE/list/cached_prosthetic_options

/datum/surgery_operation/limb/prosthetic_replacement/get_recommended_tool()
	return "any limb / any item"

/datum/surgery_operation/limb/prosthetic_replacement/get_any_tool()
	return "Any suitable arm replacement"

/datum/surgery_operation/limb/prosthetic_replacement/all_required_strings()
	. = ..()
	. += "the limb must be missing / a stump"

/datum/surgery_operation/limb/prosthetic_replacement/any_required_strings()
	return list("arms may receive any suitable item in lieu of a replacement limb") + ..()

/datum/surgery_operation/limb/prosthetic_replacement/get_radial_options(obj/item/bodypart/chest/chest, obj/item/tool, operating_zone)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_prosthetic_options, tool.type)
	if(!option)
		option = new()
		option.name = "attach [initial(tool.name)]"
		option.info = "Replace the patient's missing limb with [initial(tool.name)]."
		option.image = image(tool.type)
		LAZYSET(cached_prosthetic_options, tool.type, option)

	return option

/datum/surgery_operation/limb/prosthetic_replacement/state_check(obj/item/bodypart/limb)
	return IS_STUMP(limb)

/datum/surgery_operation/limb/prosthetic_replacement/snowflake_check_availability(obj/item/bodypart/chest, mob/living/surgeon, obj/item/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	var/real_operated_zone = deprecise_zone(operated_zone)
	// check bodyshape compatibility for real bodyparts
	if(isbodypart(tool))
		var/obj/item/bodypart/new_limb = tool
		if(real_operated_zone != new_limb.body_zone)
			return FALSE
		if(!new_limb.can_attach_limb(chest.owner))
			return FALSE
	// arbitrary prosthetics can only be used on arms (for now)
	else if(!(real_operated_zone in GLOB.arm_zones))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/prosthetic_replacement/tool_check(obj/item/tool)
	if(tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM))
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

/datum/surgery_operation/limb/prosthetic_replacement/pre_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	// always operate on absolute body zones
	operation_args[OPERATION_TARGET_ZONE] = deprecise_zone(operation_args[OPERATION_TARGET_ZONE])

/datum/surgery_operation/limb/prosthetic_replacement/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		chest.owner,
		// "You begin to attach the right arm to john doe's right arm stump"
		span_notice("You begin to attach [tool]'s to [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to attach [tool]'s to [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] begins to attach [tool]'s to [FORMAT_LIMB_OWNER(limb)]."),
	)
	display_pain(chest.owner, "You feel an uncomfortable sensation where your [parse_zone(limb.body_zone)] should be!")

	operation_args[OPERATION_REJECTION_DAMAGE] = 10
	if(isbodypart(tool))
		var/obj/item/bodypart/new_limb = tool
		if(IS_ROBOTIC_LIMB(new_limb))
			operation_args[OPERATION_REJECTION_DAMAGE] = 0
		else if(new_limb.check_for_frankenstein(chest.owner))
			operation_args[OPERATION_REJECTION_DAMAGE] = 30

/datum/surgery_operation/limb/prosthetic_replacement/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	if(!surgeon.temporarilyRemoveItemFromInventory(tool))
		return // should never happen
	if(operation_args[OPERATION_REJECTION_DAMAGE] > 0)
		chest.owner.apply_damage(operation_args[OPERATION_REJECTION_DAMAGE], TOX)
	if(isbodypart(tool))
		handle_bodypart(chest.owner, surgeon, tool)
		return
	handle_arbitrary_prosthetic(chest.owner, surgeon, tool, operation_args[OPERATION_TARGET_ZONE])

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
	new_limb.add_surgical_state(SURGERY_PROSTHETIC_UNSECURED)
	display_results(
		surgeon, patient,
		span_notice("You attach [thing_to_attach]."),
		span_notice("[surgeon] finishes attaching [thing_to_attach]!"),
		span_notice("[surgeon] finishes the attachment procedure!"),
	)
	display_pain(patient, "You feel a strange sensation as [thing_to_attach] takes the place of your arm!", TRUE)

#undef OPERATION_REJECTION_DAMAGE

/datum/surgery_operation/limb/secure_arbitrary_prosthetic
	name = "secure prosthetic"
	desc = "Ensure that an arbitrary prosthetic is properly attached to a patient's body."
	implements = list(
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/wrap/sticky_tape/surgical = 1.25,
		/obj/item/stack/medical/wrap/sticky_tape = 2,
	)
	time = 4.8 SECONDS
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_STANDING_ALLOWED | OPERATION_IGNORE_CLOTHES
	all_surgery_states_required = SURGERY_PROSTHETIC_UNSECURED

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/get_default_radial_image()
	return image(/obj/item/stack/medical/suture)

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/stack/medical/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to [tool.singular_name] [limb] to [limb.owner]'s body."),
		span_notice("[surgeon] begins to [tool.singular_name] [limb] to [limb.owner]'s body."),
		span_notice("[surgeon] begins to [tool.singular_name] something to [limb.owner]'s body."),
	)
	display_pain(limb.owner, "[surgeon] begins to [tool.singular_name] [limb] to your body!", IS_ROBOTIC_LIMB(limb))

/datum/surgery_operation/limb/secure_arbitrary_prosthetic/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/stack/medical/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You finish [tool.apply_verb] [limb] to [limb.owner]'s body."),
		span_notice("[surgeon] finishes [tool.apply_verb] [limb] to [limb.owner]'s body."),
		span_notice("[surgeon] finishes the [tool.apply_verb] procedure!"),
	)
	display_pain(limb.owner, "You feel more secure as your prosthetic is firmly attached to your body!", IS_ROBOTIC_LIMB(limb))
	limb.remove_surgical_state(SURGERY_PROSTHETIC_UNSECURED)
	limb.AddComponent(/datum/component/item_as_prosthetic_limb, null, 0) // updates drop probability to zero
	tool.use(1)
