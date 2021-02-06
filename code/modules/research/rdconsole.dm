
/*
Research and Development (R&D) Console

This is the main work horse of the R&D system. It contains the menus/controls for the Destructive Analyzer, Protolathe, and Circuit
imprinter.

Basic use: When it first is created, it will attempt to link up to related devices within 3 squares. It'll only link up if they
aren't already linked to another console. Any consoles it cannot link up with (either because all of a certain type are already
linked or there aren't any in range), you'll just not have access to that menu. In the settings menu, there are menu options that
allow a player to attempt to re-sync with nearby consoles. You can also force it to disconnect from a specific console.

The only thing that requires toxins access is locking and unlocking the console on the settings menu.
Nothing else in the console has ID requirements.

*/
/obj/machinery/computer/rdconsole
	name = "R&D Console"
	desc = "A console used to interface with R&D tools."
	icon_screen = "rdcomp"
	icon_keyboard = "rd_key"
	var/datum/techweb/stored_research					//Reference to global science techweb.
	var/obj/item/disk/tech_disk/t_disk	//Stores the technology disk.
	var/obj/item/disk/design_disk/d_disk	//Stores the design disk.
	circuit = /obj/item/circuitboard/computer/rdconsole

	req_access = list(ACCESS_RND)	//lA AND SETTING MANIPULATION REQUIRES SCIENTIST ACCESS.

	//UI VARS
	var/screen = RDSCREEN_MENU
	var/back = RDSCREEN_MENU
	var/locked = FALSE
	var/tdisk_uple = FALSE
	var/ddisk_uple = FALSE
	var/datum/selected_node_id
	var/datum/selected_design_id
	var/selected_category
	var/disk_slot_selected
	var/searchstring = ""
	var/searchtype = ""
	var/ui_mode = RDCONSOLE_UI_MODE_NORMAL

	var/research_control = TRUE

/proc/CallMaterialName(ID)
	if (istype(ID, /datum/material))
		var/datum/material/material = ID
		return material.name

	else if(GLOB.chemical_reagents_list[ID])
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[ID]
		return reagent.name
	return ID

/obj/machinery/computer/rdconsole/Initialize()
	. = ..()
	stored_research = SSresearch.science_tech
	stored_research.consoles_accessing[src] = TRUE

/obj/machinery/computer/rdconsole/Destroy()
	if(stored_research)
		stored_research.consoles_accessing -= src
	if(t_disk)
		t_disk.forceMove(get_turf(src))
		t_disk = null
	if(d_disk)
		d_disk.forceMove(get_turf(src))
		d_disk = null
	return ..()

/obj/machinery/computer/rdconsole/attackby(obj/item/D, mob/user, params)
	if(istype(D, /obj/item/research_notes))
		var/obj/item/research_notes/R = D
		SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = R.value))
		playsound(src,'sound/machines/copier.ogg', 100, TRUE)
		qdel(R)
		return TRUE
	//Loading a disk into it.
	if(istype(D, /obj/item/disk))
		if(istype(D, /obj/item/disk/tech_disk))
			if(t_disk)
				to_chat(user, "<span class='warning'>A technology disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='warning'>[D] is stuck to your hand!</span>")
				return
			t_disk = D
		else if (istype(D, /obj/item/disk/design_disk))
			if(d_disk)
				to_chat(user, "<span class='warning'>A design disk is already loaded!</span>")
				return
			if(!user.transferItemToLoc(D, src))
				to_chat(user, "<span class='warning'>[D] is stuck to your hand!</span>")
				return
			d_disk = D
		else
			to_chat(user, "<span class='warning'>Machine cannot accept disks in that format.</span>")
			return
		to_chat(user, "<span class='notice'>You insert [D] into \the [src]!</span>")
		return
	return ..()

