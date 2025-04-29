/datum/quirk/item_quirk/immunodeficiency
	name = "Immunodeficiency"
	desc = "Wheither by chronic illness or genetic happenstance, your body is a 24/7 Bed and Breakfast for bacteria, viruses, and parasites of all kinds. Even with your prescribed immunity boosters, you'll be worse off than most others."
	icon = FA_ICON_SPRAY_CAN
	value = 4
	mob_trait = TRAIT_TAGGER
	gain_text = span_notice("You know how to tag walls efficiently and quickly.")
	lose_text = span_danger("You forget how to tag walls properly.")
	medical_record_text = "Patient was recently seen for possible paint huffing incident."
	mail_goodies = list(
		/obj/item/toy/crayon/spraycan,
		/obj/item/canvas/nineteen_nineteen,
		/obj/item/canvas/twentythree_nineteen,
		/obj/item/canvas/twentythree_twentythree
	)

/datum/quirk_constant_data/tagger
	associated_typepath = /datum/quirk/item_quirk/tagger
	customization_options = list(/datum/preference/color/paint_color)

/datum/quirk/item_quirk/tagger/add_unique(client/client_source)
	var/obj/item/toy/crayon/spraycan/can = new
	can.set_painting_tool_color(client_source?.prefs.read_preference(/datum/preference/color/paint_color))
	give_item_to_holder(can, list(LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
