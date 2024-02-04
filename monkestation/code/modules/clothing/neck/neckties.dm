//Stuff that isn't cloaks
// BEGIN BUNNYTIES

/obj/item/clothing/neck/tie/bunnytie
	name = "bowtie collar"
	desc = "A fancy tie that includes a collar. Looking snazzy."
	icon = 'monkestation/icons/obj/clothing/necks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/neck.dmi'
	icon_state = "bowtie_collar_tied"
	tie_type = "bowtie_collar"
	greyscale_colors = "#ffffff#39393f"
	greyscale_config = /datum/greyscale_config/bowtie_collar
	greyscale_config_worn = /datum/greyscale_config/bowtie_collar_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/neck/tie/bunnytie/tied
	is_tied = TRUE

/obj/item/clothing/neck/tie/bunnytie/syndicate
	name = "blood-red bowtie collar"
	desc = "A fancy tie that includes a red collar. Looking sinister."
	icon_state = "bowtie_collar_syndi_tied"
	tie_type = "bowtie_collar_syndi"
	armor_type = /datum/armor/bunnytie_syndicate
	tie_timer = 2 SECONDS //Tactical tie
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/syndicate/tied
	is_tied = TRUE

/datum/armor/bunnytie_syndicate
	fire = 30
	acid = 20

/obj/item/clothing/neck/tie/bunnytie/magician
	name = "magician's bowtie collar"
	desc = "A fancy gold tie that includes a collar. Looking magical."
	icon_state = "bowtie_collar_wiz_tied"
	tie_type = "bowtie_collar_wiz"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/magician/tied
	is_tied = TRUE

/obj/item/clothing/neck/tie/bunnytie/centcom
	name = "centcom bowtie collar"
	icon_state = "bowtie_collar_centcom_tied"
	tie_type = "bowtie_collar_centcom"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/centcom/tied
	is_tied = TRUE

/obj/item/clothing/neck/tie/bunnytie/communist
	name = "really red bowtie collar"
	icon_state = "bowtie_collar_communist_tied"
	tie_type = "bowtie_collar_communist"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/communist/tied
	is_tied = TRUE

/obj/item/clothing/neck/tie/bunnytie/blue
	name = "blue bowtie collar"
	icon_state = "bowtie_collar_blue_tied"
	tie_type = "bowtie_collar_blue"
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_colors = null

/obj/item/clothing/neck/tie/bunnytie/blue/tied
	is_tied = TRUE

//END BUNNYTIES