/obj/machinery/computer/rdconsole/proc/research_node(id, mob/user)
	if(!stored_research.available_nodes[id] || stored_research.researched_nodes[id])
		say("Node unlock failed: Either already researched or not available!")
		return FALSE
	var/datum/techweb_node/TN = SSresearch.techweb_node_by_id(id)
	if(!istype(TN))
		say("Node unlock failed: Unknown error.")
		return FALSE
	var/list/price = TN.get_price(stored_research)
	if(stored_research.can_afford(price))
		investigate_log("[key_name(user)] researched [id]([json_encode(price)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
		if(stored_research == SSresearch.science_tech)
			SSblackbox.record_feedback("associative", "science_techweb_unlock", 1, list("id" = "[id]", "name" = TN.display_name, "price" = "[json_encode(price)]", "time" = SQLtime()))
		if(stored_research.research_node_id(id))
			say("Successfully researched [TN.display_name].")
			var/logname = "Unknown"
			if(isAI(user))
				logname = "AI: [user.name]"
			if(iscarbon(user))
				var/obj/item/card/id/idcard = user.get_active_held_item()
				if(istype(idcard))
					logname = "User: [idcard.registered_name]"
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/obj/item/I = H.wear_id
				if(istype(I))
					var/obj/item/card/id/ID = I.GetID()
					if(istype(ID))
						logname = "User: [ID.registered_name]"
			var/i = stored_research.research_logs.len
			stored_research.research_logs += null
			stored_research.research_logs[++i] = list(TN.display_name, price["General Research"], logname, "[get_area(src)] ([src.x],[src.y],[src.z])")
			return TRUE
		else
			say("Failed to research node: Internal database error!")
			return FALSE
	say("Not enough research points...")
	return FALSE

/obj/machinery/computer/rdconsole/emag_act(mob/user)
	if(!(obj_flags & EMAGGED))
		to_chat(user, "<span class='notice'>You disable the security protocols[locked? " and unlock the console":""].</span>")
		playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		obj_flags |= EMAGGED
		locked = FALSE
	return ..()

/obj/machinery/computer/rdconsole/proc/list_categories(list/categories, menu_num as num)
	if(!categories)
		return

	var/line_length = 1
	var/list/l = "<table style='width:100%' align='center'><tr>"

	for(var/C in categories)
		if(line_length > 2)
			l += "</tr><tr>"
			line_length = 1

		l += "<td><A href='?src=[REF(src)];category=[C];switch_screen=[menu_num]'>[C]</A></td>"
		line_length++

	l += "</tr></table></div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_header()
	var/list/l = list()
	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/research_designs)
	l += "[sheet.css_tag()][RDSCREEN_NOBREAK]"
	l += "<div class='statusDisplay'><b>[stored_research.organization] Research and Development Network</b>"
	l += "Available points: <BR>[techweb_point_display_rdconsole(stored_research.research_points, stored_research.last_bitcoins)]"
	l += "Security protocols: [obj_flags & EMAGGED ? "<font color='red'>Disabled</font>" : "<font color='green'>Enabled</font>"]"
	l += "<a href='?src=[REF(src)];switch_screen=[RDSCREEN_MENU]'>Main Menu</a> | <a href='?src=[REF(src)];switch_screen=[back]'>Back</a></div>[RDSCREEN_NOBREAK]"
	l += "[ui_mode == 1? "<span class='linkOn'>Normal View</span>" : "<a href='?src=[REF(src)];ui_mode=1'>Normal View</a>"] | [ui_mode == 2? "<span class='linkOn'>Expert View</span>" : "<a href='?src=[REF(src)];ui_mode=2'>Expert View</a>"] | [ui_mode == 3? "<span class='linkOn'>List View</span>" : "<a href='?src=[REF(src)];ui_mode=3'>List View</a>"]"
	return l

