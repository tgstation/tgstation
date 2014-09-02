#define FAB_SCREEN_WIDTH		1040
#define FAB_SCREEN_HEIGHT		750

/obj/machinery/r_n_d/fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab"
	desc = "Nothing is being built."
	idle_power_usage = 20
	active_power_usage = 5000

	var/time_coeff = 1.5 //can be upgraded with research
	var/resource_coeff = 1.5 //can be upgraded with research
	max_material_storage = 200000
	has_output = 1
	takes_material_input = 1
	var/datum/research/files
	var/id
	var/sync = 0
	var/amount = 5
	var/build_number = 16

	var/nano_file = ""

	var/part_set
	var/obj/being_built
	var/list/queue = list()
	var/processing_queue = 0
	var/screen = MECH_SCREEN_MAIN
	var/temp
	var/list/part_sets = list()
	var/list/locked_parts = list()
	var/list/unlocked_parts = list()

/obj/machinery/r_n_d/fabricator/New()
	. = ..()

	for(var/part_set in part_sets)
		convert_part_set(part_set)
	files = new /datum/research(src) //Setup the research data holder.

/obj/machinery/r_n_d/fabricator/mech/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = (187500+(T * 37500))
	T = 0
	for(var/obj/item/weapon/stock_parts/micro_laser/Ma in component_parts)
		T += Ma.rating
	if(T >= 1)
		T -= 1
	var/diff
	diff = round(initial(resource_coeff) - (initial(resource_coeff)*(T))/25,0.01)
	if(resource_coeff!=diff)
		resource_coeff = diff
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/Ml in component_parts)
		T += Ml.rating
	if(T>= 2)
		T -= 2
	diff = round(initial(time_coeff) - (initial(time_coeff)*(T))/25,0.01)
	if(time_coeff!=diff)
		time_coeff = diff

/obj/machinery/r_n_d/fabricator/emag()
	sleep()
	switch(emagged)
		if(0)
			emagged = 0.5
			src.visible_message("\icon[src] <b>[src]</b> beeps: \"DB error \[Code 0x00F1\]\"")
			sleep(10)
			src.visible_message("\icon[src] <b>[src]</b> beeps: \"Attempting auto-repair\"")
			sleep(15)
			src.visible_message("\icon[src] <b>[src]</b> beeps: \"User DB corrupted \[Code 0x00FA\]. Truncating data structure...\"")
			sleep(30)
			src.visible_message("\icon[src] <b>[src]</b> beeps: \"User DB truncated. Please contact your Nanotrasen system operator for future assistance.\"")
			req_access = null
			emagged = 1
		if(0.5)
			src.visible_message("\icon[src] <b>[src]</b> beeps: \"DB not responding \[Code 0x0003\]...\"")
		if(1)
			src.visible_message("\icon[src] <b>[src]</b> beeps: \"No records in User DB\"")
	return

/obj/machinery/r_n_d/fabricator/proc/convert_part_set(set_name as text)
	var/list/parts = part_sets[set_name]
	if(istype(parts, /list))
		for(var/i=1;i<=parts.len;i++)
			var/path = parts[i]
			var/part = new path(src)
			if(part)
				parts[i] = part
			//debug below
			if(!istype(parts[i],/obj/item)) return 0
	return


/obj/machinery/r_n_d/fabricator/proc/add_part_set(set_name as text,parts=null)
	if(set_name in part_sets)//attempt to create duplicate set
		return 0
	if(isnull(parts))
		part_sets[set_name] = list()
	else
		part_sets[set_name] = parts
	convert_part_set(set_name)
	return 1

/obj/machinery/r_n_d/fabricator/proc/add_part_to_set(set_name as text,part)
	if(!part)
		return 0

	src.add_part_set(set_name)//if no "set_name" set exists, create

	var/list/part_set = part_sets[set_name]

	var/atom/apart

	if(ispath(part))
		apart = new part(src)
	else
		apart = part

	if(!istype(apart))
		return 0

	for(var/obj/O in part_set)
		if(O.type == apart.type)
			del apart
			return 0
	part_set[++part_set.len] = apart
	return 1

