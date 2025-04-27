//for unusual clothing items that don't fit anywhere else

/obj/item/clothing/under/cowl_neck_shirt
	name = "cowl neck shirt and trousers"
	desc = "A fairly conventional broadcloth shirt rendered directional with a loose folded neckline in place of a \
	traditional shirt collar. Its complementary pants have eschewed belts and loops in favor of fit tabs."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/miscellania.dmi'
	icon_state = "cowl_neck"
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/miscellania.dmi'
	female_sprite_flags = FEMALE_UNIFORM_NO_BREASTS
	can_adjust = FALSE

/obj/item/clothing/under/collared_shirt
	name = "collared shirt and trousers"
	desc = "This style of collared shirt has persisted now for centuries with only minor changes in styling, fit, \
	and proportion. This one is very contemporary to the times."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/miscellania.dmi'
	icon_state = "collared_shirt"
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/miscellania.dmi'
	female_sprite_flags = FEMALE_UNIFORM_NO_BREASTS
	can_adjust = FALSE

/obj/item/clothing/under/pants/moto_leggings
	name = "'Naka' moto leggings"
	desc = "Lab grown lambskin has been adhered to a spandex underlayer to produce a leather with considerable \
	four way stretch, allowing for a closer fit in leather pants than ever before. This style features integrated \
	kneepads to boot. It's not recommended to use these for motorsports; they are not actually very protective."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/miscellania.dmi'
	icon_state = "moto_leggings"
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/miscellania.dmi'
	body_parts_covered = GROIN|LEGS
	can_adjust = FALSE

/obj/item/clothing/under/pants/big_pants
	name = "\improper JUNCO megacargo pants"
	desc = "De riguer for techno classicists, these extreme wide leg pants come back into style every \
		now and then. This pair has generous onboard storage."
	icon_state = "big_pants"
	supported_bodyshapes = null
	bodyshape_icon_files = null
	greyscale_config = /datum/greyscale_config/big_pants
	greyscale_config_worn = /datum/greyscale_config/big_pants/worn
	greyscale_colors = "#874f16"
	flags_1 = IS_PLAYER_COLORABLE_1
	alternate_worn_layer = LOW_FACEMASK_LAYER
	female_sprite_flags = NO_FEMALE_UNIFORM

/obj/item/clothing/under/misc/gear_harness
	name = "gear harness"
	desc = "A simple, inconspicuous harness replacement for a jumpsuit."
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/miscellania.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/miscellania.dmi'
	icon_state = "gear_harness"
	body_parts_covered = NONE
	attachment_slot_override = CHEST
	can_adjust = FALSE
	slot_flags = ITEM_SLOT_ICLOTHING | ITEM_SLOT_OCLOTHING
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/misc/gear_harness/Initialize(mapload)
	. = ..()
	allowed += GLOB.colonist_suit_allowed

/obj/item/clothing/under/costume/bunnysuit
	name = "bunny suit"
	desc = "Makes the wearer more attractive; even and especially men."
	icon_state = "bunnysuit"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/miscellania.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/miscellania.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	body_parts_covered = CHEST|GROIN
	can_adjust = TRUE
	alt_covers_chest = FALSE

/obj/item/clothing/under/athletas_bodysuit
	name = "ATHLETAS bodysuit"
	desc = "Hairfine threads of extruded silver-protein slurry ride from spindle to needle on a single production chain. \
	The fine jersey wicks and breathes while resisting microbial colonization."
	icon_state = "athletas_bodysuit"
	greyscale_config = /datum/greyscale_config/athletas_bodysuit
	greyscale_config_worn = /datum/greyscale_config/athletas_bodysuit/worn
	greyscale_colors = "#1c1c1c#c0c0c0"
	flags_1 = IS_PLAYER_COLORABLE_1
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/bodysuit
	name = "bodysuit"
	desc = "Tightly fitting underclothes made of lycra. Toggle to switch between masc and fem variants."
	icon_state = "bodysuit"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/under/miscellania.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/under/miscellania.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	can_adjust = TRUE
	alt_covers_chest = TRUE
