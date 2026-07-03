/datum/loadout_category/gloves
	category_name = "Руки"
	category_ui_icon = FA_ICON_HANDS
	type_to_generate = /datum/loadout_item/gloves

/datum/loadout_item/gloves
	abstract_type = /datum/loadout_item/gloves

/datum/loadout_item/gloves/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.gloves)
		LAZYADD(outfit.backpack_contents, outfit.gloves)
	outfit.gloves = item_path

// MARK: Tier 0
/datum/loadout_item/gloves/gloves_black
	name = "Черные перчатки"
	item_path = /obj/item/clothing/gloves/color/black

/datum/loadout_item/gloves/gloves_orange
	name = "Оранжевые перчатки"
	item_path = /obj/item/clothing/gloves/color/orange

/datum/loadout_item/gloves/gloves_red
	name = "Красные перчатки"
	item_path = /obj/item/clothing/gloves/color/red

/datum/loadout_item/gloves/gloves_blue
	name = "Синие перчатки"
	item_path = /obj/item/clothing/gloves/color/blue

/datum/loadout_item/gloves/gloves_purple
	name = "Фиолетовые перчатки"
	item_path = /obj/item/clothing/gloves/color/purple

/datum/loadout_item/gloves/gloves_green
	name = "Зеленые перчатки"
	item_path = /obj/item/clothing/gloves/color/green

/datum/loadout_item/gloves/gloves_grey
	name = "Серые перчатки"
	item_path = /obj/item/clothing/gloves/color/grey

/datum/loadout_item/gloves/gloves_light_brown
	name = "Светло-коричневые перчатки"
	item_path = /obj/item/clothing/gloves/color/light_brown

/datum/loadout_item/gloves/gloves_brown
	name = "Коричневые перчатки"
	item_path = /obj/item/clothing/gloves/color/brown

/datum/loadout_item/gloves/gloves_white
	name = "Белые перчатки"
	item_path = /obj/item/clothing/gloves/color/white

/datum/loadout_item/gloves/gloves_fingerless
	name = "Перчатки без пальцев"
	item_path = /obj/item/clothing/gloves/fingerless

// MARK: Tier 2
/datum/loadout_item/pocket_items/ringbox_silver
	name = "Коробочка с серебряным кольцом"
	item_path = /obj/item/storage/fancy/ringbox/silver
	donator_level = DONATOR_TIER_2

/datum/loadout_item/pocket_items/ringbox_gold
	name = "Коробочка с золотым кольцом"
	item_path = /obj/item/storage/fancy/ringbox
	donator_level = DONATOR_TIER_2

// MARK: Tier 4
/datum/loadout_item/pocket_items/ringbox_diamond
	name = "Коробочка с кольцом с бриллиантом"
	item_path = /obj/item/storage/fancy/ringbox/diamond
	donator_level = DONATOR_TIER_4

// MARK: Tier 1
/datum/loadout_item/gloves/biker_gloves
	name = "Байкерские перчатки"
	item_path = /obj/item/clothing/gloves/fingerless/biker_gloves
	donator_level = DONATOR_TIER_1

/datum/loadout_item/gloves/etamin_gloves
	name = "Перчатки Etamin Industries"
	item_path = /obj/item/clothing/gloves/etamin_gloves
	donator_level = DONATOR_TIER_1

// MARK: Tier 2
/datum/loadout_item/gloves/gloves_rainbow
	name = "Радужные перчатки"
	item_path = /obj/item/clothing/gloves/color/rainbow
	donator_level = DONATOR_TIER_2
