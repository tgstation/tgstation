#define REV_ENG_HEIGHT	400
#define REV_ENG_WIDTH	1200

#define REV_ENG_RESEARCHBASE 150

/obj/machinery/r_n_d/reverse_engine
	name = "Reverse Engine"
	desc = ""
	icon = 'icons/obj/machines/mechanic.dmi'
	icon_state = "reverse-engine"

	var/list/datum/design/mechanic_design/research_queue = list()//all the designs we are waiting to research
	var/list/datum/design/mechanic_design/ready_queue = list()//all the designs we HAVE researched, and are ready to print
	var/max_queue_len = 0 as num //maximum number of items in the research queue

	var/scan_rating = 1 //the scanner rating
	var/cap_rating = 1 //the capacitor rating

	research_flags = NANOTOUCH

/obj/machinery/r_n_d/reverse_engine/New()
	..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/reverse_engine,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/console_screen
	)

	RefreshParts()

/obj/machinery/r_n_d/reverse_engine/RefreshParts()
	var/i = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/S in component_parts)
		i++
		scan_rating += S.rating //sum
	scan_rating = scan_rating / i //average

	i = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		i++
		cap_rating += C.rating
	cap_rating = cap_rating / i

	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		max_queue_len = 10 * M.rating

/obj/machinery/r_n_d/reverse_engine/attackby(var/obj/O as obj, var/mob/user as mob)
	if(..())
		return 1
	if(busy)
		user <<"<span class='notice'>The [src] is currently busy, please wait until the current operation is finished.</span>"
		return
	if(istype(O, /obj/item/device/device_analyser))
		var/obj/item/device/device_analyser/DA = O
		if(DA.loaded_designs && DA.loaded_designs.len)
			if(DA.loadone)
				var/list/name_list = list()
				for(var/datum/design/mechanic_design/thisdesign in DA.loaded_designs)
					name_list[thisdesign.name] = thisdesign
				var/design_name = input(user, "Select a design to load", "Select Design", "") in name_list
				var/datum/design/mechanic_design/chosen_design = name_list[design_name]
				AddDesign(chosen_design, DA.loaded_designs, user)
				return 1
			else
				var/i = 0
				for(var/datum/design/mechanic_design/loop_design in DA.loaded_designs)
					if(!AddDesign(loop_design, DA.loaded_designs, user))
						break
					i++
				user << "Sucessfully transferred [i] design\s."
				return 1
		return
	if(istype(O, /obj/item/device/pda))
		var/obj/item/device/pda/PDA = O
		if(PDA.dev_analys)
			var/obj/item/device/device_analyser/DA = PDA.dev_analys
			for(var/datum/design/mechanic_design/loop_design in DA.loaded_designs)
				AddDesign(loop_design, DA.loaded_designs, user)
			return 1
		return 0

//Loads a design from a list onto the machine to be researched
//Pretty simple, just checks if the design is already present and then adds it and removes it from the parent list
/obj/machinery/r_n_d/reverse_engine/proc/AddDesign(var/datum/design/mechanic_design/design, var/list/design_list, var/mob/user)
	if(!istype(design))
		design_list -= design //lets just brush that under the rug
		return
	for(var/datum/design/mechanic_design/MD in research_queue)
		if(MD.build_path == design.build_path)
			design_list -= design
			user <<"<span class='notice'>The [design.name] is already loaded onto \the [src]!</span>"
			return
	for(var/datum/design/mechanic_design/MD in ready_queue)
		if(MD.build_path == design.build_path)
			design_list -= design
			user <<"<span class='notice'>The [design.name] has already been researched by \the [src]!</span>"
			return
	if(research_queue.len >= max_queue_len)
		user <<"<span class='notice'>The [src]'s research queue is full. Research some designs first before adding more.</span>"
		return
	if(design in design_list) //let's make sure, here
		research_queue += design
		design_list -= design
		user <<"<span class='notice'>The [design.name] was successfully loaded onto the [src].</span>"
		return 1
	return

//proc used to determine how quickly a design is researched.
//given a design, it checks to see the difference between the tech levels of the design and of the rd console it is linked to.
//returns the number of levels difference between the design and the console, if any at all ( no negatives )
/obj/machinery/r_n_d/reverse_engine/proc/Tech_Difference(var/datum/design/mechanic_design/design)
	var/list/techlist = design.req_tech
	var/techdifference = 0
	if(techlist.len && linked_console)
		//message_admins("We have a techlist and a linked_console")
		var/obj/machinery/computer/rdconsole/console = src.linked_console
		var/list/possible_tech = console.files.possible_tech
		for(var/checktech in techlist)
			//message_admins("Looking at [checktech] with value of [techlist[checktech]]")
			for(var/datum/tech/pointed_tech in possible_tech) //if we find that technology
				if(pointed_tech.id == checktech)
					if(techlist[checktech] > pointed_tech.level) //if the machine board's research level is higher than the one on the console
						//message_admins("Found a difference of [techlist[checktech] - pointed_tech.level]")
						techdifference += techlist[checktech] - pointed_tech.level //then add this to the tech difference
	else if(techlist.len)
		//message_admins("We only have a techlist")
		for(var/checktech in techlist) //we have no console, so this is the worst case scenario
			techdifference += techlist[checktech] - 1 //maximum time possible
	//message_admins("Techdifference before adjust is [techdifference]")
	if(techdifference < 0) //I'm not sure how this could happen, but just for sanity
		techdifference = 0
	return techdifference

