/datum/quirk/item_quirk/narcolepsy
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

/datum/quirk/item_quirk/narcolepsy/add_unique(client/client_source)
	var/mob/living/carbon/carbon_user = quirk_holder
	carbon_user.gain_trauma(/datum/brain_trauma/severe/narcolepsy/permanent, TRAUMA_RESILIENCE_ABSOLUTE)

	give_item_to_holder(
		/obj/item/storage/pill_bottle/prescription_stimulant,
		list(
			LOCATION_BACKPACK,
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_HANDS,
		),
		flavour_text = "Given to you to aid in staying awake this shift...",
		notify_player = TRUE,
	)

/datum/quirk/item_quirk/narcolepsy/remove()
	if(!QDELETED(quirk_holder) && quirk_holder.get_organ_by_type(/obj/item/organ/brain))
		var/mob/living/carbon/carbon_user = quirk_holder
		carbon_user?.cure_trauma_type(/datum/brain_trauma/severe/narcolepsy/permanent, TRAUMA_RESILIENCE_ABSOLUTE)
