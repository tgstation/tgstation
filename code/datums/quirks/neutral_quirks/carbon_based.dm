/datum/quirk/item_quirk/carbon_based
	name = "Carbon Based"
	desc = "Something about the way you think makes you completely incompatible with Man-Machine Interfaces."
	icon = FA_ICON_SEEDLING
	value = 0
	medical_record_text = "Patient's brain posesses a rare incompatibility with Man-Machine Interfaces."
	hardcore_value = 0
	quirk_flags = QUIRK_HUMAN_ONLY
	mail_goodies = list(/obj/item/toy/braintoy)

/datum/quirk/item_quirk/carbon_based/add(client/client_source)
	var/mob/living/carbon/carbon_holder = quirk_holder
	var/obj/item/organ/brain/quirk_holder_brain = carbon_holder.get_organ_slot(ORGAN_SLOT_BRAIN)
	quirk_holder_brain.no_mmi = TRUE

/datum/quirk/item_quirk/carbon_based/add_unique(client/client_source)
	var/obj/item/clothing/accessory/dogtag/borg_not_ready/dogtag = new(quirk_holder)
	give_item_to_holder(dogtag, list(LOCATION_BACKPACK, LOCATION_HANDS), notify_player = TRUE)

/datum/quirk/item_quirk/carbon_based/remove()
	var/mob/living/carbon/carbon_holder = quirk_holder
	var/obj/item/organ/brain/quirk_holder_brain = carbon_holder.get_organ_slot(ORGAN_SLOT_BRAIN)
	quirk_holder_brain.no_mmi = null
