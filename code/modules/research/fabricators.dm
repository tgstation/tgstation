#define FAB_SCREEN_WIDTH		1040
#define FAB_SCREEN_HEIGHT		750

#define FAB_TIME_BASE			5
#define FAB_MAX_QUEUE			20

#define FAB_MAT_BASEMOD			100


/obj/machinery/r_n_d/fabricator
	desc = "A fabricator. What kind, you don't know."
	idle_power_usage = 20
	active_power_usage = 5000

	var/time_coeff = 1.5 //can be upgraded with research
	var/resource_coeff = 1.5 //can be upgraded with research
	max_material_storage = 200000

	var/datum/research/files
	var/id
	var/sync = 0
	var/amount = 5
	var/build_number = 8

	var/part_set
	var/obj/being_built
	build_time = FAB_TIME_BASE //time modifier for each machine. Protolathes have low time variable, mechfabs have high
	var/list/queue = list()
	var/processing_queue = 0
	var/screen = 0
	var/temp
	var/list/part_sets = list()

	research_flags = TAKESMATIN | HASOUTPUT | HASMAT_OVER | NANOTOUCH

/obj/machinery/r_n_d/fabricator/New()
	. = ..()

	for(var/part_set in part_sets)
		convert_part_set(part_set)

	files = new /datum/research(src) //Setup the research data holder.

/obj/machinery/r_n_d/fabricator/update_icon()
	..()
	if(being_built)
		overlays += "[base_state]_ani"

/obj/machinery/r_n_d/fabricator/examine()
	..()
	if(being_built)
		usr << "It's building \a [src.being_built]."
	else
		usr << "Nothing's being built."

/obj/machinery/r_n_d/fabricator/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = (initial(max_material_storage)+(T * 37500))

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
	if(!research_flags &ACCESS_EMAG)
		return
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

/*
/obj/machinery/r_n_d/fabricator/crowbarDestroy(mob/user)
	if(..())
		for(var/obj/I in src.contents) //remove any stuff loaded, like for fridges
			qdel(I)
		return 1
	return -1
*/

//takes all the items in a list, and gets the ones which aren't designs and turns them into designs
//basically, we call this whenever we add something that isn't a design to part_sets
/obj/machinery/r_n_d/fabricator/proc/convert_part_set(set_name as text)
	var/list/parts = part_sets[set_name]
	if(istype(parts, /list))
		for(var/i=1;i<=parts.len;i++)
			var/thispart = parts[i]
			if(thispart && ispath(thispart) && !istype(thispart, /datum/design))
				var/design = FindDesign(thispart)
				if(design)
					parts[i] = new design
				else
					parts.Cut(i, i++)
					i--
			//debug below
			/*
			if(!istype(parts[i], /datum/design))
				parts.Cut(i, i++) //quick, sweep it under the rug
			*/
	return

//creates a set with the name and the list of things you give it
/obj/machinery/r_n_d/fabricator/proc/add_part_set(set_name as text, var/list/parts=null)
	if(set_name in part_sets)//attempt to create duplicate set
		return 0
	if(isnull(parts))
		part_sets[set_name] = list()
	else
		part_sets[set_name] = parts
	convert_part_set(set_name)
	return 1

/obj/machinery/r_n_d/fabricator/process()
	if(busy || stopped)
		return
	if(queue.len==0)
		stopped=1
		return
	busy=1
	spawn(0)
		var/datum/design/I = queue_pop()
		if(!build_part(I))
			queue.Add(I)
		busy=0

/obj/machinery/r_n_d/fabricator/proc/queue_pop()
	var/datum/design/D = queue[1]
	queue -= D
	return D

//adds a design to a part list
/obj/machinery/r_n_d/fabricator/proc/add_part_to_set(set_name as text, var/datum/design/part)
	if(!part || !istype(part))
		return 0

	src.add_part_set(set_name)//if no "set_name" set exists, create

	var/list/part_set = part_sets[set_name]

	for(var/datum/design/D in part_set)
		if(D.build_path == part.build_path)
			// del part
			return 0
	part_set[++part_set.len] = part
	return 1

//deletes an entire part set from part_sets
/obj/machinery/r_n_d/fabricator/proc/remove_part_set(set_name as text)
	for(var/i=1,i<=part_sets.len,i++)
		if(part_sets[i]==set_name)
			part_sets.Cut(i,++i)
			return 1
	return

/obj/machinery/r_n_d/fabricator/proc/remove_part_from_set(set_name as text, var/datum/design/part)
	var/part_set = part_sets[set_name]
	part_set -= part
	return 1

