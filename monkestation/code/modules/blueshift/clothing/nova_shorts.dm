#define SHORTS_PANTS_SHIRTS_DIGIFILE 'monkestation/code/modules/blueshift/icons/mob/clothing/under/shorts_pants_shirts_digi.dmi'

/obj/item/clothing/under/pants
	worn_icon_digitigrade = SHORTS_PANTS_SHIRTS_DIGIFILE

/obj/item/clothing/under/shorts
	worn_icon_digitigrade = SHORTS_PANTS_SHIRTS_DIGIFILE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION //That's right, TG, I have icons for ALL of these!! Mwahahaha!!!!

/obj/item/clothing/under/pants/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/shorts_pants_shirts.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/shorts_pants_shirts.dmi'

/obj/item/clothing/under/shorts/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/shorts_pants_shirts.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/shorts_pants_shirts.dmi'
	//Need to reset all these so our custom stuff can choose independently to be greyscale or not. TG putting these on the basetype was kinda gross.
	greyscale_config = null
	greyscale_config_worn = null
	greyscale_config_worn_digitigrade =  null
	greyscale_colors = null
	flags_1 = NONE

//TG's files separate this into Shorts.dmi and Pants.dmi. We wont have as many, so both go into here.

/*
*	PANTS
*/

/obj/item/clothing/under/pants/nova/jeans_ripped
	name = "ripped jeans"
	desc = "A nondescript pair of tough jeans, with several rips and tears. The staple pants choice of both rebels and the poor."
	icon_state = "jeans_ripped"
	greyscale_config = /datum/greyscale_config/jeans_ripped //These configs are defined in the GAGS module for now; the icons and item will remain in these files.
	greyscale_config_worn = /datum/greyscale_config/jeans_ripped/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/jeans_ripped/worn/digi
	greyscale_colors = "#787878#723E0E#4D7EAC"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/pants/nova/yoga
	name = "yoga pants"
	desc = "Breathable and stretchy, perfect for exercising comfortably!"
	icon_state = "yoga_pants"
	greyscale_config = /datum/greyscale_config/yoga_pants //These configs are defined in the GAGS module for now; the icons and item will remain in these files.
	greyscale_config_worn = /datum/greyscale_config/yoga_pants/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/yoga_pants/worn/digi
	greyscale_colors = "#3d3d3d" //Having all the configs for a single color feels wrong. This is wrong.
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/pants/nova/chaps
	name = "black chaps"
	desc = "Yeehaw"
	icon_state = "chaps"


/*
*	SHORTS
*/

/obj/item/clothing/under/shorts/nova/shorts_ripped
	name = "ripped shorts"
	desc = "A nondescript pair of tough jean shorts, with the ends of the pantlegs frayed and torn. No one will ever know if this was done intentionally."
	icon_state = "shorts_ripped"
	greyscale_config = /datum/greyscale_config/shorts_ripped //These configs are defined in the GAGS module for now; the icons and item will remain in these files.
	greyscale_config_worn = /datum/greyscale_config/shorts_ripped/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/shorts_ripped/worn/digi
	greyscale_colors = "#787878#723E0E#202020"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/shorts/nova/shortershorts
	name = "shorter shorts"
	desc = "Show those legs off with these even shorter shorts!"
	icon_state = "shortershorts"
	greyscale_config = /datum/greyscale_config/shortershorts
	greyscale_config_worn = /datum/greyscale_config/shortershorts/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/shortershorts/worn/digi
	greyscale_colors = "#787878#723E0E#202020"
	flags_1 = IS_PLAYER_COLORABLE_1

/*
*	MISC (Technically belongs in this file as a shorts/pants/shirt combo)
*	Here's hoping TG gives these their own typepath, but for now this is gonna be under/pants/nova. No, it's not all pants, but it's better than a whole new type
*/

/obj/item/clothing/under/pants/nova/kilt
	name = "recolorable kilt"
	desc = "A kilt and buttondown, adorned with a tartan sash. It is NOT a skirt."
	icon_state = "kilt"
	greyscale_config = /datum/greyscale_config/kilt
	greyscale_config_worn = /datum/greyscale_config/kilt/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/kilt/worn/digi
	greyscale_colors = "#FFFFFF#365736#d9e6e5"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_1 = IS_PLAYER_COLORABLE_1
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/pants/nova/vicvest //there's no way I'm typing out a path called double_breasted 10 times over, too complex and everyone will be scared of it
	name = "buttondown shirt with double-breasted vest"
	desc = "A fancy buttondown shirt with slacks and a vest worn overtop, with a second row of buttons. Truly an outdated fashion statement."
	icon_state = "buttondown_vicvest"
	greyscale_config = /datum/greyscale_config/buttondown_vicvest
	greyscale_config_worn = /datum/greyscale_config/buttondown_vicvest/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/buttondown_vicvest/worn/digi
	greyscale_colors = "#8b2c2c#222227#222227#fbc056"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_1 = IS_PLAYER_COLORABLE_1

/*
*	Shorts that were previously using nonmodular edits to add their greyscale data, pulled from code/modules/clothing/under/shorts.dm
*/

/obj/item/clothing/under/shorts
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/shorts/worn/digi

/obj/item/clothing/under/shorts/jeanshorts
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/jeanshorts/worn/digi

/*
*	Pants that were previously using nonmodular edits to add their greyscale data, pulled from code/modules/clothing/under/pants.dm
*/

/obj/item/clothing/under/pants/slacks
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/slacks/worn/digi

/obj/item/clothing/under/pants/jeans
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/jeans/worn/digi

/obj/item/clothing/under/pants/camo
	greyscale_config = /datum/greyscale_config/camo_pants
	greyscale_config_worn = /datum/greyscale_config/camo_pants/worn
	greyscale_config_worn_digitigrade =  /datum/greyscale_config/camo_pants/worn/digi
	greyscale_colors = "#69704C#6E5B4C#343741"
	flags_1 = IS_PLAYER_COLORABLE_1
