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
	var/datum/techweb/stored_research					//Reference to global science techweb.
	var/obj/item/weapon/disk/tech_disk/t_disk = null	//Stores the technology disk.
	var/obj/item/weapon/disk/design_disk/d_disk = null	//Stores the design disk.
	circuit = /obj/item/circuitboard/computer/rdconsole

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
	var/uploading_ddisk_design
	var/uploading_slot

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

<<<<<<< HEAD
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
=======
/obj/machinery/computer/rdconsole/attackby(obj/item/D, mob/user, params)

	//Loading a disk into it.
	if(istype(D, /obj/item/disk))
		if(t_disk || d_disk)
			to_chat(user, "A disk is already loaded into the machine.")
			return

		if(istype(D, /obj/item/disk/tech_disk))
			t_disk = D
		else if (istype(D, /obj/item/disk/design_disk))
>>>>>>> tgstation/master
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
			var/mname = CallMaterialName(M)
			data["sdesign_mats"] += list(list("matname" = mname, "matamt" = selected_design.materials[M]))
	//Both Lathes
	data["lathe_tabs"] = list("Category List", "Selected Category", "Search Results", "Materials", "Chemicals")
	//Protolathe
	if(linked_lathe)
		data["protobusy"] = linked_lathe.busy? TRUE : FALSE
		data["protocats"] = list()
		data["protocat"] = category_lathe
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
		data["circuitcat"] = category_imprinter
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
	data["ddisk_upload"] = uploading_ddisk_design
	if(d_disk)
		if(!uploading_ddisk_design)
			data["ddisk_size"] = d_disk.max_blueprints
			data["ddisk_designs"] = list()
			for(var/i in 1 to d_disk.max_blueprints)
				var/datum/design/D = d_disk.blueprints[i]
				if(istype(D))
					data["ddisk_designs"] += list(list("pos" = "[i]", "name" = D.name, "id" = D.id))
				else
<<<<<<< HEAD
					data["ddisk_designs"] += list(list("pos" = "[i]", "name" = "Empty Slot", "id" = "null"))
