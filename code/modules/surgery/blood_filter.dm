/datum/surgery/blood_filter
	name = "Filter blood"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/filter_blood,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = TRUE
	ignore_clothes = FALSE

/datum/surgery/blood_filter/can_start(mob/user, mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_HUSK)) //You can filter the blood of a dead person just not husked
		return FALSE
	return ..()

/datum/surgery_step/filter_blood
	name = "Filter blood"
	implements = list(/obj/item/blood_filter = 95)
	repeatable = TRUE
	time = 2.5 SECONDS

/datum/surgery_step/filter_blood/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_notice("You begin filtering [target]'s blood..."),
		span_notice("[user] uses [tool] to filter [target]'s blood."),
		span_notice("[user] uses [tool] on [target]'s chest."))
	display_pain(target, "You feel a throbbing pain in your chest!")

/datum/surgery_step/filter_blood/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(target.reagents?.total_volume)
		for(var/datum/reagent/chem as anything in target.reagents.reagent_list)
			target.reagents.remove_reagent(chem.type, min(chem.volume * 0.22, 10))
	display_results(user, target, span_notice("\The [tool] pings as it finishes filtering [target]'s blood."),
		span_notice("\The [tool] pings as it stops pumping [target]'s blood."),
		playsound(get_turf(target), 'sound/machines/ping.ogg', 25, TRUE, falloff_exponent = 12, falloff_distance = 1),
		"\The [tool] pings as it stops pumping.")
	return ..()

/datum/surgery_step/filter_blood/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, span_warning("You screw up, bruising [target]'s chest!"),
		span_warning("[user] screws up, brusing [target]'s chest!"),
		span_warning("[user] screws up!"))
	target.adjustBruteLoss(5)
