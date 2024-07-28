/obj/machinery/vending/wardrobe/robo_wardrobe
	icon = 'modular_bandastation/objects/icons/obj/machines/vending.dmi'
	icon_state = "robodrobe"
	light_mask = null

/obj/machinery/vending/wardrobe/robo_wardrobe/build_inventories(start_empty)
	products |= list(
		/obj/item/clothing/head/beret = 2,
		/obj/item/clothing/head/cowboy/roboticist = 2,
		/obj/item/clothing/head/soft/roboticist_cap = 2,
		/obj/item/clothing/suit/hooded/roboticist_cloak = 2,
		/obj/item/clothing/suit/toggle/jacket/roboticist = 2,
		/obj/item/clothing/suit/hooded/wintercoat/science/robotics/alt = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/red = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/hoodie = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/skirt = 2,
		/obj/item/clothing/under/rank/rnd/roboticist/alt/skirt/red = 2,
		)
	. = ..()
