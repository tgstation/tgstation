/datum/loadout_category/suits
	category_name = "Верхняя одежда"
	category_ui_icon = FA_ICON_VEST
	type_to_generate = /datum/loadout_item/suits

/datum/loadout_item/suits
	abstract_type = /datum/loadout_item/suits

/datum/loadout_item/suits/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.suit)
		LAZYADD(outfit.backpack_contents, outfit.suit)

	if(outfit.suit_store)
		if(outfit.suit_store::w_class <= WEIGHT_CLASS_NORMAL)
			LAZYADD(outfit.backpack_contents, outfit.suit_store)
		else if((!outfit.belt || (outfit.belt::w_class <= WEIGHT_CLASS_NORMAL)) && (outfit.suit_store::slot_flags & ITEM_SLOT_BELT))
			if(outfit.belt)
				LAZYADD(outfit.backpack_contents, outfit.belt)
			outfit.belt = outfit.suit_store
		else if(!outfit.r_hand)
			outfit.r_hand = outfit.suit_store
		else if(!outfit.l_hand)
			outfit.l_hand = outfit.suit_store

		outfit.suit_store = null

	outfit.suit = item_path

// MARK: Tier 0
/datum/loadout_item/suits/wintercoat
	name = "Зимняя"
	item_path = /obj/item/clothing/suit/hooded/wintercoat

/datum/loadout_item/suits/jacket_letterman
	name = "Курьерская"
	item_path = /obj/item/clothing/suit/jacket/letterman

/datum/loadout_item/suits/miljacket
	name = "Военная"
	item_path = /obj/item/clothing/suit/jacket/miljacket

/datum/loadout_item/suits/leather
	name = "Кожанная"
	item_path = /obj/item/clothing/suit/jacket/leather

/datum/loadout_item/suits/leather_biker
	name = "Байкерская"
	item_path = /obj/item/clothing/suit/jacket/leather/biker

/datum/loadout_item/suits/bomber
	name = "Бомбер"
	item_path = /obj/item/clothing/suit/jacket/bomber

/datum/loadout_item/suits/oversized
	name = "Оверсайз"
	item_path = /obj/item/clothing/suit/jacket/oversized

/datum/loadout_item/suits/sweater
	name = "Свитер"
	item_path = /obj/item/clothing/suit/toggle/jacket/sweater

/datum/loadout_item/suits/trenchcoat
	name = "Тренч"
	item_path = /obj/item/clothing/suit/toggle/jacket/trenchcoat

/datum/loadout_item/suits/blazer
	name = "Блейзер"
	item_path = /obj/item/clothing/suit/jacket/blazer

/datum/loadout_item/suits/lawyer
	name = "Формальный пиджак"
	item_path = /obj/item/clothing/suit/toggle/lawyer/greyscale

/datum/loadout_item/suits/hawaiian
	name = "Гавайская рубашка"
	item_path = /obj/item/clothing/suit/costume/hawaiian

/datum/loadout_item/suits/fancy
	name = "Меховое пальто"
	item_path = /obj/item/clothing/suit/jacket/fancy

/datum/loadout_item/suits/overalls
	name = "Комбинезон"
	item_path = /obj/item/clothing/suit/apron/overalls

/datum/loadout_item/suits/suspenders
	name = "Подтяжки"
	item_path = /obj/item/clothing/suit/toggle/suspenders

/datum/loadout_item/suits/yuri
	name = "Пальто посвященного юри"
	item_path = /obj/item/clothing/suit/costume/yuri

/datum/loadout_item/suits/deckers
	name = "Худи Декер"
	item_path = /obj/item/clothing/suit/costume/deckers

/datum/loadout_item/suits/pg
	name = "Куртка гангстера"
	item_path = /obj/item/clothing/suit/costume/pg

/datum/loadout_item/suits/tmc
	name = "Куртка байкера"
	item_path = /obj/item/clothing/suit/costume/tmc

/datum/loadout_item/suits/ethereal_raincoat
	name = "Эфириальный дождевик"
	item_path = /obj/item/clothing/suit/hooded/ethereal_raincoat

