//Blueshield

//Uniform items are in command.dm

/obj/item/clothing/head/helmet/space/plasmaman/blueshield
	name = "blueshield envirosuit helmet"
	desc = "A plasmaman containment helmet designed for certified blueshields, who's job guarding heads should not include self-combustion... most of the time."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/head/plasmaman_hats.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head/plasmaman_head.dmi'
	icon_state = "bs_envirohelm"

/obj/item/clothing/under/plasmaman/blueshield
	name = "blueshield envirosuit"
	desc = "A plasmaman containment suit designed for certified blueshields, offering a limited amount of extra protection."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/under/plasmaman.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/under/plasmaman.dmi'
	icon_state = "bs_envirosuit"
	armor_type = /datum/armor/clothing_under/under_plasmaman_blueshield
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/datum/armor/clothing_under/under_plasmaman_blueshield
	melee = 10
	bio = 100
	fire = 95
	acid = 95

/obj/item/clothing/head/beret/blueshield
	name = "blueshield's beret"
	desc = "A blue beret made of durathread with a genuine golden badge, denoting its owner as a Blueshield Lieuteneant. It seems to be padded with nano-kevlar, making it tougher than standard reinforced berets."
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#3A4E7D#DEB63D"
	icon_state = "beret_badge_police"

/obj/item/clothing/head/beret/blueshield/navy
	name = "navy blueshield's beret"
	desc = "A navy-blue beret made of durathread with a silver badge, denoting its owner as a Blueshield Lieuteneant. It seems to be padded with nano-kevlar, making it tougher than standard reinforced berets."
	greyscale_colors = "#3C485A#BBBBBB"

/obj/item/storage/backpack/blueshield
	name = "blueshield backpack"
	desc = "A robust backpack issued to Nanotrasen's finest."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/backpacks.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/back.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/clothing/backpack_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/clothing/backpack_righthand.dmi'
	icon_state = "backpack_blueshield"
	inhand_icon_state = "backpack_blueshield"

/obj/item/storage/backpack/satchel/blueshield
	name = "blueshield satchel"
	desc = "A robust satchel issued to Nanotrasen's finest."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/backpacks.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/back.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/clothing/backpack_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/clothing/backpack_righthand.dmi'
	icon_state = "satchel_blueshield"
	inhand_icon_state = "satchel_blueshield"

/obj/item/storage/backpack/duffelbag/blueshield
	name = "blueshield duffelbag"
	desc = "A robust duffelbag issued to Nanotrasen's finest."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/backpacks.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/back.dmi'
	lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/clothing/backpack_lefthand.dmi'
	righthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/clothing/backpack_righthand.dmi'
	icon_state = "duffel_blueshield"
	inhand_icon_state = "duffel_blueshield"

//blueshield armor
/obj/item/clothing/suit/armor/vest/blueshield
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/armor.dmi'
	name = "blueshield's armor"
	desc = "A tight-fitting kevlar-lined vest with a blue badge on the chest of it."
	icon_state = "blueshieldarmor"
	body_parts_covered = CHEST
	uses_advanced_reskins = TRUE
	unique_reskin = list(
		"Slim" = list(
			RESKIN_ICON = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/armor.dmi',
			RESKIN_ICON_STATE = "blueshieldarmor",
			RESKIN_WORN_ICON = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/armor.dmi',
			RESKIN_WORN_ICON_STATE = "blueshieldarmor",
		),
		"Marine" = list(
			RESKIN_ICON = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/armor.dmi',
			RESKIN_ICON_STATE = "bs_marine",
			RESKIN_WORN_ICON = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/armor.dmi',
			RESKIN_WORN_ICON_STATE = "bs_marine",
		),
		"Bulky" = list(
			RESKIN_ICON = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/armor.dmi',
			RESKIN_ICON_STATE = "vest_black",
			RESKIN_WORN_ICON = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/armor.dmi',
			RESKIN_WORN_ICON_STATE = "vest_black",
		),
	)

/obj/item/clothing/suit/armor/vest/blueshield/jacket
	name = "blueshield's jacket"
	desc = "An expensive kevlar-lined jacket with a golden badge on the chest and \"NT\" emblazoned on the back. It weighs surprisingly little, despite how heavy it looks."
	icon_state = "blueshield"
	body_parts_covered = CHEST|ARMS
	unique_reskin = null

/obj/item/clothing/suit/armor/vest/blueshield/jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/suit/hooded/wintercoat/nova/blueshield
	name = "blueshield's winter coat"
	icon_state = "coatblueshield"
	desc = "A comfy kevlar-lined coat with blue highlights, fit to keep the blueshield armored and warm."
	hoodtype = /obj/item/clothing/head/hooded/winterhood/nova/blueshield
	allowed = list(/obj/item/melee/baton/security/loaded)
	armor_type = /datum/armor/suit_armor

/obj/item/clothing/suit/hooded/wintercoat/nova/blueshield/Initialize(mapload)
	. = ..()
	allowed += GLOB.security_vest_allowed

/obj/item/clothing/head/hooded/winterhood/nova/blueshield
	icon_state = "hood_blueshield"
	desc = "A comfy kevlar-lined hood to go with the comfy kevlar-lined coat."
	armor_type = /datum/armor/suit_armor

/obj/item/clothing/head/hooded/winterhood/nova
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/head/winterhood.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/head/winterhood.dmi'
	icon_state = "hood_aformal"

//Coat Basetype (The Assistant's Formal Coat)
/obj/item/clothing/suit/hooded/wintercoat/nova
	name = "assistant's formal winter coat"
	desc = "A dark gray winter coat with bronze-gold detailing, and a zipper in the shape of a toolbox."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits/wintercoat.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suits/wintercoat.dmi'
	icon_state = "coataformal"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/nova