/obj/machinery/computer/rdconsole/proc/ui_main_menu()
	var/list/l = list()
	if(research_control)
		l += "<H2><a href='?src=[REF(src)];switch_screen=[RDSCREEN_TECHWEB]'>Technology</a>"
	if(d_disk)
		l += "<hr><a href='?src=[REF(src)];switch_screen=[RDSCREEN_DESIGNDISK]'>Design Disk</a>"
	if(t_disk)
		l += "<hr><a href='?src=[REF(src)];switch_screen=[RDSCREEN_TECHDISK]'>Tech Disk</a>"
	l += "<hr><a href='?src=[REF(src)];switch_screen=[RDSCREEN_SETTINGS]'>Settings</a></H2>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_locked()
	return list("<h3><a href='?src=[REF(src)];switch_screen=[RDSCREEN_MENU];unlock_console=1'>SYSTEM LOCKED</a></h3></br>")

/obj/machinery/computer/rdconsole/proc/ui_settings()
	var/list/l = list()
	l += "<div class='statusDisplay'><h3>R&D Console Settings:</h3>"
	l += "<A href='?src=[REF(src)];lock_console=1'>Lock Console</A></div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_techdisk()		//Legacy code
	RDSCREEN_UI_TDISK_CHECK
	var/list/l = list()
	l += "<div class='statusDisplay'>Disk Operations: <A href='?src=[REF(src)];clear_tech=0'>Clear Disk</A>"
	l += "<A href='?src=[REF(src)];eject_tech=1'>Eject Disk</A>"
	l += "<A href='?src=[REF(src)];updt_tech=0'>Upload All</A>"
	l += "<A href='?src=[REF(src)];copy_tech=1'>Load Technology to Disk</A></div>"
	l += "<div class='statusDisplay'><h3>Stored Technology Nodes:</h3>"
	for(var/i in t_disk.stored_research.researched_nodes)
		var/datum/techweb_node/N = SSresearch.techweb_node_by_id(i)
		l += "<A href='?src=[REF(src)];view_node=[i];back_screen=[screen]'>[N.display_name]</A>"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_designdisk()		//Legacy code
	RDSCREEN_UI_DDISK_CHECK
	var/list/l = list()
	l += "Disk Operations: <A href='?src=[REF(src)];clear_design=0'>Clear Disk</A><A href='?src=[REF(src)];updt_design=0'>Upload All</A><A href='?src=[REF(src)];eject_design=1'>Eject Disk</A>"
	for(var/i in 1 to d_disk.max_blueprints)
		l += "<div class='statusDisplay'>"
		if(d_disk.blueprints[i])
			var/datum/design/D = d_disk.blueprints[i]
			l += "<A href='?src=[REF(src)];view_design=[D.id]'>[D.name]</A>"
			l += "Operations: <A href='?src=[REF(src)];updt_design=[i]'>Upload to database</A> <A href='?src=[REF(src)];clear_design=[i]'>Clear Slot</A>"
		else
			l += "Empty Slot Operations: <A href='?src=[REF(src)];switch_screen=[RDSCREEN_DESIGNDISK_UPLOAD];disk_slot=[i]'>Load Design to Slot</A>"
		l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_designdisk_upload()	//Legacy code
	RDSCREEN_UI_DDISK_CHECK
	var/list/l = list()
	l += "<A href='?src=[REF(src)];switch_screen=[RDSCREEN_DESIGNDISK];back_screen=[screen]'>Return to Disk Operations</A><div class='statusDisplay'>"
	l += "<h3>Load Design to Disk:</h3>"
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		l += "[D.name] "
		l += "<A href='?src=[REF(src)];copy_design=[disk_slot_selected];copy_design_ID=[D.id]'>Copy to Disk</A>"
	l += "</div>"
	return l

