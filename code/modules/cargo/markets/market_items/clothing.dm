/datum/market_item/clothing
	category = "Clothing"
	abstract_path = /datum/market_item/clothing

/datum/market_item/clothing/ninja_mask
	name = "Space Ninja Mask"
	desc = "Apart from being acid, lava, fireproof and being hard to take off someone it does nothing special on its own."
	item = /obj/item/clothing/mask/gas/ninja

	price_min = CARGO_CRATE_VALUE
	price_max = CARGO_CRATE_VALUE * 2.5
	stock_max = 3
	availability_prob = 40

/datum/market_item/clothing/durathread_vest
	name = "Durathread Vest"
	desc = "Don't let them tell you this stuff is \"Like asbestos\" or \"Pulled from the market for safety concerns\". It could be the difference between a robusting and a retaliation."
	item = /obj/item/clothing/suit/armor/vest/durathread

	price_min = CARGO_CRATE_VALUE
	price_max = CARGO_CRATE_VALUE * 2
	stock_max = 4
	availability_prob = 50

/datum/market_item/clothing/durathread_helmet
	name = "Durathread Helmet"
	desc = "Customers ask why it's called a helmet when it's just made from armoured fabric and I always say the same thing: No refunds."
	item = /obj/item/clothing/head/helmet/durathread

	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 4
	availability_prob = 50

/datum/market_item/tool/medsechud
	name = "MedSec HUD"
	desc = "A mostly defunct combination of security and health scanner HUDs. They don't produce these around anymore."
	item = /obj/item/clothing/glasses/hud/medsechud

	price_min = CARGO_CRATE_VALUE * 2
	price_max = CARGO_CRATE_VALUE * 3.5
	stock_max = 3
	availability_prob = 50

/datum/market_item/clothing/full_spacesuit_set
	name = "\improper Nanotrasen Branded Spacesuit Box"
	desc = "A few boxes of \"Old Style\" space suits fell off the back of a space truck."
	item = /obj/item/storage/box

	price_min = CARGO_CRATE_VALUE * 1.875
	price_max = CARGO_CRATE_VALUE * 4
	stock_max = 3
	availability_prob = 30

/datum/market_item/clothing/full_spacesuit_set/spawn_item(loc)
	var/obj/item/storage/box/B = ..()
	B.name = "Spacesuit Box"
	B.desc = "It has an NT logo on it."
	new /obj/item/clothing/suit/space(B)
	new /obj/item/clothing/head/helmet/space(B)
	return B

/datum/market_item/clothing/chameleon_hat
	name = "Chameleon Hat"
	desc = "Pick any hat you want with this Handy device. Not Quality Tested."
	item = /obj/item/clothing/head/chameleon/broken

	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 2
	availability_prob = 70

/datum/market_item/clothing/rocket_boots
	name = "Rocket Boots"
	desc = "We found a pair of jump boots and overclocked the hell out of them. No liability for grievous harm to or with a body."
	item = /obj/item/clothing/shoes/bhop/rocket

	price_min = CARGO_CRATE_VALUE * 5
	price_max = CARGO_CRATE_VALUE * 10
	stock_max = 1
	availability_prob = 40

/datum/market_item/clothing/anti_sec_pin
	name = "Subversive Pin"
	desc = "Exclusive and fashionable red pin from a limited run, proclaiming your allegiance to enemies of the Nanotrasen corporation. \
		Contains an RFID chip which interferes with common scanning equipment, to ensure that they know you are serious. Share them with your friends!"
	item = /obj/item/clothing/accessory/anti_sec_pin

	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE * 1.5
	stock_max = 5
	availability_prob = 70

/datum/market_item/clothing/floortileset
	name = "Floor-tile Camouflage Uniform"
	desc = "Hey there, looking to surprise somebody? Spy? Steal? Then you're lucky, meet our newest \
		floor-tile 'NT SCUM' styled camouflage fatigues. This is the ultimate \
		espionage uniform used by the very best. Providing the best \
		flexibility, with our latest Camo-tech threads. Perfect for \
		risky espionage hallway operations. Enjoy our product!"
	item = /obj/item/storage/box/floor_camo
	price_min = CARGO_CRATE_VALUE * 0.5
	price_max = CARGO_CRATE_VALUE
	stock_max = 3
	availability_prob = 40

/datum/market_item/clothing/collar_bomb
	name = "Collar Bomb Kit"
	desc = "An unpatented and questionably ethical kit consisting of a low-yield explosive collar and a remote to trigger it."
	item = /obj/item/storage/box/collar_bomb
	price_min = CARGO_CRATE_VALUE * 3.5
	price_max = CARGO_CRATE_VALUE * 4.5
	stock_max = 3
	availability_prob = 60
