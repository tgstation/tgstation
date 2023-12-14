/obj/item/clothing/suit/hooded/tiger_co_hoodie
	name = "religious hoodie"
	desc = "A red hoodie with an orange cross mark going through its back and front. Or a double axe. Or a 'T', perhaps?"
	icon = 'icons/obj/clothing/suits/jacket.dmi'
	worn_icon = 'icons/mob/clothing/suits/jacket.dmi'
	icon_state = "tiger_co_hoodie"
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/lighter,
		/obj/item/radio,
		/obj/item/storage/belt/holster,
	)

	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	inhand_icon_state = null
	species_exception = list(/datum/species/golem)
	hoodtype = /obj/item/clothing/head/hooded/tiger_co_hood

/obj/item/clothing/head/hooded/tiger_co_hood
	name = "red hood"
	desc = "A red hood with an orange trim. Not exactly the type for bringing things to grandma in. Nor for hunting wolves."
	icon = 'icons/obj/clothing/head/chaplain.dmi'
	worn_icon = 'icons/mob/clothing/head/chaplain.dmi'
	icon_state = "tiger_co_hood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	inhand_icon_state = null

/obj/item/clothing/suit/hooded/tiger_co_inquisitor
	name = "tiger inquisitor's armor"
	desc = "The proper attire of Tiger Cooperative associated chaplain-inquisitors. Almost surprising it doesn't feature a fleshy third arm or something."
	icon = 'icons/obj/clothing/suits/chaplain.dmi'
	worn_icon = 'icons/mob/clothing/suits/chaplain.dmi'
	icon_state = "tiger_co_inquisitor_armour"
	hoodtype = /obj/item/clothing/head/hooded/tiger_co_hood
	inhand_icon_state = null
	blood_overlay_type = "armor"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor_type = /datum/armor/tiger_co_inquisitor

/datum/armor/tiger_co_inquisitor
	melee = 35
	bullet = 25
	laser = 25
	energy = 35
	bomb = 25
	fire = 50
	acid = 50
	wound = 10

/obj/item/clothing/under/syndicate/tacticool/puffed_shirt
	name = "red puffed shirt"
	desc = "Mix of streetwear and utility. Though it might look expensive, it's mostly made from recycled packages of Waffle Corp. products."
	icon_state = "puffed_shirt"

/obj/item/clothing/mask/mummy/tiger_co
	name = "set of bandadges"
	desc = "To cover results of ritual scarification, disfigurement from drugs, and your ugly face."

/obj/item/clothing/gloves/bandages
	name = "set of arm wraps"
	desc = "These are used to cover up wounds along the arms. Deep ones."
	icon_state = "bandages"

/datum/outfit/tiger_fanatic
	name = "Tiger Fanatic Corpse"
	uniform = /obj/item/clothing/under/syndicate/tacticool/puffed_shirt
	suit = /obj/item/clothing/suit/hooded/tiger_co_hoodie
	shoes = /obj/item/clothing/shoes/laceup
	mask = /obj/item/clothing/mask/mummy/tiger_co
	gloves = /obj/item/clothing/gloves/bandages
