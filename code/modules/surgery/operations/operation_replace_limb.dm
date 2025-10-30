/datum/surgery_operation/limb/replace_limb
	name = "augment limb"
	rnd_name = "Cybernetic Augmentation"
	desc = "Replace a patient's limb with a robotic or prosthetic one."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		/obj/item/bodypart = 1,
	)
	time = 3.2 SECONDS
	/// Radial slice datums for every augment type
	VAR_PRIVATE/list/cached_augment_options

/datum/surgery_operation/limb/replace_limb/get_recommended_tool()
	return "cybernetic limb"

/datum/surgery_operation/limb/replace_limb/get_radial_options(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_augment_options, tool.type)
	if(!option)
		option = new()
		option.name = "augment with [tool.name]"
		option.info = "Replace the patient's [limb.name] with [tool.name]."
		option.image = image(tool)
		LAZYSET(cached_augment_options, tool.type, option)

	return option

/datum/surgery_operation/limb/replace_limb/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/bodypart/tool, body_zone)
	if(limb.body_zone != body_zone)
		return FALSE
	if(limb.body_zone != tool.body_zone)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/replace_limb/state_check(obj/item/bodypart/limb)
	if(HAS_TRAIT(limb.owner, TRAIT_NO_AUGMENTS))
		return FALSE
	if(!LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN))
		return FALSE
	if(limb.bodypart_flags & BODYPART_UNREMOVABLE)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/replace_limb/tool_check(obj/item/bodypart/tool)
	if(HAS_TRAIT(tool, TRAIT_NODROP) || (tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM)))
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
		span_notice("You begin to augment [limb.owner]'s [limb] with [tool]..."),
		span_notice("[surgeon] begins to augment [limb.owner]'s [limb] with [tool]."),
		span_notice("[surgeon] begins to augment [limb.owner]'s [limb]."),
	)
	display_pain(limb.owner, "You feel a horrible pain in your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/replace_limb/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/bodypart/tool, list/operation_args)
	if(!surgeon.temporarilyRemoveItemFromInventory(tool))
		return // should never happen

	if(!tool.replace_limb(limb))
		display_results(
			surgeon,
			limb.owner,
			span_warning("You can't seem to fit [tool] onto [limb.owner]'s body!"),
			span_warning("[surgeon] can't seem to fit [tool] onto [limb.owner]'s body!"),
			span_warning("[surgeon] can't seem to fit [tool] onto [limb.owner]'s body!"),
		)
		return // could possibly happen

	if(tool.check_for_frankenstein(limb.owner))
		tool.bodypart_flags |= BODYPART_IMPLANTED

	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully augment [limb.owner]'s [limb.plaintext_zone] with [tool]!"),
		span_notice("[surgeon] successfully augments [limb.owner]'s [limb.plaintext_zone] with [tool]!"),
		span_notice("[surgeon] finishes augmenting [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "Your [limb.plaintext_zone] comes awash with synthetic sensation!", TRUE)
	log_combat(surgeon, limb.owner, "augmented", addition = "by giving him new [tool]")
