/obj/item/clothing/under/dress
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	icon = 'icons/obj/clothing/under/dress.dmi'
	worn_icon = 'icons/mob/clothing/under/dress.dmi'

/obj/item/clothing/under/dress/striped/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/gags_recolorable)
	update_icon(UPDATE_OVERLAYS)

/obj/item/clothing/under/dress/striped
	name = "striped dress"
	desc = "Fashion in space."
	inhand_icon_state = null
	female_sprite_flags = FEMALE_UNIFORM_FULL
	icon = 'icons/map_icons/clothing/under/dress.dmi'
	icon_state = "/obj/item/clothing/under/dress/striped"
	post_init_icon_state = "stripeddress"
	greyscale_config = /datum/greyscale_config/striped_dress
	greyscale_config_worn = /datum/greyscale_config/striped_dress/worn
	flags_1 = IS_PLAYER_COLORABLE_1
	greyscale_colors = "#003284#000000#ffffff"

/obj/item/clothing/under/dress/sailor
	name = "sailor dress"
	desc = "Formal wear for a leading lady."
	alternate_worn_layer = UNDER_SUIT_LAYER
	icon = 'icons/map_icons/clothing/under/dress.dmi'
	icon_state = "/obj/item/clothing/under/dress/sailor"
	post_init_icon_state = "sailor_dress"
	greyscale_config = /datum/greyscale_config/sailor_dress
	greyscale_config_worn = /datum/greyscale_config/sailor_dress/worn
	greyscale_colors = "#0000ff#cc0000#eaeaea"
	inhand_icon_state = "blackskirt"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/wedding_dress
	name = "wedding dress"
	desc = "A luxurious gown for once-in-a-lifetime occasions."
	icon_state = "wedding_dress"
	alternate_worn_layer = UNDER_SUIT_LAYER
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS
	flags_inv = HIDESHOES

/obj/item/clothing/under/dress/wedding_dress/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 4) //You aren't going to fish with this are you?

/obj/item/clothing/under/dress/eveninggown
	name = "evening gown"
	desc = "Fancy dress for space bar singers."
	alternate_worn_layer = UNDER_SUIT_LAYER
	inhand_icon_state = null
	icon = 'icons/map_icons/clothing/under/dress.dmi'
	icon_state = "/obj/item/clothing/under/dress/eveninggown"
	post_init_icon_state = "evening_gown"
	greyscale_config = /datum/greyscale_config/evening_dress
	greyscale_config_worn = /datum/greyscale_config/evening_dress/worn
	flags_1 = IS_PLAYER_COLORABLE_1
	greyscale_colors = "#e11f1f"

/obj/item/clothing/under/dress/eveninggown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 4) //You aren't going to fish with this are you?

/obj/item/clothing/under/dress/skirt
	name = "cardigan skirt"
	desc = "A nice skirt with a cute cardigan, very fancy!"
	icon = 'icons/map_icons/clothing/under/dress.dmi'
	icon_state = "/obj/item/clothing/under/dress/skirt"
	post_init_icon_state = "cardiganskirt"
	greyscale_config = /datum/greyscale_config/cardiganskirt
	greyscale_config_worn = /datum/greyscale_config/cardiganskirt/worn
	greyscale_colors = "#bf504d#545454"
	inhand_icon_state = "blackskirt"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/skirt/plaid
	name = "plaid skirt"
	desc = "A preppy plaid skirt with a white blouse."
	icon_state = "/obj/item/clothing/under/dress/skirt/plaid"
	post_init_icon_state = "plaidskirt"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#CC2102"
	greyscale_config = /datum/greyscale_config/plaidskirt
	greyscale_config_worn = /datum/greyscale_config/plaidskirt/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/skirt/turtleskirt
	name = "turtleneck skirt"
	desc = "A casual turtleneck skirt."
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#cc0000#5f5f5f"
	icon = 'icons/map_icons/clothing/under/dress.dmi'
	icon_state = "/obj/item/clothing/under/dress/skirt/turtleskirt"
	post_init_icon_state = "turtleskirt"
	greyscale_config = /datum/greyscale_config/turtleskirt
	greyscale_config_worn = /datum/greyscale_config/turtleskirt/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/tango
	name = "tango dress"
	desc = "Filled with Latin fire."
	alternate_worn_layer = UNDER_SUIT_LAYER
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#ff0000#1c1c1c"
	icon = 'icons/map_icons/clothing/under/dress.dmi'
	icon_state = "/obj/item/clothing/under/dress/tango"
	post_init_icon_state = "tango"
	greyscale_config = /datum/greyscale_config/tango
	greyscale_config_worn = /datum/greyscale_config/tango/worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/dress/sundress
	name = "sundress"
	desc = "Makes you want to frolic in a field of daisies."
	custom_price = PAYCHECK_CREW
	greyscale_colors = "#FFE60F#9194A5#1F243C"
	icon = 'icons/map_icons/clothing/under/dress.dmi'
	icon_state = "/obj/item/clothing/under/dress/sundress"
	post_init_icon_state = "sundress"
	greyscale_config = /datum/greyscale_config/sundress
	greyscale_config_worn = /datum/greyscale_config/sundress/worn
	flags_1 = IS_PLAYER_COLORABLE_1
