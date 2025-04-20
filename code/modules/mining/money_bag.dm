/*****************************Money bag********************************/

/obj/item/storage/bag/money
	name = "money bag"
	desc = "A bag for storing your profits."
	icon_state = "moneybag"
	worn_icon_state = "moneybag"
	force = 10
	throwforce = 0
	resistance_flags = FLAMMABLE
	max_integrity = 100
	w_class = WEIGHT_CLASS_BULKY
	storage_type = /datum/storage/bag/money

/obj/item/storage/bag/money/Initialize(mapload)
	. = ..()
	if(prob(20))
		icon_state = "moneybagalt"

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
