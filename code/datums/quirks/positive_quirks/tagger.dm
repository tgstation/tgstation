/datum/quirk/item_quirk/tagger
	name = "Tagger"
	desc = "Вы опытный художник. Люди будут впечатлены вашим граффити, а вы сможете использовать в два раза больше краски для рисования."
	icon = FA_ICON_SPRAY_CAN
	value = 4
	mob_trait = TRAIT_TAGGER
	gain_text = span_notice("Вы знаете, как эффективно и быстро размечать стены.")
	lose_text = span_danger("Вы забыли, как правильно размечать стены.")
	medical_record_text = "Пациент недавно был замечен в связи с возможным инцидентом ненадлежащего распыления краски."
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
	give_item_to_holder(can, list(LOCATION_BACKPACK, LOCATION_HANDS))
