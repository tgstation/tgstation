var/global/datum/crafting_controller/crafting_master

/datum/crafting_recipe
	var/name = ""
	var/reqs[] = list()
	var/result_path
	var/tools[] = list()
	var/time = 0
	var/parts[] = list()
	var/chem_catalists[] = list()
	var/can_be_deconstructed = 0

/datum/crafting_recipe/New()
	spawn(10)
		crafting_master.all_crafting_recipes |= src

//////////////////////////////////////
//                                  //
//     ~*  E X A M P L E S  *~      //
//                                  //
//////////////////////////////////////

/datum/crafting_recipe/IED
	name = "IED"
	result_path = /obj/item/weapon/grenade/iedcasing
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
	/obj/item/stack/cable_coil = 1,
	/obj/item/device/assembly/igniter = 1,
	/obj/item/weapon/reagent_containers/food/drinks/soda_cans = 1,
	/datum/reagent/fuel = 10)
	time = 80

/datum/crafting_recipe/stunprod
	name = "Stunprod"
	result_path = /obj/item/weapon/melee/baton/cattleprod
	reqs = list(/obj/item/weapon/handcuffs/cable = 1,
	/obj/item/stack/rods = 1,
	/obj/item/weapon/wirecutters = 1,
	/obj/item/weapon/stock_parts/cell = 1)
	time = 80
	parts = list(/obj/item/weapon/stock_parts/cell = 1)

