/obj/item/cartridge/virus/clown
	var/storemode = 0
	var/bananapoints = 0
	var/list/clown_buyables = list()

/obj/item/cartridge/virus/clown/has_independent_menu()
	if(!storemode)
		return 0
	var/dat = "<html><head><title><font color='#66ff66'>Honk Store!!</font></title></head><body bgcolor=\"#ff99ff\">"
	dat += "<P><font color='#66ff66'><B>Banana Points: [bananapoints]</B></font></P>"
	for(var/path in clown_buyables)
		if(!ispath(path)||!clown_buyables[path])
			continue
		var/list/paramslist = params2list(clown_buyables[path])
		if(!paramslist || !paramslist.len)
			continue
		if(!paramslist["name"] || !paramslist["cost"] || !isnum(paramslist["cost"]))
			continue
		dat += "<font color='#66ff66'><A href='?src=\ref[src];buy=[path]'>[paramslist[name]]</A> Cost: [paramslist["cost"]]</font><br>"
	return 1

/obj/item/cartridge/virus/clown/Topic(href, href_list)
	if(host_pda)
		if (!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
			usr.unset_machine()
			usr << browse(null, "window=pda")
			return
		if(href_list["buy"] && ispath(text2path(href_list["buy"])) && storemode)
			var/thepath = text2path(href_list["buy"])
			if(thepath in clown_buyables && usr.mind && usr.mind.assigned_role == "Clown")
				var/list/paramslist = params2list(clown_buyables[thepath])
				if(istype(paramslist,/list) && paramslist.len)
					if(bananapoints >= text2num(paramslist["cost"]))
						var/atom/movable/AM = new thepath()
						usr.put_in_hands(AM)
					else
						to_chat(usr,"Not enough banana points.")

/obj/item/cartridge/virus/clown/insert_item(mob/user,obj/item/I)
	if(istype(I,/obj/item/reagent_containers/food/snacks/grown/banana))
		var/obj/item/reagent_containers/food/snacks/grown/banana/banana = I
		if(user.doUnEquip(I))


