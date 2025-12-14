/datum/surgery_operation/limb/replace_limb
	name = "augment limb"
	rnd_name = "Augmentation"
	desc = "Replace a patient's limb with a robotic or prosthetic one."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		/obj/item/bodypart = 1,
	)
	time = 3.2 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN
	/// Radial slice datums for every augment type
	VAR_PRIVATE/list/cached_augment_options

/datum/surgery_operation/limb/replace_limb/get_recommended_tool()
	return "cybernetic limb"

/datum/surgery_operation/limb/replace_limb/get_default_radial_image()
	return image(/obj/item/bodypart/chest/robot)

/datum/surgery_operation/limb/replace_limb/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_augment_options, tool.type)
	if(!option)
		option = new()
		option.name = "augment with [initial(tool.name)]"
		option.info = "Replace the patient's [initial(limb.name)] with [initial(tool.name)]."
		option.image = image(tool.type)
		LAZYSET(cached_augment_options, tool.type, option)

	return option

/datum/surgery_operation/limb/replace_limb/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/bodypart/tool, operated_zone)
	if(!surgeon.canUnEquip(tool))
		return FALSE
	if(limb.body_zone != tool.body_zone)
		return FALSE
	if(!tool.can_attach_limb(limb.owner))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/replace_limb/state_check(obj/item/bodypart/limb)
	return !HAS_TRAIT(limb.owner, TRAIT_NO_AUGMENTS) && !(limb.bodypart_flags & BODYPART_UNREMOVABLE)

/datum/surgery_operation/limb/replace_limb/tool_check(obj/item/bodypart/tool)
	if(tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM))
		return FALSE
	if(!isbodypart(tool))
		return FALSE
	var/obj/item/bodypart/limb = tool
	if(!IS_ROBOTIC_LIMB(limb))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/replace_limb/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/bodypart/tool, list/operation_args)
	// purposefully doesn't use plaintext zone for more context on what is being replaced with what
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to augment [limb.owner]'s [limb.name] with [tool]..."),
		span_notice("[surgeon] begins to augment [limb.owner]'s [limb.name] with [tool]."),
		span_notice("[surgeon] begins to augment [limb.owner]'s [limb.name]."),
	)
	display_pain(limb.owner, "You feel a horrible pain in your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/replace_limb/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/bodypart/tool, list/operation_args)
	if(!surgeon.temporarilyRemoveItemFromInventory(tool))
		return // should never happen

	var/mob/living/patient = limb.owner // owner's about to be nulled
	if(!tool.replace_limb(patient))
		display_results(
			surgeon,
			patient,
			span_warning("You can't seem to fit [tool] onto [patient]'s body!"),
			span_warning("[surgeon] can't seem to fit [tool] onto [patient]'s body!"),
			span_warning("[surgeon] can't seem to fit [tool] onto [patient]'s body!"),
		)
		tool.forceMove(patient.drop_location())
		return // could possibly happen

	if(tool.check_for_frankenstein(patient))
		tool.bodypart_flags |= BODYPART_IMPLANTED

	display_results(
		surgeon,
		patient,
		span_notice("You successfully augment [patient]'s [limb.plaintext_zone] with [tool]!"),
		span_notice("[surgeon] successfully augments [patient]'s [limb.plaintext_zone] with [tool]!"),
		span_notice("[surgeon] finishes augmenting [patient]'s [limb.plaintext_zone]."),
	)
	display_pain(patient, "Your [limb.plaintext_zone] comes awash with synthetic sensation!", TRUE)
	log_combat(surgeon, patient, "augmented", addition = "by giving him new [tool]")
