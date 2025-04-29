/datum/quirk/item_quirk/immunodeficiency
	name = "Immunodeficiency"
	desc = "Whiether by chronic illness or genetic happenstance, your body is a 24/7 Bed and Breakfast for bacteria, viruses, and parasites of all kinds. Even with your prescribed immunity boosters, you'll fare worse than most others."
	icon = FA_ICON_MASK_FACE
	value = -10
	mob_trait = TRAIT_IMMUNODEFICIENCY
	gain_text = span_danger("Just the thought of illness makes you feverish.")
	lose_text = span_notice("Your immune system miraculously reasserts itself.")
	medical_record_text = "Patient is afflicted with chronic immunodeficiency."
	mail_goodies = list(
		/obj/item/reagent_containers/syringe/antiviral,
		/obj/item/healthanalyzer/simple/disease
	)

/datum/quirk/item_quirk/immunodeficiency/add_unique(client/client_source)
	var/obj/item/clothing/mask/surgical/ppe = new
	give_item_to_holder(ppe, list(LOCATION_MASK = ITEM_SLOT_MASK, LOCATION_BACKPACK = ITEM_SLOT_BACKPACK, LOCATION_HANDS = ITEM_SLOT_HANDS))
	give_item_to_holder(
		/obj/item/storage/pill_bottle/immunodeficiency,
		list(
			LOCATION_LPOCKET = ITEM_SLOT_LPOCKET,
			LOCATION_RPOCKET = ITEM_SLOT_RPOCKET,
			LOCATION_BACKPACK = ITEM_SLOT_BACKPACK,
			LOCATION_HANDS = ITEM_SLOT_HANDS,
		)
	)
