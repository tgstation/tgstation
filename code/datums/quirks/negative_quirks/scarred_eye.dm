/datum/quirk/item_quirk/scarred_eye
	name = "Scarred Eye"
	desc = "An accident in your past has cost you one of your eyes, but you spawn with an eyepatch. Yarr!"
	icon = FA_ICON_EYE_SLASH
	value = -2
	gain_text = span_danger("After all this time, your eye still stings a bit...")
	lose_text = span_notice("Your peripherial vision grows by about thirty percent.")
	medical_record_text = "Patient has severe scarring on one of their eyes, resulting in partial vision loss."
	hardcore_value = 2
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/reagent_containers/cup/glass/bottle/rum, /obj/item/clothing/mask/bandana/red)

/datum/quirk_constant_data/eye_scarring
	associated_typepath = /datum/quirk/item_quirk/scarred_eye
	customization_options = list(/datum/preference/choiced/scarred_eye)

/datum/quirk/item_quirk/scarred_eye/add_unique(client/client_source)
	if (client_source?.prefs.read_preference(/datum/preference/choiced/scarred_eye) == "Double")
		give_item_to_holder(new /obj/item/clothing/glasses/blindfold/white(get_turf(quirk_holder)), list(
			LOCATION_EYES = ITEM_SLOT_EYES,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		))
		return

	var/obj/item/clothing/glasses/eyepatch/eyepatch = new(get_turf(quirk_holder))
	if (HAS_TRAIT(quirk_holder, TRAIT_LEFT_EYE_SCAR))
		eyepatch.attack_self(quirk_holder)
	give_item_to_holder(eyepatch, list(
		LOCATION_EYES = ITEM_SLOT_EYES,
		LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
		LOCATION_HANDS = ITEM_SLOT_HANDS,
	))

/datum/quirk/item_quirk/scarred_eye/add(client/client_source)
	var/mob/living/carbon/human/human_owner = quirk_holder
	var/obj/item/organ/internal/eyes/eyes = human_owner.get_organ_slot(ORGAN_SLOT_EYES)
	if (isnull(eyes))
		return

	var/eye_side = client_source?.prefs.read_preference(/datum/preference/choiced/scarred_eye) || "Random"

	if (eye_side == "Double")
		eyes.AddElement(/datum/element/eye_scar, TRUE)
		eyes.AddElement(/datum/element/eye_scar, FALSE)
		return

	switch (eye_side)
		if ("Random")
			eye_side = pick(TRUE, FALSE)
		if ("Right Eye")
			eye_side = TRUE
		if ("Left Eye")
			eye_side = FALSE
	eyes.AddElement(/datum/element/eye_scar, eye_side)

/datum/quirk/item_quirk/scarred_eye/remove()
	var/mob/living/carbon/human/human_owner = quirk_holder
	var/obj/item/organ/internal/eyes/eyes = human_owner.get_organ_slot(ORGAN_SLOT_EYES)
	if (!isnull(eyes))
		eyes.RemoveElement(/datum/element/eye_scar)