/datum/loadout_item/suits/irs
	name = "Куртка налоговой службы"
	item_path = /obj/item/clothing/suit/costume/irs

/datum/loadout_item/suits/letterman_red
	name = "Красная куртка лейтенанта"
	item_path = /obj/item/clothing/suit/jacket/letterman_red

/datum/loadout_item/suits/soviet
	name = "Советское пальто"
	item_path = /obj/item/clothing/suit/costume/soviet

/datum/loadout_item/suits/mothcoat
	name = "Молиный лётный костюм"
	item_path = /obj/item/clothing/suit/mothcoat

/datum/loadout_item/suits/wintercoat
	name = "Зимнее пальто"
	item_path = /obj/item/clothing/suit/hooded/wintercoat

// MARK: Tier 1
/datum/loadout_item/suits/soundhand_white_jacket
	name = "Саундхэнд (Белая)"
	item_path = /obj/item/clothing/suit/soundhand_white_jacket/tag
	donator_level = DONATOR_TIER_1

/datum/loadout_item/suits/soundhand_black_jacket
	name = "Саундхэнд (Чёрная)"
	item_path = /obj/item/clothing/suit/soundhand_black_jacket/tag
	donator_level = DONATOR_TIER_1

/datum/loadout_item/suits/soundhand_olive_jacket
	name = "Саундхэнд (Оливковая)"
	item_path = /obj/item/clothing/suit/soundhand_olive_jacket/tag
	donator_level = DONATOR_TIER_1

/datum/loadout_item/suits/soundhand_brown_jacket
	name = "Саундхэнд (Коричневая)"
	item_path = /obj/item/clothing/suit/soundhand_brown_jacket/tag
	donator_level = DONATOR_TIER_1

/datum/loadout_item/suits/etamin_jacket
	name = "Кожаная куртка Etamin Industries"
	item_path = /obj/item/clothing/suit/toggle/etamin_jacket
	donator_level = DONATOR_TIER_1

// MARK: Tier 2
/datum/loadout_item/suits/shark_suit
	name = "Костюм акулы"
	item_path = /obj/item/clothing/suit/hooded/shark_costume
	donator_level = DONATOR_TIER_2

/datum/loadout_item/suits/shark_light_suit
	name = "Костюм акулы (светло-голубой)"
	item_path = /obj/item/clothing/suit/hooded/shark_costume/light
	donator_level = DONATOR_TIER_2

// MARK: Tier 3
/datum/loadout_item/suits/v_jacket
	name = "Куртка V"
	item_path = /obj/item/clothing/suit/v_jacket
	donator_level = DONATOR_TIER_3

/datum/loadout_item/suits/takemura_jacket
	name = "Куртка Такэмуры"
	item_path = /obj/item/clothing/suit/takemura_jacket
	donator_level = DONATOR_TIER_3

/datum/loadout_item/suits/v_jacket
	name = "Куртка Вай"
	item_path = /obj/item/clothing/suit/hooded/vi_arcane
	donator_level = DONATOR_TIER_3

/datum/loadout_item/suits/etamin_cloak
	name = "Плащ Etamin Industries"
	item_path = /obj/item/clothing/suit/hooded/etamin_cloak
	donator_level = DONATOR_TIER_3

// MARK: Tier 4
/datum/loadout_item/suits/katarina_jacket
	name = "Куртка Катарины"
	item_path = /obj/item/clothing/suit/katarina_jacket
	donator_level = DONATOR_TIER_4

/datum/loadout_item/suits/katarina_cyberjacket
	name = "Кибер-куртка Катарины"
	item_path = /obj/item/clothing/suit/katarina_cyberjacket
	donator_level = DONATOR_TIER_4

// MARK: Tier 5
/datum/loadout_item/suits/soundhand_white_jacket
	name = "Серебристая куртка Арии"
	item_path = /obj/item/clothing/suit/soundhand_white_jacket/tag
	donator_level = DONATOR_TIER_5

/datum/loadout_item/suits/etamin_coat
	name = "Офицерский плащ Etamin Industries"
	item_path = /obj/item/clothing/suit/etamin_coat
	donator_level = DONATOR_TIER_5