//gets all the mats for a design, and returns a formatted string
/obj/machinery/r_n_d/fabricator/proc/output_part_cost(var/datum/design/part)
	var/output = ""
	for(var/M in part.materials)
		if(copytext(M,1,2) == "$")
			var/matID=copytext(M,2)
			var/datum/material/material=materials[matID]
			output += "[output ? " | " : null][get_resource_cost_w_coeff(part,"$[matID]")] [material.processed_name]"
	return output

/obj/machinery/r_n_d/fabricator/proc/build_part(var/datum/design/part)
	if(!part)
		return

	for(var/M in part.materials)
		if(!check_mat(part, M))
			src.visible_message("<font color='blue'>The [src.name] beeps, \"Not enough materials to complete item.\"</font>")
			stopped=1
			return 0
		if(copytext(M,1,2) == "$")
			var/matID=copytext(M,2)
			var/datum/material/material=materials[matID]
			material.stored = max(0, (material.stored-part.materials[M]))
			materials[matID]=material
		else
			reagents.remove_reagent(M, part.materials[M])

	src.being_built = new part.build_path(src)

	src.busy = 1
	src.overlays += "[base_state]_ani"
	src.use_power = 2
	src.updateUsrDialog()
	//message_admins("We're going building with [get_construction_time_w_coeff(part)]")
	sleep(get_construction_time_w_coeff(part))
	src.use_power = 1
	src.overlays -= "[base_state]_ani"
	if(being_built)
		if(part.locked && research_flags &LOCKBOXES)
			var/obj/item/weapon/storage/lockbox/L
			if(research_flags &TRUELOCKS)
				L = new/obj/item/weapon/storage/lockbox(src) //Make a lockbox
			else
				L = new /obj/item/weapon/storage/lockbox/unlockable(src) //Make an unlockable lockbox
			being_built.loc = L //Put the thing in the lockbox
			L.name += " ([being_built.name])"
			being_built = L //Building the lockbox now, with the thing in it
		being_built.loc = get_turf(output)
		src.visible_message("\icon [src] \The [src] beeps: \"Succesfully completed \the [being_built.name].\"")
		src.being_built = null
	src.updateUsrDialog()
	src.busy = 0
	return 1

//max_length is, from the top of the list, the parts you want to queue down to
/obj/machinery/r_n_d/fabricator/proc/add_part_set_to_queue(set_name, max_length)
	var/list/set_parts = part_sets[set_name]
	if(set_name in part_sets)
		for(var/i = 1; i <= set_parts.len; i++)
			if(max_length > 0 &&  i > max_length)
				break
			var/datum/design/D = set_parts[i]
			add_to_queue(D)
	src.visible_message("\icon[src] <b>[src]</b> beeps: \"[set_name] parts were added to the queue\".")
	return

/obj/machinery/r_n_d/fabricator/proc/add_to_queue(var/datum/design/part)
	if(!istype(queue))
		queue = list()
	if(!istype(part))
		part = FindDesign(part)
	if(!part)
		return
	if(part)
		//src.visible_message("\icon[src] <b>[src]</b> beeps: [part.name] was added to the queue\".")
		queue[++queue.len] = part
	return queue.len

/obj/machinery/r_n_d/fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index<1 || index>queue.len))
		return 0
	queue.Cut(index,++index)
	return 1

/* This is what process() is for you nerd - N3X
/obj/machinery/r_n_d/fabricator/proc/process_queue()

	if(!queue.len)
		return

	var/datum/design/part = src.queue[1]

	if(!part)
		remove_from_queue(1)
		if(src.queue.len)
			return process_queue()
		else
			return
	while(part)
		if(stat&(NOPOWER|BROKEN))
			return 0
		remove_from_queue(1)
		build_part(part)
		if(!queue.len)
			return
		else
			if(!isnull(src.queue[1]))
				part = src.queue[1]
	src.visible_message("\icon[src] <b>[src]</b> beeps, \"Queue processing finished successfully\".")
	return 1
*/


/obj/machinery/r_n_d/fabricator/proc/convert_designs()
	if(!files) return
	var/i = 0
	for(var/datum/design/D in files.known_designs)
		if(D.build_type &src.build_number)
			if(D.category in part_sets)//Checks if it's a valid category
				if(add_part_to_set(D.category, D))//Adds it to said category
					i++
			else
				if(add_part_to_set("Misc", D))//If in doubt, chunk it into the Misc
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
	if(busy)
		src.visible_message("\icon[src] <b>[src]</b> beeps, \"Please wait for completion of current operation.\"")
		return
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

