/datum/surgery_operation/limb/filter_blood
	name = "blood filtration"
	desc = "Remove unwanted chemicals from a patient's bloodstream."
	implements = list(/obj/item/blood_filter = 1)
	time = 2.5 SECONDS
	operation_flags = OPERATION_LOOPING
	success_sound = 'sound/machines/card_slide.ogg'

/datum/surgery_operation/limb/filter_blood/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/blood_filter)
	return base

/datum/surgery_operation/limb/filter_blood/state_check(obj/item/bodypart/limb)
	if(!LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT))
		return FALSE
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/filter_blood/can_loop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	return ..() && has_filterable_chems(limb.owner, tool)

/datum/surgery_operation/limb/filter_blood/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_pain(limb.owner, "You feel a throbbing pain in your chest!")

/datum/surgery_operation/limb/filter_blood/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	var/obj/item/blood_filter/bloodfilter = tool
	for(var/datum/reagent/chem as anything in limb.owner.reagents?.reagent_list)
		if(!length(bloodfilter.whitelist) || !(chem.type in bloodfilter.whitelist))
			limb.owner.reagents.remove_reagent(chem.type, clamp(round(chem.volume * 0.22, 0.2), 0.4, 10))

	display_results(
		surgeon,
		limb.owner,
		span_notice("[tool] completes a cycle filtering [limb.owner]'s blood."),
		span_notice("[tool] whirrs as it filters [limb.owner]'s blood."),
		span_notice("[tool] whirrs as it pumps."),
	)

	if(surgeon.is_holding_item_of_type(/obj/item/healthanalyzer))
		chemscan(surgeon, limb.owner)

/datum/surgery_operation/limb/filter_blood/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("You screw up, bruising [limb.owner]'s chest!"),
		span_warning("[surgeon] screws up, brusing [limb.owner]'s chest!"),
		span_warning("[surgeon] screws up!"),
	)
	limb.receive_damage(5, damage_source = tool)

/datum/surgery_operation/limb/filter_blood/proc/has_filterable_chems(mob/living/carbon/target, obj/item/blood_filter/bloodfilter)
	if(!length(target.reagents?.reagent_list))
		bloodfilter.audible_message(span_notice("[bloodfilter] pings as it reports no chemicals detected in [target]'s blood."))
		playsound(target, 'sound/machines/ping.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1)
		return FALSE

	if(!length(bloodfilter.whitelist))
		return TRUE

	for(var/datum/reagent/chem as anything in target.reagents.reagent_list)
		if(chem.type in bloodfilter.whitelist)
			return TRUE

	return FALSE
