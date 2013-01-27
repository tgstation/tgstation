
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "Ore Box"
	desc = "A heavy box used for storing ore."
	density = 1

/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/ore))
		src.contents += W;
	if (istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		S.hide_from(usr)
		for(var/obj/item/weapon/ore/O in S.contents)
			S.remove_from_storage(O, src) //This will move the item to this item's contents
		user << "\blue You empty the satchel into the box."
	return

/obj/structure/ore_box/attack_hand(obj, mob/user as mob)
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_glass = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0
	var/amt_strange = 0


	for (var/obj/item/weapon/ore/C in contents)
		if (istype(C,/obj/item/weapon/ore/diamond))
			amt_diamond++;
		if (istype(C,/obj/item/weapon/ore/glass))
			amt_glass++;
		if (istype(C,/obj/item/weapon/ore/plasma))
			amt_plasma++;
		if (istype(C,/obj/item/weapon/ore/iron))
			amt_iron++;
		if (istype(C,/obj/item/weapon/ore/silver))
			amt_silver++;
		if (istype(C,/obj/item/weapon/ore/gold))
			amt_gold++;
		if (istype(C,/obj/item/weapon/ore/uranium))
			amt_uranium++;
		if (istype(C,/obj/item/weapon/ore/clown))
			amt_clown++;
		if (istype(C,/obj/item/weapon/ore/strangerock))
			amt_strange++;

	var/dat = text("<b>The contents of the ore box reveal...</b><br>")
	if (amt_gold)
		dat += text("Gold ore: [amt_gold]<br>")
	if (amt_silver)
		dat += text("Silver ore: [amt_silver]<br>")
	if (amt_iron)
		dat += text("Metal ore: [amt_iron]<br>")
	if (amt_glass)
		dat += text("Sand: [amt_glass]<br>")
	if (amt_diamond)
		dat += text("Diamond ore: [amt_diamond]<br>")
	if (amt_plasma)
		dat += text("Plasma ore: [amt_plasma]<br>")
	if (amt_uranium)
		dat += text("Uranium ore: [amt_uranium]<br>")
	if (amt_clown)
		dat += text("Bananium ore: [amt_clown]<br>")
	if (amt_strange)
		dat += text("Strange rocks: [amt_strange]<br>")

	dat += text("<br><br><A href='?src=\ref[src];removeall=1'>Empty box</A>")
	user << browse("[dat]", "window=orebox")
	return

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["removeall"])
		for (var/obj/item/weapon/ore/O in contents)
			contents -= O
			O.loc = src.loc
		usr << "\blue You empty the box"
	src.updateUsrDialog()
	return

