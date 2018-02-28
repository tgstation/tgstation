/obj/machinery/rnd/protolathe/department
	name = "department protolathe"
	desc = "A special protolathe with a built in interface meant for departmental usage, with built in ExoSync recievers allowing it to print designs researched that match its ROM-encoded department type. Features a bluespace materials reciever for recieving materials without the hassle of running to mining!"
	icon_state = "protolathe"
	container_type = OPENCONTAINER
	circuit = /obj/item/circuitboard/machine/protolathe/department
	requires_console = FALSE

	var/list/datum/design/cached_designs
	var/list/datum/design/matching_designs
	var/department_tag = "Unidentified"			//used for material distribution among other things.
	var/datum/techweb/stored_research
	var/datum/techweb/host_research
	var/screen = DEPLATHE_SCREEN_PRIMARY

/obj/machinery/rnd/protolathe/department/engineering
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_ENGINEERING
	department_tag = "Engineering"
	circuit = /obj/item/circuitboard/machine/protolathe/department/engineering

/obj/machinery/rnd/protolathe/department/service
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SERVICE
	department_tag = "Service"
	circuit = /obj/item/circuitboard/machine/protolathe/department/service

/obj/machinery/rnd/protolathe/department/medical
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_MEDICAL
	department_tag = "Medical"
	circuit = /obj/item/circuitboard/machine/protolathe/department/medical

/obj/machinery/rnd/protolathe/department/cargo
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_CARGO
	department_tag = "Cargo"
	circuit = /obj/item/circuitboard/machine/protolathe/department/cargo

/obj/machinery/rnd/protolathe/department/science
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SCIENCE
	department_tag = "Science"
	circuit = /obj/item/circuitboard/machine/protolathe/department/science

/obj/machinery/rnd/protolathe/department/security
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SECURITY
	department_tag = "Security"
	circuit = /obj/item/circuitboard/machine/protolathe/department/security

/obj/machinery/rnd/protolathe/department/Initialize()
	. = ..()
	matching_designs = list()
	cached_designs = list()
	stored_research = new
	host_research = SSresearch.science_tech
	update_research()

/obj/machinery/rnd/protolathe/department/Destroy()
	QDEL_NULL(stored_research)
	return ..()

/obj/machinery/rnd/protolathe/department/user_try_print_id(id, amount)
	var/datum/design/D = get_techweb_design_by_id(id)
	if(!D || !(D.departmental_flags & allowed_department_flags))
		say("Warning: Printing failed. Please update the research data with the on-screen button!")
		return FALSE
	. = ..()

/obj/machinery/rnd/protolathe/department/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/rnd/protolathe/department/interact(mob/user)
	user.set_machine(src)
	var/datum/browser/popup = new(user, "rndconsole", name, 460, 550)
	popup.set_content(generate_ui())
	popup.open()

/obj/machinery/rnd/protolathe/department/proc/search(string)
	matching_designs.Cut()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if(!(D.build_type & PROTOLATHE) || !(D.departmental_flags & allowed_department_flags))
			continue
		if(findtext(D.name,string))
			matching_designs.Add(D)

/obj/machinery/rnd/protolathe/department/proc/update_research()
	host_research.copy_research_to(stored_research, TRUE)
	update_designs()

/obj/machinery/rnd/protolathe/department/proc/update_designs()
	cached_designs.Cut()
	for(var/i in stored_research.researched_designs)
		var/datum/design/d = stored_research.researched_designs[i]
		if((d.departmental_flags & allowed_department_flags) && (d.build_type & PROTOLATHE))
			cached_designs |= d

/obj/machinery/rnd/protolathe/department/proc/generate_ui()
	var/list/ui = list()
	ui += ui_header()
	switch(screen)
		if(DEPLATHE_SCREEN_MATERIALS)
			ui += ui_materials()
		if(DEPLATHE_SCREEN_CHEMICALS)
			ui += ui_chemicals()
		if(DEPLATHE_SCREEN_SEARCH)
			ui += ui_search()
		else
			ui += ui_department_lathe()
	for(var/i in 1 to length(ui))
		if(!findtextEx(ui[i], RDSCREEN_NOBREAK))
			ui[i] += "<br>"
		ui[i] = replacetextEx(ui[i], RDSCREEN_NOBREAK, "")
	return ui.Join("")

/obj/machinery/rnd/protolathe/department/proc/ui_search()		//Legacy code
	var/list/l = list()
	var/coeff = efficiency_coeff
	l += "<h2>Search Results:</h2>"
	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"
	for(var/datum/design/D in matching_designs)
		var/temp_material
		var/c = 50
		var/t
		var/all_materials = D.materials + D.reagents_list
		for(var/M in all_materials)
			t = check_mat(D, M)
			temp_material += " | "
			if (t < 1)
				temp_material += "<span class='bad'>[all_materials[M]*coeff] [CallMaterialName(M)]</span>"
			else
				temp_material += " [all_materials[M]*coeff] [CallMaterialName(M)]"
			c = min(c,t)

		if (c >= 1)
			l += "<A href='?src=[REF(src)];build=[D.id];amount=1'>[D.name]</A>[RDSCREEN_NOBREAK]"
			if(c >= 5)
				l += "<A href='?src=[REF(src)];build=[D.id];amount=5'>x5</A>[RDSCREEN_NOBREAK]"
			if(c >= 10)
				l += "<A href='?src=[REF(src)];build=[D.id];amount=10'>x10</A>[RDSCREEN_NOBREAK]"
			l += "[temp_material][RDSCREEN_NOBREAK]"
		else
			l += "<span class='linkOff'>[D.name]</span>[temp_material][RDSCREEN_NOBREAK]"
		l += ""
	l += "</div>"
	return l

