/datum/quirk/chipped
	name = "Chipped"
	desc = "You got caught up in the skillchip craze a few years back, and had one of the commercially available chips implanted into yourself."
	icon = FA_ICON_MICROCHIP
	value = 2
	gain_text = span_notice("You suddenly feels chipped.")
	lose_text = span_danger("You don't feel so chipped anymore.")
	medical_record_text = "Patient explained how they got caught up in 'the skillchip chase' recently, and now they have some useless chip in their head. Dumbass."
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
	gain_text = span_notice("The [installed_chip::name] in your head buzzes with knowledge.")
	lose_text = span_notice("You stop feeling the chip inside your head.")
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
