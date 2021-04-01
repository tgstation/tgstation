/obj/item/clothing/gloves/color/white/griffin
	name = "griffin gloves"
	desc = "A pair of white insulated gloves."
	siemens_coefficient = 0
	permeability_coefficient = 0.05

/obj/item/clothing/suit/toggle/owlwings/griffinwings/griffin
	name = "Griffin's cloak"
	desc = "A plush white cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive your captives mad."

	armor = list(MELEE = 25, BULLET = 25, LASER = 20, ENERGY = 30, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 10)
	slowdown = -0.2 //Less armor, more speed

/obj/item/clothing/suit/toggle/owlwings/griffinwings/griffin/Initialize()
	. = ..()
	allowed = GLOB.security_hardsuit_allowed

/obj/item/storage/belt/utility/griffon/PopulateContents()
	new /obj/item/screwdriver/power(src)
	new /obj/item/crowbar/power(src)
	new /obj/item/weldingtool/experimental(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/flashlight(src)
	new /obj/item/analyzer(src)

/obj/item/tank/jetpack/oxygen/harness/griffin
	name = "jet harness (oxygen)"
	desc = "A modified jet harness with an expanded air tank. It has some white feathers on it."
	volume = 90

/obj/item/clothing/head/griffin/griffin
	body_parts_covered = HEAD
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEARS|HIDEEYES|HIDESNOUT
	armor = list(MELEE = 25, BULLET = 25, LASER = 20, ENERGY = 30, BOMB = 25, BIO = 0, RAD = 0, FIRE = 50, ACID = 50, WOUND = 10)
