/obj/item/clothing/under/suit
	icon = 'icons/obj/clothing/under/suits.dmi'
	worn_icon = 'icons/mob/clothing/under/suits.dmi'
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_NO_BREASTS
	inhand_icon_state = null

/obj/item/clothing/under/suit/green
	name = "green suit"
	desc = "A green suit and yellow necktie. Baller."
	icon = 'icons/obj/clothing/under/captain.dmi'
	icon_state = "green_suit"
	inhand_icon_state = "dg_suit"
	worn_icon = 'icons/mob/clothing/under/captain.dmi'

/obj/item/clothing/under/suit/red //Also used by the Curator's suit, /obj/item/clothing/under/rank/civilian/curator
	name = "red suit"
	desc = "A red suit and blue tie. Somewhat formal."
	icon_state = "red_suit"
	inhand_icon_state = "r_suit"

/obj/item/clothing/under/suit/charcoal
	name = "charcoal suit"
	desc = "A charcoal suit and red tie. Very professional."
	icon_state = "charcoal_suit"

/obj/item/clothing/under/suit/navy
	name = "navy suit"
	desc = "A navy suit and red tie, intended for the station's finest."
	icon_state = "navy_suit"

/obj/item/clothing/under/suit/burgundy
	name = "burgundy suit"
	desc = "A burgundy suit and black tie. Somewhat formal."
	icon_state = "burgundy_suit"

/obj/item/clothing/under/suit/checkered
	name = "checkered suit"
	desc = "That's a very nice suit you have there. Shame if something were to happen to it, eh?"
	icon_state = "checkered_suit"

/obj/item/clothing/under/suit/beige
	name = "beige suit"
	desc = "An excellent light colored suit, experts in the field stress that it should not to be confused with the inferior tan suit."
	icon_state = "beige_suit"

/obj/item/clothing/under/suit/black
	name = "black two piece suit"
	desc = "A black suit with charcoal pants and a red tie. Very formal."
	icon_state = "black_suit"

/obj/item/clothing/under/suit/black/skirt
	name = "black two piece suit"
	desc = "A black suit with a charcoal skirt and a red tie. Very formal."
	icon_state = "black_suit_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/suit/white
	name = "white suit"
	desc = "A white suit and jacket with a blue shirt. You wanna play rough? OKAY!"
	icon_state = "white_suit"
	inhand_icon_state = "white_suit"

/obj/item/clothing/under/suit/white/skirt
	name = "white suitskirt"
	desc = "A white suitskirt, suitable for an excellent host."
	icon_state = "white_suit_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/suit/tan
	name = "tan suit"
	desc = "A tan suit. Smart, but casual."
	icon_state = "tan_suit"
	inhand_icon_state = "tan_suit"

/obj/item/clothing/under/suit/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tip."
	icon_state = "waiter"
	inhand_icon_state = "waiter"

/obj/item/clothing/under/suit/black_really
	name = "executive suit"
	desc = "A formal black suit, intended for the station's finest."
	icon_state = "really_black_suit"
	inhand_icon_state = null

/obj/item/clothing/under/suit/black_really/skirt
	name = "executive suitskirt"
	desc = "A formal black suitskirt, intended for the station's finest."
	icon_state = "really_black_suit_skirt"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY|FEMALE_UNIFORM_NO_BREASTS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/suit/tuxedo
	name = "tuxedo"
	desc = "A formal black tuxedo. It exudes classiness."
	icon_state = "tuxedo"
	inhand_icon_state = null

/obj/item/clothing/under/suit/tuxedo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, 4) //You aren't going to fish with this are you?

/obj/item/clothing/under/suit/carpskin
	name = "carpskin suit"
	desc = "An luxurious suit made with only the finest scales, perfect for conducting dodgy business deals."
	icon_state = "carpskin_suit"
	inhand_icon_state = null

/obj/item/clothing/under/suit/carpskin/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/adjust_fishing_difficulty, -2)
