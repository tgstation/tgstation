/datum/blackmarket_item/clothing
	category = "Clothing"

/datum/blackmarket_item/clothing/ninja_mask
	name = "Space Ninja Mask"
	desc = "Apart from being acid, lava, fireproof and being hard to take off someone it does nothing special on it's own."
	item = /obj/item/clothing/mask/gas/space_ninja
	
	price_min = 200
	price_max = 500
	stock_max = 3
	availability_prob = 40

/datum/blackmarket_item/clothing/durathread_vest
	name = "Durathread Vest"
	desc = ""
	item = /obj/item/clothing/suit/armor/vest/durathread

	price_min = 200
	price_max = 400
	stock_max = 4
	availability_prob = 50

/datum/blackmarket_item/clothing/durathread_helmet
	name = "Durathread Helmet"
	desc = ""
	item = /obj/item/clothing/head/helmet/durathread

	price_min = 100
	price_max = 200
	stock_max = 4
	availability_prob = 50

/datum/blackmarket_item/clothing/full_spacesuit_set
	name = "Nanotrasen Branded Spacesuit Box"
	desc = "A few boxes of \"Old Style\" space suits fell off the back of a space truck."
	item = /obj/item/storage/box

	price_min = 1500
	price_max = 4000
	stock_max = 3
	availability_prob = 30

/datum/blackmarket_item/clothing/full_spacesuit_set/spawn_item(loc)
	var/obj/item/storage/box/B = ..()
	B.name = "Space suit Box"
	B.contents += new /obj/item/clothing/suit/space
	B.contents += new /obj/item/clothing/head/helmet/space
	return B

/datum/blackmarket_item/clothing/chameleon_hat
	name = "Chameleon Hat"
	desc = "Pick any hat you want with this Handy device. Not Quality Tested."
	item = /obj/item/clothing/head/chameleon/broken

	price_min = 100
	price_max = 200
	stock_max = 2
	availability_prob = 70
