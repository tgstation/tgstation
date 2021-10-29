/obj/machinery/vending/wardrobe/canLoadItem(obj/item/I,mob/user)
	return (I.type in products)

/obj/machinery/vending/wardrobe/syndie_wardrobe
	name = "\improper SynDrobe"
	desc = "A vending machine for our boys in red, now in brand new crimson!"
	icon = 'modular_skyrat/modules/mapping/icons/obj/vending.dmi'
	icon_state = "syndrobe"
	product_ads = "Put a Donk on it!;Aim, Style, Shoot!;Brigged for wearing the best!"
	vend_reply = "Thank you for using the SynDrobe!"
	products = list(/obj/item/clothing/under/syndicate = 3,
					/obj/item/clothing/under/syndicate/skirt = 3,
					/obj/item/clothing/under/syndicate/bloodred/sleepytime = 3,
					/obj/item/clothing/under/syndicate/sniper = 3,
					/obj/item/clothing/under/syndicate/camo = 3,
					/obj/item/clothing/under/syndicate/combat = 3,
					/obj/item/clothing/shoes/combat = 3,
					/obj/item/clothing/mask/gas/syndicate = 3)
	contraband = list(/obj/item/knife/combat = 1,
					/obj/item/clothing/under/syndicate/coldres = 2,
					/obj/item/clothing/shoes/combat/coldres = 2)
	premium = list(/obj/item/knife/combat/survival = 1,
					/obj/item/storage/fancy/cigarettes/cigpack_syndicate = 5,
					/obj/item/clothing/gloves/combat = 3)
	refill_canister = /obj/item/vending_refill/wardrobe/syndie_wardrobe
	light_color = COLOR_MOSTLY_PURE_RED

/obj/item/vending_refill/wardrobe/syndie_wardrobe
	machine_name = "SynDrobe"
