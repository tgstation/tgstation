/*****************************Money bag********************************/

/obj/item/weapon/storage/bag/money
	name = "money bag"
	icon_state = "moneybag"
	force = 10
	throwforce = 0
	resistance_flags = FLAMMABLE
	max_integrity = 100
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 80
	max_combined_w_class = 40
	can_hold = list(/obj/item/weapon/coin, /obj/item/stack/spacecash)


/obj/item/weapon/storage/bag/money/vault/New()
	..()
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/gold(src)
	new /obj/item/weapon/coin/gold(src)
	new /obj/item/weapon/coin/adamantine(src)