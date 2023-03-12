/obj/item/clothing/under/rank/civilian/curator
	name = "sensible suit"
	desc = "It's very... sensible."
	icon = 'icons/obj/clothing/under/suits.dmi'
	icon_state = "red_suit"
	inhand_icon_state = null
	worn_icon = 'icons/mob/clothing/under/suits.dmi'
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/curator/skirt
	name = "sensible suitskirt"
	desc = "It's very... sensible."
	icon = 'icons/obj/clothing/under/suits.dmi'
	icon_state = "red_suit_skirt"
	inhand_icon_state = null
	worn_icon = 'icons/mob/clothing/under/suits.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	dying_key = DYE_REGISTRY_JUMPSKIRT
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/civilian/curator/treasure_hunter
	name = "treasure hunter uniform"
	desc = "A rugged uniform suitable for treasure hunting."
	icon = 'icons/obj/clothing/under/civilian.dmi'
	icon_state = "curator"
	inhand_icon_state = null
	worn_icon = 'icons/mob/clothing/under/civilian.dmi'

/obj/item/clothing/under/rank/civilian/curator/nasa
	name = "\improper NASA jumpsuit"
	desc = "It has a NASA logo on it and is made of space-proofed materials."
	icon_state = "jumpsuit"
	inhand_icon_state = "jumpsuit"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	w_class = WEIGHT_CLASS_BULKY
	armor_type = /datum/armor/curator_nasa
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST | GROIN | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = NONE

/datum/armor/curator_nasa
	bio = 95
