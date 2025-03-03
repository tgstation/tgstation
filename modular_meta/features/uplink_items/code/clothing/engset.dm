/obj/item/clothing/under/syndicate/engineer
	name = "tactical engineering jumpsuit"
	desc = "A suspicious looking jumpsuit with a white shirt underneath, is made of fire and acid resistant materials. Suitable for skirmishes somewhere, like in Space-Texas region."
	icon_state = "under_syndieeng"
	inhand_icon_state = null
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/clothing_under/syndicate/engineer
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'modular_meta/features/uplink_items/icons/clothing/obj/engset.dmi'
	worn_icon = 'modular_meta/features/uplink_items/icons/clothing/engset.dmi'

/datum/armor/clothing_under/syndicate/engineer //почему такие резисты? - одежда предназначена для сета предназначеного бегать голышом (рубаха и +- нагрудник если его можно так назвать)
	melee = 10
	bullet = 10
	fire = 50
	acid = 50
	wound = 20

/obj/item/clothing/gloves/one_hand/engineer
	name = "orange engineering glove"
	desc = "Forgotten glove of one of the engineers, only one glove was found."
	icon_state = "glove"
	inhand_icon_state = null
	armor_type = /datum/armor/gloves/one_hand/engineer
	resistance_flags = NONE
	icon = 'modular_meta/features/uplink_items/icons/clothing/obj/engset.dmi'
	worn_icon = 'modular_meta/features/uplink_items/icons/clothing/engset.dmi'

/datum/armor/gloves/one_hand/engineer
	bio = 25

/obj/item/clothing/suit/vest/engineer
	name = "engineering vest"
	desc = "A special engineering vest, made of durable materials."
	icon_state = "armor_syndieeng"
	icon = 'modular_meta/features/uplink_items/icons/clothing/obj/engset.dmi'
	worn_icon = 'modular_meta/features/uplink_items/icons/clothing/engset.dmi'
	inhand_icon_state = null
	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	armor_type = /datum/armor/vest/engineer
	allowed = null

/datum/armor/vest/engineer
	melee = 25
	bullet = 25
	laser = 25
	energy = 20
	bomb = 10
	fire = 50
	acid = 50
	wound = 10

/obj/item/storage/belt/utility/syndieeng
	name = "toolbelt"
	desc = "I wonder if that is exactly a toolbelt."
	icon_state = "belt_syndieeng"
	worn_icon_state = "belt_syndieeng"
	inhand_icon_state = null
	content_overlays = FALSE
	icon = 'modular_meta/features/uplink_items/icons/clothing/obj/engset.dmi'
	worn_icon = 'modular_meta/features/uplink_items/icons/clothing/engset.dmi'
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'

/obj/item/storage/belt/utility/syndieeng/full/PopulateContents()
	SSwardrobe.provide_type(/obj/item/gun/ballistic/automatic/pistol, src)
	SSwardrobe.provide_type(/obj/item/wrench, src)

/obj/item/storage/belt/utility/syndieeng/full/get_types_to_preload()
	var/list/to_preload = list()
	to_preload += /obj/item/gun/ballistic/automatic/pistol //когда достаёшь пистолет - он не засунется обратно, поэтому его затем положат в рюкзак, а так это обычный тулбелт с респрайтом
	to_preload += /obj/item/wrench
	return to_preload

/obj/item/clothing/head/hats/utility/syndieeng
	name = "engineer hardhat"
	inhand_icon_state = null
	icon_state = "hardhat_syndie"
	icon = 'modular_meta/features/uplink_items/icons/clothing/obj/engset.dmi'
	worn_icon = 'modular_meta/features/uplink_items/icons/clothing/engset.dmi'
	armor_type = /datum/armor/utility_hardhat