/obj/machinery/r_n_d/reverse_engine/proc/researchQueue()
	while(research_queue[1])
		if(stat&(NOPOWER|BROKEN))
			return 0
		var/datum/design/mechanic_design/current_design = research_queue[1]
		if(!researchDesign(current_design))
			break
		if(!research_queue.len)
			break
		else
			current_design = research_queue[1]
	if(!research_queue.len)
		src.visible_message("<span class='notice'>\icon [src] \The [src] beeps: 'Successfully researched all designs.'</span>")

/obj/machinery/r_n_d/reverse_engine/proc/researchDesign(var/datum/design/mechanic_design/design)
	//message_admins("This researchDesign got called with the [design.design_name].")
	if(busy)
		return
	if(!istype(design) || !(design in research_queue)) //sanity checking, always good
		return
	if(design in ready_queue)
		src.visible_message("<span class='notice'>\icon [src] \The [src] beeps:'The [design.name] is already researched.'</span>")
		research_queue -= design
		return
	var/researchtime = ( (REV_ENG_RESEARCHBASE * Tech_Difference(design)) / (scan_rating + cap_rating) )
	busy = 1
	overlays += "[base_state]_ani"
	sleep(researchtime) //we use sleep instead of spawn because code like the queue code has to hang on this proc
	research_queue -= design
	busy = 0
	overlays -= "[base_state]_ani"
	if(!(design in ready_queue))
		ready_queue += design
		src.visible_message("<span class='notice'>\icon [src] \The [src] beeps: 'Successfully researched \the [design.name].'</span>")
		return 1
	return

//finds a printer connected to the console, and use it to print our design
/obj/machinery/r_n_d/reverse_engine/proc/PrintDesign(var/datum/design/mechanic_design/design, var/use_nano = 0)
	if(linked_console)
		//message_admins("Looking for machines...")
		for(var/obj/machinery/r_n_d/M in linked_console.linked_machines)
			if(istype(M, /obj/machinery/r_n_d/blueprinter))
				var/obj/machinery/r_n_d/blueprinter/BP = M
				//message_admins("Found the blueprinter!")
				BP.PrintDesign(design, use_nano)
				return 1
	else
		src.visible_message("You need to link this machine to a research console first!")


/obj/machinery/r_n_d/reverse_engine/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(src.stat & (BROKEN|NOPOWER))
		return
	if((user.stat && !isobserver(user)) || user.restrained() || !allowed(user))
		return

	var/data[0]
	var/list/todo_queue = list()
	var/list/done_queue = list()

	for(var/i=1;i<=research_queue.len;i++)
		var/datum/design/mechanic_design/research_item = research_queue[i]
		todo_queue.Add(list(list("name" = research_item.name, "command1" = list("research" = i), "command2" = list("remove_tosearch" = i))))

	for(var/i=1;i<=ready_queue.len;i++)
		var/datum/design/mechanic_design/ready_item = ready_queue[i]
		done_queue.Add(list(list("name" = ready_item.name, "command1" = list("print_design" = i), "command2" = list("nanoprint_design" = i), "command3" = list("remove_researched" = i))))

	data["research_queue"] = todo_queue
	data["ready_queue"] = done_queue

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "rev-engine.tmpl", name, REV_ENG_WIDTH, REV_ENG_HEIGHT)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/r_n_d/reverse_engine/Topic(href, href_list)

	if(..())
		return

	if(href_list["remove_tosearch"])
		var/datum/design/mechanic_design/design = research_queue[text2num(href_list["remove_tosearch"])]
		if(design)
			research_queue -= design
			del(design)
		ui_interact(usr)
		return 1

	if(href_list["remove_researched"])
		var/datum/design/mechanic_design/design = ready_queue[text2num(href_list["remove_researched"])]
		if(design)
			ready_queue -= design
			del(design)
		ui_interact(usr)
		return 1

	if(href_list["research"])
		var/datum/design/mechanic_design/design = research_queue[text2num(href_list["research"])]
		if(design)
			researchDesign(design)
		ui_interact(usr)
		return 1

	if(href_list["research_all"])
		researchQueue()
		ui_interact(usr)
		return 1

	if(href_list["print_design"])
		var/datum/design/mechanic_design/design = ready_queue[text2num(href_list["print_design"])]
		if(design)
			PrintDesign(design, 0)
		return 1

	if(href_list["nanoprint_design"])
		var/datum/design/mechanic_design/design = ready_queue[text2num(href_list["nanoprint_design"])]
		if(design)
			PrintDesign(design, 1)
		return 1