/obj/machinery/r_n_d/fabricator/proc/remove_part_set(set_name as text)
	for(var/i=1,i<=part_sets.len,i++)
		if(part_sets[i]==set_name)
			part_sets.Cut(i,++i)
	return

/obj/machinery/r_n_d/fabricator/proc/output_parts_list(set_name)
	var/output = ""
	var/list/part_set = listgetindex(part_sets, set_name)
	if(istype(part_set))
		for(var/obj/item/part in part_set)
			var/resources_available = check_resources(part)
			output += "<div class='part'>[output_part_info(part)]<br>\[[resources_available?"<a href='?src=\ref[src];part=\ref[part]'>Build</a> | ":null]<a href='?src=\ref[src];add_to_queue=\ref[part]'>Add to queue</a>\]\[<a href='?src=\ref[src];part_desc=\ref[part]'>?</a>\]</div>"
	return output

/obj/machinery/r_n_d/fabricator/proc/output_part_info(var/obj/item/part)
	var/output = "[part.name] (Cost: [output_part_cost(part)]) [get_construction_time_w_coeff(part)/10]sec"
	return output

/obj/machinery/r_n_d/fabricator/proc/output_part_cost(var/obj/item/part)
	var/i = 0
	var/output
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))//The most efficient way to go about this. Not all objects have these vars, but if they don't then they CANNOT be made by the mech fab. Doing it this way reduces a major amount of typecasting and switches, while cutting down maintenece for them as well -Sieve
		for(var/c in part:construction_cost)//The check should ensure that anything without the var doesn't make it to this point
			if(c=="metal")
				c="iron"
			if(c in materials)
				var/datum/material/material = materials[c]
				output += "[i?" | ":null][get_resource_cost_w_coeff(part,c)] [material.processed_name]"
				i++
			else
				testing("Unknown matID [c] in [part.type]!")
		return output
	else
		return 0

/obj/machinery/r_n_d/fabricator/proc/output_available_resources()
	var/output
	for(var/matID in materials)
		var/datum/material/material = materials[matID]
		output += "<span class=\"res_name\">[material.processed_name]: </span>[material.stored] cm&sup3;"
		if(material.stored>0)
			output += "<span style='font-size:80%;'> - Remove \[<a href='?src=\ref[src];remove_mat=1;material=[matID]'>1</a>\] | \[<a href='?src=\ref[src];remove_mat=10;material=[matID]'>10</a>\] | \[<a href='?src=\ref[src];remove_mat=[max_material_storage];material=[matID]'>All</a>\]</span>"
		output += "<br/>"
	return output

/obj/machinery/r_n_d/fabricator/proc/remove_resources(var/obj/item/part)
//Be SURE to add any new equipment to this switch, but don't be suprised if it spits out children objects
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))
		for(var/matID in part:construction_cost)
			if(matID=="metal")
				matID="iron"
			if(matID in src.materials)
				var/datum/material/material = materials[matID]
				material.stored -= get_resource_cost_w_coeff(part,matID)
				materials[matID]=material
	else
		return

/obj/machinery/r_n_d/fabricator/proc/check_resources(var/obj/item/part)
//		if(istype(part, /obj/item/robot_parts) || istype(part, /obj/item/mecha_parts) || istype(part,/obj/item/borg/upgrade))
//Be SURE to add any new equipment to this switch, but don't be suprised if it spits out children objects
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))
		for(var/matID in part:construction_cost)
			if(matID=="metal")
				matID="iron"
			if(matID in src.materials)
				var/datum/material/material = materials[matID]
				if(material.stored < get_resource_cost_w_coeff(part,matID))
					return 0
		return 1
	else
		return 0