/datum/crafting_recipe/ed209
	name = "ED209"
	result_path = /obj/machinery/bot/ed209
	reqs = list(/obj/item/robot_parts/robot_suit = 1,
	/obj/item/clothing/head/helmet = 1,
	/obj/item/clothing/suit/armor/vest = 1,
	/obj/item/robot_parts/l_leg = 1,
	/obj/item/robot_parts/r_leg = 1,
	/obj/item/stack/sheet/metal = 5,
	/obj/item/stack/cable_coil = 5,
	/obj/item/weapon/gun/energy/taser = 1,
	/obj/item/weapon/stock_parts/cell = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	tools = list(/obj/item/weapon/weldingtool, /obj/item/weapon/screwdriver)
	time = 120

/datum/crafting_recipe/secbot
	name = "Secbot"
	result_path = /obj/machinery/bot/secbot
	reqs = list(/obj/item/device/assembly/signaler = 1,
	/obj/item/clothing/head/helmet = 1,
	/obj/item/weapon/melee/baton = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	tools = list(/obj/item/weapon/weldingtool)
	time = 120

/datum/crafting_recipe/cleanbot
	name = "Cleanbot"
	result_path = /obj/machinery/bot/cleanbot
	reqs = list(/obj/item/weapon/reagent_containers/glass/bucket = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	time = 80

/datum/crafting_recipe/floorbot
	name = "Floorbot"
	result_path = /obj/machinery/bot/floorbot
	reqs = list(/obj/item/weapon/storage/toolbox/mechanical = 1,
	/obj/item/stack/tile/plasteel = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	time = 80

/datum/crafting_recipe/medbot
	name = "Medbot"
	result_path = /obj/machinery/bot/medbot
	reqs = list(/obj/item/device/healthanalyzer = 1,
	/obj/item/weapon/storage/firstaid = 1,
	/obj/item/device/assembly/prox_sensor = 1,
	/obj/item/robot_parts/r_arm = 1)
	time = 80

/datum/crafting_recipe/flamethrower
	name = "Flamethrower"
	result_path = /obj/item/weapon/flamethrower
	reqs = list(/obj/item/weapon/weldingtool = 1,
	/obj/item/device/assembly/igniter = 1,
	/obj/item/stack/rods = 2)
	tools = list(/obj/item/weapon/screwdriver)
	time = 20


/////////////////////////////////////////////////////////


/datum/crafting_controller
	var/list/families = list()
	var/list/all_crafting_points = list()
	var/list/all_crafting_recipes = list()

/datum/crafting_controller/New()
	init_subtypes(/datum/crafting_recipe, all_crafting_recipes)

/datum/crafting_controller/proc/add_family(name, list/members)
	var/list/family = members
	families.Add(name = family)

/datum/crafting_controller/proc/add_member(family_name, member)
	var/list/family = families[family_name]
	family.Add(member)

/datum/crafting_controller/proc/add_recipe_to_family(family_name, datum/recipe)
	var/list/family = families[family_name]
	for(var/datum/crafting_holder/A in family)
		A.add_recipe(recipe)

/datum/crafting_controller/proc/remove_recipe_from_family(family_name, datum/recipe)
	var/list/family = families[family_name]
	for(var/datum/crafting_holder/A in family)
		A.remove_recipe(recipe)

/datum/crafting_controller/proc/remove_member(family_name, member)
	var/list/family = families[family_name]
	family.Remove(member)

/datum/crafting_controller/proc/remove_family(family_name)
	var/list/family = families[family_name]
	families.Remove(family)
	families.Remove(family_name)

/datum/crafting_holder
	var/name
	var/atom/holder
	var/recipes
	var/busy

/datum/crafting_holder/New(atom/location)
	location.craft_holder = src
	holder = location
	spawn(10)
		crafting_master.all_crafting_points |= src

/datum/crafting_holder/proc/add_recipe(recipe)
	recipes |= recipe

/datum/crafting_holder/proc/remove_recipe(recipe)
	recipes -= recipe

/datum/crafting_holder/proc/deconstruct(mob/user, datum/crafting_recipe/R)
	if(!R.can_be_deconstructed)
		return
	var/list/result = list()
	var/list/holder_contents = check_holder()
	var/atom/movable/target = locate(R.result_path) in holder_contents
	if(!target)
		return
	if(check_tools(user, R, holder_contents))
		for(var/A in R.reqs)
			var/amount = R.reqs[A]
			if(ispath(A, /datum/reagent))
				for(var/obj/item/weapon/reagent_containers/RC in holder_contents)
					var/diff = RC.reagents.total_volume - RC.reagents.maximum_volume
					if(diff)
						diff = min(diff, amount)
						var/datum/reagent/C = new A()
						C.volume = diff
						RC.reagents.reagent_list.Add(C)
						RC.reagents.total_volume += diff
						result.Add(C)
						amount -= diff
						if(!amount)
							break
			else
				while(amount)
					result.Add(new A(holder.loc))
					amount--
	qdel(target)
	return result

/datum/crafting_holder/proc/check_contents(datum/crafting_recipe/R, list/holder_contents)
	main_loop:
		for(var/A in R.reqs)
			for(var/B in holder_contents)
				if(ispath(B, A))
					if(holder_contents[B] >= R.reqs[A])
						continue main_loop
			return 0
	for(var/A in R.chem_catalists)
		if(holder_contents[A] < R.chem_catalists[A])
			return 0
	return 1

/datum/crafting_holder/proc/check_holder()
	var/list/holder_contents = list()
	for(var/obj/I in holder.loc)
		if(istype(I, /obj/item/stack))
			var/obj/item/stack/S = I
			holder_contents[I.type] += S.amount
		else
			if(istype(I, /obj/item/weapon/reagent_containers))
				for(var/datum/reagent/R in I.reagents.reagent_list)
					holder_contents[R.type] += R.volume

			holder_contents[I.type] += 1

	return holder_contents

/datum/crafting_holder/proc/check_tools(mob/user, datum/crafting_recipe/R, list/holder_contents)
	if(!R.tools.len)
		return 1
	var/list/possible_tools = list()
	for(var/obj/item/I in user.contents)
		if(istype(I, /obj/item/weapon/storage))
			for(var/obj/item/SI in I.contents)
				possible_tools += SI.type
		else
			possible_tools += I.type
	possible_tools += holder_contents
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

/datum/crafting_holder/proc/construct_item(mob/user, datum/crafting_recipe/R)
	var/list/holder_contents = check_holder()
	if(check_contents(R, holder_contents) && check_tools(user, R, holder_contents))
		if(do_after(user, R.time))
			if(!check_contents(R, holder_contents) || !check_tools(user, R, holder_contents))
				return 0
			var/list/parts = del_reqs(R, holder_contents)
			var/atom/movable/I = new R.result_path
			for(var/A in parts)
				if(istype(A, /obj/item))
					var/atom/movable/B = A
					B.loc = I
				else
					if(!I.reagents)
						I.reagents = new /datum/reagents()
					I.reagents.reagent_list.Add(A)
			I.CheckParts()
			I.loc = holder.loc
			return 1
	return 0

/datum/crafting_holder/proc/del_reqs(datum/crafting_recipe/R, list/holder_contents)
	var/list/Deletion = list()
	var/amt
	for(var/A in R.reqs)
		amt = R.reqs[A]
		if(ispath(A, /obj/item/stack))
			var/obj/item/stack/S
			stack_loop:
				for(var/B in holder_contents)
					if(ispath(B, A))
						while(amt > 0)
							S = locate(B) in holder.loc
							if(S.amount >= amt)
								S.use(amt)
								break stack_loop
							else
								amt -= S.amount
								qdel(S)
		else if(ispath(A, /obj/item))
			var/obj/item/I
			item_loop:
				for(var/B in holder_contents)
					if(ispath(B, A))
						while(amt > 0)
							I = locate(B) in holder.loc
							Deletion.Add(I)
							amt--
						break item_loop
		else
			var/datum/reagent/RG = new A
			reagent_loop:
				for(var/B in holder_contents)
					if(ispath(B, /obj/item/weapon/reagent_containers))
						var/obj/item/RC = locate(B) in holder.loc
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

/datum/crafting_holder/proc/interact(mob/user)
	var/list/holder_contents = check_holder()
	if(!holder_contents.len)
		return
	var/dat = "<h3>Construction menu</h3>"
	dat += "<div class='statusDisplay'>"
	if(busy)
		dat += "Construction inprogress...</div>"
	else
		for(var/datum/crafting_recipe/R in recipes)
			if(check_contents(R, holder_contents))
				dat += "<A href='?src=\ref[src];make=\ref[R]'>[R.name]</A><BR>"
		dat += "</div>"

	var/datum/browser/popup = new(user, "craft", "Craft", 300, 300)
	popup.set_content(dat)
	popup.open()
	return

/datum/crafting_holder/Topic(href, href_list)
	if(usr.stat || !holder.Adjacent(usr) || usr.lying)
		return
	if(href_list["make"])
		var/datum/crafting_recipe/TR = locate(href_list["make"])
		busy = 1
		if(construct_item(usr, TR))
			usr << "<span class='notice'>[TR.name] constructed.</span>"
		else
			usr << "<span class ='warning'>Construction failed.</span>"
		busy = 0
		interact(usr)