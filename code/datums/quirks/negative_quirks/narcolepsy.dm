/// Odds seconds_per_tick the user falls asleep
#define SLEEP_CHANCE 0.333
/// Odds seconds_per_tick the user falls asleep while running
#define SLEEP_CHANCE_RUNNING 0.5
/// Odds seconds_per_tick the user falls asleep while drowsy
#define SLEEP_CHANCE_DROWSY 1

/datum/quirk/narcolepsy
	name = "Narcolepsy"
	desc = "You feel drowsy often, and could fall asleep at any moment. Staying caffeinated, walking or even supressing symptoms with stimulants, prescribed or otherwise, can help you get through the shift..."
	icon = FA_ICON_BED
	value = -8
	hardcore_value = 8
	medical_record_text = "Patient may involuntarily fall asleep during normal activities, and feel drowsy at any given moment."
	mail_goodies = list(
		/obj/item/reagent_containers/cup/glass/coffee,
		/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind,
		/obj/item/storage/pill_bottle/prescription_stimulant,
	)

/datum/quirk/narcolepsy/post_add()
	. = ..()
	var/mob/living/carbon/human/user = quirk_holder
	user.gain_trauma(/datum/brain_trauma/severe/narcolepsy/permanent, TRAUMA_RESILIENCE_ABSOLUTE)

	var/obj/item/storage/pill_bottle/prescription_stimulant/stimmies = new()
	if(quirk_holder.equip_to_storage(stimmies, ITEM_SLOT_BACK, indirect_action = TRUE, del_on_fail = TRUE))
		to_chat(quirk_holder, span_info("You have been given a bottle of mild stimulants to assist in staying awake this shift..."))

/datum/quirk/narcolepsy/remove()
	. = ..()
	var/mob/living/carbon/human/user = quirk_holder
	user?.cure_trauma_type(/datum/brain_trauma/severe/narcolepsy/permanent, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/brain_trauma/severe/narcolepsy/permanent
	scan_desc = "chronic narcolepsy"

//similar to parent but slower and can be suppressed by medicine and caffeine
/datum/brain_trauma/severe/narcolepsy/permanent/on_life(seconds_per_tick, times_fired)
	if(owner.IsSleeping())
		return

	/// If any of these are in the user's blood, return early
	var/list/immunity_medicine = list(
		/datum/reagent/medicine/modafinil,
		/datum/reagent/medicine/synaptizine,
	) //unlike parent which only truly gets surpressed by modafinil
	for(var/datum/reagent/medicine in immunity_medicine)
		if(owner.reagents.has_reagent(medicine))
			return

	var/sleep_chance = SLEEP_CHANCE
	var/drowsy = !!owner.has_status_effect(/datum/status_effect/drowsiness)
	var/caffeinated = HAS_TRAIT(owner, TRAIT_STIMULATED)
	if(owner.move_intent == MOVE_INTENT_RUN)
		sleep_chance = SLEEP_CHANCE_RUNNING //dont stack this one, walking or running should only have a minor impact
	if(drowsy)
		sleep_chance += SLEEP_CHANCE_DROWSY //stack drowsy ontop of base or running odds with the += operator
	if(caffeinated)
		sleep_chance = sleep_chance / 2 //make it real hard to fall asleep on caffeine

	//if not drowsy, don't fall asleep but make them drowsy. this is unlike parent, but telegraphing a potential snooze is more fun for the player
	if(!drowsy && SPT_PROB(sleep_chance, seconds_per_tick))
		to_chat(owner, span_warning("You feel tired..."))
		owner.adjust_drowsiness(rand(30 SECONDS, 60 SECONDS))
	//if drowsy, fall asleep. you've had your chance to remedy it
	else if(drowsy && SPT_PROB(sleep_chance, seconds_per_tick))
		to_chat(owner, span_warning("You fall asleep."))
		owner.Sleeping(rand(20 SECONDS, 30 SECONDS))

#undef SLEEP_CHANCE
#undef SLEEP_CHANCE_RUNNING
#undef SLEEP_CHANCE_DROWSY