/obj/machinery/r_n_d/fabricator/proc/build_part(var/obj/item/part) //You may ask why this doesn't use build_thing. Honest answer: build_thing builds designs instantly. Fabricators are meant to function differently
	if(!part) return

	 // critical exploit prevention, do not remove unless you replace it -walter0o
	if( !(locate(part, src.contents)) || !(part.vars.Find("construction_time")) || !(part.vars.Find("construction_cost")) ) // these 3 are the current requirements for an object being buildable by the mech_fabricator
		return

	src.being_built = new part.type(src)
	src.busy = 1
	src.desc = "It's building [src.being_built]."
	src.remove_resources(part)
	src.overlays += "[base_state]-active"
	src.use_power = 2
	src.updateUsrDialog()
	sleep(get_construction_time_w_coeff(part))
	src.use_power = 1
	src.overlays -= "[base_state]-active"
	src.desc = initial(src.desc)
	if(being_built)
		src.visible_message("\icon[src] <b>[src]</b> beeps, \"The following has been completed: [src.being_built] is built\".")
		var/locked = 0
		for(var/i = 1; i <= locked_parts.len; i++) //first checks if it should go in a lockbox
			if(istype(being_built, locked_parts[i]))
				locked = 1
				break
		for(var/i = 1; i <= unlocked_parts.len; i++) //then checks to see if it's excluded
			if(istype(being_built, unlocked_parts[i]))
				locked = 0
				break
		if(locked)
			var/obj/item/weapon/storage/lockbox/L = new/obj/item/weapon/storage/lockbox //Make a lockbox
			being_built.loc = L //Put the thing in the lockbox
			L.name += " ([being_built.name])"
			being_built = L //Building the lockbox now, with the thing in it
		src.being_built.Move(get_turf(output))
		src.being_built = null
	src.updateUsrDialog()
	src.busy = 0
	return 1


/*
	for(var/i=1;i<=queue.len;i++)
		var/obj/part_path = text2path(queue[i])
		var/obj/Part = new part_path()
		queue_list.Add(list(list("name" = Part.name, "commands" = list("remove_from_queue" = i))))
*/


/obj/machinery/r_n_d/fabricator/proc/add_part_set_to_queue(set_name)
	var/part_set_name = part_sets
	var/list/set_parts = part_set_name[set_name]
	if(set_name in part_set_name)
		for(var/i = 1; i < set_parts.len; i ++)
			if(part_set_name["Robot"] && i>7)
				break
			var/obj/P = set_parts[i]
			var/obj/Part = P.type
			add_to_queue("[Part]")
	src.visible_message("\icon[src] <b>[src]</b> beeps: [set_name] parts were added to the queue\".")
	return

/obj/machinery/r_n_d/fabricator/proc/add_to_queue(part)
	if(!istype(queue))
		queue = list()
	if(part)
		//src.visible_message("\icon[src] <b>[src]</b> beeps: [part.name] was added to the queue\".")
		queue[++queue.len] = part
	return queue.len

/obj/machinery/r_n_d/fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index<1 || index>queue.len))
		return 0
	queue.Cut(index,++index)
	return 1

/obj/machinery/r_n_d/fabricator/proc/process_queue()
	if(!queue.len)
		return

	var/obj/part_path = text2path(src.queue[1])
	var/obj/item/part = new part_path()
	//var/obj/item/part = listgetindex(src.queue, 1)
	if(!part)
		remove_from_queue(1)
		if(src.queue.len)
			return process_queue()
		else
			return
	if(!(part.vars.Find("construction_time")) || !(part.vars.Find("construction_cost")))//If it shouldn't be printed
		remove_from_queue(1)//Take it out of the quene
		return process_queue()//Then reprocess it
	while(part)
		if(stat&(NOPOWER|BROKEN))
			return 0
		if(!check_resources(part))
			src.visible_message("\icon[src] <b>[src]</b> beeps, \"Not enough resources. Queue processing stopped\".")
			return 0
		remove_from_queue(1)
		build_part(part)
		if(!queue.len)
			return
		else
			part_path = text2path(src.queue[1])
			part = new part_path()
	src.visible_message("\icon[src] <b>[src]</b> beeps, \"Queue processing finished successfully\".")
	return 1



