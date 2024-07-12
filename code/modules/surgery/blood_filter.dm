/datum/surgery/blood_filter
	name = "Filter blood"
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/incise,
		/datum/surgery_step/filter_blood,
		/datum/surgery_step/close,
	)

/datum/surgery/blood_filter/can_start(mob/user, mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_HUSK)) //You can filter the blood of a dead person just not husked
		return FALSE
	return ..()

/datum/surgery_step/filter_blood/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	display_results(
		user,
		target,
		span_notice("You begin filtering [target]'s blood..."),
		span_notice("[user] uses [tool] to filter [target]'s blood."),
		span_notice("[user] uses [tool] on [target]'s chest."),
	)
	if(!..())
		return
	while(has_filterable_chems(target, tool))
		if(!..())
			break

/**
 * Checks if the mob contains chems we can filter
 *
 * If the blood filter's whitelist is empty this checks if the mob contains any chems
 * If the whitelist contains chems it checks if any chems in the mob match chems in the whitelist
 *
 * Arguments:
 * * target - The mob to check the chems of
 * * bloodfilter - The blood filter to check the whitelist of
 */
/datum/surgery_step/filter_blood/proc/has_filterable_chems(mob/living/carbon/target, obj/item/blood_filter/bloodfilter)
	if(!length(target.reagents?.reagent_list))
		bloodfilter.audible_message(span_notice("[bloodfilter] pings as it reports no chemicals detected in [target]'s blood."))
		playsound(get_turf(target), 'sound/machines/ping.ogg', 75, TRUE, falloff_exponent = 12, falloff_distance = 1)
		return FALSE

	if(!length(bloodfilter.whitelist))
		return TRUE

	for(var/datum/reagent/chem as anything in target.reagents.reagent_list)
		if(chem.type in bloodfilter.whitelist)
			return TRUE

	return FALSE

/datum/surgery_step/filter_blood
	name = "Filter blood (blood filter)"
	implements = list(/obj/item/blood_filter = 95)
	repeatable = TRUE
	time = 2.5 SECONDS
	success_sound = 'sound/machines/card_slide.ogg'

/datum/surgery_step/filter_blood/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_pain(target, "You feel a throbbing pain in your chest!")

/datum/surgery_step/filter_blood/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/obj/item/blood_filter/bloodfilter = tool
	if(target.reagents?.total_volume)
		for(var/datum/reagent/chem as anything in target.reagents.reagent_list)
			if(!length(bloodfilter.whitelist) || (chem.type in bloodfilter.whitelist))
				target.reagents.remove_reagent(chem.type, clamp(round(chem.volume * 0.22, 0.2), 0.4, 10))
	display_results(
		user,
		target,
		span_notice("\The [tool] completes a cycle filtering [target]'s blood."),
		span_notice("\The [tool] whirrs as it filters [target]'s blood."),
		span_notice("\The [tool] whirrs as it pumps."),
	)

	if(locate(/obj/item/healthanalyzer) in user.held_items)
		chemscan(user, target)

	return ..()

/datum/surgery_step/filter_blood/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_warning("You screw up, bruising [target]'s chest!"),
		span_warning("[user] screws up, brusing [target]'s chest!"),
		span_warning("[user] screws up!"),
	)
	target.adjustBruteLoss(5)
