/datum/personal_crafting
	var/busy
	var/viewing_category = 1 //typical powergamer starting on the Weapons tab
	var/list/categories = list(CAT_WEAPON,CAT_AMMO,CAT_ROBOT,CAT_FOOD,CAT_MISC,CAT_PRIMAL)
	var/datum/action/innate/crafting/button





/*	This is what procs do:
	get_environment - gets a list of things accessable for crafting by user
	get_surroundings - takes a list of things and makes a list of key-types to values-amounts of said type in the list
	check_contents - takes a recipe and a key-type list and checks if said recipe can be done with available stuff
	check_tools - takes recipe, a key-type list, and a user and checks if there are enough tools to do the stuff, checks bugs one level deep
	construct_item - takes a recipe and a user, call all the checking procs, calls do_after, checks all the things again, calls del_reqs, creates result, calls CheckParts of said result with argument being list returned by deel_reqs
	del_reqs - takes recipe and a user, loops over the recipes reqs var and tries to find everything in the list make by get_environment and delete it/add to parts list, then returns the said list
*/




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
			for(var/B in T)
				var/atom/movable/AM = B
				if(AM.flags & HOLOGRAM)
					continue
				. += AM

/datum/personal_crafting/proc/get_surroundings(mob/user)
	. = list()
	for(var/obj/item/I in get_environment(user))
		if(I.flags & HOLOGRAM)
			continue
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
	for(var/A in R.parts)
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
				var/list/parts = del_reqs(R, user)
				var/atom/movable/I = new R.result (get_turf(user.loc))
				I.CheckParts(parts, R)
				if(send_feedback)
					feedback_add_details("object_crafted","[I.type]")
				return 0
			return "."
		return ", missing tool."
	return ", missing component."


/*Del reqs works like this:

	Loop over reqs var of the recipe
	Set var amt to the value current cycle req is pointing to, its amount of type we need to delete
	Get var/surroundings list of things accessable to crafting by get_environment()
	Check the type of the current cycle req
		If its reagent then do a while loop, inside it try to locate() reagent containers, inside such containers try to locate needed reagent, if there isnt remove thing from surroundings
			If there is enough reagent in the search result then delete the needed amount, create the same type of reagent with the same data var and put it into deletion list
			If there isnt enough take all of that reagent from the container, put into deletion list, substract the amt var by the volume of reagent, remove the container from surroundings list and keep searching
			While doing above stuff check deletion list if it already has such reagnet, if yes merge instead of adding second one
		If its stack check if it has enough amount
			If yes create new stack with the needed amount and put in into deletion list, substract taken amount from the stack
			If no put all of the stack in the deletion list, substract its amount from amt and keep searching
			While doing above stuff check deletion list if it already has such stack type, if yes try to merge them instead of adding new one
		If its anything else just locate() in in the list in a while loop, each find --s the amt var and puts the found stuff in deletion loop

	Then do a loop over parts var of the recipe
		Do similar stuff to what we have done above, but now in deletion list, until the parts conditions are satisfied keep taking from the deletion list and putting it into parts list for return

	After its done loop over deletion list and delete all the shit that wasnt taken by parts loop

	del_reqs return the list of parts resulting object will recieve as argument of CheckParts proc, on the atom level it will add them all to the contents, on all other levels it calls ..() and does whatever is needed afterwards but from contents list already
*/

/datum/personal_crafting/proc/del_reqs(datum/crafting_recipe/R, mob/user)
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
					else
						surroundings -= RC
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
	if(user.incapacitated() || user.lying || istype(user.loc, /obj/mecha))
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