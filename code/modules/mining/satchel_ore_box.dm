/**********************Satchel**************************/

/obj/item/weapon/satchel
	icon = 'mining.dmi'
	icon_state = "satchel"
	name = "Mining Satchel"
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 25; //the number of ore pieces it can carry.
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	w_class = 1

/obj/item/weapon/satchel/attack_self(mob/user as mob)
	for (var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = user.loc
	user << "\blue You empty the satchel."
	return

/obj/item/weapon/satchel/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/ore))
		var/obj/item/weapon/ore/O = W
		src.contents += O;
	return

/obj/item/weapon/satchel/verb/toggle_mode()
	set name = "Switch Satchel Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The satchel now picks up all ore in a tile at once."
		if(0)
			usr << "The satchel now picks up one ore at a time."

/obj/item/weapon/satchel/borg
	icon = 'mining.dmi'
	icon_state = "satchel"
	name = "Cyborg Mining Satchel"
	mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	capacity = 75; //the number of ore pieces it can carry.

/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'mining.dmi'
	icon_state = "orebox0"
	name = "Ore Box"
	desc = "A heavy box used for storing ore."
	density = 1
	var/capacity = 200

	New()
		if(prob(50))
			icon_state = "orebox1"

/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/ore))
		if (src.contents.len + 1 <= src.capacity)
			src.contents += W;
		else
			user << "\blue The ore box is full."

	else if (istype(W, /obj/item/weapon/satchel))
		if ( src.contents.len + W.contents.len <= src.capacity)
			src.contents += W.contents
			user << "\blue You empty the satchel into the box."
		else
			user << "\blue The ore box is full."

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
	var/amt_archaeo = 0
	for (var/obj/item/weapon/ore/C in contents)
		if (istype(C,/obj/item/weapon/ore/diamond))
			amt_diamond++;
		else if (istype(C,/obj/item/weapon/ore/glass))
			amt_glass++;
		else if (istype(C,/obj/item/weapon/ore/plasma))
			amt_plasma++;
		else if (istype(C,/obj/item/weapon/ore/iron))
			amt_iron++;
		else if (istype(C,/obj/item/weapon/ore/silver))
			amt_silver++;
		else if (istype(C,/obj/item/weapon/ore/gold))
			amt_gold++;
		else if (istype(C,/obj/item/weapon/ore/uranium))
			amt_uranium++;
		else if (istype(C,/obj/item/weapon/ore/clown))
			amt_clown++;
		else if (istype(C,/obj/item/weapon/ore/strangerock))
			amt_archaeo++;

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
	if (amt_archaeo)
		dat += text("Strange rocks: [amt_archaeo]<br>")

	dat += text("<br><br><A href='?src=\ref[src];removeall=1'>Empty box</A>")
	user << browse("[dat]", "window=orebox")
	return

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["removeall"])
		for (var/obj/item/weapon/ore/O in contents)
			contents -= O
			O.loc = src.loc
		usr << "\blue You empty the box."
	src.updateUsrDialog()
	return