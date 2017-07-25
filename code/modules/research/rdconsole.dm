/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The imprinting and construction menus do NOT require toxins access to access but all the other menus do. However, if you leave it
on a menu, nothing is to stop the person from using the options on that menu (although they won't be able to change to a different
one). You can also lock the console on the settings menu if you're feeling paranoid and you don't want anyone messing with it who
doesn't have toxins access.

*/

/obj/machinery/computer/rdconsole
	name = "R&D Console"
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	circuit = /obj/item/weapon/circuitboard/computer/rdconsole
	var/datum/techweb/stored_research					//Reference to global science techweb.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.

	var/obj/machinery/rnd/destructive_analyzer/linked_destroy = null	//Linked Destructive Analyzer
	var/obj/machinery/rnd/protolathe/linked_lathe = null				//Linked Protolathe
	var/obj/machinery/rnd/circuit_imprinter/linked_imprinter = null	//Linked Circuit Imprinter

	req_access = list(ACCESS_TOX)	//DATA AND SETTING MANIPULATION REQUIRES SCIENTIST ACCESS.

	var/category_lathe
	var/category_imprinter
	var/current_tab = "settings"
	var/list/datum/design/matching_designs_protolathe //for the search function
	var/list/datum/design/matching_designs_imprinter
	var/list/datum/design/cat_designs_protolathe
	var/list/datum/design/cat_designs_imprinter
	var/tdisk_update = FALSE
	var/ddisk_update = FALSE
	var/datum/techweb_node/selected_node
	var/datum/design/selected_design
	var/locked = FALSE

/proc/CallMaterialName(ID)
	if (copytext(ID, 1, 2) == "$" && GLOB.materials_list[ID])
		var/datum/material/material = GLOB.materials_list[ID]
		return material.name

	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return "ERROR: Report This"

/obj/machinery/computer/rdconsole/proc/SyncRDevices() //Makes sure it is properly sync'ed up with the devices attached to it (if any).
	for(var/obj/machinery/rnd/D in oview(3,src))
		if(D.linked_console != null || D.disabled || D.panel_open)
			continue
		if(istype(D, /obj/machinery/rnd/destructive_analyzer))
			if(linked_destroy == null)
				linked_destroy = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/protolathe))
			if(linked_lathe == null)
				linked_lathe = D
				D.linked_console = src
		else if(istype(D, /obj/machinery/rnd/circuit_imprinter))
			if(linked_imprinter == null)
				linked_imprinter = D
				D.linked_console = src

/obj/machinery/computer/rdconsole/Initialize()
	. = ..()
	stored_research = SSresearch.science_tech
	stored_research.consoles_accessing[src] = TRUE
	matching_designs_imprinter = list()
	matching_designs_protolathe = list()
	cat_designs_protolathe = list()
	cat_designs_imprinter = list()
	SyncRDevices()

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
	matching_designs_protolathe = null
	matching_designs_imprinter = null
	cat_designs_protolathe = null
	cat_designs_imprinter = null
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	if(t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null
	if(d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	selected_node = null
	selected_design = null
	return ..()

/obj/machinery/computer/rdconsole/attackby(obj/item/weapon/D, mob/user, params)
	//Loading a disk into it.
	if(istype(D, /obj/item/weapon/disk))
		if(istype(D, /obj/item/weapon/disk/tech_disk))
			if(t_disk)
				to_chat(user, "<span class='danger'>A technology disk is already loaded!</span>")
				return
			if(!user.drop_item())
				to_chat(user, "<span class='danger'>[D] is stuck to your hand!</span>")
				return
			D.forceMove(src)
			t_disk = D
		else if (istype(D, /obj/item/weapon/disk/design_disk))
			if(d_disk)
				to_chat(user, "<span class='danger'>A design disk is already loaded!</span>")
				return
			if(!user.drop_item())
				to_chat(user, "<span class='danger'>[D] is stuck to your hand!</span>")
				return
			d_disk = D
		else
			to_chat(user, "<span class='danger'>Machine cannot accept disks in that format.</span>")
			return
		to_chat(user, "<span class='notice'>You insert [D] into \the [src]!</span>")
	else if(!(linked_destroy && linked_destroy.busy) && !(linked_lathe && linked_lathe.busy) && !(linked_imprinter && linked_imprinter.busy))
		. = ..()

/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	CRASH("RESEARCH NODE NOT CODED!")

/obj/machinery/computer/rdconsole/on_deconstruction()
	if(linked_destroy)
		linked_destroy.linked_console = null
		linked_destroy = null
	if(linked_lathe)
		linked_lathe.linked_console = null
		linked_lathe = null
	if(linked_imprinter)
		linked_imprinter.linked_console = null
		linked_imprinter = null
	..()


/obj/machinery/computer/rdconsole/emag_act(mob/user)
	if(emagged)
		return
	playsound(src, "sparks", 75, 1)
	emagged = TRUE
	to_chat(user, "<span class='notice'>You disable the security protocols</span>")

/*

	else if(href_list["updt_design"]) //Updates the research holder with design data from the design disk.
		var/n = text2num(href_list["updt_design"])
		screen = SCICONSOLE_UPDATE_DATABASE
		var/wait = 50
		if(!n)
			wait = 0
			for(var/D in d_disk.blueprints)
				if(D)
					wait += 50
		spawn(wait)
			screen = SCICONSOLE_DDISK
			if(d_disk)
				if(!n)
					for(var/D in d_disk.blueprints)
						if(D)
							stored_research.add_design(D)
				else
					stored_research.add_design(d_disk.blueprints[n])
				updateUsrDialog()

	else if(href_list["clear_design"]) //Erases data on the design disk.
		if(d_disk)
			var/n = text2num(href_list["clear_design"])
			if(!n)
				for(var/i in 1 to d_disk.max_blueprints)
					d_disk.blueprints[i] = null
			else
				d_disk.blueprints[n] = null


	else if(href_list["copy_design"]) //Copy design data from the research holder to the design disk.
		var/slot = text2num(href_list["copy_design"])
		var/datum/design/D = stored_research.researched_designs[href_list["copy_design_ID"]]
		if(D)
			var/autolathe_friendly = 1
			if(D.reagents_list.len)
				autolathe_friendly = 0
				D.category -= "Imported"
			else
				for(var/x in D.materials)
					if( !(x in list(MAT_METAL, MAT_GLASS)))
						autolathe_friendly = 0
						D.category -= "Imported"

			if(D.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE)) // Specifically excludes circuit imprinter and mechfab
				D.build_type = autolathe_friendly ? (D.build_type | AUTOLATHE) : D.build_type
				D.category |= "Imported"
			d_disk.blueprints[slot] = D
		screen = SCICONSOLE_DDISK


	if(SCICONSOLE_TDISK) //Technology Disk Menu
		dat += SCICONSOLE_HEADER
		dat += "Disk Operations: <A href='?src=\ref[src];clear_tech=0'>Clear Disk</A>"
		dat += "<A href='?src=\ref[src];eject_tech=1'>Eject Disk</A>"
		dat += "<A href='?src=\ref[src];updt_tech=0'>Upload All</A>"
		dat += "<A href='?src=\ref[src];copy_tech=1'>Load Technology to Disk</A>"
		dat += "<div class='statusDisplay'><h3>Stored Technology Nodes:</h3>"
		for(var/i in t_disk.stored_research.researched_nodes)
			var/datum/techweb_node/N = t_disk.stored_research.researched_nodes[i]
			dat += "<A href='?src=\ref[src];view_node=[i];back_screen=[screen]'>[N.display_name]</A>"
		dat += "</div>"

	if(SCICONSOLE_DDISK) //Design Disk menu.
		dat += SCICONSOLE_HEADER
		dat += "Disk Operations: <A href='?src=\ref[src];clear_design=0'>Clear Disk</A><A href='?src=\ref[src];updt_design=0'>Upload All</A><A href='?src=\ref[src];eject_design=1'>Eject Disk</A>"
		for(var/i in 1 to d_disk.max_blueprints)
			dat += "<div class='statusDisplay'>"
			if(d_disk.blueprints[i])
				var/datum/design/D = d_disk.blueprints[i]
				dat += "<A href='?src=\ref[src];view_design=[D.id]'>[D.name]</A>"
				dat += "Operations: <A href='?src=\ref[src];updt_design=[i]'>Upload to Database</A> <A href='?src=\ref[src];clear_design=[i]'>Clear Slot</A>"
			else
				dat += "Empty SlotOperations: <A href='?src=\ref[src];menu=[SCICONSOLE_DDISKL];disk_slot=[i]'>Load Design to Slot</A>"
			dat += "</div>"
	if(SCICONSOLE_DDISKL) //Design disk submenu
		dat += SCICONSOLE_HEADER
		dat += "<A href='?src=\ref[src];menu=[SCICONSOLE_DDISK];back_screen=[screen]'>Return to Disk Operations</A><div class='statusDisplay'>"
		dat += "<h3>Load Design to Disk:</h3>"
		for(var/v in stored_research.researched_designs)
			var/datum/design/D = stored_research.researched_designs[v]
			dat += "[D.name] "
			dat += "<A href='?src=\ref[src];copy_design=[disk_slot_selected];copy_design_ID=[D.id]'>Copy to Disk</A>"
		dat += "</div>"

*/


/obj/machinery/computer/rdconsole/ui_data(mob/user)
	var/list/data = list()
	//Tabs
	data["tabs"] = list("Technology", "View Node", "View Design", "Disk Operations - Design", "Disk Operations - Technology", "Deconstructive Analyzer", "Protolathe", "Circuit Imprinter", "Settings")
	//Locking
	data["locked"] = locked
	//General Access
	data["research_points_stored"] = stored_research.research_points
	data["protolathe_linked"] = linked_lathe? TRUE : FALSE
	data["circuit_linked"] = linked_imprinter? TRUE : FALSE
	data["destroy_linked"] = linked_destroy? TRUE : FALSE
	data["node_selected"] = selected_node? TRUE : FALSE
	data["design_selected"] = selected_design? TRUE : FALSE
	//Techweb
	var/list/techweb_avail = list()
	var/list/techweb_locked = list()
	var/list/techweb_researched = list()
	var/l1 = stored_research.get_available_nodes()
	var/l2 = stored_research.get_visible_nodes()
	var/l3 = stored_research.get_researched_nodes()
	for(var/id in l1)
		var/datum/techweb_node/N = l1[id]
		techweb_avail += list(list("id" = N.id, "display_name" = N.display_name))
	for(var/id in l2)
		var/datum/techweb_node/N = l2[id]
		techweb_locked += list(list("id" = N.id, "display_name" = N.display_name))
	for(var/id in l3)
		var/datum/techweb_node/N = l3[id]
		techweb_researched += list(list("id" = N.id, "display_name" = N.display_name))
	data["techweb_avail"] = techweb_avail
	data["techweb_locked"] = techweb_locked
	data["techweb_researched"] = techweb_researched
	//Node View
	if(selected_node)
		data["snode_name"] = selected_node.display_name
		data["snode_id"] = selected_node.id
		data["snode_researched"] = stored_research.researched_nodes[selected_node.id]? TRUE : FALSE
		data["snode_cost"] = selected_node.get_price(stored_research)
		data["snode_export"] = selected_node.export_price
		data["snode_desc"] = selected_node.description
		var/list/prereqs = list()
		var/list/unlocks = list()
		var/list/designs = list()
		for(var/id in selected_node.prerequisites)
			var/datum/techweb_node/N = selected_node.prerequisites[id]
			prereqs += list(list("id" = N.id, "display_name" = N.display_name))
		for(var/id in selected_node.unlocks)
			var/datum/techweb_node/N = selected_node.unlocks[id]
			unlocks += list(list("id" = N.id, "display_name" = N.display_name))
		for(var/id in selected_node.designs)
			var/datum/design/D = selected_node.designs[id]
			designs += list(list("id" = D.id, "name" = D.name))
		data["node_prereqs"] = prereqs
		data["node_unlocks"] = unlocks
		data["node_designs"] = designs
	//Design View
	if(selected_design)
		data["sdesign_id"] = selected_design.id
		data["sdesign_name"] = selected_design.name
		data["sdesign_desc"] = selected_design.desc
		data["sdesign_buildtype"] = selected_design.build_type
		data["sdesign_mats"] = list()
		for(var/M in selected_design.materials)
			data["sdesign_mats"]["[CallMaterialName(M)]"] = selected_design.materials[M]
	//Both Lathes
	data["lathe_tabs"] = list("Category List", "Selected Category", "Search Results", "Materials", "Chemicals")
	//Protolathe
	if(linked_lathe)
		data["protobusy"] = linked_lathe.busy? TRUE : FALSE
		data["protocats"] = list()
		for(var/v in linked_lathe.categories)
			data["protocats"] += list(list("name" = v))
		data["protomats"] = "[linked_lathe.materials.total_amount]"
		data["protomaxmats"] = "[linked_lathe.materials.max_amount]"
		data["protochems"] = "[linked_lathe.reagents.total_volume]"
		data["protomaxchems"] = "[linked_lathe.reagents.maximum_volume]"
		data["protodes"] = list()
		for(var/v in cat_designs_protolathe)
			var/datum/design/D = cat_designs_protolathe[v]
			data["protodes"] += list(list("name" = D.name, "id" = D.id, "canprint" = check_canprint(D, PROTOLATHE), "matstring" = get_actual_mat_string(D, PROTOLATHE)))
		data["protomatch"] = list()
		for(var/v in matching_designs_protolathe)
			var/datum/design/D = matching_designs_protolathe[v]
			data["protomatch"] += list(list("name" = D.name, "id" = D.id, "canprint" = check_canprint(D, PROTOLATHE), "matstring" = get_actual_mat_string(D, PROTOLATHE)))
		data["protomat_list"] = list()
		for(var/m in linked_lathe.materials.materials)
			var/datum/material/M = linked_lathe.materials.materials[m]
			var/sheets = Floor(M.amount/MINERAL_MATERIAL_AMOUNT)
			data["protomat_list"] += list(list("name" = M.name, "amount" = M.amount, "sheets" = sheets, "mat_id" = m))
		data["protochem_list"] = list()
		for(var/datum/reagent/R in linked_lathe.reagents.reagent_list)
			data["protochem_list"] += list(list("name" = R.name, "amount" = R.volume, "reagentid" = R.id))
	//Circuit Imprinter
	if(linked_imprinter)
		data["circuitbusy"] = linked_imprinter.busy? TRUE : FALSE
		data["circuitcats"] = list()
		for(var/v in linked_lathe.categories)
			data["circuitcats"] += list(list("name" = v))
		data["circuitmats"] = "[linked_imprinter.materials.total_amount]"
		data["circuitmaxmats"] = "[linked_imprinter.materials.max_amount]"
		data["circuitchems"] = "[linked_imprinter.reagents.total_volume]"
		data["circuitmaxchems"] = "[linked_imprinter.reagents.maximum_volume]"
		data["imprintdes"] = list()
		for(var/v in cat_designs_imprinter)
			var/datum/design/D = cat_designs_imprinter[v]
			data["imprintdes"] += list(list("name" = D.name, "id" = D.id, "canprint" = check_canprint(D, PROTOLATHE), "matstring" = get_actual_mat_string(D, PROTOLATHE)))
		data["imprintmatch"] = list()
		for(var/v in matching_designs_imprinter)
			var/datum/design/D = matching_designs_protolathe[v]
			data["imprintmatch"] += list(list("name" = D.name, "id" = D.id, "canprint" = check_canprint(D, IMPRINTER), "matstring" = get_actual_mat_string(D, IMPRINTER)))
		data["circuitmat_list"] = list()
		for(var/m in linked_imprinter.materials.materials)
			var/datum/material/M = linked_imprinter.materials.materials[m]
			var/sheets = Floor(M.amount/MINERAL_MATERIAL_AMOUNT)
			data["circuitmat_list"] += list(list("name" = M.name, "amount" = M.amount, "sheets" = sheets, "mat_id" = m))
		data["circuitchem_list"] = list()
		for(var/datum/reagent/R in linked_imprinter.reagents.reagent_list)
			data["circuitchem_list"] += list(list("name" = R.name, "amount" = R.volume, "reagentid" = R.id))
	if(linked_destroy)
		data["destroybusy"] = linked_destroy.busy? TRUE : FALSE
		data["destroy_loaded"] = linked_destroy.loaded_item? TRUE : FALSE
		if(linked_destroy.loaded_item)
			data["destroy_name"] = linked_destroy.loaded_item.name
			data["boost_paths"] = list()
			var/list/input = techweb_item_boost_check(linked_destroy.loaded_item)	//Node datum = value
			for(var/v in input)
				var/datum/techweb_node/TN = v
				var/boost = input[v]
				var/can_boost = stored_research.boosted_nodes[TN]? FALSE : TRUE
				data["boost_paths"] += list(list("name" = TN.display_name, "value" = boost, "allow" = can_boost, "id" = TN.id))
	//Disk Operations
	data["tdisk"] = t_disk? TRUE : FALSE
	data["ddisk"] = d_disk? TRUE : FALSE
	data["tdisk_update"] = tdisk_update
	data["ddisk_update"] = ddisk_update
	data["alldesigns"] = list()
	for(var/v in matching_designs_protolathe)
		var/datum/design/D = matching_designs_protolathe[v]
		data["alldesigns"] += list(list("name" = D.name, "id" = D.id))
	if(d_disk)
		data["ddisk_designs"] = list()

	if(t_disk)
		data["tdisk_nodes"] = list()
		for(var/v in t_disk.stored_research.researched_nodes)
			var/datum/techweb_node/TN = t_disk.stored_research.researched_nodes[v]
			data["tdisk_nodes"] += list(list("display_name" = TN.display_name, "id" = TN.id))

	return data

/obj/machinery/computer/rdconsole/ui_act(action, params)
	if(..())
		return
	to_chat(usr, "<span class='boldnotice'>DEBUG: Interact with action [action] and params: \"[list2params(params)]\"</span>")
	switch(action)
		if("select_node")
			selected_node = SSresearch.techweb_nodes[params["id"]]
		if("select_design")
			selected_design = SSresearch.techweb_designs[params["id"]]
		if("research_node")
			research_node(params["id"], usr)
		if("Lock")
			if(allowed(usr))
				lock_console(usr)
			else
				to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
		if("Unlock")
			if(allowed(usr))
				unlock_console(usr)
			else
				to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
		if("Resync")
			to_chat(usr, "<span class='boldnotice'>[bicon(src)]: Resynced with nearby machinery.</span>")
			SyncRDevices()
		if("textSearch")
			var/text = params["inputText"]
			var/compare
			if(params["latheType"] == "proto")
				compare = PROTOLATHE
			else if(params["latheType"] == "imprinter")
				compare = IMPRINTER
			var/list/operating = compare == PROTOLATHE? matching_designs_protolathe : matching_designs_imprinter
			operating.Cut()
			for(var/v in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[v]
				if(!(D.build_type & compare))
					continue
				if(findtext(D.name, text))
					operating[D.id] = D
		if("switchcat")
			if(params["type"] == "proto")
				category_lathe = params["cat"]
			else if(params["type"] == "imprinter")
				category_imprinter = params["cat"]
			rescan_category_views()
		if("releasemats")
			if(params["latheType"])
				linked_lathe.materials.retrieve_sheets(text2num(params["sheets"]), params["mat_id"])
			else if(params["latheType"])
				linked_imprinter.materials.retrieve_sheets(text2num(params["sheets"]), params["mat_id"])
		if("purgechem")
			if(params["type"])
				linked_lathe.reagents.del_reagent(params["id"])
			else if(params["type"])
				linked_lathe.reagents.del_reagent(params["id"])
		if("disconnect")
			switch(params["type"])
				if("destroy")
					linked_destroy.linked_console = null
					linked_destroy = null
				if("lathe")
					linked_lathe.linked_console = null
					linked_lathe = null
				if("imprinter")
					linked_imprinter.linked_console = null
					linked_imprinter = null
		if("eject_da")
			linked_destroy.unload_item()
		if("deconstruct")
			linked_destroy.user_try_decon_id(params["id"])
		if("print")
			if(params["latheType"] == "proto")
				linked_lathe.user_try_print_id(params["id"], params["amount"])
			if(params["latheType"] == "circuit")
				linked_imprinter.user_try_print_id(params["id"])
		if("eject_disk")
			eject_disk(params["type"])
		if("tdisk_clear")
			if(t_disk)
				qdel(t_disk.stored_research)
				t_disk.stored_research = new
				say("Technology disk cleared.")
				addtimer(CALLBACK(src, .proc/tdisk_update_complete), 50)
		if("tdisk_down")
			if(t_disk)
				stored_research.copy_research_to(t_disk.stored_research)
				say("Downloading research to disk.")
				addtimer(CALLBACK(src, .proc/tdisk_update_complete), 30)
		if("tdisk_up")
			if(t_disk)
				t_disk.stored_research.copy_research_to(stored_research)
				say("Uploading research from disk.")
				tdisk_update = TRUE
				addtimer(CALLBACK(src, .proc/tdisk_update_complete), 50)
	SStgui.try_update_ui(usr, src, "rdconsole")			//Force refresh.

/obj/machinery/computer/rdconsole/proc/tdisk_update_complete()
	tdisk_update = FALSE

/obj/machinery/computer/rdconsole/proc/ddisk_update_complete()
	ddisk_update = FALSE

/obj/machinery/computer/rdconsole/proc/eject_disk(type)
	if(type == "design")
		d_disk.forceMove(get_turf(src))
		d_disk = null
	if(type == "tech")
		t_disk.forceMove(get_turf(src))
		t_disk = null

/obj/machinery/computer/rdconsole/proc/rescan_category_views()
	cat_designs_protolathe = list()
	cat_designs_imprinter = list()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if((D.build_type & PROTOLATHE) && (category_lathe in D.category))
			cat_designs_protolathe[D.id] = D
		if((D.build_type & IMPRINTER) && (category_imprinter in D.category))
			cat_designs_imprinter[D.id] = D

/obj/machinery/computer/rdconsole/proc/get_actual_mat_string(datum/design/D, buildtype)
	. = ""
	var/all_materials = D.materials + D.reagents_list
	if(buildtype == IMPRINTER)
		if(!linked_imprinter)
			return FALSE
		for(var/M in all_materials)
			. += " | "
			. += " <span class='[linked_imprinter.check_mat(D, M)? "" : "bad"]'>[all_materials[M]/linked_lathe.efficiency_coeff] [CallMaterialName(M)]</span>"
	else if(buildtype == PROTOLATHE)
		if(!linked_lathe)
			return FALSE
		for(var/M in all_materials)
			. += " | "
			. += " <span class='[linked_lathe.check_mat(D, M)? "" : "bad"]'>[all_materials[M]/linked_lathe.efficiency_coeff] [CallMaterialName(M)]</span>"

/obj/machinery/computer/rdconsole/proc/check_canprint(datum/design/D, buildtype)
	var/amount = 50
	if(buildtype == IMPRINTER)
		if(!linked_imprinter)
			return FALSE
		for(var/M in D.materials + D.reagents_list)
			amount = min(amount, linked_imprinter.check_mat(D, M))
			if(amount < 1)
				return FALSE
	else if(buildtype == PROTOLATHE)
		if(!linked_lathe)
			return FALSE
		for(var/M in D.materials + D.reagents_list)
			amount = min(amount, linked_lathe.check_mat(D, M))
			if(amount < 1)
				return FALSE
	else
		return FALSE
	return amount

/obj/machinery/computer/rdconsole/proc/lock_console(mob/user)
	locked = TRUE

/obj/machinery/computer/rdconsole/proc/unlock_console(mob/user)
	locked = FALSE

/obj/machinery/computer/rdconsole/ui_interact(mob/user, ui_key = "rdconsole", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "rdconsole_primary", "Research and Development", 880, 880, master_ui, state)
		ui.open()

//helper proc, which return a table containing categories
/obj/machinery/computer/rdconsole/proc/list_categories(list/categories, menu_num as num)
	if(!categories)
		return

	var/line_length = 1
	var/dat = "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			dat += "</tr><tr>"
			line_length = 1

		dat += "<td><A href='?src=\ref[src];category=[C];menu=[menu_num]'>[C]</A></td>"
		line_length++

	dat += "</tr></table></div>"
	return dat

/obj/machinery/computer/rdconsole/robotics
	name = "Robotics R&D Console"
	desc = "A console used to interface with R&D tools."
	req_access = null
	req_access_txt = "29"

/obj/machinery/computer/rdconsole/robotics/Initialize()
	. = ..()
	if(circuit)
		circuit.name = "R&D Console - Robotics (Computer Board)"
		circuit.build_path = /obj/machinery/computer/rdconsole/robotics

/obj/machinery/computer/rdconsole/core
	name = "Core R&D Console"
	desc = "A console used to interface with R&D tools."

/obj/machinery/computer/rdconsole/experiment
	name = "E.X.P.E.R.I-MENTOR R&D Console"
	desc = "A console used to interface with R&D tools."
