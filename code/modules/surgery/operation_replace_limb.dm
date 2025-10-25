/datum/surgery_operation/limb/replace_limb
	name = "replace limb"
	desc = "Replace a patient's limb with a robotic or prosthetic one."
	implements = list(
		/obj/item/bodypart = 1,
	)
	time = 3.2 SECONDS

/datum/surgery_operation/limb/replace_limb/is_available(obj/item/bodypart/limb, mob/living/surgeon, obj/item/bodypart/tool)
	if(HAS_TRAIT(limb.owner, TRAIT_NO_AUGMENTS))
		return FALSE
	if(!HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN))
		return FALSE
	if(limb.bodypart_flags & BODYPART_UNREMOVABLE)
		return FALSE
	if(deprecise_zone(surgeon.zone_selected) != limb.body_zone)
		return FALSE
	if(limb.body_zone != tool.body_zone)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/replace_limb/tool_check(obj/item/bodypart/tool)
	if(HAS_TRAIT(tool, TRAIT_NODROP) || (tool.item_flags & (ABSTRACT|DROPDEL|HAND_ITEM)))
		return FALSE
	if(!IS_ROBOTIC_LIMB(tool))
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
