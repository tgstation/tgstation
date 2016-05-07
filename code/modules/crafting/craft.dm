/datum/personal_crafting
	var/busy
	var/viewing_category = 1 //typical powergamer starting on the Weapons tab
	var/list/categories = list(CAT_WEAPON,CAT_AMMO,CAT_ROBOT,CAT_FOOD,CAT_MISC,CAT_PRIMAL)
	var/datum/action/innate/crafting/button

/datum/personal_crafting/proc/check_contents(datum/crafting_recipe/R, list/contents)
	main_loop:
		for(var/A in R.reqs)
			var/needed_amount = R.reqs[A]
			for(var/B in contents)
				if(ispath(B, A))
					if(contents[B] >= R.reqs[A])
						continue main_loop
					else
						needed_amount -= contents[B]
						if(needed_amount <= 0)
							continue main_loop
						else
							continue
			return 0
	for(var/A in R.chem_catalysts)
		if(contents[A] < R.chem_catalysts[A])
			return 0
	return 1

/datum/personal_crafting/proc/get_environment(mob/user)
	. = list()
	. += user.r_hand
	. += user.l_hand
	if(!istype(user.loc, /turf))
		return
	var/list/L = block(get_step(user, SOUTHWEST), get_step(user, NORTHEAST))
	for(var/A in L)
		var/turf/T = A
		if(T.Adjacent(user))
			. += T.contents


/datum/personal_crafting/proc/get_surroundings(mob/user)
	. = list()
	for(var/obj/item/I in get_environment(user))
		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			.[I.type] += S.amount
		else
			if(istype(I, /obj/item/weapon/reagent_containers))
				var/obj/item/weapon/reagent_containers/RC = I
				if(RC.flags & OPENCONTAINER)
					for(var/datum/reagent/A in RC.reagents.reagent_list)
						.[A.type] += A.volume
			.[I.type] += 1

/datum/personal_crafting/proc/check_tools(mob/user, datum/crafting_recipe/R, list/contents)
	if(!R.tools.len)
		return 1
	var/list/possible_tools = list()
	for(var/obj/item/I in user.contents)
		if(istype(I, /obj/item/weapon/storage))
			for(var/obj/item/SI in I.contents)
				possible_tools += SI.type
		possible_tools += I.type
	possible_tools += contents

	main_loop:
		for(var/A in R.tools)
			for(var/I in possible_tools)
				if(ispath(I,A))
					continue main_loop
			return 0
	return 1

/datum/personal_crafting/proc/construct_item(mob/user, datum/crafting_recipe/R)
	var/list/contents = get_surroundings(user)
	var/send_feedback = 1
	if(check_contents(R, contents))
		if(check_tools(user, R, contents))
			if(do_after(user, R.time, target = user))
				contents = get_surroundings(user)
				if(!check_contents(R, contents))
					return ", missing component."
				if(!check_tools(user, R, contents))
					return ", missing tool."
				var/list/parts = del_reqs(R, contents, user)
				var/atom/movable/I = new R.result (user.loc)
				I.CheckParts(parts, R)
				if(send_feedback)
					feedback_add_details("object_crafted","[I.type]")
				return 0
			return "."
		return ", missing tool."
	return ", missing component."

/datum/personal_crafting/proc/del_reqs(datum/crafting_recipe/R, list/contents, mob/user)
	var/list/surroundings
	var/list/Deletion = list()
	. = list()
	var/data
	var/amt
	main_loop:
		for(var/A in R.reqs)
			amt = R.reqs[A]
			surroundings = get_environment(user)
			surroundings -= Deletion
			if(ispath(A, /datum/reagent))
				var/datum/reagent/RG = new A
				var/datum/reagent/RGNT
				while(amt > 0)
					var/obj/item/weapon/reagent_containers/RC = locate() in surroundings
					RG = RC.reagents.get_reagent(A)
					if(RG)
						if(!locate(RG.type) in Deletion)
							Deletion += new RG.type()
						if(RG.volume > amt)
							RG.volume -= amt
							data = RG.data
							RC.reagents.conditional_update(RC)
							RG = locate(RG.type) in Deletion
							RG.volume = amt
							RG.data += data
							continue main_loop
						else
							surroundings -= RC
							amt -= RG.volume
							RC.reagents.reagent_list -= RG
							RC.reagents.conditional_update(RC)
							RGNT = locate(RG.type) in Deletion
							RGNT.volume += RG.volume
							RGNT.data += RG.data
							qdel(RG)
			else if(ispath(A, /obj/item/stack))
				var/obj/item/stack/S
				var/obj/item/stack/SD
				while(amt > 0)
					S = locate(A) in surroundings
					if(S.amount >= amt)
						if(!locate(S.type) in Deletion)
							SD = new S.type()
							Deletion += SD
						S.use(amt)
						SD = locate(S.type) in Deletion
						SD.amount += amt
						continue main_loop
					else
						amt -= S.amount
						if(!locate(S.type) in Deletion)
							Deletion += S
						else
							data = S.amount
							S = locate(S.type) in Deletion
							S.add(data)
						surroundings -= S
			else
				var/atom/movable/I
				while(amt > 0)
					I = locate(A) in surroundings
					Deletion += I
					surroundings -= I
					amt--
	var/list/partlist = list(R.parts.len)
	for(var/M in R.parts)
		partlist[M] = R.parts[M]
	for(var/A in R.parts)
		if(istype(A, /datum/reagent))
			var/datum/reagent/RG = locate(A) in Deletion
			if(RG.volume > partlist[A])
				RG.volume = partlist[A]
			. += RG
			Deletion -= RG
			continue
		else if(istype(A, /obj/item/stack))
			var/obj/item/stack/ST = locate(A) in Deletion
			if(ST.amount > partlist[A])
				ST.amount = partlist[A]
			. += ST
			Deletion -= ST
			continue
		else
			while(partlist[A] > 0)
				var/atom/movable/AM = locate(A) in Deletion
				. += AM
				Deletion -= AM
				partlist[A] -= 1
	while(Deletion.len)
		var/DL = Deletion[Deletion.len]
		Deletion.Cut(Deletion.len)
		qdel(DL)

