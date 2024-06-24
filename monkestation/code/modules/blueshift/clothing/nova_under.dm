/obj/item/clothing/under/misc/bluetracksuit
	name = "blue tracksuit"
	desc = "Found on a dead homeless man squatting in an alleyway, the classic design has been mass produced to bring terror to the galaxy."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/uniform.dmi'
	icon_state = "tracksuit_blue"

/obj/item/clothing/under/tachawaiian
	name = "orange tactical hawaiian outfit"
	desc = "Clearly the wearer didn't know if they wanted to invade a country or lay on a nice Hawaiian beach."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/uniform.dmi'
	icon_state = "tacticool_hawaiian_orange"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION

/obj/item/clothing/under/tachawaiian/blue
	name = "blue tactical hawaiian outfit"
	icon_state = "tacticool_hawaiian_blue"

/obj/item/clothing/under/tachawaiian/purple
	name = "purple tactical hawaiian outfit"
	icon_state = "tacticool_hawaiian_purple"

/obj/item/clothing/under/tachawaiian/green
	name = "green tactical hawaiian outfit"
	icon_state = "tacticool_hawaiian_green"

/obj/item/clothing/under/texas
	name = "texan formal outfit"
	desc = "A premium quality shirt and pants combo straight from Texas."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/uniform.dmi'
	icon_state = "texas"
	supports_variations_flags = NONE

/obj/item/clothing/under/doug_dimmadome
	name = "dimmadome formal outfit"
	desc = "A tight fitting suit with a belt that is surely made out of gold."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/uniform.dmi'
	icon_state = "doug_dimmadome"
	supports_variations_flags = NONE

/obj/item/clothing/under/pants/tactical
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/shorts_pants_shirts.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/shorts_pants_shirts.dmi'
	name = "tactical pants"
	desc = "A pair of tactical pants, designed for military use."
	icon_state = "tactical_pants"

/obj/item/clothing/under/sweater
	name = "cableknit sweater"
	desc = "Why trade style for comfort? Now you can go commando down south and still be cozy up north."
	icon_state = "cableknit_sweater"
	greyscale_config = /datum/greyscale_config/cableknit_sweater
	greyscale_config_worn = /datum/greyscale_config/cableknit_sweater/worn
	greyscale_colors = "#b2a484"
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = TRUE
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/under/sweater/black
	name = "black cableknit sweater"
	greyscale_colors = "#4f4f4f"

/obj/item/clothing/under/sweater/red
	name = "red cableknit sweater"
	greyscale_colors = "#9a0000"

/obj/item/clothing/under/sweater/keyhole
	name = "keyhole sweater"
	desc = "So let me get this straight. They cut cleavage out of something meant to keep you warm..? Why? \"Now you can go commando down south and be freezing cold on your chest\" isn't a good motto!"
	icon_state = "keyhole_sweater"
	greyscale_colors = "#c5699c"
