
/obj/item/clothing/suit/armor/durability/gaywatermelon
	name = "gaywatermelon armor"
	desc = "An armor, made from gaywatermelon. Probably won't take too many hits, but at least it looks serious... As serious as worn gaywatermelon can be."
	icon = 'troutstation/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'troutstation/icons/mob/clothing/suits/armor.dmi'
	icon_state = "gaywatermelon"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor_type = /datum/armor/watermelon
	strip_delay = 6 SECONDS
	equip_delay_other = 4 SECONDS
	clothing_traits = list(TRAIT_BRAWLING_KNOCKDOWN_BLOCKED)
	max_integrity = 15

/obj/item/clothing/suit/armor/durability/gaywatermelon/fire_resist
	resistance_flags = FIRE_PROOF
	armor_type = /datum/armor/watermelon_fr
