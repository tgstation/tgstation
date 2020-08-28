/datum/surgery/blood_filter
	name = "Filter blood"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/filter_blood,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = TRUE
	ignore_clothes = FALSE

/datum/surgery_step/filter_blood
	name = "Filter blood"
	implements = list(/obj/item/blood_filter = 95)
	repeatable = FALSE
	time = 40

/datum/surgery/filter_blood/can_start(mob/user, mob/living/carbon/target)
	if(HAS_TRAIT(target, TRAIT_HUSK)) //You can filter the blood of a dead person just not husked
		return FALSE
	return ..()

/datum/surgery_step/filter_blood/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin filtering [target]'s blood...</span>",
		"<span class='notice'>[user] uses the [tool] to filtering your blood.</span>",
		"<span class='notice'>[user] uses the [tool] on [target]'s chest.</span>")

/datum/surgery_step/filter_blood/tool_check(mob/user, obj/item/tool)
	if(!implement_type == TOOL_BLOODFILTER)
		return FALSE
	var/obj/item/blood_filter/filter = tool
	if(!filter.beaker)
		to_chat(user, "<span class='warning'>The [tool] is missing a beaker to operate properly.</span>")
		return FALSE
	return TRUE

/datum/surgery_step/filter_blood/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(user, target, "<span class='notice'>The [tool] pings as it finishes filtering [target]'s blood.</span>",
		"<span class='notice'>The [tool] pings as it stops pumping your blood.</span>",
		"The [tool] pings as it stops pumping.")
	var/obj/item/blood_filter/filter = tool
	filter.act_filter_blood(user, target)
	return ..()

/datum/surgery_step/filter_blood/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='warning'>You screw up, brusing [target]'s chest!</span>",
		"<span class='warning'>[user] screws up, brusing [target]'s chest!</span>",
		"<span class='warning'>[user] screws up!</span>")
	target.adjustBruteLoss(5)