=======
					files.AddDesign2Known(d_disk.blueprints[n])
				updateUsrDialog()
				griefProtection() //Update centcom too

	else if(href_list["clear_design"]) //Erases data on the design disk.
		if(d_disk)
			var/n = text2num(href_list["clear_design"])
			if(!n)
				for(var/i in 1 to d_disk.max_blueprints)
					d_disk.blueprints[i] = null
			else
				d_disk.blueprints[n] = null

	else if(href_list["eject_design"]) //Eject the design disk.
		if(d_disk)
			d_disk.loc = src.loc
			d_disk = null
		screen = 1.0

	else if(href_list["copy_design"]) //Copy design data from the research holder to the design disk.
		var/slot = text2num(href_list["copy_design"])
		var/datum/design/D = files.known_designs[href_list["copy_design_ID"]]
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
		screen = 1.4

	else if(href_list["eject_item"]) //Eject the item inside the destructive analyzer.
		if(linked_destroy)
			if(linked_destroy.busy)
				to_chat(usr, "<span class='danger'>The destructive analyzer is busy at the moment.</span>")

			else if(linked_destroy.loaded_item)
				linked_destroy.loaded_item.forceMove(linked_destroy.loc)
				linked_destroy.loaded_item = null
				linked_destroy.icon_state = "d_analyzer"
				screen = 1.0

	else if(href_list["deconstruct"]) //Deconstruct the item in the destructive analyzer and update the research holder.
		if(!linked_destroy || linked_destroy.busy || !linked_destroy.loaded_item)
			updateUsrDialog()
			return

		var/list/temp_tech = linked_destroy.ConvertReqString2List(linked_destroy.loaded_item.origin_tech)
		var/cancontinue = FALSE
		for(var/T in temp_tech)
			if(files.IsTechHigher(T, temp_tech[T]))
				cancontinue = TRUE
				break
		if(!cancontinue)
			var/choice = input("This item does not raise tech levels. Proceed destroying loaded item anyway?") in list("Proceed", "Cancel")
			if(choice == "Cancel" || !linked_destroy || !linked_destroy.loaded_item) return
		linked_destroy.busy = TRUE
		screen = 0.1
		updateUsrDialog()
		flick("d_analyzer_process", linked_destroy)
		spawn(24)
			if(linked_destroy)
				linked_destroy.busy = FALSE
				if(!linked_destroy.loaded_item)
					screen = 1.0
					return

				for(var/T in temp_tech)
					var/datum/tech/KT = files.known_tech[T] //For stat logging of high levels
					if(files.IsTechHigher(T, temp_tech[T]) && KT.level >= 5) //For stat logging of high levels
						SSblackbox.add_details("high_research_level","[KT][KT.level + 1]") //+1 to show the level which we're about to get
					files.UpdateTech(T, temp_tech[T])

				if(linked_lathe) //Also sends salvaged materials to a linked protolathe, if any.
					for(var/material in linked_destroy.loaded_item.materials)
						linked_lathe.materials.insert_amount(min((linked_lathe.materials.max_amount - linked_lathe.materials.total_amount), (linked_destroy.loaded_item.materials[material]*(linked_destroy.decon_mod/10))), material)
					SSblackbox.add_details("item_deconstructed","[linked_destroy.loaded_item.type]")
				linked_destroy.loaded_item = null
				for(var/obj/I in linked_destroy.contents)
					for(var/mob/M in I.contents)
						M.death()
					if(istype(I, /obj/item/stack/sheet))//Only deconsturcts one sheet at a time instead of the entire stack
						var/obj/item/stack/sheet/S = I
						if(S.amount > 1)
							S.amount--
							linked_destroy.loaded_item = S
						else
							qdel(S)
							linked_destroy.icon_state = "d_analyzer"
					else
						if(!(I in linked_destroy.component_parts))
							qdel(I)
							linked_destroy.icon_state = "d_analyzer"
			screen = 1.0
			use_power(250)
			updateUsrDialog()

	else if(href_list["lock"]) //Lock the console from use by anyone without tox access.
		if(src.allowed(usr))
			screen = text2num(href_list["lock"])
		else
			to_chat(usr, "Unauthorized Access.")

	else if(href_list["sync"]) //Sync the research holder with all the R&D consoles in the game that aren't sync protected.
		screen = 0.0
		if(!sync)
			to_chat(usr, "<span class='danger'>You must connect to the network first!</span>")
		else
			griefProtection() //Putting this here because I dont trust the sync process
			spawn(30)
				if(src)
					for(var/obj/machinery/r_n_d/server/S in GLOB.machines)
						var/server_processed = 0
						if(S.disabled)
							continue
						if((id in S.id_with_upload) || istype(S, /obj/machinery/r_n_d/server/centcom))
							for(var/v in files.known_tech)
								var/datum/tech/T = files.known_tech[v]
								S.files.AddTech2Known(T)
							for(var/v in files.known_designs)
								var/datum/design/D = files.known_designs[v]
								S.files.AddDesign2Known(D)
							S.files.RefreshResearch()
							server_processed = 1
						if(((id in S.id_with_download) && !istype(S, /obj/machinery/r_n_d/server/centcom)) || S.hacked)
							for(var/v in S.files.known_tech)
								var/datum/tech/T = S.files.known_tech[v]
								files.AddTech2Known(T)
							for(var/v in S.files.known_designs)
								var/datum/design/D = S.files.known_designs[v]
								files.AddDesign2Known(D)
							files.RefreshResearch()
							server_processed = 1
						if(!istype(S, /obj/machinery/r_n_d/server/centcom) && server_processed)
							S.produce_heat(100)
					screen = 1.6
					updateUsrDialog()

	else if(href_list["togglesync"]) //Prevents the console from being synced by other consoles. Can still send data.
		sync = !sync

	else if(href_list["build"]) //Causes the Protolathe to build something.
		var/datum/design/being_built = files.known_designs[href_list["build"]]
		var/amount = text2num(href_list["amount"])

		if(being_built.make_reagents.len)
			return 0

		if(!linked_lathe || !being_built || !amount)
			updateUsrDialog()
			return

		if(linked_lathe.busy)
			to_chat(usr, "<span class='danger'>Protolathe is busy at the moment.</span>")
			return

		var/coeff = linked_lathe.efficiency_coeff
		var/power = 1000
		var/old_screen = screen

		amount = max(1, min(10, amount))
		for(var/M in being_built.materials)
			power += round(being_built.materials[M] * amount / 5)
		power = max(3000, power)
		screen = 0.3
		var/key = usr.key	//so we don't lose the info during the spawn delay
		if (!(being_built.build_type & PROTOLATHE))
			message_admins("Protolathe exploit attempted by [key_name(usr, usr.client)]!")
			updateUsrDialog()
			return

		var/g2g = 1
		var/enough_materials = 1
		linked_lathe.busy = TRUE
		flick("protolathe_n",linked_lathe)
		use_power(power)

		var/list/efficient_mats = list()
		for(var/MAT in being_built.materials)
			efficient_mats[MAT] = being_built.materials[MAT]*coeff

		if(!linked_lathe.materials.has_materials(efficient_mats, amount))
			linked_lathe.say("Not enough materials to complete prototype.")
			enough_materials = 0
			g2g = 0
		else
			for(var/R in being_built.reagents_list)
				if(!linked_lathe.reagents.has_reagent(R, being_built.reagents_list[R]*coeff))
					linked_lathe.say("Not enough reagents to complete prototype.")
					enough_materials = 0
					g2g = 0

		if(enough_materials)
			linked_lathe.materials.use_amount(efficient_mats, amount)
			for(var/R in being_built.reagents_list)
				linked_lathe.reagents.remove_reagent(R, being_built.reagents_list[R]*coeff)

		var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.

		coeff *= being_built.lathe_time_factor

		spawn(32*coeff*amount**0.8)
			if(linked_lathe)
				if(g2g) //And if we only fail the material requirements, we still spend time and power
					var/already_logged = 0
					for(var/i = 0, i<amount, i++)
						var/obj/item/new_item = new P(src)
						if( new_item.type == /obj/item/storage/backpack/holding )
							new_item.investigate_log("built by [key]", INVESTIGATE_SINGULO)
						if(!istype(new_item, /obj/item/stack/sheet) && !istype(new_item, /obj/item/ore/bluespace_crystal)) // To avoid materials dupe glitches
							new_item.materials = efficient_mats.Copy()
						new_item.loc = linked_lathe.loc
						if(!already_logged)
							SSblackbox.add_details("item_printed","[new_item.type]|[amount]")
							already_logged = 1
				screen = old_screen
				linked_lathe.busy = FALSE
			else
				say("Protolathe connection failed. Production halted.")
				screen = 1.0
			updateUsrDialog()

	else if(href_list["imprint"]) //Causes the Circuit Imprinter to build something.
		var/datum/design/being_built = files.known_designs[href_list["imprint"]]

		if(!linked_imprinter || !being_built)
			updateUsrDialog()
			return

		if(linked_imprinter.busy)
			to_chat(usr, "<span class='danger'>Circuit Imprinter is busy at the moment.</span>")
			updateUsrDialog()
			return

		var/coeff = linked_imprinter.efficiency_coeff

		var/power = 1000
		var/old_screen = screen
		for(var/M in being_built.materials)
			power += round(being_built.materials[M] / 5)
		power = max(4000, power)
		screen = 0.4
		if (!(being_built.build_type & IMPRINTER))
			message_admins("Circuit imprinter exploit attempted by [key_name(usr, usr.client)]!")
			updateUsrDialog()
			return

		var/g2g = 1
		var/enough_materials = 1
		linked_imprinter.busy = TRUE
		flick("circuit_imprinter_ani", linked_imprinter)
		use_power(power)

		var/list/efficient_mats = list()
		for(var/MAT in being_built.materials)
			efficient_mats[MAT] = being_built.materials[MAT]/coeff

		if(!linked_imprinter.materials.has_materials(efficient_mats))
			linked_imprinter.say("Not enough materials to complete prototype.")
			enough_materials = 0
			g2g = 0
		else
			for(var/R in being_built.reagents_list)
				if(!linked_imprinter.reagents.has_reagent(R, being_built.reagents_list[R]/coeff))
					linked_imprinter.say("Not enough reagents to complete prototype.")
					enough_materials = 0
					g2g = 0

		if(enough_materials)
			linked_imprinter.materials.use_amount(efficient_mats)
			for(var/R in being_built.reagents_list)
				linked_imprinter.reagents.remove_reagent(R, being_built.reagents_list[R]/coeff)

		var/P = being_built.build_path //lets save these values before the spawn() just in case. Nobody likes runtimes.
		spawn(16)
			if(linked_imprinter)
				if(g2g)
					var/obj/item/new_item = new P(src)
					new_item.loc = linked_imprinter.loc
					new_item.materials = efficient_mats.Copy()
					SSblackbox.add_details("circuit_printed","[new_item.type]")
				screen = old_screen
				linked_imprinter.busy = FALSE
			else
				say("Circuit Imprinter connection failed. Production halted.")
				screen = 1.0
			updateUsrDialog()

	//Protolathe Materials
	else if(href_list["disposeP"] && linked_lathe)  //Causes the protolathe to dispose of a single reagent (all of it)
		linked_lathe.reagents.del_reagent(href_list["disposeP"])

	else if(href_list["disposeallP"] && linked_lathe) //Causes the protolathe to dispose of all it's reagents.
		linked_lathe.reagents.clear_reagents()

	else if(href_list["ejectsheet"] && linked_lathe) //Causes the protolathe to eject a sheet of material
		linked_lathe.materials.retrieve_sheets(text2num(href_list["eject_amt"]), href_list["ejectsheet"])

	//Circuit Imprinter Materials
	else if(href_list["disposeI"] && linked_imprinter)  //Causes the circuit imprinter to dispose of a single reagent (all of it)
		linked_imprinter.reagents.del_reagent(href_list["disposeI"])

	else if(href_list["disposeallI"] && linked_imprinter) //Causes the circuit imprinter to dispose of all it's reagents.
		linked_imprinter.reagents.clear_reagents()

	else if(href_list["imprinter_ejectsheet"] && linked_imprinter) //Causes the imprinter to eject a sheet of material
		linked_imprinter.materials.retrieve_sheets(text2num(href_list["eject_amt"]), href_list["imprinter_ejectsheet"])


	else if(href_list["find_device"]) //The R&D console looks for devices nearby to link up with.
		screen = 0.0
		spawn(20)
			SyncRDevices()
			screen = 1.7
			updateUsrDialog()

	else if(href_list["disconnect"]) //The R&D console disconnects with a specific device.
		switch(href_list["disconnect"])
			if("destroy")
				linked_destroy.linked_console = null
				linked_destroy = null
			if("lathe")
				linked_lathe.linked_console = null
				linked_lathe = null
			if("imprinter")
				linked_imprinter.linked_console = null
				linked_imprinter = null

	else if(href_list["reset"]) //Reset the R&D console's database.
		griefProtection()
		var/choice = alert("R&D Console Database Reset", "Are you sure you want to reset the R&D console's database? Data lost cannot be recovered.", "Continue", "Cancel")
		if(choice == "Continue" && usr.canUseTopic(src))
			message_admins("[key_name_admin(usr)] reset \the [src.name]'s database")
			log_game("[key_name_admin(usr)] reset \the [src.name]'s database")
			screen = 0.0
			qdel(files)
			files = new /datum/research(src)
			spawn(20)
				screen = 1.6
				updateUsrDialog()

	else if(href_list["search"]) //Search for designs with name matching pattern
		var/compare

		matching_designs.Cut()

		if(href_list["type"] == "proto")
			compare = PROTOLATHE
			screen = 3.17
