/obj/item/clothing/accessory/maidapron/syndicate
	name = "syndicate maid apron"
	desc = "Practical? No. Tactical? Also no. Cute? Most definitely yes."
	icon = 'monkestation/icons/obj/clothing/accessories.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/accessories.dmi'
	icon_state = "maidapronsynd"

// BEGIN BUNNYTIES

/obj/item/clothing/accessory/bunnytie
	name = "bowtie collar"
	desc = "A fancy tie that includes a collar. Looking snazzy."
	icon = 'monkestation/icons/obj/clothing/accessories.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/accessories.dmi'
	icon_state = "bowtie_collar"
	greyscale_colors = "#ffffff#39393f"
	greyscale_config = /datum/greyscale_config/bowtie_collar
	greyscale_config_worn = /datum/greyscale_config/bowtie_collar_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/accessory/bunnytie/syndicate
	name = "blood-red bowtie collar"
	desc = "A fancy tie that includes a red collar. Looking sinister."
	icon_state = "bowtie_collar_syndie"
	armor_type = /datum/armor/bunnytie_syndicate
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/datum/armor/bunnytie_syndicate
	fire = 30
	acid = 20

//END BUNNYTIES
