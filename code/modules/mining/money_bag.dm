/*****************************Money bag********************************/

/obj/item/storage/bag/money
	name = "money bag"
	icon_state = "moneybag"
	worn_icon_state = "moneybag"
	force = 10
	throwforce = 0
	resistance_flags = FLAMMABLE
	max_integrity = 100
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/bag/money/Initialize(mapload)
	. = ..()
	if(prob(20))
		icon_state = "moneybagalt"
	atom_storage.max_slots = 40
	atom_storage.max_specific_storage = 40
	atom_storage.set_holdable(list(/obj/item/coin, /obj/item/stack/spacecash, /obj/item/holochip))

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
