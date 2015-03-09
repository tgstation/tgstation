/obj/structure/table
	var/list/table_contents = list()

/obj/structure/table/MouseDrop(atom/over)
	if(over != usr)
		return
	interact(usr)

/obj/structure/table/proc/check_contents(datum/table_recipe/R)
	check_table()
	main_loop:
		for(var/A in R.reqs)
			for(var/B in table_contents)
				if(ispath(B, A))
					if(table_contents[B] >= R.reqs[A])
						continue main_loop
			return 0
	for(var/A in R.chem_catalists)
		if(table_contents[A] < R.chem_catalists[A])
			return 0
	return 1

/obj/structure/table/proc/check_table()
	table_contents = list()
	for(var/obj/item/I in loc)
		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			table_contents[I.type] += S.amount
		else
			if(istype(I, /obj/item/weapon/reagent_containers))
				for(var/datum/reagent/R in I.reagents.reagent_list)
					table_contents[R.type] += R.volume

			table_contents[I.type] += 1

/obj/structure/table/proc/check_tools(mob/user, datum/table_recipe/R)
	if(!R.tools.len)
		return 1
	var/list/possible_tools = list()
	for(var/obj/item/I in user.contents)
		if(istype(I, /obj/item/weapon/storage))
			for(var/obj/item/SI in I.contents)
				possible_tools += SI.type
		else
			possible_tools += I.type
	possible_tools += table_contents
	var/i = R.tools.len
	var/I
	for(var/A in R.tools)
		I = possible_tools.Find(A)
		if(I)
			possible_tools.Cut(I, I+1)
			i--
		else
			break
	return !i

/obj/structure/table/proc/construct_item(mob/user, datum/table_recipe/R)
	check_table()
	if(check_contents(R) && check_tools(user, R))
		if(do_after(user, R.time))
			if(!check_contents(R) || !check_tools(user, R))
				return 0
			var/list/parts = del_reqs(R)
			var/atom/movable/I = new R.result (loc)
			for(var/A in parts)
				if(istype(A, /obj/item))
					var/atom/movable/B = A
					B.loc = I
				else
					if(!I.reagents)
						I.reagents = new /datum/reagents()
					I.reagents.reagent_list.Add(A)
			I.CheckParts()
			return 1
	return 0

/obj/structure/table/proc/del_reqs(datum/table_recipe/R)
	var/list/Deletion = list()
	var/amt
	for(var/A in R.reqs)
		amt = R.reqs[A]
		if(ispath(A, /obj/item/stack))
			var/obj/item/stack/S
			stack_loop:
				for(var/B in table_contents)
					if(ispath(B, A))
						while(amt > 0)
							S = locate(B) in loc
							if(S.amount >= amt)
								S.use(amt)
								break stack_loop
							else
								amt -= S.amount
								qdel(S)
		else if(ispath(A, /obj/item))
			var/obj/item/I
			item_loop:
				for(var/B in table_contents)
					if(ispath(B, A))
						while(amt > 0)
							I = locate(B) in loc
							Deletion.Add(I)
							I.loc = null //remove it from the table loc so that we don't locate the same item every time (will be relocated inside the crafted item in construct_item())
							amt--
						break item_loop
		else
			var/datum/reagent/RG = new A
			reagent_loop:
				for(var/B in table_contents)
					if(ispath(B, /obj/item/weapon/reagent_containers))
						var/obj/item/RC = locate(B) in loc
						if(RC.reagents.has_reagent(RG.id, amt))
							RC.reagents.remove_reagent(RG.id, amt)
							RG.volume = amt
							Deletion.Add(RG)
							break reagent_loop
						else if(RC.reagents.has_reagent(RG.id))
							Deletion.Add(RG)
							RG.volume += RC.reagents.get_reagent_amount(RG.id)
							amt -= RC.reagents.get_reagent_amount(RG.id)
							RC.reagents.del_reagent(RG.id)

	for(var/A in R.parts)
		for(var/B in Deletion)
			if(!istype(B, A))
				Deletion.Remove(B)
				qdel(B)

	return Deletion

/obj/structure/table/interact(mob/user)
	if(user.stat || user.lying || !Adjacent(user))
		return
	check_table()
	if(!table_contents.len)
		return
	user.face_atom(src)
	var/dat = "<h3>Construction menu</h3>"
	dat += "<div class='statusDisplay'>"
	if(busy)
		dat += "Construction in progress...</div>"
	else
		for(var/datum/table_recipe/R in table_recipes)
			if(check_contents(R))
				dat += "<A href='?src=\ref[src];make=\ref[R]'>[R.name]</A><BR>"
		dat += "</div>"

	var/datum/browser/popup = new(user, "table", "Table", 300, 300)
	popup.set_content(dat)
	popup.open()
	return

/obj/structure/table/Topic(href, href_list)
	if(usr.stat || !Adjacent(usr) || usr.lying)
		return
	if(href_list["make"])
		var/datum/table_recipe/TR = locate(href_list["make"])
		busy = 1
		interact(usr)
		if(construct_item(usr, TR))
			usr << "<span class='notice'>[TR.name] constructed.</span>"
		else
			usr << "<span class ='warning'>Construction failed.</span>"
		busy = 0
		interact(usr)