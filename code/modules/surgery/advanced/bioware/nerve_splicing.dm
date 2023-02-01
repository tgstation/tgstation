/datum/surgery/advanced/bioware/nerve_splicing
	name = "Nerve Splicing"
	desc = "A surgical procedure which splices the patient's nerves, making them more resistant to stuns."
	possible_locs = list(BODY_ZONE_CHEST)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/splice_nerves,
		/datum/surgery_step/close,
	)

	bioware_target = BIOWARE_NERVES

/datum/surgery_step/splice_nerves
	name = "splice nerves (hand)"
	accept_hand = TRUE
	time = 155

/datum/surgery_step/splice_nerves/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start splicing together [target]'s nerves."),
		span_notice("[user] starts splicing together [target]'s nerves."),
		span_notice("[user] starts manipulating [target]'s nervous system."),
	)
	display_pain(target, "Your entire body goes numb!")

/datum/surgery_step/splice_nerves/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("You successfully splice [target]'s nervous system!"),
		span_notice("[user] successfully splices [target]'s nervous system!"),
		span_notice("[user] finishes manipulating [target]'s nervous system."),
	)
	display_pain(target, "You regain feeling in your body; It feels like everything's happening around you in slow motion!")
	new /datum/bioware/spliced_nerves(target)
	if(target.ckey)
		SSblackbox.record_feedback("nested tally", "nerve_splicing", 1, list("[target.ckey]", "got")) 
	return ..()

/datum/bioware/spliced_nerves
	name = "Spliced Nerves"
	desc = "Nerves are connected to each other multiple times, greatly reducing the impact of stunning effects."
	mod_type = BIOWARE_NERVES

/datum/bioware/spliced_nerves/on_gain()
	..()
	owner.physiology.stun_mod *= 0.5
	owner.physiology.stamina_mod *= 0.8

/datum/bioware/spliced_nerves/on_lose()
	..()
	owner.physiology.stun_mod *= 2
	owner.physiology.stamina_mod *= 1.25