/obj/machinery/computer/rdconsole/proc/ui_techweb()
	var/list/l = list()
	if(ui_mode != RDCONSOLE_UI_MODE_LIST)
		var/list/columns = list()
		var/max_tier = 0
		for (var/node_ in stored_research.tiers)
			var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_)
			var/tier = stored_research.tiers[node.id]
			LAZYINITLIST(columns["[tier]"])  // String hackery to make the numbers associative
			columns["[tier]"] += ui_techweb_single_node(node, minimal=(tier != 1))
			max_tier = max(max_tier, tier)

		l += "<table><tr><th align='left'>Researched</th><th align='left'>Available</th><th align='left'>Future</th></tr><tr>[RDSCREEN_NOBREAK]"
		if(max_tier)
			for(var/tier in 0 to max_tier)
				l += "<td valign='top'>[RDSCREEN_NOBREAK]"
				l += columns["[tier]"]
				l += "</td>[RDSCREEN_NOBREAK]"
		l += "</tr></table>[RDSCREEN_NOBREAK]"
	else
		var/list/avail = list()			//This could probably be optimized a bit later.
		var/list/unavail = list()
		var/list/res = list()
		for(var/v in stored_research.researched_nodes)
			res += SSresearch.techweb_node_by_id(v)
		for(var/v in stored_research.available_nodes)
			if(stored_research.researched_nodes[v] || stored_research.hidden_nodes[v])
				continue
			avail += SSresearch.techweb_node_by_id(v)
		for(var/v in stored_research.visible_nodes)
			if(stored_research.available_nodes[v])
				continue
			unavail += SSresearch.techweb_node_by_id(v)
		l += "<h2>Technology Nodes:</h2>[RDSCREEN_NOBREAK]"
		l += "<div><h3>Available for Research:</h3>"
		for(var/datum/techweb_node/N in avail)
			var/not_unlocked = (stored_research.available_nodes[N.id] && !stored_research.researched_nodes[N.id])
			var/has_points = (stored_research.can_afford(N.get_price(stored_research)))
			var/research_href = not_unlocked? (has_points? "<A href='?src=[REF(src)];research_node=[N.id]'>Research</A>" : "<span class='linkOff bad'>Not Enough Points</span>") : null
			l += "<A href='?src=[REF(src)];view_node=[N.id];back_screen=[screen]'>[N.display_name]</A>[research_href]"
		l += "</div><div><h3>Locked Nodes:</h3>"
		for(var/datum/techweb_node/N in unavail)
			l += "<A href='?src=[REF(src)];view_node=[N.id];back_screen=[screen]'>[N.display_name]</A>"
		l += "</div><div><h3>Researched Nodes:</h3>"
		for(var/datum/techweb_node/N in res)
			l += "<A href='?src=[REF(src)];view_node=[N.id];back_screen=[screen]'>[N.display_name]</A>"
		l += "</div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/computer/rdconsole/proc/machine_icon(atom/item)
	return icon2html(initial(item.icon), usr, initial(item.icon_state), SOUTH)

