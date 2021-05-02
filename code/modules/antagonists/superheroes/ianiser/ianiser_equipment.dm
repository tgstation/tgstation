/obj/item/clothing/suit/hooded/ian_costume/ianiser
	name = "insulated corgi costume"
	desc = "An insulated corgi costume. Neat!"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|HANDS
	armor = list(MELEE = 15, BULLET = 25, LASER = 15, ENERGY = 15, BOMB = 25, BIO = 0, RAD = 0, FIRE = 25, ACID = 30)

	hoodtype = /obj/item/clothing/head/hooded/ian_hood/ianiser

	siemens_coefficient = 0
	permeability_coefficient = 0.05

/obj/item/clothing/head/hooded/ian_hood/ianiser
	name = "corgi hood"
	desc = "An insulated corgi hood with a mask attached to it. It has some strange glowy aura around it."
	worn_icon_state = "ian_man"
	worn_y_offset = 7
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS

	armor = list(MELEE = 15, BULLET = 25, LASER = 15, ENERGY = 15, BOMB = 25, BIO = 0, RAD = 0, FIRE = 25, ACID = 30)

	siemens_coefficient = 0
	permeability_coefficient = 0.05
