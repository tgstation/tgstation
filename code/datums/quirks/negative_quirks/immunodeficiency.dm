/datum/quirk/item_quirk/immunodeficiency
	name = "Immunodeficiency"
	desc = "Будь то хроническое заболевание или генетическая случайность, ваше тело круглосуточно служит приютом для бактерий, вирусов и паразитов всех видов. Даже принимая назначенные препараты для повышения иммунитета, вы будете переносить инфекции хуже большинства других людей."
	icon = FA_ICON_MASK_FACE
	value = -10
	mob_trait = TRAIT_IMMUNODEFICIENCY
	gain_text = span_danger("Одна мысль о болезни вызывает у вас лихорадку.")
	lose_text = span_notice("Ваша иммунная система чудесным образом восстанавливает свою активность.")
	medical_record_text = "У пациента хронический иммунодефицит."
	mail_goodies = list(
		/obj/item/reagent_containers/syringe/antiviral,
		/obj/item/healthanalyzer/simple/disease
	)

/datum/quirk/item_quirk/immunodeficiency/add_unique(client/client_source)
	give_item_to_holder(
		/obj/item/clothing/mask/surgical,
		list(
			LOCATION_MASK,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		)
	)
	give_item_to_holder(
		/obj/item/storage/pill_bottle/immunodeficiency,
		list(
			LOCATION_LPOCKET,
			LOCATION_RPOCKET,
			LOCATION_BACKPACK,
			LOCATION_HANDS,
		)
	)
