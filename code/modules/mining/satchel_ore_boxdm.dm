/**********************Satchel**************************/

/obj/item/weapon/satchel
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	name = "Mining Satchel"
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 50; //the number of ore pieces it can carry.
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
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	name = "Cyborg Mining Satchel"
	mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	capacity = 200; //the number of ore pieces it can carry.

/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox"
	name = "Ore Box"
	desc = "It's heavy"
	density = 1

/obj/structure/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/ore))
		src.contents += W;
	if (istype(W, /obj/item/weapon/satchel))
		src.contents += W.contents
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
		usr << "\blue You empty the box"
	src.updateUsrDialog()
	return

/**********************Sheet Snatcher**************************/
//Stolen satchel code, making it a box just wouldn't work well for this -Sieve

/obj/item/weapon/sheetsnatcher
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	name = "Sheet Snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."
	var/mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 300; //the number of sheets it can carry.
	flags = FPRINT | TABLEPASS
	w_class = 3
	var/metal = 0//Holder values, to have a count of how much of each type is in the snatcher
	var/glass = 0
	var/gold = 0
	var/silver = 0
	var/diamond = 0
	var/plasma = 0
	var/uranium = 0
	var/clown = 0
	var/euranium = 0
	var/plasteel = 0
	var/rglass = 0

/obj/item/weapon/sheetsnatcher/attack_self(mob/user as mob)//Credit goes to carn on this one
	var/location = get_turf(src)    //fetches the turf containing the object. (so stuff spawns on the floor)
	while(metal)
		var/obj/item/stack/sheet/metal/S = new (location)
		var/stacksize = min(metal,50)  //maximum stack size is 50!
		S.amount = stacksize
		metal -= stacksize
	while(glass)
		var/obj/item/stack/sheet/glass/S = new (location)
		var/stacksize = min(glass,50)
		S.amount = stacksize
		glass -= stacksize
	while(gold)
		var/obj/item/stack/sheet/gold/S = new (location)
		var/stacksize = min(gold,50)
		S.amount = stacksize
		gold -= stacksize
	while(silver)
		var/obj/item/stack/sheet/silver/S = new (location)
		var/stacksize = min(silver,50)
		S.amount = stacksize
		silver -= stacksize
	while(diamond)
		var/obj/item/stack/sheet/diamond/S = new (location)
		var/stacksize = min(diamond,50)
		S.amount = stacksize
		diamond -= stacksize
	while(plasma)
		var/obj/item/stack/sheet/plasma/S = new (location)
		var/stacksize = min(plasma,50)
		S.amount = stacksize
		plasma -= stacksize
	while(uranium)
		var/obj/item/stack/sheet/uranium/S = new (location)
		var/stacksize = min(uranium,50)
		S.amount = stacksize
		uranium -= stacksize
	while(clown)
		var/obj/item/stack/sheet/clown/S = new (location)
		var/stacksize = min(clown,50)
		S.amount = stacksize
		clown -= stacksize
	while(euranium)
		var/obj/item/stack/sheet/enruranium/S = new (location)
		var/stacksize = min(euranium,50)
		S.amount = stacksize
		euranium -= stacksize
	while(plasteel)
		var/obj/item/stack/sheet/plasteel/S = new (location)
		var/stacksize = min(plasteel,50)
		S.amount = stacksize
		plasteel -= stacksize
	while(rglass)
		var/obj/item/stack/sheet/rglass/S = new (location)
		var/stacksize = min(rglass,50)
		S.amount = stacksize
		rglass -= stacksize
	if(!metal && !glass && !gold && !silver && !diamond && !plasma && !uranium && !clown && !euranium && !plasteel && !rglass)
		user << "\blue You empty the snatch."
		return


/obj/item/weapon/sheetsnatcher/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/stack/sheet))
		var/obj/item/stack/sheet/O = W
		src.add(O,user)
	return

/obj/item/weapon/sheetsnatcher/verb/toggle_mode()
	set name = "Switch Sheet Snatcher Method"
	set category = "Object"

	mode = !mode
	switch (mode)
		if(1)
			usr << "The snatcher now picks up all sheets on a tile at once."
		if(0)
			usr << "The snatcher now picks up one sheet at a time."

/obj/item/weapon/sheetsnatcher/proc/add(var/obj/item/stack/sheet/S as obj, mob/user as mob)//Handles sheets, adds them to the holder values
	if((S.name == "Sandstone Bricks") || (S.name == "Wood Planks"))//Does not pick up sandstone or wood, as they are not true sheets
		return
	var/current = metal+glass+gold+silver+diamond+plasma+uranium+clown+euranium+plasteel+rglass
	if(capacity == current)//If it's full, you're done
		user << "\red The snatcher is full."
		return
	if(capacity < current + S.amount)//If the stack will fill it up
		var/diff = capacity - current
		switch(S.name)
			if("metal")
				metal += diff
			if("glass")
				glass += diff
			if("silver")
				silver += diff
			if("gold")
				gold += diff
			if("diamond")
				diamond += diff
			if("solid plasma")
				plasma += diff
			if("uranium")
				uranium += diff
			if("bananium")
				clown += diff
			if("enriched uranium")
				euranium += diff
			if("plasteel")
				plasteel += diff
			if("reinforced glass")
				rglass += diff
		S.amount -= diff
		user << "\blue You add the [S.name] to the [name]"
	else
		switch(S.name)
			if("metal")
				metal += S.amount
			if("glass")
				glass += S.amount
			if("silver")
				silver += S.amount
			if("gold")
				gold += S.amount
			if("diamond")
				diamond += S.amount
			if("solid plasma")
				plasma += S.amount
			if("uranium")
				uranium += S.amount
			if("bananium")
				clown += S.amount
			if("enriched uranium")
				euranium += S.amount
			if("plasteel")
				plasteel += S.amount
			if("reinforced glass")
				rglass += S.amount
		user << "\blue You add the [S.name] to the [name]"
		del (S)
	return

/obj/item/weapon/sheetsnatcher/borg
	name = "Sheet Snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization