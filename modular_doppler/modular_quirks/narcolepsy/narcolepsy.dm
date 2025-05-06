/datum/quirk/narcolepsy
	name = "Narcolepsy"
	desc = "You may fall asleep at any moment and feel tired often."
	icon = FA_ICON_CLOUD_MOON_RAIN
	value = -8
	hardcore_value = 8
	medical_record_text = "Patient may involuntarily fall asleep during normal activities."
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
	if(quirk_holder.equip_to_slot_if_possible(stimmies, ITEM_SLOT_BACKPACK, qdel_on_fail = TRUE, initial = TRUE, indirect_action = TRUE))
		to_chat(quirk_holder, span_info("You have been given a bottle of mild stimulants to assist in staying awake this shift..."))

/datum/quirk/narcolepsy/remove()
	. = ..()
	var/mob/living/carbon/human/user = quirk_holder
	user?.cure_trauma_type(/datum/brain_trauma/severe/narcolepsy/permanent, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/brain_trauma/severe/narcolepsy/permanent
	scan_desc = "narcolepsy"

//similar to parent but slower
/datum/brain_trauma/severe/narcolepsy/permanent/on_life(seconds_per_tick, times_fired)
	if(owner.IsSleeping())
		return
	if(owner.reagents.has_reagent(/datum/reagent/medicine/modafinil))
		return //stimulant which already blocks sleeping
	if(owner.reagents.has_reagent(/datum/reagent/medicine/synaptizine))
		return //mild stimulant easily made in chemistry

	var/sleep_chance = 0.333 //3
	var/drowsy = !!owner.has_status_effect(/datum/status_effect/drowsiness)
	var/caffeinated = HAS_TRAIT(owner, TRAIT_STIMULATED)
	if(drowsy)
		sleep_chance = 1
	if(caffeinated) //make it real hard to fall asleep on caffeine
		sleep_chance = sleep_chance / 2

	if(!drowsy && SPT_PROB(sleep_chance, seconds_per_tick))
		to_chat(owner, span_warning("You feel tired..."))
		owner.adjust_drowsiness(rand(30 SECONDS, 60 SECONDS))

	else if(drowsy && SPT_PROB(sleep_chance, seconds_per_tick))
		to_chat(owner, span_warning("You fall asleep."))
		owner.Sleeping(rand(20 SECONDS, 30 SECONDS))

/obj/item/storage/pill_bottle/prescription_stimulant
	name = "bottle of prescribed stimulant pills"
	desc = "A bottle of mild and medicinally approved stimulants to help prevent drowsiness."
	spawn_type = /obj/item/reagent_containers/applicator/pill/prescription_stimulant

/obj/item/reagent_containers/applicator/pill/prescription_stimulant
	name = "prescription stimulant pill"
	desc = "Used to treat symptoms of drowsiness and sudden loss of consciousness. A warning label reads: <b>Take in moderation</b>."
	list_reagents = list(/datum/reagent/consumable/sugar = 5, /datum/reagent/medicine/synaptizine = 5, /datum/reagent/medicine/modafinil = 3)
	icon_state = "pill15"
