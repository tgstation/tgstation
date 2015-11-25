/*****************************Money bag********************************/

/obj/item/weapon/moneybag
	icon = 'icons/obj/storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	flags = FPRINT
	siemens_coefficient = 1
	force = 10.0
	throwforce = 2.0
	w_class = 4.0

	var/datum/materials/coin_value

/obj/item/weapon/moneybag/attack_hand(user as mob)
	var/credits=0
	if(!coin_value)
		coin_value = getFromPool(/datum/materials)
	else
		coin_value.resetVariables() //make its storage be 0

	for (var/obj/item/weapon/coin/C in contents)
		if (istype(C,/obj/item/weapon/coin))
			coin_value.addAmount(C.material, 1)
			credits += C.credits

	var/dat = "<b>The contents of the moneybag reveal...</b><ul>"
	for(var/ore_id in coin_value.storage)
		var/datum/material/ore_info = coin_value.getMaterial(ore_id)
		if(coin_value.storage[ore_id])
			dat += "<li>[ore_info.processed_name] coins: [coin_value.storage[ore_id]] <A href='?src=\ref[src];remove=[ore_id]'>Remove one</A></li>"
	dat += "</ul><b>Total haul:</b> $[credits]"
	user << browse("[dat]", "window=moneybag")

/obj/item/weapon/moneybag/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/coin))
		var/obj/item/weapon/coin/C = W
		to_chat(user, "<span class='notice'>You add the [C.name] into the bag.</span>")
		usr.drop_item(W, src)
	if (istype(W, /obj/item/weapon/moneybag))
		var/obj/item/weapon/moneybag/C = W
		for (var/obj/O in C.contents)
			contents += O
		to_chat(user, "<span class='notice'>You empty the [C.name] into the bag.</span>")
	return

/obj/item/weapon/moneybag/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["remove"])
		var/datum/material/material = coin_value.getMaterial(href_list["remove"])
		var/obj/item/weapon/coin/COIN=locate(material.cointype, src.contents)
		if(!COIN)
			return
		COIN.loc = get_turf(src)
		if(!usr.get_active_hand())
			usr.put_in_hands(COIN)
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