/obj/machinery/r_n_d/fabricator/proc/convert_designs()
	if(!files) return
	var/i = 0
	for(var/datum/design/D in files.known_designs)
		if(D.build_type&src.build_number)
			if(D.category in part_sets)//Checks if it's a valid category
				if(add_part_to_set(D.category, D.build_path))//Adds it to said category
					i++
			else
				if(add_part_to_set("Misc", D.build_path))//If in doubt, chunk it into the Misc
					i++
	return i

/obj/machinery/r_n_d/fabricator/proc/update_tech()
	if(!files) return
	var/output
	for(var/datum/tech/T in files.known_tech)
		if(T && T.level > 1)
			var/diff
			switch(T.id) //bad, bad formulas
				if("materials")
					var/pmat = 0//Calculations to make up for the fact that these parts and tech modify the same thing
					for(var/obj/item/weapon/stock_parts/micro_laser/Ml in component_parts)
						pmat += Ml.rating
					if(pmat >= 1)
						pmat -= 1//So the equations don't have to be reworked, upgrading a single part from T1 to T2 is == to 1 tech level
					diff = round(initial(resource_coeff) - (initial(resource_coeff)*(T.level+pmat))/25,0.01)
					if(resource_coeff!=diff)
						resource_coeff = diff
						output+="Production efficiency increased.<br>"
				if("programming")
					var/ptime = 0
					for(var/obj/item/weapon/stock_parts/manipulator/Ma in component_parts)
						ptime += Ma.rating
					if(ptime >= 2)
						ptime -= 2
					diff = round(initial(time_coeff) - (initial(time_coeff)*(T.level+ptime))/25,0.1)
					if(time_coeff!=diff)
						time_coeff = diff
						output+="Production routines updated.<br>"
	return output


/obj/machinery/r_n_d/fabricator/proc/sync(silent=null)
	var/new_data=0
	var/found = 0
	var/obj/machinery/computer/rdconsole/console
	if(linked_console)
		console = linked_console
	else
		src.visible_message("\icon[src] <b>[src]</b> beeps, \"Not connected to a server. Please connect from a local console first.\"")
	if(console)
		for(var/datum/tech/T in console.files.known_tech)
			if(T)
				files.AddTech2Known(T)
		for(var/datum/design/D in console.files.known_designs)
			if(D)
				files.AddDesign2Known(D)
		files.RefreshResearch()
		var/i = src.convert_designs()
		var/tech_output = update_tech()
		if(!silent)
			temp = "Processed [i] equipment designs.<br>"
			temp += tech_output
			temp += "<a href='?src=\ref[src];clear_temp=1'>Return</a>"
			src.updateUsrDialog()
		if(i || tech_output)
			new_data=1
	if(new_data)
		src.visible_message("\icon[src] <b>[src]</b> beeps, \"Succesfully synchronized with R&D server. New data processed.\"")
	if(!silent && !found)
		temp = "Unable to connect to local R&D Database.<br>Please check your connections and try again.<br><a href='?src=\ref[src];clear_temp=1'>Return</a>"
		src.updateUsrDialog()


/obj/machinery/r_n_d/fabricator/proc/get_resource_cost_w_coeff(var/obj/item/part as obj,var/resource as text, var/roundto=1)
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))
		if (resource=="iron" && !("iron" in part:construction_cost))
			resource="metal"
		return round(part:construction_cost[resource]*resource_coeff, roundto)
	else
		return 0

/obj/machinery/r_n_d/fabricator/proc/get_construction_time_w_coeff(var/obj/item/part as obj, var/roundto=1)
//Be SURE to add any new equipment to this switch, but don't be suprised if it spits out children objects
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))
		return round(part:construction_time*time_coeff, roundto)
	else
		return 0