/datum/personal_crafting/proc/craft(mob/user)
	if(user.incapacitated() || user.lying)
		return
	var/list/surroundings = get_surroundings(user)
	var/dat = "<h3>Crafting menu</h3>"
	if(busy)
		dat += "<div class='statusDisplay'>"
		dat += "Crafting in progress...</div>"
	else
		dat += "<A href='?src=\ref[src];backwardCat=1'><--</A>"
		dat += " [categories[prev_cat()]] |"
		dat += " <B>[categories[viewing_category]]</B> "
		dat += "| [categories[next_cat()]] "
		dat += "<A href='?src=\ref[src];forwardCat=1'>--></A><BR><BR>"

		dat += "<div class='statusDisplay'>"

		//Filter the recipes we can craft to the top
		var/list/can_craft = list()
		var/list/cant_craft = list()
		for(var/datum/crafting_recipe/R in crafting_recipes)
			if(R.category != categories[viewing_category])
				continue
			if(check_contents(R, surroundings))
				can_craft += R
			else
				cant_craft += R

		for(var/datum/crafting_recipe/R in can_craft)
			dat += build_recipe_text(R, surroundings)
		for(var/datum/crafting_recipe/R in cant_craft)
			dat += build_recipe_text(R, surroundings)


		dat += "</div>"

	var/datum/browser/popup = new(user, "crafting", "Crafting", 500, 500)
	popup.set_content(dat)
	popup.open()
	return

/datum/personal_crafting/Topic(href, href_list)
	if(usr.stat || usr.lying)
		return
	if(href_list["make"])
		var/datum/crafting_recipe/TR = locate(href_list["make"])
		busy = 1
		craft(usr)
		var/fail_msg = construct_item(usr, TR)
		if(!fail_msg)
			usr << "<span class='notice'>[TR.name] constructed.</span>"
		else
			usr << "<span class ='warning'>Construction failed[fail_msg]</span>"
		busy = 0
		craft(usr)
	if(href_list["forwardCat"])
		viewing_category = next_cat()
		usr << "<span class='notice'>Category is now [categories[viewing_category]].</span>"
		craft(usr)
	if(href_list["backwardCat"])
		viewing_category = prev_cat()
		usr << "<span class='notice'>Category is now [categories[viewing_category]].</span>"
		craft(usr)

//Next works nicely with modular arithmetic
/datum/personal_crafting/proc/next_cat()
	. = viewing_category % categories.len + 1

//Previous can go fuck itself
/datum/personal_crafting/proc/prev_cat()
	if(viewing_category == categories.len)
		. = viewing_category-1
	else
		. = viewing_category % categories.len - 1
	if(. <= 0)
		. = categories.len

/datum/personal_crafting/proc/build_recipe_text(datum/crafting_recipe/R, list/contents)
	. = ""
	var/name_text = ""
	var/req_text = ""
	var/tool_text = ""
	var/catalist_text = ""
	if(check_contents(R, contents))
		name_text ="<A href='?src=\ref[src];make=\ref[R]'>[R.name]</A>"

	else
		name_text = "<span class='linkOff'>[R.name]</span>"

	if(name_text)
		for(var/A in R.reqs)
			if(ispath(A, /obj))
				var/obj/O = A
				req_text += " [R.reqs[A]] [initial(O.name)]"
			else if(ispath(A, /datum/reagent))
				var/datum/reagent/RE = A
				req_text += " [R.reqs[A]] [initial(RE.name)]"

		if(R.chem_catalysts.len)
			catalist_text += ", Catalysts:"
			for(var/C in R.chem_catalysts)
				if(ispath(C, /datum/reagent))
					var/datum/reagent/RE = C
					catalist_text += " [R.chem_catalysts[C]] [initial(RE.name)]"

		if(R.tools.len)
			tool_text += ", Tools:"
			for(var/O in R.tools)
				if(ispath(O, /obj))
					var/obj/T = O
					tool_text += " [R.tools[O]] [initial(T.name)]"

		. = "[name_text][req_text][tool_text][catalist_text]<BR>"