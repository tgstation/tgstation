/datum/quirk/chipped
	name = "Chipped"
	desc = "You got caught up in the skillchip craze a few years back, and had one of the commercially available chips implanted into yourself."
	icon = FA_ICON_MICROCHIP
	value = 2
	gain_text = span_notice("The chip in your head itches a bit.")
	lose_text = span_danger("You don't feel so chipped anymore..")
	medical_record_text = "Patient explained how they got caught up in 'the skillchip chase' recently, and now the chip in their head itches every so often. Dumbass."
	mail_goodies = list(
		/obj/item/skillchip/matrix_taunt,
		/obj/item/skillchip/big_pointer,
		/obj/item/skillchip/acrobatics,
		/obj/item/storage/pill_bottle/mannitol/braintumor,
	)
	/// Variable that holds the chip, used on removal.
	var/obj/item/skillchip/installed_chip
	///itchy status effect we give our owner
	var/datum/itchy_effect

/datum/quirk_constant_data/chipped
	associated_typepath = /datum/quirk/chipped
	customization_options = list(/datum/preference/choiced/chipped)

/datum/quirk/chipped/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source, unique = TRUE, announce = FALSE)
	var/chip_pref = client_source?.prefs?.read_preference(/datum/preference/choiced/chipped)

	if(isnull(chip_pref))
		return ..()
	installed_chip = GLOB.quirk_chipped_choice[chip_pref] || GLOB.quirk_chipped_choice[pick(GLOB.quirk_chipped_choice)]
	gain_text = span_notice("The [installed_chip::name] in your head itches a bit.")
	lose_text = span_notice("Your head stops itching so much.")
	return ..()

/datum/quirk/chipped/add_unique(client/client_source)
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/quirk_holder_carbon = quirk_holder
	installed_chip = new installed_chip()

	RegisterSignals(installed_chip, list(COMSIG_QDELETING, COMSIG_SKILLCHIP_REMOVED), PROC_REF(remove_effect))
	RegisterSignal(installed_chip, COMSIG_SKILLCHIP_IMPLANTED, PROC_REF(apply_effect))

	quirk_holder_carbon.implant_skillchip(installed_chip, force = TRUE)
	installed_chip.try_activate_skillchip(silent = FALSE, force = TRUE)

/datum/quirk/chipped/proc/apply_effect(datum/source, obj/item/brain_applied)
	SIGNAL_HANDLER
	var/mob/living/carbon/quirk_holder_carbon = quirk_holder
	if(brain_applied == quirk_holder_carbon.get_organ_slot(ORGAN_SLOT_BRAIN))
		itchy_effect = quirk_holder.apply_status_effect(/datum/status_effect/itchy_skillchip_quirk)

/datum/quirk/chipped/proc/remove_effect(datum/source, obj/item/brain_removed)
	SIGNAL_HANDLER
	var/mob/living/carbon/quirk_holder_carbon = quirk_holder
	if(QDELING(source) || brain_removed == quirk_holder_carbon.get_organ_slot(ORGAN_SLOT_BRAIN))
		quirk_holder.remove_status_effect(itchy_effect)
		itchy_effect = null

/datum/quirk/chipped/remove()
	QDEL_NULL(installed_chip)
	if(itchy_effect)
		quirk_holder.remove_status_effect(itchy_effect)
		itchy_effect = null
	return ..()

/datum/status_effect/itchy_skillchip_quirk
	id = "itchy skillchip"
	tick_interval_lowerbound = 5 SECONDS
	tick_interval_upperbound = 10 MINUTES
	alert_type = null
	///lower damage we apply to our itchy owner
	var/minimum_damage = 1
	///upper damage we apply to our itchy owner
	var/maximum_damage = 5

/datum/status_effect/itchy_skillchip_quirk/tick(seconds_between_ticks)
	var/mob/living/carbon/carbon_owner = owner
	var/obj/item/organ/brain/itchy_brain = carbon_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(isnull(itchy_brain))
		return
	itchy_brain.apply_organ_damage(rand(minimum_damage, maximum_damage), maximum = itchy_brain.maxHealth * 0.3)
	if(owner.stat == CONSCIOUS && !owner.incapacitated && owner.get_empty_held_indexes())
		to_chat(owner, span_warning("You scratch the itch in your head."))