/obj/machinery/computer/rdconsole/proc/ui_techweb_single_node(datum/techweb_node/node, selflink=TRUE, minimal=FALSE)
	var/list/l = list()
	if (stored_research.hidden_nodes[node.id])
		return l
	var/display_name = node.display_name
	if (selflink)
		display_name = "<A href='?src=[REF(src)];view_node=[node.id];back_screen=[screen]'>[display_name]</A>"
	l += "<div class='statusDisplay technode'><b>[display_name]</b> [RDSCREEN_NOBREAK]"
	if(minimal)
		l += "<br>[node.description]"
	else
		if(stored_research.researched_nodes[node.id])
			l += "<span class='linkOff'>Researched</span>"
		else if(stored_research.available_nodes[node.id])
			if(stored_research.can_afford(node.get_price(stored_research)))
				l += "<BR><A href='?src=[REF(src)];research_node=[node.id]'>[node.price_display(stored_research)]</A>"
			else
				l += "<BR><span class='linkOff'>[node.price_display(stored_research)]</span>"  // gray - too expensive
		else
			l += "<BR><span class='linkOff bad'>[node.price_display(stored_research)]</span>"  // red - missing prereqs
		if(ui_mode == RDCONSOLE_UI_MODE_NORMAL)
			l += "[node.description]"
			for(var/i in node.design_ids)
				var/datum/design/D = SSresearch.techweb_design_by_id(i)
				l += "<span data-tooltip='[D.name]' onclick='location=\"?src=[REF(src)];view_design=[i];back_screen=[screen]\"'>[D.icon_html(usr)]</span>[RDSCREEN_NOBREAK]"
	l += "</div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/computer/rdconsole/proc/ui_techweb_nodeview()
	var/datum/techweb_node/selected_node = SSresearch.techweb_node_by_id(selected_node_id)
	RDSCREEN_UI_SNODE_CHECK
	var/list/l = list()
	if(stored_research.hidden_nodes[selected_node.id])
		l += "<div><h3>ERROR: RESEARCH NODE UNKNOWN.</h3></div>"
		return

	l += "<table><tr>[RDSCREEN_NOBREAK]"
	if (length(selected_node.prereq_ids))
		l += "<th align='left'>Requires</th>[RDSCREEN_NOBREAK]"
	l += "<th align='left'>Current Node</th>[RDSCREEN_NOBREAK]"
	if (length(selected_node.unlock_ids))
		l += "<th align='left'>Unlocks</th>[RDSCREEN_NOBREAK]"

	l += "</tr><tr>[RDSCREEN_NOBREAK]"
	if (length(selected_node.prereq_ids))
		l += "<td valign='top'>[RDSCREEN_NOBREAK]"
		for (var/i in selected_node.prereq_ids)
			l += ui_techweb_single_node(SSresearch.techweb_node_by_id(i))
		l += "</td>[RDSCREEN_NOBREAK]"
	l += "<td valign='top'>[RDSCREEN_NOBREAK]"
	l += ui_techweb_single_node(selected_node, selflink=FALSE)
	l += "</td>[RDSCREEN_NOBREAK]"
	if (length(selected_node.unlock_ids))
		l += "<td valign='top'>[RDSCREEN_NOBREAK]"
		for (var/i in selected_node.unlock_ids)
			l += ui_techweb_single_node(SSresearch.techweb_node_by_id(i))
		l += "</td>[RDSCREEN_NOBREAK]"

	l += "</tr></table>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/computer/rdconsole/proc/ui_techweb_designview()		//Legacy code
	var/datum/design/selected_design = SSresearch.techweb_design_by_id(selected_design_id)
	RDSCREEN_UI_SDESIGN_CHECK
	var/list/l = list()
	l += "<div><table><tr><td>[selected_design.icon_html(usr)]</td><td><b>[selected_design.name]</b></td></tr></table>[RDSCREEN_NOBREAK]"
	if(selected_design.build_type)
		var/lathes = list()
		if(selected_design.build_type & IMPRINTER)
			lathes += "<span data-tooltip='Circuit Imprinter'>[machine_icon(/obj/machinery/rnd/production/circuit_imprinter)]</span>[RDSCREEN_NOBREAK]"
		if(selected_design.build_type & PROTOLATHE)
			lathes += "<span data-tooltip='Protolathe'>[machine_icon(/obj/machinery/rnd/production/protolathe)]</span>[RDSCREEN_NOBREAK]"
		if(selected_design.build_type & AUTOLATHE)
			lathes += "<span data-tooltip='Autolathe'>[machine_icon(/obj/machinery/autolathe)]</span>[RDSCREEN_NOBREAK]"
		if(selected_design.build_type & MECHFAB)
			lathes += "<span data-tooltip='Exosuit Fabricator'>[machine_icon(/obj/machinery/mecha_part_fabricator)]</span>[RDSCREEN_NOBREAK]"
		if(selected_design.build_type & BIOGENERATOR)
			lathes += "<span data-tooltip='Biogenerator'>[machine_icon(/obj/machinery/biogenerator)]</span>[RDSCREEN_NOBREAK]"
		if(selected_design.build_type & LIMBGROWER)
			lathes += "<span data-tooltip='Limbgrower'>[machine_icon(/obj/machinery/limbgrower)]</span>[RDSCREEN_NOBREAK]"
		if(selected_design.build_type & SMELTER)
			lathes += "<span data-tooltip='Smelter'>[machine_icon(/obj/machinery/mineral/processing_unit)]</span>[RDSCREEN_NOBREAK]"
		l += "Construction types:"
		l += lathes
		l += ""
	l += "Required materials:"
	var/all_mats = selected_design.materials + selected_design.reagents_list
	for(var/M in all_mats)
		l += "* [CallMaterialName(M)] x [all_mats[M]]"
	l += "Unlocked by:"
	for (var/i in selected_design.unlocked_by)
		l += ui_techweb_single_node(SSresearch.techweb_node_by_id(i))
	l += "[RDSCREEN_NOBREAK]</div>"
	return l

