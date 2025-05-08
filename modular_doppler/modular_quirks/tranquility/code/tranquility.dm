/datum/quirk/tranquil
	name = "Tranquil"
	desc = "Whether by choice, or as modern punishment from even the 4CA, you had a chip installed to prevent any direct acts of violence. It cannot be removed, asides from intensive surgeries."
	gain_text = span_warning("You couldn't fathom hurting people so freely and easily.")
	lose_text = span_notice("At last, violence has arrived.")
	medical_record_text = "Patient has had a Tranquility chip installed, preventing direct acts of violence. Do not attempt removal."
	value = -10
	icon = FA_ICON_FACE_SMILE
	quirk_flags = QUIRK_HUMAN_ONLY
	/// Variable that holds the chip, used on removal.
	var/obj/item/skillchip/installed_chip

/datum/quirk/tranquil/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source, unique)
	installed_chip = /obj/item/skillchip/pacification/unremovable
	return ..()

/datum/quirk/tranquil/add_unique(client/client_source)
	if(!iscarbon(quirk_holder))
		return

	var/mob/living/carbon/quirk_holder_carbon = quirk_holder
	installed_chip = new installed_chip()

	quirk_holder_carbon.implant_skillchip(installed_chip, force = TRUE)
	installed_chip.try_activate_skillchip(silent = FALSE, force = TRUE)

/datum/quirk/tranquil/remove()
	QDEL_NULL(installed_chip)
	return ..()

/obj/item/skillchip/pacification
	name = "MED-AS skillchip"
	desc = "Meditative Assistance chip. These are used by modern societies to assist violent individuals, or by those who wish to avoid violent lifestyles."
	auto_traits = list(TRAIT_PACIFISM)
	skill_name = "Tranquility"
	skill_description = "Live a quiet life unmarred by blood. Avoid ending the life of even the smallest creatures."
	skill_icon = "fa-peace"
	activate_message = span_notice("You have no enemies.")
	deactivate_message = span_notice("You hope you are forgiven for the violence you may inflict.")

/obj/item/skillchip/pacification/unremovable
	name = "TRNQ lockchip"
	desc = "Tranquility lockchip. These are used by modern societies to punish violent individuals, or occasionally used illegally. These do not have a standard interface for chip connectors or Skillsoft stations."
	can_be_removed = FALSE
	can_be_deactivated = FALSE

/datum/design/pacification_chip
	name = "MED-AS skillchip"
	desc = "Meditative Assistance chip. These are used by modern societies to assist violent individuals, or by those who wish to avoid violent lifestyles."
	id = "pacification_chip"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/skillchip/pacification
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_MEDICAL

/datum/design/pacification_lockchip
	name = "TNRQ lockchip"
	desc = "Tranquility lockchip. These are used by modern societies to punish violent individuals, or occasionally used illegally. These do not have a standard interface for chip connectors or Skillsoft stations."
	id = "pacification_lockchip"
	build_type = PROTOLATHE | AWAY_LATHE
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 7,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 8,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT * 2,
	)
	build_path = /obj/item/skillchip/pacification
	category = list(
		RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_SECURITY | DEPARTMENT_BITFLAG_MEDICAL