/obj/machinery/rnd/protolathe/department/proc/ui_department_lathe()
	var/list/l = list()
	var/coeff = efficiency_coeff
	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"
	for(var/datum/design/D in cached_designs)
		var/temp_material
		var/c = 50
		var/t
		var/all_materials = D.materials + D.reagents_list
		for(var/M in all_materials)
			t = check_mat(D, M)
			temp_material += " | "
			if (t < 1)
				temp_material += "<span class='bad'>[all_materials[M]*coeff] [CallMaterialName(M)]</span>"
			else
				temp_material += " [all_materials[M]*coeff] [CallMaterialName(M)]"
			c = min(c,t)

		if (c >= 1)
			l += "<A href='?src=[REF(src)];build=[D.id];amount=1'>[D.name]</A>[RDSCREEN_NOBREAK]"
			if(c >= 5)
				l += "<A href='?src=[REF(src)];build=[D.id];amount=5'>x5</A>[RDSCREEN_NOBREAK]"
			if(c >= 10)
				l += "<A href='?src=[REF(src)];build=[D.id];amount=10'>x10</A>[RDSCREEN_NOBREAK]"
			l += "[temp_material][RDSCREEN_NOBREAK]"
		else
			l += "<span class='linkOff'>[D.name]</span>[temp_material][RDSCREEN_NOBREAK]"
		l += ""
	l += "</div>"
	return l

/obj/machinery/rnd/protolathe/department/proc/ui_header()
	var/list/l = list()
	l += "<div class='statusDisplay'><b>[host_research.organization] [department_tag] Department Lathe</b>"
	l += "Security protocols: [(obj_flags & EMAGGED) ? "<font color='red'>Disabled</font>" : "<font color='green'>Enabled</font>"]"
	l += "<A href='?src=[REF(src)];switch_screen=[DEPLATHE_SCREEN_MATERIALS]'><B>Material Amount:</B> [materials.total_amount] / [materials.max_amount]</A>"
	l += "<A href='?src=[REF(src)];switch_screen=[DEPLATHE_SCREEN_CHEMICALS]'><B>Chemical volume:</B> [reagents.total_volume] / [reagents.maximum_volume]</A>"
	l += "<a href='?src=[REF(src)];sync_research=1'>Synchronize Research</a>"
	l += "<a href='?src=[REF(src)];switch_screen=[DEPLATHE_SCREEN_PRIMARY]'>Main Screen</a></div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/rnd/protolathe/department/proc/ui_materials()
	var/list/l = list()
	l += "<div class='statusDisplay'><h3>Material Storage:</h3>"
	for(var/mat_id in materials.materials)
		var/datum/material/M = materials.materials[mat_id]
		l += "* [M.amount] of [M.name]: "
		if(M.amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];ejectsheet=[M.id];eject_amt=1'>Eject</A> [RDSCREEN_NOBREAK]"
		if(M.amount >= MINERAL_MATERIAL_AMOUNT*5) l += "<A href='?src=[REF(src)];ejectsheet=[M.id];eject_amt=5'>5x</A> [RDSCREEN_NOBREAK]"
		if(M.amount >= MINERAL_MATERIAL_AMOUNT) l += "<A href='?src=[REF(src)];ejectsheet=[M.id];eject_amt=50'>All</A>[RDSCREEN_NOBREAK]"
		l += ""
	l += "</div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/rnd/protolathe/department/proc/ui_chemicals()
	var/list/l = list()
	l += "<div class='statusDisplay'><A href='?src=[REF(src)];disposeall=1'>Disposal All Chemicals in Storage</A>"
	l += "<h3>Chemical Storage:</h3>"
	for(var/datum/reagent/R in reagents.reagent_list)
		l += "[R.name]: [R.volume]"
		l += "<A href='?src=[REF(src)];dispose=[R.id]'>Purge</A>"
	l += "</div>"
	return l

/obj/machinery/rnd/protolathe/department/Topic(raw, ls)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)
	if(ls["switch_screen"])
		screen = text2num(ls["switch_screen"])
	if(ls["build"]) //Causes the Protolathe to build something.
		if(busy)
			say("Warning: Fabricators busy!")
		else
			user_try_print_id(ls["build"], ls["amount"])
	if(ls["search"]) //Search for designs with name matching pattern
		search(ls["to_search"])
		screen = DEPLATHE_SCREEN_SEARCH
	if(ls["sync_research"])
		update_research()
		say("Synchronizing research with host technology database.")
	if(ls["dispose"])  //Causes the protolathe to dispose of a single reagent (all of it)
		reagents.del_reagent(ls["dispose"])
	if(ls["disposeall"]) //Causes the protolathe to dispose of all it's reagents.
		reagents.clear_reagents()
	if(ls["ejectsheet"]) //Causes the protolathe to eject a sheet of material
		materials.retrieve_sheets(text2num(ls["eject_amt"]), ls["ejectsheet"])
	updateUsrDialog()
