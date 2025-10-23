/datum/surgery_operation/asthmatic_bypass
	name = "force open windpipe"
	desc = "Forcibly expand a patient's windpipe, relieving asthma symptoms."
	implements = list(
		TOOL_RETRACTOR = 0.80,
		TOOL_WIRECUTTER = 0.45,
	)
	time = 8 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'

	/// The amount of inflammation a failure or success of this surgery will reduce.
	var/inflammation_reduction = 75

/datum/surgery_operation/asthmatic_bypass/state_check(obj/item/bodypart/limb)
	if(!(locate(/obj/item/organ/lungs) in limb))
		return FALSE
	if(!limb.owner.has_quirk(/datum/quirk/item_quirk/asthma))
		return FALSE
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	return TRUE

/datum/surgery_operation/asthmatic_bypass/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to stretch [limb.owner]'s windpipe, trying your best to avoid nearby blood vessels..."),
		span_notice("[surgeon] begins to stretch [limb.owner]'s windpipe, taking care to avoid any nearby blood vessels."),
		span_notice("[surgeon] begins to stretch [limb.owner]'s windpipe."),
	)
	display_pain(limb.owner, "You feel an agonizing stretching sensation in your neck!")

/datum/surgery_operation/asthmatic_bypass/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/quirk/item_quirk/asthma/asthma = limb.owner.get_quirk(/datum/quirk/item_quirk/asthma)
	if(isnull(asthma))
		return

	asthma.adjust_inflammation(-inflammation_reduction)

	display_results(
		surgeon,
		limb.owner,
		span_notice("You stretch [limb.owner]'s windpipe with [tool], managing to avoid the nearby blood vessels and arteries."),
		span_notice("[surgeon] succeeds at stretching [limb.owner]'s windpipe with [tool], avoiding the nearby blood vessels and arteries."),
		span_notice("[surgeon] finishes stretching [limb.owner]'s windpipe.")
	)

/datum/surgery_operation/asthmatic_bypass/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args, total_penalty_modifier)
	var/datum/quirk/item_quirk/asthma/asthma = limb.owner.get_quirk(/datum/quirk/item_quirk/asthma)
	if(isnull(asthma))
		return

	asthma.adjust_inflammation(-inflammation_reduction)

	display_results(
		surgeon,
		limb.owner,
		span_warning("You stretch [limb.owner]'s windpipe with [tool], but accidentally clip a few arteries!"),
		span_warning("[surgeon] succeeds at stretching [limb.owner]'s windpipe with [tool], but accidentally clips a few arteries!"),
		span_warning("[surgeon] finishes stretching [limb.owner]'s windpipe, but screws up!"),
	)

	limb.owner.losebreath++

	if(prob(30))
		limb.owner.cause_wound_of_type_and_severity(WOUND_SLASH, limb, WOUND_SEVERITY_MODERATE, WOUND_SEVERITY_CRITICAL, WOUND_PICK_LOWEST_SEVERITY, tool)
	limb.receive_damage(brute = 10, wound_bonus = tool.wound_bonus, sharpness = SHARP_EDGED, damage_source = tool)
