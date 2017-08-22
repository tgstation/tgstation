
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox"
	name = "ore box"
	desc = "A heavy wooden box, which can be filled with a lot of ores."
	density = TRUE
	pressure_resistance = 5*ONE_ATMOSPHERE

/obj/structure/ore_box/attackby(obj/item/W, mob/user, params)
	if (istype(W, /obj/item/ore))
		if(!user.drop_item())
			return
		W.forceMove(src)
	else if (istype(W, /obj/item/storage))
		var/obj/item/storage/S = W
		for(var/obj/item/ore/O in S.contents)
			S.remove_from_storage(O, src) //This will move the item to this item's contents
		to_chat(user, "<span class='notice'>You empty the ore in [S] into \the [src].</span>")
	else if(istype(W, /obj/item/crowbar))
		playsound(loc, W.usesound, 50, 1)
		var/obj/item/crowbar/C = W
		if(do_after(user, 50*C.toolspeed, target = src))
			user.visible_message("[user] pries \the [src] apart.", "<span class='notice'>You pry apart \the [src].</span>", "<span class='italics'>You hear splitting wood.</span>")
			deconstruct(TRUE, user)
	else
		return ..()

/obj/structure/ore_box/examine(mob/living/user)
	if(Adjacent(user) && istype(user))
		show_contents(user)
	. = ..()

/obj/structure/ore_box/attack_hand(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/attack_robot(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/proc/show_contents(mob/user)
	var/dat = text("<b>The contents of the ore box reveal...</b><br>")
	var/list/oretypes = list()
	for(var/obj/item/ore/O in contents)
		oretypes |= O.type
	for(var/i in oretypes)
		var/obj/item/ore/T = locate(i) in contents
		dat += "[capitalize(T.name)]: [count_by_type(contents, T.type)]<br>"
	dat += text("<br><br><A href='?src=\ref[src];removeall=1'>Empty box</A>")
	user << browse(dat, "window=orebox")

/obj/structure/ore_box/proc/dump_box_contents()
	for(var/obj/item/ore/O in contents)
		O.forceMove(loc)

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	if(!Adjacent(usr))
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["removeall"])
		dump_box_contents()
		to_chat(usr, "<span class='notice'>You empty the box.</span>")
	updateUsrDialog()


/obj/structure/ore_box/deconstruct(disassembled = TRUE, mob/user)
	var/obj/item/stack/sheet/mineral/wood/WD = new (loc, 4)
	if(user)
		WD.add_fingerprint(user)
	dump_box_contents()
	qdel(src)
