/datum/quirk/chipped
	name = "Chipped"
	desc = "Несколько лет назад вы попали под влияние моды на чипы навыков и установили себе один из коммерчески доступных чипов."
	icon = FA_ICON_MICROCHIP
	value = 2
	gain_text = span_notice("Вы вдруг почувствовали, что стали чипированным.")
	lose_text = span_danger("Теперь вы больше не чувствуете себя чипированным.")
	medical_record_text = "Пациент объяснил, как попал под влияние повального увлечения чипами навыков, и теперь у него в голове оказался бесполезный чип. Тупица."
	mail_goodies = list(
		/obj/item/skillchip/matrix_taunt,
		/obj/item/skillchip/big_pointer,
		/obj/item/skillchip/acrobatics,
	)
	/// Variable that holds the chip, used on removal.
	var/obj/item/skillchip/installed_chip

/datum/quirk_constant_data/chipped
	associated_typepath = /datum/quirk/chipped
	customization_options = list(/datum/preference/choiced/chipped)

/datum/quirk/chipped/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source, unique = TRUE, announce = FALSE)
	var/chip_pref = client_source?.prefs?.read_preference(/datum/preference/choiced/chipped)

	if(isnull(chip_pref))
		return ..()
	installed_chip = GLOB.quirk_chipped_choice[chip_pref] || GLOB.quirk_chipped_choice[pick(GLOB.quirk_chipped_choice)]
	gain_text = span_notice("[installed_chip::name] наполняет вашу голову знанием.")
	lose_text = span_notice("Вы перестаёте ощущать чип внутри вашей головы.")
	return ..()

/datum/quirk/chipped/add_unique(client/client_source)
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/quirk_holder_carbon = quirk_holder
	installed_chip = new installed_chip()
	quirk_holder_carbon.implant_skillchip(installed_chip, force = TRUE)
	installed_chip.try_activate_skillchip(silent = FALSE, force = TRUE)

/datum/quirk/chipped/remove()
	QDEL_NULL(installed_chip)
	return ..()
