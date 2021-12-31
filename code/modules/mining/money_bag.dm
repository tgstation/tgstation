/*****************************Money bag********************************/

/obj/item/storage/bag/money
	name = "money bag"
	icon_state = "moneybag"
	worn_icon_state = "moneybag"
	force = 10
	throwforce = 0
	resistance_flags = FLAMMABLE
	max_integrity = 100
	atom_size = ITEM_SIZE_BULKY
	max_atom_size = ITEM_SIZE_NORMAL
	max_total_atom_size = ITEM_SIZE_NORMAL * 14
	max_items = 40

/obj/item/storage/bag/money/Initialize(mapload)
	. = ..()
	if(prob(20))
		icon_state = "moneybagalt"
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.set_holdable(list(/obj/item/coin, /obj/item/stack/spacecash, /obj/item/holochip))

/obj/item/storage/bag/money/vault/PopulateContents()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/adamantine(src)

///Used in the dutchmen pirate shuttle.
/obj/item/storage/bag/money/dutchmen/PopulateContents()
	for(var/iteration in 1 to 9)
		new /obj/item/coin/silver/doubloon(src)
	for(var/iteration in 1 to 9)
		new /obj/item/coin/gold/doubloon(src)
	new /obj/item/coin/adamantine/doubloon(src)