/obj/machinery/r_n_d/fabricator/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER))
		return
	if((user.stat && !isobserver(user)) || user.restrained() || !allowed(user))
		return

	var/data[0]
	var/queue_list[0]

	for(var/i=1;i<=queue.len;i++)
		var/obj/part_path = text2path(queue[i])
		var/obj/Part = new part_path()
		queue_list.Add(list(list("name" = Part.name, "commands" = list("remove_from_queue" = i))))

	data["queue"] = queue_list
	data["screen"]=screen
	var/materials_list[0]
		//Get the material names
	for(var/matID in materials)
		var/datum/material/material = materials[matID] // get the ID of the materials
		if(material && material.stored > 0)
			materials_list.Add(list(list("name" = material.processed_name, "storage" = material.stored, "commands" = list("eject" = matID)))) // get the amount of the materials
	data["materials"] = materials_list

	var/parts_list[0] // setup a list to get all the information for parts
	for(var/set_name in part_sets)
		var/list/set_name_list = list()
		for(var/obj/Part in part_sets[set_name])
			set_name_list.Add(list(list("name" = Part.name, "cost" = output_part_cost(Part), "time" = get_construction_time_w_coeff(Part)/10, "command1" = list("add_to_queue" = Part.type), "command2" = list("build" = Part.type))))
		parts_list[set_name] = set_name_list
	data["parts"] = parts_list // assigning the parts data to the data sent to UI

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, nano_file, name, FAB_SCREEN_WIDTH, FAB_SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()




/obj/machinery/r_n_d/fabricator/Topic(href, href_list)

	if(..()) // critical exploit prevention, do not remove unless you replace it -walter0o
		return

	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)

	if(href_list["remove_from_queue"])
		remove_from_queue(filter.getNum("remove_from_queue"))
		return 1
	if(href_list["eject"])
		var/num = input("Enter amount to eject", "Amount", "5") as num
		if(num)
			amount = round(text2num(num), 5)
		if(amount < 0)
			amount = 0
		if(amount > 50)
			amount = 50

		remove_material(href_list["eject"], amount)
		return 1
	if(href_list["build"])
		var/obj/part_path = text2path(href_list["build"])
		var/obj/part = new part_path()
		if(!processing_queue)
			if(!check_resources(part))
				src.visible_message("\icon[src] <b>[src]</b> beeps, \"Not enough resources. Unable to build: [part.name]\".")
				return 0
			if(src.exploit_prevention(part, usr))
				return
			build_part(part)
		return 1

	if(href_list["add_to_queue"])
		var/obj/part = href_list["add_to_queue"]
		var/obj/part_path = text2path(part)
		var/obj/real_part = new part_path()
	//	world << "This is the assigned part: [part]"
		// critical exploit prevention, do not remove unless you replace it -walter0o
		if(src.exploit_prevention(real_part, usr))
			return
		if(queue.len > 20)
			src.visible_message("\icon[src] <b>[src]</b> beeps, \"Queue is full, please clear or finish.\".")
			return

		add_to_queue(part)
		return 1

	if(href_list["queue_part_set"])
		var/set_name = href_list["queue_part_set"]
		if(queue.len > 20)
			src.visible_message("\icon[src] <b>[src]</b> beeps, \"Queue is full, please clear or finish.\".")
			return
		add_part_set_to_queue(set_name)
		return 1

	if(href_list["clear_queue"])
		queue = list()
		return 1

	if(href_list["sync"])
		queue = list()
		temp = "Updating local R&D database..."
		src.updateUsrDialog()
		spawn(30)
			src.sync()
		return 1

	if(href_list["process_queue"])
		spawn(-1)
			if(processing_queue || being_built)
				return 0
			processing_queue = 1
			process_queue()
			processing_queue = 0
			return 1


	if(href_list["screen"])
		var/prevscreen=screen
		screen = text2num(href_list["screen"])
		if(prevscreen==screen) return 0
		ui_interact(usr)
		return 1



