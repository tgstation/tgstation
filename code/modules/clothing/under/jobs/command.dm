//CAPTAIN
/obj/item/clothing/under/rank/captain
	desc = "It's a blue jumpsuit with some gold markings denoting the rank of \"Captain\"."
	name = "captain's jumpsuit"
	icon_state = "captain"
	inhand_icon_state = "b_suit"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	icon = 'icons/obj/clothing/under/captain.dmi'
	worn_icon = 'icons/mob/clothing/under/captain.dmi'
	armor_type = /datum/armor/rank_captain

/datum/armor/rank_captain
	bio = 10
	wound = 15

/obj/item/clothing/under/rank/captain/skirt
	name = "captain's jumpskirt"
	desc = "It's a blue jumpskirt with some gold markings denoting the rank of \"Captain\"."
	icon_state = "captain_skirt"
	inhand_icon_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	inhand_icon_state = "dg_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/captain/suit/skirt
	name = "green suitskirt"
	desc = "A green suitskirt and yellow necktie. Exemplifies authority."
	icon_state = "green_suit_skirt"
	inhand_icon_state = "dg_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/captain/parade
	name = "captain's parade uniform"
	desc = "A captain's luxury-wear, for special occasions."
	icon_state = "captain_parade"
	inhand_icon_state = null
	can_adjust = FALSE

//ADJUTANT
/obj/item/clothing/under/rank/adjutant
	desc = "It's a light blue suit, its resistant to the hardest profanities and coffee spills."
	name = "adjutant's suit"
	icon_state = "adjutantsuit"
	inhand_icon_state = "b_suit"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	icon = 'icons/obj/clothing/under/suits.dmi'
	worn_icon = 'icons/mob/clothing/under/suits.dmi'
	armor_type = /datum/armor/rank_captain

/obj/item/clothing/under/rank/adjutant/skirt
	desc = "It's a light blue suitskirt, its resistant to the hardest profanities and coffee spills."
	name = "adjutant's suitskirt"
	icon_state = "adjutantsuit_skirt"
	body_parts_covered = CHEST|GROIN|ARMS
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
