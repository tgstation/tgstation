/datum/quirk/chipped
	name = "Chipped"
	desc = "You got caught up in the skillchip craze a few years back, and had one of the commercially available chips implanted into yourself."
	icon = FA_ICON_MICROCHIP
	value = 2
	gain_text = span_notice("The chip in your head itches a bit.")
	lose_text = span_danger("You don't feel so chipped anymore..")
	medical_record_text = "Patient explained how they got caught up in 'the skillchip chase' recently, and now the chip in they head itches every so often. Dumbass."
	mail_goodies = list(
		/obj/item/skillchip/matrix_taunt,
		/obj/item/skillchip/big_pointer,
		/obj/item/skillchip/acrobatics,
		/obj/item/storage/pill_bottle/mannitol/braintumor,
	)
	/// Variable that holds the chip, used on removal.
	var/obj/item/skillchip/installed_chip
	var/datum/callback/itchy_timer

/datum/quirk_constant_data/chipped
	associated_typepath = /datum/quirk/chipped
	customization_options = list(/datum/preference/choiced/chipped)

/datum/quirk/chipped/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source)
	var/obj/item/skillchip/chip_pref = GLOB.quirk_chipped_choice[client_source?.prefs?.read_preference(/datum/preference/choiced/chipped)]

	if(!chip_pref)
		return ..()

	gain_text = span_notice("The [chip_pref] in your head itches a bit.")
	lose_text = span_notice("Your head stops itching so much.")
	return ..()

/datum/quirk/chipped/add_unique(client/client_source)

	var/preferred_chip = GLOB.quirk_chipped_choice[client_source?.prefs?.read_preference(/datum/preference/choiced/chipped)]
	if(isnull(preferred_chip))  //Client is gone or they chose a random chip
		preferred_chip = GLOB.quirk_chipped_choice[pick(GLOB.quirk_chipped_choice)]

	var/mob/living/carbon/quirk_holder_carbon = quirk_holder
	if(iscarbon(quirk_holder))
		installed_chip = new preferred_chip()
		quirk_holder_carbon.implant_skillchip(installed_chip, force = TRUE)
	installed_chip.try_activate_skillchip(silent = FALSE, force = TRUE)

	var/obj/item/organ/brain/itchy_brain = quirk_holder.get_organ_by_type(ORGAN_SLOT_BRAIN)
	itchy_timer = addtimer(CALLBACK(src, PROC_REF(cause_itchy), itchy_brain), rand(5 SECONDS, 10 MINUTES)) // they get The Itch from a poor quality install every so often

/datum/quirk/chipped/remove()
	qdel(installed_chip)
	deltimer(itchy_timer)
	. = ..()

/datum/quirk/chipped/proc/cause_itchy(obj/item/organ/brain/itchy_brain)

	itchy_brain.apply_organ_damage(rand(1, 5), maximum = itchy_brain.maxHealth * 0.3)
	to_chat(itchy_brain.owner, span_warning("Your [itchy_brain] itches."))
	itchy_timer = addtimer(CALLBACK(itchy_brain, PROC_REF(cause_itchy)), rand(5 SECONDS, 10 MINUTES)) // it will never end
