/*****************************Money bag********************************/

/obj/item/weapon/moneybag
	icon = 'icons/obj/storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 2.0
	w_class = 4.0

/obj/item/weapon/moneybag/attack_hand(user as mob)
	var/credits=0
	var/list/ore=list()
	for(var/oredata in typesof(/datum/material) - /datum/material)
		var/datum/material/ore_datum = new oredata
		ore[ore_datum.id]=ore_datum

	for (var/obj/item/weapon/coin/C in contents)
		if (istype(C,/obj/item/weapon/coin))
			var/datum/material/ore_info=ore[C.material]
			ore_info.stored++
			ore[C.material]=ore_info
			credits += C.credits

	var/dat = "<b>The contents of the moneybag reveal...</b><ul>"
	for(var/ore_id in ore)
		var/datum/material/ore_info=ore[ore_id]
		if(ore_info.stored)
			dat += "<li>[ore_info.processed_name] coins: [ore_info.stored] <A href='?src=\ref[src];remove=[ore_id]'>Remove one</A></li>"
	dat += "</ul><b>Total haul:</b> $[credits]"
	user << browse("[dat]", "window=moneybag")

/obj/item/weapon/moneybag/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/coin))
		var/obj/item/weapon/coin/C = W
		user << "\blue You add the [C.name] into the bag."
		usr.drop_item()
		contents += C
	if (istype(W, /obj/item/weapon/moneybag))
		var/obj/item/weapon/moneybag/C = W
		for (var/obj/O in C.contents)
			contents += O;
		user << "\blue You empty the [C.name] into the bag."
	return

/obj/item/weapon/moneybag/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["remove"])
		var/typepath = text2path("/obj/item/weapon/coin/[href_list["remove"]]")
		var/obj/item/weapon/coin/COIN=locate(typepath, src.contents)
		if(!COIN)
			return
		COIN.loc = src.loc
	return

/obj/item/weapon/moneybag/MouseDrop(obj/over_object as obj)
	if(ishuman(usr))
		if(over_object == usr)
			var/mob/living/carbon/human/H = usr
			H.put_in_hands(src)


/obj/item/weapon/moneybag/vault

/obj/item/weapon/moneybag/vault/New()
	..()
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/silver(src)
	new /obj/item/weapon/coin/gold(src)
	new /obj/item/weapon/coin/gold(src)
	new /obj/item/weapon/coin/adamantine(src)