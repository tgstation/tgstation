/obj/item/clothing/suit/jacket
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	abstract_type = /obj/item/clothing/suit/jacket
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/radio,
		)
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/jacket/Initialize(mapload)
	. = ..()
	allowed += GLOB.personal_carry_allowed

/obj/item/clothing/suit/toggle/jacket
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	abstract_type = /obj/item/clothing/suit/toggle/jacket
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/tank/jetpack/oxygen/captain,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/radio,
		)
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/toggle/jacket/Initialize(mapload)
	. = ..()
	allowed += GLOB.personal_carry_allowed

/obj/item/clothing/suit/toggle/jacket/sweater
	name = "sweater jacket"
	desc = "A sweater jacket."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/jacket/sweater"
	post_init_icon_state = "sweater"
	greyscale_config = /datum/greyscale_config/sweater
	greyscale_config_worn = /datum/greyscale_config/sweater/worn
	greyscale_colors = "#414344"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/toggle/jacket/trenchcoat
	name = "trenchcoat"
	desc = "A multi-purpose trenchcoat."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/toggle/jacket/trenchcoat"
	post_init_icon_state = "trenchcoat"
	greyscale_config = /datum/greyscale_config/trenchcoat
	greyscale_config_worn = /datum/greyscale_config/trenchcoat/worn
	greyscale_colors = "#414344"
	flags_1 = IS_PLAYER_COLORABLE_1
	blood_overlay_type = "coat"
	flags_inv = HIDEBELT

/obj/item/clothing/suit/toggle/jacket/trenchcoat/Initialize(mapload)
	. = ..()
	allowed += GLOB.improvised_firearm_allowed

/obj/item/clothing/suit/jacket/blazer
	name = "blazer jacket"
	desc = "A blazer jacket."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/jacket/blazer"
	post_init_icon_state = "blazer"
	greyscale_config = /datum/greyscale_config/blazer
	greyscale_config_worn = /datum/greyscale_config/blazer/worn
	greyscale_colors = "#414344"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/jacket/oversized
	name = "oversized jacket"
	desc = "An oversized jacket."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/jacket/oversized"
	post_init_icon_state = "jacket_oversized"
	greyscale_config = /datum/greyscale_config/jacket_oversized
	greyscale_config_worn = /datum/greyscale_config/jacket_oversized/worn
	greyscale_colors = "#414344"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/jacket/fancy
	name = "fancy fur coat"
	desc = "Rated 10 out of 10 in Cosmo for best coat brand."
	icon = 'icons/map_icons/clothing/suit/_suit.dmi'
	icon_state = "/obj/item/clothing/suit/jacket/fancy"
	post_init_icon_state = "fancy_coat"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	greyscale_config = /datum/greyscale_config/fancy_coat
	greyscale_config_worn = /datum/greyscale_config/fancy_coat/worn
	greyscale_colors = "#EDE3DC#414344"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/suit/jacket/bomber
	name = "bomber jacket"
	desc = "Aviators not included."
	icon_state = "bomberjacket"
	inhand_icon_state = "brownjsuit"

/obj/item/clothing/suit/jacket/bomber/Initialize(mapload)
	. = ..()
	allowed += GLOB.improvised_firearm_allowed

/obj/item/clothing/suit/jacket/leather
	name = "leather jacket"
	desc = "Pompadour not included."
	icon_state = "leatherjacket"
	inhand_icon_state = "hostrench"
	resistance_flags = NONE
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT

/obj/item/clothing/suit/jacket/leather/Initialize(mapload)
	. = ..()
	allowed += GLOB.improvised_firearm_allowed

/obj/item/clothing/suit/jacket/leather/biker
	name = "biker jacket"
	desc = "You think I'm not even worth a single dollar, but I feel like a millionare."
	icon_state = "leatherjacket_biker"

/obj/item/clothing/suit/jacket/puffer
	name = "puffer jacket"
	desc = "A thick jacket with a rubbery, water-resistant shell."
	icon_state = "pufferjacket"
	inhand_icon_state = "hostrench"
	armor_type = /datum/armor/jacket_puffer

/datum/armor/jacket_puffer
	bio = 50

/obj/item/clothing/suit/jacket/puffer/vest
	name = "puffer vest"
	desc = "A thick vest with a rubbery, water-resistant shell."
	icon_state = "puffervest"
	inhand_icon_state = "armor"
	body_parts_covered = CHEST|GROIN
	cold_protection = CHEST|GROIN
	armor_type = /datum/armor/puffer_vest

/datum/armor/puffer_vest
	bio = 30

/obj/item/clothing/suit/jacket/miljacket
	name = "military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable."
	icon_state = "militaryjacket"
	inhand_icon_state = null

/obj/item/clothing/suit/jacket/miljacket/Initialize(mapload)
	. = ..()
	allowed += GLOB.improvised_firearm_allowed

/obj/item/clothing/suit/jacket/letterman
	name = "letterman jacket"
	desc = "A classic brown letterman jacket. Looks pretty hot and heavy."
	icon_state = "letterman"
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/jacket/letterman/Initialize(mapload)
	. = ..()
	allowed += GLOB.improvised_firearm_allowed

/obj/item/clothing/suit/jacket/letterman_red
	name = "red letterman jacket"
	desc = "A letterman jacket in a sick red color. Radical."
	icon_state = "letterman_red"
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/jacket/letterman_red/Initialize(mapload)
	. = ..()
	allowed += GLOB.improvised_firearm_allowed

/obj/item/clothing/suit/jacket/letterman_syndie
	name = "blood-red letterman jacket"
	desc = "Oddly, this jacket seems to have a large S on the back..."
	icon_state = "letterman_s"
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/jacket/letterman_syndie/Initialize(mapload)
	. = ..()
	allowed += GLOB.improvised_firearm_allowed

/obj/item/clothing/suit/jacket/letterman_nanotrasen
	name = "blue letterman jacket"
	desc = "A blue letterman jacket with a proud Nanotrasen N on the back. The tag says that it was made in Space China."
	icon_state = "letterman_n"
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)

/obj/item/clothing/suit/jacket/letterman_nanotrasen/Initialize(mapload)
	. = ..()
	allowed += GLOB.improvised_firearm_allowed
