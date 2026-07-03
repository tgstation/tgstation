/datum/quirk/strong_stomach
	name = "Strong Stomach"
	desc = "Вы можете есть еду находящуюся на земле без последствий в виде болезни, а рвота влияет на вас меньше."
	icon = FA_ICON_FACE_GRIN_BEAM_SWEAT
	value = 4
	mob_trait = TRAIT_STRONG_STOMACH
	gain_text = span_notice("Ты чувствуешь, что можешь съесть всё, что угодно!")
	lose_text = span_danger("Смотря на еду на земле, тебя начинает немного подташнивать.")
	medical_record_text = "У пациента иммунная система организма сильнее, чем среднестатическая...  К пищевому отравлению, по крайней мере."
	mail_goodies = list(
		/obj/item/reagent_containers/applicator/pill/ondansetron,
	)
