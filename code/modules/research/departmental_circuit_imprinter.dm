/obj/machinery/rnd/circuit_imprinter/department
	name = "Department Circuit Imprinter"
	desc = "A special circuit imprinter with a built in interface meant for departmental usage, with built in ExoSync recievers allowing it to print designs researched that match its ROM-encoded department type. Features a bluespace materials reciever for recieving materials without the hassle of running to mining!"
	icon_state = "circuit_imprinter"
	container_type = OPENCONTAINER
	circuit = /obj/item/circuitboard/machine/circuit_imprinter/department
	requires_console = FALSE

	var/list/datum/design/cached_designs
	var/list/datum/design/matching_designs
	var/department_tag = "Unidentified"			//used for material distribution among other things.
	var/datum/techweb/stored_research
	var/datum/techweb/host_research
	var/screen = DEPPRINTER_SCREEN_PRIMARY

/obj/machinery/rnd/circuit_imprinter/department/science
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SCIENCE
	department_tag = "Science"

/obj/machinery/rnd/circuit_imprinter/department/Initialize()
	. = ..()
	stored_research = new
	cached_designs = list()
	host_research = SSresearch.science_tech
	matching_designs = list()
	update_research()

/obj/machinery/rnd/circuit_imprinter/department/Destroy()
	QDEL_NULL(stored_research)
	return ..()

/obj/machinery/rnd/circuit_imprinter/department/user_try_print_id(id, amount)
	var/datum/design/D = get_techweb_design_by_id(id)
	if(!D || !(D.departmental_flags & allowed_department_flags))
		say("Warning: Printing failed. Please update the research data with the on-screen button!")
		return FALSE
	. = ..()

/obj/machinery/rnd/circuit_imprinter/department/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/rnd/circuit_imprinter/department/interact(mob/user)
	user.set_machine(src)

	var/datum/browser/popup = new(user, "rndconsole", name, 460, 550)
	popup.set_content(generate_ui())
	popup.open()

/obj/machinery/rnd/circuit_imprinter/department/proc/search(string)
	matching_designs.Cut()
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = stored_research.researched_designs[v]
		if(!(D.build_type & IMPRINTER) || !(D.departmental_flags & allowed_department_flags))
			continue
		if(findtext(D.name,string))
			matching_designs.Add(D)

/obj/machinery/rnd/circuit_imprinter/department/proc/update_research()
	host_research.copy_research_to(stored_research, TRUE)
	update_designs()

/obj/machinery/rnd/circuit_imprinter/department/proc/update_designs()
	cached_designs.Cut()
	for(var/i in stored_research.researched_designs)
		var/datum/design/d = stored_research.researched_designs[i]
		if((d.departmental_flags & allowed_department_flags) && (d.build_type & IMPRINTER))
			cached_designs |= d

/obj/machinery/rnd/circuit_imprinter/department/proc/generate_ui()
	var/list/ui = list()
	ui += ui_header()
	switch(screen)
		if(DEPPRINTER_SCREEN_MATERIALS)
			ui += ui_materials()
		if(DEPPRINTER_SCREEN_CHEMICALS)
			ui += ui_chemicals()
		if(DEPPRINTER_SCREEN_SEARCH)
			ui += ui_search()
		else
			ui += ui_department_imprinter()
	for(var/i in 1 to length(ui))
		if(!findtextEx(ui[i], RDSCREEN_NOBREAK))
			ui[i] += "<br>"
		ui[i] = replacetextEx(ui[i], RDSCREEN_NOBREAK, "")
	return ui.Join("")

/obj/machinery/rnd/circuit_imprinter/department/proc/ui_search()		//Legacy code
	var/list/l = list()
	l += "<h2>Search Results:</h2>"
	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"
	var/coeff = efficiency_coeff
	for(var/datum/design/D in matching_designs)
		var/temp_materials
		var/check_materials = TRUE
		var/all_materials = D.materials + D.reagents_list
		for(var/M in all_materials)
			temp_materials += " | "
			if (!check_mat(D, M))
				check_materials = FALSE
				temp_materials += " <span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
			else
				temp_materials += " [all_materials[M]/coeff] [CallMaterialName(M)]"
		if (check_materials)
			l += "<A href='?src=[REF(src)];imprint=[D.id]'>[D.name]</A>[temp_materials]"
		else
			l += "<span class='linkOff'>[D.name]</span>[temp_materials]"
	l += "</div>"
	return l

