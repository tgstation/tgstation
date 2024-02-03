//Stuff that isn't cloaks
// BEGIN BUNNYTIES

/obj/item/clothing/neck/tie/bunnytie
	name = "bowtie collar"
	desc = "A fancy tie that includes a collar. Looking snazzy."
	icon = 'monkestation/icons/obj/clothing/necks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/neck.dmi'
	icon_state = "bowtie_collar_tied"
	tie_type = "bowtie_collar"
	alternate_worn_layer = UNDER_SUIT_LAYER
	greyscale_colors = "#ffffff#39393f"
	greyscale_config = /datum/greyscale_config/bowtie_collar
	greyscale_config_worn = /datum/greyscale_config/bowtie_collar_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/tie/bunnytie/syndicate
	name = "blood-red bowtie collar"
	desc = "A fancy tie that includes a red collar. Looking sinister."
	icon_state = "bowtie_collar_syndie_tied"
	tie_type = "bowtie_collar_syndie"
	armor_type = /datum/armor/bunnytie_syndicate
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
	tie_timer = 2 SECONDS //Tactical tie

/datum/armor/bunnytie_syndicate
	fire = 30
	acid = 20

//END BUNNYTIES
