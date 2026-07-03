#define _COLOR_WHITE "#dddddd"
#define _COLOR_BLACK "#242424"

#define COLORS_2(x, y) x + y
#define COLORS_3(x, y, z) x + y + z

/obj/item/clothing/under/carnival
	icon = 'icons/map_icons/clothing/under/_under.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/under/carnival.dmi'
	can_adjust = FALSE

/obj/item/clothing/under/carnival/formal
	name = "formal suit"
	desc = "Костюм приятного качества из рубашки и брюк."
	icon_state = "/obj/item/clothing/under/carnival/formal"
	post_init_icon_state = "formal"
	greyscale_config = /datum/greyscale_config/carnival_formal
	greyscale_config_worn = /datum/greyscale_config/carnival_formal/worn
	greyscale_colors = COLORS_2(_COLOR_BLACK, _COLOR_WHITE)
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/carnival/jacket
	name = "jacket suit"
	desc = "Практичный костюм для торжественных вечеринок с жилетом."
	icon_state = "/obj/item/clothing/under/carnival/jacket"
	post_init_icon_state = "jacket"
	greyscale_config = /datum/greyscale_config/carnival_jacket
	greyscale_config_worn = /datum/greyscale_config/carnival_jacket/worn
	greyscale_colors = COLORS_2(_COLOR_BLACK, _COLOR_WHITE)
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/carnival/dress_fancy
	name = "luxurious dress"
	desc = "Бальное платье, пошитое в викторианском стиле."
	icon_state = "/obj/item/clothing/under/carnival/dress_fancy"
	post_init_icon_state = "dress_fancy"
	greyscale_config = /datum/greyscale_config/carnival_dress_fancy
	greyscale_config_worn = /datum/greyscale_config/carnival_dress_fancy/worn
	greyscale_colors = COLORS_3(_COLOR_BLACK, _COLOR_BLACK, _COLOR_WHITE)
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/carnival/dress_corset
	name = "corset dress"
	desc = "Платье с корсетом, пошитое в викторианском стиле."
	icon_state = "/obj/item/clothing/under/carnival/dress_corset"
	post_init_icon_state = "dress_corset"
	greyscale_config = /datum/greyscale_config/carnival_dress_corset
	greyscale_config_worn = /datum/greyscale_config/carnival_dress_corset/worn
	greyscale_colors = COLORS_2(_COLOR_BLACK, _COLOR_WHITE)
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/carnival/dress_mel
	name = "Wolf's dress"
	desc = "Платье, выполненное в особом стиле и пошитое неизвестной, но явно престижной компанией. \
		Скорее всего такой наряд могут позволить себе единицы ввиду ограниченного тиража."
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/carnival.dmi'
	icon_state = "dress_mel"

/obj/item/clothing/under/carnival/silco
	name = "Industrialist's suit"
	desc = "Костюм, вышитый золотом. На бирке виднеется надпись - \"чтобы править - вселяй страх\"."
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/carnival.dmi'
	icon_state = "silco"

/obj/item/clothing/under/carnival/kim
	name = "Kitsuragi's suit"
	desc = "Явно одежда какого-то полицейского..."
	icon = 'modular_bandastation/objects/icons/obj/clothing/under/carnival.dmi'
	icon_state = "kim"

#undef _COLOR_WHITE
#undef _COLOR_BLACK

#undef COLORS_2
#undef COLORS_3
