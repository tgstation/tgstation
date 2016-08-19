
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox"
	name = "ore box"
	desc = "A heavy wooden box, which can be filled with a lot of ores."
	density = 1
	pressure_resistance = 5*ONE_ATMOSPHERE

/obj/structure/ore_box/attackby(obj/item/weapon/W, mob/user, params)
	if (istype(W, /obj/item/weapon/ore))
		if(!user.drop_item())
			return
		W.loc = src
	else if (istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		for(var/obj/item/weapon/ore/O in S.contents)
			S.remove_from_storage(O, src) //This will move the item to this item's contents
		user << "<span class='notice'>You empty the ore in [S] into \the [src].</span>"
	else if(istype(W, /obj/item/weapon/crowbar))
		playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		var/obj/item/weapon/crowbar/C = W
		var/time = 50
		if(do_after(user, time/C.toolspeed, target = src))
			user.visible_message("[user] pries \the [src] apart.", "<span class='notice'>You pry apart \the [src].</span>", "<span class='italics'>You hear splitting wood.</span>")
			// If you change the amount of wood returned, remember
			// to change the construction costs
			var/obj/item/stack/sheet/mineral/wood/wo = new (loc, 4)
			wo.add_fingerprint(user)
			deconstruct()
	else
		return ..()

/obj/structure/ore_box/attack_hand(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/attack_robot(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/proc/show_contents(mob/user)
	var/dat = text("<b>The contents of the ore box reveal...</b><br>")
	var/list/oretypes = list()
	for(var/obj/item/weapon/ore/O in contents)
		oretypes |= O.type
	for(var/i in oretypes)
		var/obj/item/weapon/ore/T = locate(i) in contents
		dat += "[capitalize(T.name)]: [count_by_type(contents, T.type)]<br>"
	dat += text("<br><br><A href='?src=\ref[src];removeall=1'>Empty box</A>")
	user << browse("[dat]", "window=orebox")

/obj/structure/ore_box/proc/dump_contents()
	for (var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = src.loc

/obj/structure/ore_box/Topic(href, href_list)
	if(..())
		return
	if(!Adjacent(usr))
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["removeall"])
		dump_contents()
		usr << "<span class='notice'>You empty the box.</span>"
	src.updateUsrDialog()
	return

/obj/structure/ore_box/ex_act(severity, target)
	if(prob(100 / severity) && severity < 3)
		qdel(src) //nothing but ores can get inside unless its a bug and ores just return nothing on ex_act, not point in calling it on them

/obj/structure/ore_box/Destroy()
	dump_contents()
	return ..()