/obj/machinery/r_n_d/fabricator/attack_hand(mob/user as mob)

	var/turf/exit = get_turf(output)
	if(exit.density)
		src.visible_message("\icon[src] <b>[src]</b> beeps, \"Error! Part outlet is obstructed\".")
		return
	.
	if(stat & BROKEN)
		return

	if(!allowed(user))
		src.visible_message("<span class='warning'>Unauthorized Access</span>: attempted by <b>[user]</b>")
		return

	ui_interact(user)


/obj/machinery/r_n_d/fabricator/proc/exploit_prevention(var/obj/Part, mob/user as mob, var/desc_exploit)
// critical exploit prevention, feel free to improve or replace this, but do not remove it -walter0o

	if(!Part || !user || !istype(Part) || !istype(user)) // sanity
		return 1

	if( !(locate(Part, src.contents)) || !(Part.vars.Find("construction_time")) || !(Part.vars.Find("construction_cost")) ) // these 3 are the current requirements for an object being buildable by the mech_fabricator

		var/turf/LOC = get_turf(user)
		message_admins("[key_name_admin(user)] tried to exploit an Exosuit Fabricator to [desc_exploit ? "get the desc of" : "duplicate"] <a href='?_src_=vars;Vars=\ref[Part]'>[Part]</a> ! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])", 0)
		log_admin("EXPLOIT : [key_name(user)] tried to exploit an Exosuit Fabricator to [desc_exploit ? "get the desc of" : "duplicate"] [Part] !")
		return 1

	return null
/*
/obj/machinery/r_n_d/fabricator/mech/Topic(href, href_list)

	if(href_list["process_queue"])
		spawn(-1)
			if(processing_queue || being_built)
				return 0
			processing_queue = 1
			process_queue()
			processing_queue = 0

	if(href_list["clear_temp"])
		temp = null
	if(href_list["screen"])
		src.screen = href_list["screen"]

	if(href_list["queue_move"] && href_list["index"])
		var/index = filter.getNum("index")
		var/new_index = index + filter.getNum("queue_move")
		if(isnum(index) && isnum(new_index))
			if(InRange(new_index,1,queue.len))
				queue.Swap(index,new_index)
		return update_queue_on_page()

	if(href_list["clear_queue"])
		queue = list()
		return update_queue_on_page()
	if(href_list["sync"])
		queue = list()
		temp = "Updating local R&D database..."
		src.updateUsrDialog()
		spawn(30)
			src.sync()
		return update_queue_on_page()
	if(href_list["part_desc"])
		var/obj/part = filter.getObj("part_desc")

		// critical exploit prevention, do not remove unless you replace it -walter0o
		if(src.exploit_prevention(part, usr, 1))
			return

		if(part)
			temp = {"<h1>[part] description:</h1>
						[part.desc]<br>
						<a href='?src=\ref[src];clear_temp=1'>Return</a>
						"}
	if(href_list["remove_mat"] && href_list["material"])
		temp = "Ejected [remove_material(href_list["material"],text2num(href_list["remove_mat"]))] of [href_list["material"]]<br><a href='?src=\ref[src];clear_temp=1'>Return</a>"
	src.updateUsrDialog()
	return
*/
/obj/machinery/r_n_d/fabricator/proc/remove_material(var/matID, var/amount)
	if(matID in materials)
		var/datum/material/material = materials[matID]
		//var/obj/item/stack/sheet/res = new material.sheettype(src)
		var/total_amount = min(round(material.stored/material.cc_per_sheet),amount)
		var/to_spawn = total_amount

		while(to_spawn > 0)
			var/obj/item/stack/sheet/mats = new material.sheettype(src)
			if(to_spawn > mats.max_amount)
				mats.amount = mats.max_amount
				to_spawn -= mats.max_amount
			else
				mats.amount = to_spawn
				to_spawn = 0

			material.stored -= mats.amount * mats.perunit
			//materials[matID]=material - why?
			mats.loc = src.loc
		return total_amount
	return 0


/obj/machinery/r_n_d/fabricator/attackby(obj/W as obj, mob/user as mob)
	..()
