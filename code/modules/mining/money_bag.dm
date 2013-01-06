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
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0
	var/amt_adamantine = 0

	for (var/obj/item/weapon/coin/C in contents)
		if (istype(C,/obj/item/weapon/coin/diamond))
			amt_diamond++;
		if (istype(C,/obj/item/weapon/coin/plasma))
			amt_plasma++;
		if (istype(C,/obj/item/weapon/coin/iron))
			amt_iron++;
		if (istype(C,/obj/item/weapon/coin/silver))
			amt_silver++;
		if (istype(C,/obj/item/weapon/coin/gold))
			amt_gold++;
		if (istype(C,/obj/item/weapon/coin/uranium))
			amt_uranium++;
		if (istype(C,/obj/item/weapon/coin/clown))
			amt_clown++;
		if (istype(C,/obj/item/weapon/coin/adamantine))
			amt_adamantine++;

	var/dat = text("<b>The contents of the moneybag reveal...</b><br>")
	if (amt_gold)
		dat += text("Gold coins: [amt_gold] <A href='?src=\ref[src];remove=gold'>Remove one</A><br>")
	if (amt_silver)
		dat += text("Silver coins: [amt_silver] <A href='?src=\ref[src];remove=silver'>Remove one</A><br>")
	if (amt_iron)
		dat += text("Metal coins: [amt_iron] <A href='?src=\ref[src];remove=iron'>Remove one</A><br>")
	if (amt_diamond)
		dat += text("Diamond coins: [amt_diamond] <A href='?src=\ref[src];remove=diamond'>Remove one</A><br>")
	if (amt_plasma)
		dat += text("Plasma coins: [amt_plasma] <A href='?src=\ref[src];remove=plasma'>Remove one</A><br>")
	if (amt_uranium)
		dat += text("Uranium coins: [amt_uranium] <A href='?src=\ref[src];remove=uranium'>Remove one</A><br>")
	if (amt_clown)
		dat += text("Bananium coins: [amt_clown] <A href='?src=\ref[src];remove=clown'>Remove one</A><br>")
	if (amt_adamantine)
		dat += text("Adamantine coins: [amt_adamantine] <A href='?src=\ref[src];remove=adamantine'>Remove one</A><br>")
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
		var/obj/item/weapon/coin/COIN
		switch(href_list["remove"])
			if("gold")
				COIN = locate(/obj/item/weapon/coin/gold,src.contents)
			if("silver")
				COIN = locate(/obj/item/weapon/coin/silver,src.contents)
			if("iron")
				COIN = locate(/obj/item/weapon/coin/iron,src.contents)
			if("diamond")
				COIN = locate(/obj/item/weapon/coin/diamond,src.contents)
			if("plasma")
				COIN = locate(/obj/item/weapon/coin/plasma,src.contents)
			if("uranium")
				COIN = locate(/obj/item/weapon/coin/uranium,src.contents)
			if("clown")
				COIN = locate(/obj/item/weapon/coin/clown,src.contents)
			if("adamantine")
				COIN = locate(/obj/item/weapon/coin/adamantine,src.contents)
		if(!COIN)
			return
		COIN.loc = src.loc
	return



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