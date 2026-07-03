/datum/quirk/item_quirk/scarred_eye
	name = "Scarred Eye"
	desc = "В результате несчастного случая вы лишились одного глаза, зато теперь у вас крутая пиратская повязка. Йо-хо-хо!"
	icon = FA_ICON_EYE_SLASH
	value = -2
	gain_text = span_danger("Спустя столько времени ваш глаз всё ещё немного покалывает...")
	lose_text = span_notice("Ваше периферическое зрение расширяется примерно на тридцать процентов.")
	medical_record_text = "У пациента имеются серьезные рубцы на одном глазу, что привело к частичной потере зрения."
	hardcore_value = 2
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/reagent_containers/cup/glass/bottle/rum, /obj/item/clothing/mask/bandana/red)

/datum/quirk_constant_data/eye_scarring
	associated_typepath = /datum/quirk/item_quirk/scarred_eye
	customization_options = list(/datum/preference/choiced/scarred_eye)

/datum/quirk/item_quirk/scarred_eye/add_unique(client/client_source)
	if (client_source?.prefs.read_preference(/datum/preference/choiced/scarred_eye) == "Double")
		give_item_to_holder(new /obj/item/clothing/glasses/blindfold/white(get_turf(quirk_holder)), list(
			LOCATION_EYES,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		))
		return

	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/clothing/glasses/eyepatch/eyepatch = new(get_turf(quirk_holder))
	if (human_holder.get_eye_scars() & LEFT_EYE_SCAR)
		eyepatch.flip_eyepatch()
	give_item_to_holder(eyepatch, list(
		LOCATION_EYES,
		LOCATION_BACKPACK,
		LOCATION_HANDS,
	))

/datum/quirk/item_quirk/scarred_eye/add(client/client_source)
	var/mob/living/carbon/human/human_owner = quirk_holder
	var/obj/item/organ/eyes/eyes = human_owner.get_organ_slot(ORGAN_SLOT_EYES)
	if (isnull(eyes))
		return

	var/eye_side = client_source?.prefs.read_preference(/datum/preference/choiced/scarred_eye) || "Random"

	if (eye_side == "Double")
		eyes.apply_scar(RIGHT_EYE_SCAR)
		eyes.apply_scar(LEFT_EYE_SCAR)
		return

	switch (eye_side)
		if ("Random")
			eye_side = pick(RIGHT_EYE_SCAR, LEFT_EYE_SCAR)
		if ("Right Eye")
			eye_side = RIGHT_EYE_SCAR
		if ("Left Eye")
			eye_side = LEFT_EYE_SCAR
	eyes.apply_scar(eye_side)

/datum/quirk/item_quirk/scarred_eye/remove()
	var/mob/living/carbon/human/human_owner = quirk_holder
	var/obj/item/organ/eyes/eyes = human_owner.get_organ_slot(ORGAN_SLOT_EYES)
	if (!isnull(eyes))
		eyes.fix_scar(RIGHT_EYE_SCAR)
		eyes.fix_scar(LEFT_EYE_SCAR)
