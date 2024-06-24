//Base Jacket - same stats as /obj/item/clothing/suit/jacket, just toggleable and serving as the base for all the departmental jackets and flannels
/obj/item/clothing/suit/toggle/jacket
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "bomber jacket"
	desc = "A warm bomber jacket, with synthetic-wool lining to keep you nice and warm in the depths of space. Aviators not included."
	icon_state = "bomberalt"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/radio)
	body_parts_covered = CHEST|ARMS|GROIN
	cold_protection = CHEST|ARMS|GROIN
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	toggle_noun = "zipper"

//Job Jackets
/obj/item/clothing/suit/toggle/jacket/engi
	name = "engineering jacket"
	desc = "A comfortable jacket in engineering yellow."
	icon_state = "engi_dep_jacket"
	armor_type = /datum/armor/jacket_engi
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)

/datum/armor/jacket_engi
	fire = 30
	acid = 45

/obj/item/clothing/suit/toggle/jacket/sci
	name = "science jacket"
	desc = "A comfortable jacket in science purple."
	icon_state = "sci_dep_jacket"
	armor_type = /datum/armor/jacket_sci

/datum/armor/jacket_sci
	bomb = 10

/obj/item/clothing/suit/toggle/jacket/med
	name = "medbay jacket"
	desc = "A comfortable jacket in medical blue."
	icon_state = "med_dep_jacket"
	armor_type = /datum/armor/jacket_med

/datum/armor/jacket_med
	bio = 50
	acid = 45

/obj/item/clothing/suit/toggle/jacket/supply
	name = "cargo jacket"
	desc = "A comfortable jacket in supply brown."
	icon_state = "supply_dep_jacket"

/obj/item/clothing/suit/toggle/jacket/assistant
	name = "non-departmental jacket"
	desc = "A comfortable jacket in a neutral black"
	icon_state = "off_dep_jacket"

/obj/item/clothing/suit/toggle/jacket/supply/head
	name = "quartermaster's jacket"
	desc = "Even if people refuse to recognize you as a head, they can recognize you as a badass."
	icon_state = "qmjacket"

/obj/item/clothing/suit/toggle/jacket/sec
	name = "security jacket"
	desc = "A comfortable jacket in security blue. Probably against uniform regulations."
	icon_state = "sec_dep_jacket"
	armor_type = /datum/armor/sec_dep_jacket

/obj/item/clothing/suit/toggle/jacket/sec/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/datum/armor/sec_dep_jacket
	melee = 30
	bullet = 20
	laser = 30
	energy = 40
	bomb = 25
	fire = 30
	acid = 45

/obj/item/clothing/suit/toggle/jacket/sec/old	//Oldsec (Red)
	icon_state = "sec_dep_jacket_old"

//Flannels
/obj/item/clothing/suit/toggle/jacket/flannel
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/suit.dmi'
	name = "flannel jacket"
	desc = "A cozy and warm plaid flannel jacket. Praised by Lumberjacks and Truckers alike."
	icon_state = "flannel"
	body_parts_covered = CHEST|ARMS //Being a bit shorter, flannels dont cover quite as much as the rest of the woolen jackets (- GROIN)
	cold_protection = CHEST|ARMS
	heat_protection = CHEST|ARMS	//As a plus side, they're more insulating, protecting a bit from the heat as well

/obj/item/clothing/suit/toggle/jacket/flannel/red
	name = "red flannel jacket"
	icon_state = "flannel_red"

/obj/item/clothing/suit/toggle/jacket/flannel/aqua
	name = "aqua flannel jacket"
	icon_state = "flannel_aqua"

/obj/item/clothing/suit/toggle/jacket/flannel/brown
	name = "brown flannel jacket"
	icon_state = "flannel_brown"

/obj/item/clothing/suit/toggle/jacket/flannel/gags
	name = "flannel shirt"
	icon_state = "flannelgags"
	greyscale_config = /datum/greyscale_config/flannelgags
	greyscale_config_worn = /datum/greyscale_config/flannelgags/worn
	greyscale_colors = "#a61e1f"
	flags_1 = IS_PLAYER_COLORABLE_1
