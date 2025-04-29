/datum/quirk/item_quirk/immunodeficiency
	name = "Immunodeficiency"
	desc = "Whiether by chronic illness or genetic happenstance, your body is a 24/7 Bed and Breakfast for bacteria, viruses, and parasites of all kinds. Even with your prescribed immunity boosters, you'll fare worse than most others."
	icon = FA_ICON_SPRAY_CAN
	value = -8
	mob_trait = TRAIT_IMMUNODEFICIENCY
	gain_text = span_danger("Just the thought of illness makes you feverish.")
	lose_text = span_notice("Your immune system miraculously reasserts itself.")
	medical_record_text = "Patient is afflicted with chronic immunodeficiency."
	mail_goodies = list(
		/obj/item/reagent_containers/syringe/antiviral,
		/obj/item/canvas/nineteen_nineteen,
		/obj/item/canvas/twentythree_nineteen
	)

/datum/quirk_constant_data/tagger
	associated_typepath = /datum/quirk/item_quirk/tagger
	customization_options = list(/datum/preference/color/paint_color)

/datum/quirk/item_quirk/tagger/add_unique(client/client_source)
	var/obj/item/toy/crayon/spraycan/can = new
	can.set_painting_tool_color(client_source?.prefs.read_preference(/datum/preference/color/paint_color))
	give_item_to_holder(can, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
