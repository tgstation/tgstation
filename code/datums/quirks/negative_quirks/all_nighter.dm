#define SLEEP_BANK_MULTIPLIER 10

/datum/quirk/all_nighter
	name = "All Nighter"
	desc = "You didn't get any sleep last night, and people can tell! You'll constantly be in a bad mood and will have a tendency to sleep longer. Stimulants or a nap might help, though."
	icon = FA_ICON_BED
	value = -4
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = span_danger("You feel exhausted.")
	lose_text = span_notice("You feel well rested.")
	medical_record_text = "Patient appears to be suffering from sleep deprivation."
	hardcore_value = 2
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE|QUIRK_MOODLET_BASED|QUIRK_PROCESSES

	mail_goodies = list(
		/obj/item/clothing/glasses/blindfold,
		/obj/item/bedsheet/random,
		/obj/item/clothing/under/misc/pj/red,
		/obj/item/clothing/head/costume/nightcap/red,
		/obj/item/clothing/under/misc/pj/blue,
		/obj/item/clothing/head/costume/nightcap/blue,
		/obj/item/pillow/random,
	)

	///a list of all the reagents which alleviate the negative moodlet
	var/list/stimulants = list(
		/datum/reagent/medicine/stimulants,
		/datum/reagent/drug/methamphetamine,
		/datum/reagent/drug/bath_salts,
		/datum/reagent/drug/aranesp,
		/datum/reagent/drug/pumpup,
		/datum/reagent/drug/blastoff,
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/tea,
		/datum/reagent/consumable/volt_energy,
		/datum/reagent/consumable/monkey_energy
	)
	///essentially our "sleep bank". sleeping charges it up and its drained while awake
	var/five_more_minutes = 0
	///the overlay we put over the eyes
	var/datum/bodypart_overlay/simple/bags/bodypart_overlay


///adds the corresponding moodlet and visual effects
/datum/quirk/all_nighter/add(client/client_source)
	quirk_holder.add_mood_event("all_nighter", /datum/mood_event/all_nighter)
	add_bags()

///removes the corresponding moodlet and visual effects
/datum/quirk/all_nighter/remove(client/client_source)
	quirk_holder.clear_mood_event("all_nighter", /datum/mood_event/all_nighter)
	remove_bags()

///adds the bag overlay
/datum/quirk/all_nighter/proc/add_bags(client/client_source)
	var/mob/living/carbon/human/sleepy_head = quirk_holder
	var/obj/item/bodypart/head/face = sleepy_head.get_bodypart(BODY_ZONE_HEAD)
	bodypart_overlay = new() //creates our overlay
	face.add_bodypart_overlay(bodypart_overlay)
	sleepy_head.update_body_parts() //make sure to update icon

///removes the bag overlay
/datum/quirk/all_nighter/proc/remove_bags(client/client_source)
	var/mob/living/carbon/human/sleepy_head = quirk_holder
	var/obj/item/bodypart/head/face = sleepy_head.get_bodypart(BODY_ZONE_HEAD)
	//our overlay is stored as a datum var, so referencing it is easy
	face.remove_bodypart_overlay(bodypart_overlay)
	QDEL_NULL(bodypart_overlay)
	sleepy_head.update_body_parts()

/**
*Here we actively handle our moodlet & eye bags, adding/removing them as necessary
*
**Logic:
**Every second spent sleeping adds to the "sleep bank" with a multiplier of SLEEP_BANK_MULTIPLIER
**Every waking second drains the sleep bank until empty
**An empty sleep bank means you have bags beneath your eyes
**An empty sleep bank AND a lack of stimulants means you have the negative moodlet
*
**Variables:
**happy_camper - FALSE if we should have the negative moodlet
**beauty_sleep - FALSE if we should have bags
*/
/datum/quirk/all_nighter/process(seconds_per_tick)
	var/happy_camper = TRUE
	var/beauty_sleep = TRUE
	var/stims_present = FALSE

	if(quirk_holder.IsSleeping())
		five_more_minutes += SLEEP_BANK_MULTIPLIER * seconds_per_tick
	else if(five_more_minutes > 0)
		five_more_minutes -= seconds_per_tick
	else
		beauty_sleep = FALSE //no sleep means eye bags

		for(var/stimulant in stimulants)
			if(quirk_holder.has_reagent(stimulant))  //checking for stims
				stims_present = TRUE
				break
		if(!stims_present) //no stims and no sleep means an unhappy camper
			happy_camper = FALSE

	//adjusts the mood event accordingly
	if(("all_nighter" in quirk_holder.mob_mood?.mood_events) && happy_camper)
		quirk_holder.clear_mood_event("all_nighter", /datum/mood_event/all_nighter)
	if(!("all_nighter" in quirk_holder.mob_mood?.mood_events) && !happy_camper)
		quirk_holder.add_mood_event("all_nighter", /datum/mood_event/all_nighter)
		to_chat(quirk_holder, span_danger("You start feeling tired again."))

	//adjusts bag overlay accordingly
	if(bodypart_overlay && beauty_sleep)
		remove_bags()
	if(!bodypart_overlay && !beauty_sleep)
		add_bags()


#undef SLEEP_BANK_MULTIPLIER
