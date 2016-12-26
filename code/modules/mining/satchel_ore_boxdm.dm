
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox"
	name = "ore box"
	desc = "A heavy wooden box, which can be filled with a lot of ores."
	density = 1
	pressure_resistance = 5*ONE_ATMOSPHERE
	var/list/obj/item/stack/ore/stack_list = list()

/obj/structure/ore_box/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/stack/ore))
		user.unEquip(W)
		add_ore(W)
	else if (istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		for(var/obj/item/stack/ore/O in S.contents)
			S.remove_from_storage(O) //This will move the item to this item's contents
			add_ore(O)
		user << "<span class='notice'>You empty the ore in [S] into \the [src].</span>"
	else if(istype(W, /obj/item/weapon/crowbar))
		playsound(loc, W.usesound, 50, 1)
		var/obj/item/weapon/crowbar/C = W
		if(do_after(user, 50*C.toolspeed, target = src))
			user.visible_message("[user] pries \the [src] apart.", "<span class='notice'>You pry apart \the [src].</span>", "<span class='italics'>You hear splitting wood.</span>")
			deconstruct(TRUE, user)
	else
		return ..()

/obj/structure/ore_box/proc/add_ore(obj/item/stack/ore/O)	//Muh copypasta
	var/obj/item/stack/ore/O2 = O.type
	if(!(O2 in stack_list))
		var/obj/item/stack/ore/O3 = new O2(src)
		O3.amount = 0
		stack_list[O2] = O3
	var/obj/item/stack/ore/storage = stack_list[O2]
	storage.amount += O.amount
	qdel(O)

/obj/structure/ore_box/attack_hand(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/attack_robot(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/proc/show_contents(mob/user)
	var/dat = text("<b>The contents of the ore box reveal...</b><br>")
	for(var/obj/item/stack/ore/S in stack_list)
		dat += "[capitalize(S)]: [S.amount]<br>"
	dat += text("<br><br><A href='?src=\ref[src];removeall=1'>Empty box</A>")
	user << browse(dat, "window=orebox")

/obj/structure/ore_box/proc/dump_box_contents()
	for(var/obj/item/stack/ore/S in stack_list)
		while(S.amount > 0)
			if(S.amount >= 50)
				new S(get_turf(src), 50)
				S.use(50)
			else
				new S(get_turf(src), S.amount)
				S.use(S.amount)
		if(S)
			qdel(S)

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	if(!Adjacent(usr))
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["removeall"])
		dump_box_contents()
		usr << "<span class='notice'>You empty the box.</span>"
	updateUsrDialog()

/obj/structure/ore_box/deconstruct(disassembled = TRUE, mob/user)
	var/obj/item/stack/sheet/mineral/wood/WD = new (loc, 4)
	if(user)
		WD.add_fingerprint(user)
	dump_box_contents()
	qdel(src)