// Tell the machine to start processing the queue on the next process().
/obj/machinery/r_n_d/fabricator/proc/start_processing_queue()
	stopped=0

// Stop processing queue (currently-executing ticks will finish first).
/obj/machinery/r_n_d/fabricator/proc/stop_processing_queue()
	stopped=1

/obj/machinery/r_n_d/fabricator/proc/get_resource_cost_w_coeff(var/datum/design/part as obj,var/resource as text, var/roundto=1)
	return round(part.materials[resource]*resource_coeff, roundto)

//produces the adjusted time taken to build a component
//different fabricators have different modifiers
//this is in the works, so expect to edit it over time
//MatTotal is a time modifier based on the total material cost of the design, divided by FAB_MAT_BASEMOD
//build_time is a var unique to each fabricator. It's mostly one, but bigger machines get higher build_time
//time_coeff is set by the machine components
/obj/machinery/r_n_d/fabricator/proc/get_construction_time_w_coeff(var/datum/design/part as obj, var/roundto=1)
	return round(/*TechTotal(part)*/(part.MatTotal()/FAB_MAT_BASEMOD)*build_time*time_coeff, roundto)

/obj/machinery/r_n_d/fabricator/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(stat & (BROKEN|NOPOWER))
		return
	if((user.stat && !isobserver(user)) || user.restrained() || !allowed(user))
		return

	var/data[0]
	var/queue_list[0]

	for(var/i=1;i<=queue.len;i++)
		var/datum/design/part = queue[i]
		queue_list.Add(list(list("name" = part.name, "commands" = list("remove_from_queue" = i))))

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
		//message_admins("Assiging parts to [set_name]")
		var/list/parts = part_sets[set_name]
		var/list/set_name_list = list()
		var/i = 0
		for(var/datum/design/part in parts)
			//message_admins("Adding the [part.name] to the list")
			i++
			set_name_list.Add(list(list("name" = part.name, "cost" = output_part_cost(part), "time" = get_construction_time_w_coeff(part)/10, "command1" = list("add_to_queue" = "[i][set_name]"), "command2" = list("build" = "[i][set_name]"))))
		parts_list[set_name] = set_name_list
	data["parts"] = parts_list // assigning the parts data to the data sent to UI

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, nano_file, name, FAB_SCREEN_WIDTH, FAB_SCREEN_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/r_n_d/fabricator/proc/getTopicDesign(var/stringinput = "")
	var/final_digit = 0
	for(var/i = 1, i <= length(stringinput), i++)
		if(!text2num(copytext(stringinput, i)))
			//message_admins("Breaking on [copytext(stringinput, i)] and [i]")
			final_digit = i
			break
	var/part_list = part_sets[copytext(stringinput, final_digit)]
	var/index = text2num(copytext(stringinput, 1, final_digit))
	//message_admins("From [stringinput] we have [index] and [copytext(stringinput, final_digit)]")
	return part_list[index]

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
			amount = Clamp(round(text2num(num), 5), 0, 50)
		remove_material(href_list["eject"], amount)
		return 1

	if(href_list["build"])
		var/datum/design/part = getTopicDesign(href_list["build"])
		if(!processing_queue && part)
			build_part(part)
		return 1

	if(href_list["add_to_queue"])
		var/datum/design/part = getTopicDesign(href_list["add_to_queue"])
		if(queue.len > FAB_MAX_QUEUE)
			src.visible_message("\icon[src] <b>[src]</b> beeps, \"Queue is full, please clear or finish.\".")
			return

		add_to_queue(part)
		return 1

	if(href_list["queue_part_set"])
		var/set_name = href_list["queue_part_set"]
		if(queue.len > FAB_MAX_QUEUE)
			src.visible_message("\icon[src] <b>[src]</b> beeps, \"Queue is full, please clear or finish.\".")
			return
		if(set_name == "Robot")
			add_part_set_to_queue(set_name, 7)
		else
			add_part_set_to_queue(set_name)
		return 1

	if(href_list["clear_queue"])
		stop_processing_queue()
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
		if(!stopped)
			return 0
		start_processing_queue()
		return 1


	if(href_list["screen"])
		var/prevscreen=screen
		screen = text2num(href_list["screen"])
		if(prevscreen==screen) return 0
		ui_interact(usr)
		return 1



/obj/machinery/r_n_d/fabricator/attack_hand(mob/user as mob)
	if((user.stat && !isobserver(user)) || user.restrained()) //allowed is later on, so we don't check it
		return

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

	if(research_flags & NANOTOUCH)
		ui_interact(user)

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
