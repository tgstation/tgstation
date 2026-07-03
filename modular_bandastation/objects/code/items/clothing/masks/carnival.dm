#define _COLOR_WHITE "#dddddd"
#define _COLOR_RUBY "#981724"
#define _COLOR_GOLD "#ffd700"

#define COLORS_2(x, y) x + y
#define COLORS_3(x, y, z) x + y + z

/obj/item/clothing/mask/carnival
	name = "carnival mask"
	icon = 'icons/map_icons/clothing/mask.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/mask/carnival.dmi'
	flags_inv = HIDEFACE

/obj/item/clothing/mask/carnival/feather
	name = "Jester mask"
	desc = "Изысканная маска с перьями для карнавалов и маскарадов. Неотъемлемый спутник королей."
	icon_state = "/obj/item/clothing/mask/carnival/feather"
	post_init_icon_state = "feather"
	greyscale_config = /datum/greyscale_config/carnival_mask_feather
	greyscale_config_worn = /datum/greyscale_config/carnival_mask_feather/worn
	greyscale_colors = COLORS_3(_COLOR_RUBY, _COLOR_WHITE, _COLOR_GOLD)
	flags_1 = IS_PLAYER_COLORABLE_1
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/carnival/half
	name = "Colombina mask"
	desc = "Изысканная полумаска для карнавалов и маскарадов. Для тех, кто не склонен прятать красоту лица."
	icon_state = "/obj/item/clothing/mask/carnival/half"
	post_init_icon_state = "half"
	greyscale_config = /datum/greyscale_config/carnival_mask_half
	greyscale_config_worn = /datum/greyscale_config/carnival_mask_half/worn
	greyscale_colors = COLORS_2(_COLOR_WHITE, _COLOR_GOLD)
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/mask/carnival/triangles
	name = "Harlequin mask"
	desc = "Изысканная маска с конусами и колокольчиками для карнавалов и маскарадов. Воплощение поединка с собой и со всем миром."
	icon_state = "/obj/item/clothing/mask/carnival/triangles"
	post_init_icon_state = "triangles"
	greyscale_config = /datum/greyscale_config/carnival_mask_triangles
	greyscale_config_worn = /datum/greyscale_config/carnival_mask_triangles/worn
	greyscale_colors = COLORS_3(_COLOR_WHITE, _COLOR_GOLD, _COLOR_RUBY)
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/mask/carnival/colored
	name = "Volto mask"
	desc = "Изысканная маска для карнавалов и маскарадов, покрывающая все лицо. Дуализм души и тела."
	icon_state = "/obj/item/clothing/mask/carnival/colored"
	post_init_icon_state = "colored"
	greyscale_config = /datum/greyscale_config/carnival_mask_colored
	greyscale_config_worn = /datum/greyscale_config/carnival_mask_colored/worn
	greyscale_colors = COLORS_2(_COLOR_GOLD, _COLOR_WHITE)
	flags_1 = IS_PLAYER_COLORABLE_1

#undef _COLOR_WHITE
#undef _COLOR_RUBY
#undef _COLOR_GOLD

#undef COLORS_2
#undef COLORS_3
