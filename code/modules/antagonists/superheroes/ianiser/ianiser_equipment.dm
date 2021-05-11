/obj/item/clothing/suit/hooded/ian_costume/ianiser
	name = "insulated corgi costume"
	desc = "An insulated corgi costume. Neat!"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|HANDS
	armor = list(MELEE = 50, BULLET = 50, LASER = 40, ENERGY = 50, BOMB = 45, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

	hoodtype = /obj/item/clothing/head/hooded/ian_hood/ianiser

	siemens_coefficient = 0
	permeability_coefficient = 0.05

/obj/item/clothing/head/hooded/ian_hood/ianiser
	name = "corgi hood"
	desc = "An insulated corgi hood with a mask attached to it. It has some strange glowy aura around it."
	worn_icon_state = "ian_man"
	worn_y_offset = 3
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS

	armor = list(MELEE = 50, BULLET = 50, LASER = 40, ENERGY = 50, BOMB = 45, BIO = 100, RAD = 70, FIRE = 100, ACID = 100, WOUND = 25)

	siemens_coefficient = 0
	permeability_coefficient = 0.05

/obj/item/clothing/suit/hooded/ian_costume/ianiser/winter
	desc = "An insulated corgi costume. Neat!  This one has some additional fur to make it even warmer."
	hoodtype = /obj/item/clothing/head/hooded/ian_hood/ianiser/winter

	cold_protection = CHEST|GROIN|ARMS|LEGS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/head/hooded/ian_hood/ianiser/winter
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/shoes/wheelys/skishoes/ianiser
	name = "advanced ski shoes"
	desc = "A pair of modified ski shoes with automatic space lube appliers that allow user to gain great speed in cost of their stability."
	slowdown = SHOES_SLOWDOWN
	wheels = /obj/vehicle/ridden/scooter/skateboard/wheelys/skishoes/ianiser

/obj/item/clothing/suit/hooded/ian_costume/ianiser/Initialize()
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/hooded/ian_costume/ianiser/winter/Initialize()
	. = ..()
	allowed = GLOB.security_hardsuit_allowed