//Fuck TGUI.
/obj/machinery/computer/rdconsole/proc/generate_ui()
	var/list/ui = list()
	ui += ui_header()
	if(locked)
		ui += ui_locked()
	else
		switch(screen)
			if(RDSCREEN_MENU)
				ui += ui_main_menu()
			if(RDSCREEN_TECHWEB)
				ui += ui_techweb()
			if(RDSCREEN_TECHWEB_NODEVIEW)
				ui += ui_techweb_nodeview()
			if(RDSCREEN_TECHWEB_DESIGNVIEW)
				ui += ui_techweb_designview()
			if(RDSCREEN_DESIGNDISK)
				ui += ui_designdisk()
			if(RDSCREEN_DESIGNDISK_UPLOAD)
				ui += ui_designdisk_upload()
			if(RDSCREEN_TECHDISK)
				ui += ui_techdisk()
			if(RDSCREEN_SETTINGS)
				ui += ui_settings()

	for(var/i in 1 to length(ui))
		if(!findtextEx(ui[i], RDSCREEN_NOBREAK))
			ui[i] += "<br>"
	. = ui.Join("")
	return replacetextEx(., RDSCREEN_NOBREAK, "")

/obj/machinery/computer/rdconsole/Topic(raw, ls)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)
	if(ls["switch_screen"])
		back = screen
		screen = text2num(ls["switch_screen"])
	if(ls["ui_mode"])
		ui_mode = text2num(ls["ui_mode"])
	if(ls["lock_console"])
		if(obj_flags & EMAGGED)
			to_chat(usr, "<span class='boldwarning'>Security protocol error: Unable to lock.</span>")
			return
		if(allowed(usr))
			lock_console(usr)
		else
			to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
	if(ls["unlock_console"])
		if(allowed(usr))
			unlock_console(usr)
		else
			to_chat(usr, "<span class='boldwarning'>Unauthorized Access.</span>")
	if(ls["back_screen"])
		back = text2num(ls["back_screen"])
	if(ls["category"])
		selected_category = ls["category"]
	if(ls["eject_design"]) //Eject the design disk.
		eject_disk("design")
		screen = RDSCREEN_MENU
		say("Ejecting Design Disk")
	if(ls["eject_tech"]) //Eject the technology disk.
		eject_disk("tech")
		screen = RDSCREEN_MENU
		say("Ejecting Technology Disk")
	if(ls["disk_slot"])
		disk_slot_selected = text2num(ls["disk_slot"])
	if(ls["research_node"])
		if(!research_control)
			return				//honestly should call them out for href exploiting :^)
		if(!SSresearch.science_tech.available_nodes[ls["research_node"]])
			return			//Nope!
		research_node(ls["research_node"], usr)
	if(ls["clear_tech"]) //Erase la on the technology disk.
		if(QDELETED(t_disk))
			say("No Technology Disk Inserted!")
			return
		qdel(t_disk.stored_research)
		t_disk.stored_research = new
		say("Wiping technology disk.")
	if(ls["copy_tech"]) //Copy some technology la from the research holder to the disk.
		if(QDELETED(t_disk))
			say("No Technology Disk Inserted!")
			return
		stored_research.copy_research_to(t_disk.stored_research)
		screen = RDSCREEN_TECHDISK
		say("Downloading to technology disk.")
	if(ls["clear_design"]) //Erases la on the design disk.
		if(QDELETED(d_disk))
			say("No Design Disk Inserted!")
			return
		var/n = text2num(ls["clear_design"])
		if(!n)
			for(var/i in 1 to d_disk.max_blueprints)
				d_disk.blueprints[i] = null
				say("Wiping design disk.")
		else
			var/datum/design/D = d_disk.blueprints[n]
			say("Wiping design [D.name] from design disk.")
			d_disk.blueprints[n] = null
	if(ls["updt_tech"]) //Uple the research holder with information from the technology disk.
		if(QDELETED(t_disk))
			say("No Technology Disk Inserted!")
			return
		say("Uploading technology disk.")
		t_disk.stored_research.copy_research_to(stored_research)
	if(ls["copy_design"]) //Copy design from the research holder to the design disk.
		if(QDELETED(d_disk))
			say("No Design Disk Inserted!")
			return
		var/slot = text2num(ls["copy_design"])
		var/datum/design/D = SSresearch.techweb_design_by_id(ls["copy_design_ID"])
		if(D)
			var/autolathe_friendly = TRUE
			if(D.reagents_list.len)
				autolathe_friendly = FALSE
				D.category -= "Imported"
			else
				for(var/x in D.materials)
					if( !(x in list(/datum/material/iron, /datum/material/glass)))
						autolathe_friendly = FALSE
						D.category -= "Imported"

			if(D.build_type & (AUTOLATHE|PROTOLATHE)) // Specifically excludes circuit imprinter and mechfab
				D.build_type = autolathe_friendly ? (D.build_type | AUTOLATHE) : D.build_type
				D.category |= "Imported"
			d_disk.blueprints[slot] = D
		screen = RDSCREEN_DESIGNDISK
	if(ls["view_node"])
		selected_node_id = ls["view_node"]
		screen = RDSCREEN_TECHWEB_NODEVIEW
	if(ls["view_design"])
		selected_design_id = ls["view_design"]
		screen = RDSCREEN_TECHWEB_DESIGNVIEW
	if(ls["updt_design"]) //Uploads a design from disk to the techweb.
		if(QDELETED(d_disk))
			say("No design disk found.")
			return
		var/n = text2num(ls["updt_design"])
		if(!n)
			for(var/D in d_disk.blueprints)
				if(D)
					stored_research.add_design(D, TRUE)
		else
			stored_research.add_design(d_disk.blueprints[n], TRUE)

	updateUsrDialog()

/obj/machinery/computer/rdconsole/ui_interact(mob/user)
	. = ..()
	var/datum/browser/popup = new(user, "rndconsole", name, 900, 600)
	popup.add_stylesheet("techwebs", 'html/browser/techwebs.css')
	popup.set_content(generate_ui())
	popup.open()

/obj/machinery/computer/rdconsole/proc/tdisk_uple_complete()
	tdisk_uple = FALSE
	updateUsrDialog()

/obj/machinery/computer/rdconsole/proc/ddisk_uple_complete()
	ddisk_uple = FALSE
	updateUsrDialog()

/obj/machinery/computer/rdconsole/proc/eject_disk(type)
	if(type == "design")
		d_disk.forceMove(get_turf(src))
		d_disk = null
	if(type == "tech")
		t_disk.forceMove(get_turf(src))
		t_disk = null

/obj/machinery/computer/rdconsole/proc/lock_console(mob/user)
	locked = TRUE

/obj/machinery/computer/rdconsole/proc/unlock_console(mob/user)
	locked = FALSE
