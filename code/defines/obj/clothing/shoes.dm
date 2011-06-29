// OMG SHOES

/obj/item/clothing/shoes
	name = "shoes"
	icon = 'shoes.dmi'

	body_parts_covered = FEET

	protective_temperature = 500
	heat_transfer_coefficient = 0.10
	permeability_coefficient = 0.50
	slowdown = SHOES_SLOWDOWN
	armor = list(melee = 0, bullet = 0, laser = 2, taser = 2, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/shoes/black
	name = "Black Shoes"
	icon_state = "black"

/obj/item/clothing/shoes/brown
	name = "Brown Shoes"
	icon_state = "brown"

/obj/item/clothing/shoes/orange
	name = "Orange Shoes"
	icon_state = "orange"
	var/chained = 0

/obj/item/clothing/shoes/swat
	name = "SWAT shoes"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	slowdown = 0
	armor = list(melee = 80, bullet = 60, laser = 50, taser = 25, bomb = 50, bio = 10, rad = 0)

/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	slowdown = 0
	protective_temperature = 700
	permeability_coefficient = 0.01
	flags = NOSLIP
	armor = list(melee = 60, bullet = 50, laser = 30, taser = 15, bomb = 30, bio = 30, rad = 30)

/obj/item/clothing/shoes/white
	name = "White Shoes"
	icon_state = "white"
	permeability_coefficient = 0.25

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "Magic Shoes"
	icon_state = "black"

/obj/item/clothing/shoes/galoshes
	desc = "Rubber boots"
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags = NOSLIP
	slowdown = 0

/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	protective_temperature = 800
	heat_transfer_coefficient = 0.01
	var/magpulse = 0
//	flags = NOSLIP //disabled by default

/obj/item/clothing/shoes/clown_shoes
	desc = "Damn, thems some big shoes."
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = 0