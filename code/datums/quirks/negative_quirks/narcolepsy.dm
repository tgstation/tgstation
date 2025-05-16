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
