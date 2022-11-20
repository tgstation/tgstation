/datum/surgery/advanced/bioware/nerve_grounding
	name = "Nerve Grounding"
	desc = "A surgical procedure which makes the patient's nerves act as grounding rods, protecting them from electrical shocks."
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/ground_nerves,
		/datum/surgery_step/close,
	)

	bioware_target = BIOWARE_NERVES

/datum/surgery_step/ground_nerves
	name = "ground nerves (hand)"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/ground_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start rerouting [target]'s nerves."),
		span_notice("[user] starts rerouting [target]'s nerves."),
		span_notice("[user] starts manipulating [target]'s nervous system."),
	)
	display_pain(target, "Your entire body goes numb!")

/datum/surgery_step/ground_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("You successfully reroute [target]'s nervous system!"),
		span_notice("[user] successfully reroutes [target]'s nervous system!"),
		span_notice("[user] finishes manipulating [target]'s nervous system."),
	)
	display_pain(target, "You regain feeling in your body! You feel energzed!")
	new /datum/bioware/grounded_nerves(target)
	return ..()

/datum/bioware/grounded_nerves
	name = "Grounded Nerves"
	desc = "Nerves form a safe path for electricity to traverse, protecting the body from electric shocks."
	mod_type = BIOWARE_NERVES

/datum/bioware/grounded_nerves/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, EXPERIMENTAL_SURGERY_TRAIT)

/datum/bioware/grounded_nerves/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, EXPERIMENTAL_SURGERY_TRAIT)