>>>>>>> tgstation/master
		else
			data["ddisk_possible_designs"] = list()
			for(var/i in stored_research.researched_designs)
				var/datum/design/D = stored_research.researched_designs[i]
				data["ddisk_possible_designs"] += list(list("name" = D.name, "id" = D.id))
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
		if("ddisk_upall")
			if(d_disk)
				for(var/i in d_disk.blueprints)
					var/datum/design/D = i
					if(istype(D))
						stored_research.add_design(D)
				say("Uploading all disk designs to stored research.")
				ddisk_update = TRUE
				addtimer(CALLBACK(src, .proc/ddisk_update_complete), 20)
		if("clear_designdisk")
			if(d_disk)
				for(var/i in d_disk.blueprints)
					d_disk.blueprints[i] = null
				say("Wiping design disk.")
				ddisk_update = TRUE
				addtimer(CALLBACK(src, .proc/ddisk_update_complete), 50)
		if("upload_empty_ddisk_slot")
			if(params["slot"])
				uploading_ddisk_design = TRUE
				uploading_slot = params["slot"]
		if("ddisk_uploaddesign")
			uploading_ddisk_design = FALSE
			if(params["design_id"])
				if(stored_research.isDesignResearchedID(params["design_id"]))
					if(uploading_slot)
						d_disk.blueprints[uploading_slot] = stored_research.isDesignResearchedID(params["design_id"])
						say("Uploading Design to disk.")
						ddisk_update = TRUE
						addtimer(CALLBACK(src, .proc/ddisk_update_complete), 5)
		if("ddisk_erasepos")
			if(params["slot"])
				d_disk.blueprints[params["slot"]] = null
				say("Clearing slot [params["slot"]] on design disk!")
				ddisk_update = TRUE
				addtimer(CALLBACK(src, .proc/ddisk_update_complete), 5)

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
			. += " {{{<span class='[linked_imprinter.check_mat(D, M)? "" : "bad"]'>}}}[all_materials[M]/linked_lathe.efficiency_coeff] [CallMaterialName(M)]{{{</span>}}}"
	else if(buildtype == PROTOLATHE)
		if(!linked_lathe)
			return FALSE
		for(var/M in all_materials)
			. += " | "
			. += " {{{<span class='[linked_lathe.check_mat(D, M)? "" : "bad"]'>}}}[all_materials[M]/linked_lathe.efficiency_coeff] [CallMaterialName(M)]{{{</span>}}}"

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
