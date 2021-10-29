/obj/machinery/vending/ashclothingvendor
	name = "\improper Ashland Clothing Storage"
	desc = "A large container, filled with various clothes for the Ash Walkers."
	product_ads = "Praise the Necropolis"
	icon = 'modular_skyrat/modules/ashwalkers/icons/vendor/vending.dmi'
	icon_state = "ashclothvendor"
	icon_deny = "necrocrate"

	products = list( //Relatively normal to have, I GUESS
		/obj/item/clothing/under/costume/gladiator/ash_walker/tribal = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/robe = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/shaman = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/chiefrags = 15,
		/obj/item/clothing/under/costume/gladiator/ash_walker/yellow = 15,
		/obj/item/clothing/suit/ashwalkermantle = 12,
		/obj/item/clothing/suit/ashwalkermantle/cape = 12,
		/obj/item/clothing/shoes/jackboots/ashwalker = 12,
		/obj/item/clothing/shoes/jackboots/ashwalker/legate = 12,
		/obj/item/clothing/shoes/wraps/ashwalker = 10,
		/obj/item/clothing/head/shamanash = 3,
		/obj/item/clothing/gloves/military/claw = 5,
		/obj/item/clothing/gloves/military/ashwalk = 10
	)

/obj/machinery/vending/ashclothingvendor/Initialize(mapload)
	. = ..()
	onstation = FALSE