/obj/machinery/rnd/circuit_imprinter/department/proc/ui_department_imprinter()
	var/list/l = list()
	var/coeff = efficiency_coeff
	l += "<form name='search' action='?src=[REF(src)]'>\
	<input type='hidden' name='src' value='[REF(src)]'>\
	<input type='hidden' name='search' value='to_search'>\
	<input type='text' name='to_search'>\
	<input type='submit' value='Search'>\
	</form><HR>"
	for(var/datum/design/D in cached_designs)
		var/temp_materials
		var/check_materials = TRUE
		var/all_materials = D.materials + D.reagents_list
		for(var/M in all_materials)
			temp_materials += " | "
			if (!check_mat(D, M))
				check_materials = FALSE
				temp_materials += " <span class='bad'>[all_materials[M]/coeff] [CallMaterialName(M)]</span>"
			else
				temp_materials += " [all_materials[M]/coeff] [CallMaterialName(M)]"
		if (check_materials)
			l += "<A href='?src=[REF(src)];imprint=[D.id]'>[D.name]</A>[temp_materials]"
		else
			l += "<span class='linkOff'>[D.name]</span>[temp_materials]"
	l += "</div>"
	return l

/obj/machinery/rnd/circuit_imprinter/department/proc/ui_header()
	var/list/l = list()
	l += "<div class='statusDisplay'><b>[host_research.organization] [department_tag] Department Circuit Imprinter</b>"
	l += "Security protocols: [(obj_flags & EMAGGED) ? "<font color='red'>Disabled</font>" : "<font color='green'>Enabled</font>"]"
	l += "<A href='?src=[REF(src)];switch_screen=[DEPPRINTER_SCREEN_MATERIALS]'><B>Material Amount:</B> [materials.total_amount] / [materials.max_amount]</A>"
	l += "<A href='?src=[REF(src)];switch_screen=[DEPPRINTER_SCREEN_CHEMICALS]'><B>Chemical volume:</B> [reagents.total_volume] / [reagents.maximum_volume]</A>"
	l += "<a href='?src=[REF(src)];sync_research=1'>Synchronize Research</a>"
	l += "<a href='?src=[REF(src)];switch_screen=[DEPPRINTER_SCREEN_PRIMARY]'>Main Screen</a></div>[RDSCREEN_NOBREAK]"
	return l

/obj/machinery/rnd/circuit_imprinter/department/proc/ui_materials()
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

/obj/machinery/rnd/circuit_imprinter/department/proc/ui_chemicals()
	var/list/l = list()
	l += "<div class='statusDisplay'><A href='?src=[REF(src)];disposeall=1'>Disposal All Chemicals in Storage</A>"
	l += "<h3>Chemical Storage:</h3>"
	for(var/datum/reagent/R in reagents.reagent_list)
		l += "[R.name]: [R.volume]"
		l += "<A href='?src=[REF(src)];dispose=[R.id]'>Purge</A>"
	l += "</div>"
	return l

/obj/machinery/rnd/circuit_imprinter/department/Topic(raw, ls)
	if(..())
		return
	add_fingerprint(usr)
	usr.set_machine(src)
	if(ls["switch_screen"])
		screen = text2num(ls["switch_screen"])
	if(ls["imprint"]) //Causes the circuit_imprinter to build something.
		if(busy)
			say("Warning: Fabricators busy!")
		else
			user_try_print_id(ls["imprint"])
	if(ls["search"]) //Search for designs with name matching pattern
		search(ls["to_search"])
		screen = DEPPRINTER_SCREEN_SEARCH
	if(ls["sync_research"])
		update_research()
		say("Synchronizing research with host technology database.")
	if(ls["dispose"])  //Causes the protolathe to dispose of a single reagent (all of it)
		reagents.del_reagent(ls["dispose"])
	if(ls["disposeall"]) //Causes the protolathe to dispose of all it's reagents.
		reagents.clear_reagents()
	if(ls["ejectsheet"]) //Causes the protolathe to eject a sheet of material
		materials.retrieve_sheets(text2num(ls["eject_amt"]), ls["ejectsheet"])
