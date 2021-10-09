/**
 * This file adds new products to vending machines upon /Initialize()
 * Thanks to this, it can be added moduarly.
 */

/obj/machinery/vending/autodrobe/Initialize(mapload)
	products += list(
		/obj/item/clothing/shoes/beefman_shoes = 3,
	)
	. = ..()
