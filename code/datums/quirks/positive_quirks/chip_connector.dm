/datum/quirk/chip_connector
	name = "Chip Connector"
	desc = "You had a device installed that lets you manually add and remove skillchips! Just try not to get near any electromagnetic pulses."
	icon = FA_ICON_PLUG
	value = 4
	gain_text = span_notice("You feel CONNECTED.")
	lose_text = span_danger("You don't feel so CONNECTED anymore.")
	medical_record_text = "Patient has a cybernetic implant on their back of their head that lets them install and remove skillchips at will. Gross."
	mail_goodies = list()
	var/obj/item/organ/cyberimp/brain/connector/connector

/datum/quirk/chip_connector/New()
	. = ..()
	mail_goodies = assoc_to_keys(GLOB.quirk_chipped_choice) + /datum/quirk/chipped::mail_goodies

/datum/quirk/chip_connector/add_unique(client/client_source)
	. = ..()
	var/mob/living/carbon/carbon_holder = quirk_holder
	if(!iscarbon(quirk_holder))
		return
	connector = new()
	connector.Insert(carbon_holder, special = TRUE)

/datum/quirk/chip_connector/post_add()
	to_chat(quirk_holder, span_boldannounce(desc)) // efficiency is clever laziness

/datum/quirk/chip_connector/remove()
	qdel(connector)
