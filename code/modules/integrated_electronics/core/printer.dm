/obj/item/device/integrated_circuit_printer
	name = "integrated circuit printer"
	desc = "A portable(ish) machine made to print tiny modular circuitry out of metal."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "circuit_printer"
	w_class = WEIGHT_CLASS_BULKY
	var/metal = 0
	var/init_max_metal = 100
	var/max_metal = 100
	var/metal_per_sheet = 10 // One sheet equals this much metal.
	var/debug = FALSE
	var/upgraded = FALSE		// When hit with an upgrade disk, will turn true, allowing it to print the higher tier circuits.
	var/can_clone = FALSE		// Same for above, but will allow the printer to duplicate a specific assembly.
	var/static/list/recipe_list	//category = list(paths in category)
	var/current_category = null
	var/as_printing = FALSE
	var/as_needs = 0
	var/program ="blank"
	var/obj/item/device/integrated_electronics/prefab/PR = null

/obj/item/device/integrated_circuit_printer/proc/check_interactivity(mob/user)
	return user.canUseTopic(src,be_close = TRUE)

/obj/item/device/integrated_circuit_printer/upgraded
	upgraded = TRUE
	can_clone = TRUE

/obj/item/device/integrated_circuit_printer/Initialize()
	. = ..()
	if(!recipe_list)
		recipe_list = SScircuit.circuit_fabricator_recipe_list

/obj/item/device/integrated_circuit_printer/attackby(var/obj/item/O, var/mob/user)
	if(istype(O,/obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/stack = O
		var/num = min((max_metal - metal) / metal_per_sheet, stack.amount)
		if(num < 1)
			to_chat(user, "<span class='warning'>\The [src] is too full to add more metal.</span>")
			return
		if(stack.use(num))
			to_chat(user, "<span class='notice'>You add [num] sheet\s to \the [src].</span>")
			metal += num * metal_per_sheet
			if(as_printing)
				if(as_needs <= metal)
					PR = new/obj/item/device/integrated_electronics/prefab(get_turf(loc))
					PR.program = program
					metal = metal - as_needs
					to_chat(user, "<span class='notice'>Assembly has been printed.</span>")
					as_printing = FALSE
					as_needs = 0
					max_metal = init_max_metal
				else
					to_chat(user, "<span class='notice'>Please insert [(as_needs-metal)/10] more metal!</span>")
			interact(user)
			return TRUE

	if(istype(O,/obj/item/integrated_circuit))
		to_chat(user, "<span class='notice'>You insert the circuit into \the [src]. </span>")
		user.temporarilyRemoveItemFromInventory(O)
		metal = min(metal + O.w_class, max_metal)
		qdel(O)
		interact(user)
		return TRUE

	if(istype(O,/obj/item/disk/integrated_circuit/upgrade/advanced))
		if(upgraded)
			to_chat(user, "<span class='warning'>\The [src] already has this upgrade. </span>")
			return TRUE
		to_chat(user, "<span class='notice'>You install \the [O] into  \the [src]. </span>")
		upgraded = TRUE
		interact(user)
		return TRUE

	if(istype(O,/obj/item/disk/integrated_circuit/upgrade/clone))
		if(can_clone)
			to_chat(user, "<span class='warning'>\The [src] already has this upgrade. </span>")
			return TRUE
		to_chat(user, "<span class='notice'>You install \the [O] into  \the [src]. </span>")
		can_clone = TRUE
		interact(user)
		return TRUE

	return ..()

/obj/item/device/integrated_circuit_printer/attack_self(var/mob/user)
	interact(user)

/obj/item/device/integrated_circuit_printer/interact(mob/user)
	var/window_height = 600
	var/window_width = 500

	if(isnull(current_category))
		current_category = recipe_list[1]

	var/HTML = "<center><h2>Integrated Circuit Printer</h2></center><br>"
	HTML += "Metal: [metal/metal_per_sheet]/[max_metal/metal_per_sheet] sheets.<br>"
	HTML += "Circuits available: [upgraded ? "Advanced":"Regular"]."
	HTML += "Assembly Cloning: [can_clone ? "Available": "Unavailable"]."
	HTML += "Crossed out circuits mean that the printer is not sufficiently upgraded to create that circuit.<br>"
	HTML += "<hr>"
	if(can_clone)
		HTML += "Here you can load script for your assembly.<br>"
		if(as_printing)
			HTML += " {Load Program} "
		else
			HTML += " <A href='?src=[REF(src)];print=load'>{Load Program}</a> "
		if(program == "blank")
			HTML += " {Check Program} "
		else
			HTML += " <A href='?src=[REF(src)];print=check'>{Check Program}</a> "
		if((program == "blank")|as_printing)
			HTML += " {Print assembly} "
		else
			HTML += " <A href='?src=[REF(src)];print=print'>{Print assembly}</a> "
		if(as_printing)
			HTML += "<br> printing in process. Please insert more metal. "
		HTML += "<br><hr>"
	HTML += "Categories:"
	for(var/category in recipe_list)
		if(category != current_category)
			HTML += " <a href='?src=[REF(src)];category=[category]'>\[[category]\]</a> "
		else // Bold the button if it's already selected.
			HTML += " <b>\[[category]\]</b> "
	HTML += "<hr>"
	HTML += "<center><h4>[current_category]</h4></center>"

	var/list/current_list = recipe_list[current_category]
	for(var/k in 1 to current_list.len)
		var/obj/O = current_list[k]
		var/can_build = TRUE
		if(istype(O, /obj/item/integrated_circuit))
			var/obj/item/integrated_circuit/IC = current_list[k]
			if((initial(IC.spawn_flags) & IC_SPAWN_RESEARCH) && (!(initial(IC.spawn_flags) & IC_SPAWN_DEFAULT)) && !upgraded)
				can_build = FALSE
		if(can_build)
			HTML += "<A href='?src=[REF(src)];build=[current_list[k]]'>\[[initial(O.name)]\]</A>: [initial(O.desc)]<br>"
		else
			HTML += "<s>\[[initial(O.name)]\]: [initial(O.desc)]</s><br>"

	user << browse(jointext(HTML, null), "window=integrated_printer;size=[window_width]x[window_height];border=1;can_resize=1;can_close=1;can_minimize=1")

/obj/item/device/integrated_circuit_printer/Topic(href, href_list)
	if(!check_interactivity(usr))
		return
	if(..())
		return TRUE
	var/sc = 0
	add_fingerprint(usr)

	if(href_list["category"])
		current_category = href_list["category"]

	if(href_list["build"])
		var/build_type = text2path(href_list["build"])
		if(!build_type || !ispath(build_type))
			return TRUE

		var/cost = 1
		if(ispath(build_type, /obj/item/device/electronic_assembly))
			var/obj/item/device/electronic_assembly/E = build_type
			cost = round( (initial(E.max_complexity) + initial(E.max_components) ) / 4)
		else if(ispath(build_type, /obj/item/integrated_circuit))
			var/obj/item/integrated_circuit/IC = build_type
			cost = initial(IC.w_class)

		if(metal - cost < 0)
			to_chat(usr, "<span class='warning'>You need [cost] metal to build that!.</span>")
			return TRUE
		metal -= cost
		new build_type(get_turf(loc))

	if(href_list["print"])
		if(!CONFIG_GET(flag/ic_printing))
			to_chat(usr, "<span class='warning'>CentCom has disabled printing of custom circuitry due to recent allegations of copyright infringement.</span>")
			return
		switch(href_list["print"])
			if("load")
				program = input("Put your code there:", "loading", null, null)
			if("check")
				sc = sanity_check(program,usr)
				if(sc == 0)
					to_chat(usr,  "<span class='warning'>Invalid program.</span>")
				else if(sc == -1)
					to_chat(usr,  "<span class='warning'>Unknown circuits found. Upgrades required to process this design.</span>")
				else if(sc == null)
					to_chat(usr,  "<span class='warning'>Invalid program.</span>")
				else
					to_chat(usr,  "<span class='notice'>Program is correct.You'll need [sc/10] sheets of metal</span>")
			if("print")
				sc = sanity_check(program,usr)
				if(sc == 0 || sc == null)
					to_chat(usr,  "<span class='warning'>Invalid program.</span>")
				else if(sc == -1)
					to_chat(usr,  "<span class='warning'>Unknown circuits found. Upgrades required to process this design.</span>")
				else
					as_printing = TRUE
					if(sc <= metal)
						PR = new/obj/item/device/integrated_electronics/prefab(get_turf(loc))
						PR.program = program
						metal = metal - sc
						to_chat(usr,  "<span class='notice'>Assembly has been printed.</span>")
						as_printing = FALSE
						as_needs = 0
						max_metal=init_max_metal
					else
						max_metal = sc + metal_per_sheet
						as_needs = sc
						to_chat(usr,  "<span class='notice'>Please insert [(as_needs-metal)/10] more metal!</span>")
	interact(usr)

// FUKKEN UPGRADE DISKS
/obj/item/disk/integrated_circuit/upgrade
	name = "integrated circuit printer upgrade disk"
	desc = "Install this into your integrated circuit printer to enhance it."
	icon = 'icons/obj/electronic_assemblies.dmi'
	icon_state = "upgrade_disk"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 4)

/obj/item/disk/integrated_circuit/upgrade/advanced
	name = "integrated circuit printer upgrade disk - advanced designs"
	desc = "Install this into your integrated circuit printer to enhance it.  This one adds new, advanced designs to the printer."

// To be implemented later.
/obj/item/disk/integrated_circuit/upgrade/clone
	name = "integrated circuit printer upgrade disk - circuit cloner"
	desc = "Install this into your integrated circuit printer to enhance it.  This one allows the printer to duplicate assemblies."
	icon_state = "upgrade_disk_clone"
	origin_tech = list(TECH_ENGINEERING = 4, TECH_DATA = 5)

/obj/item/device/integrated_circuit_printer/proc/sanity_check(var/program,var/mob/user)
	var/list/chap = splittext( program ,"{{*}}")
	if(chap.len != 6)
		return 0 //splitting incorrect
	var/list/elements = list()
	var/list/elements_input = list()
	var/list/element = list()
	var/obj/item/PA
	var/obj/item/device/electronic_assembly/PF
	var/datum/integrated_io/IO
	var/datum/integrated_io/IO2
	var/i = 0
	var/obj/item/integrated_circuit/comp
	var/list/ioa = list()
	var/list/as_samp = list()
	var/list/all_circuits = SScircuit.all_circuits // It's free. Performance. We're giving you cpu time. It's free. We're giving you time. It's performance, free. It's free cpu time for you jim!
	var/list/assembly_list = list(
			/obj/item/device/electronic_assembly,
			/obj/item/device/electronic_assembly/medium,
			/obj/item/device/electronic_assembly/large,
			/obj/item/device/electronic_assembly/drone,
		)
	var/compl = 0
	var/maxcomp = 0
	var/cap = 0
	var/maxcap = 0
	var/metalcost = 0
	for(var/k in 1 to assembly_list.len)
		var/obj/item/I = assembly_list[k]
		as_samp[initial(I.name)] = I
	if(debug)
		visible_message( "<span class='notice'>started successful</span>")
	if(chap[2] != "")
		if(debug)
			visible_message( "<span class='notice'>assembly</span>")
		element = splittext( chap[2] ,"=-=")
		PA = as_samp[element[1]]
		if(ispath(PA,/obj/item/device/electronic_assembly))
			PF = PA
			maxcap = initial(PF.max_components)
			maxcomp = initial(PF.max_complexity)
			metalcost = metalcost + round( (initial(PF.max_complexity) + initial(PF.max_components) ) / 4)
			if(debug)
				visible_message( "<span class='notice'>maxcap[maxcap]maxcomp[maxcomp]</span>")
		else
			return 0
		to_chat(usr, "<span class='notice'>This is program for [element[2]]</span>")

	else
		return 0 //what's the point if there is no assembly?
	if(chap[3] != "components")   //if there is only one word,there is no components.
		elements_input = splittext( chap[3] ,"^%^")
		if(debug)
			visible_message( "<span class='notice'>components[elements_input.len]</span>")
		i = 0
		elements = list()
		for(var/elem in elements_input)
			i=i+1
			if(i>1)
				elements.Add(elem)
		if(debug)
			visible_message( "<span class='notice'>components[elements.len]</span>")
		if(elements_input.len<1)
			return 0
		if(debug)
			visible_message( "<span class='notice'>inserting components[elements.len]</span>")
		i=0
		for(var/E in elements)
			i=i+1
			element = splittext( E ,"=-=")
			if(debug)
				visible_message( "<span class='notice'>[E]</span>")
			comp = all_circuits[element[1]]
			if(!comp)
				break
			if(!upgraded)
				var/obj/item/integrated_circuit/IC = comp
				if(!(initial(IC.spawn_flags) & IC_SPAWN_DEFAULT))
					return -1
			compl = compl + initial(comp.complexity)
			cap = cap + initial(comp.size)
			metalcost = metalcost + initial(initial(comp.w_class))
			var/obj/item/integrated_circuit/circuit = new comp
			var/list/ini = circuit.inputs
			if(length(ini))
				for(var/j in 1 to ini.len)
					var/datum/integrated_io/IN = ini[j]
					ioa["[i]i[j]"] = IN
					if(debug)
						visible_message( "<span class='notice'>[i]i[j]</span>")
			ini = circuit.outputs
			if(length(ini))
				for(var/j in 1 to ini.len)               //Also this block uses for setting all i/o id's
					var/datum/integrated_io/OUT = ini[j]
					ioa["[i]o[j]"] = OUT
					if(debug)
						visible_message( "<span class='notice'>[i]o[j]</span>")
			ini = circuit.activators
			if(length(ini))
				for(var/j in 1 to ini.len)
					var/datum/integrated_io/ACT = ini.[j]
					ioa["[i]a[j]"] = ACT
					if(debug)
						visible_message( "<span class='notice'>[i]a[j]</span>")
		if(i<elements.len)
			return 0
	else
		return 0
	if(debug)
		visible_message( "<span class='notice'>cap[cap]compl[compl]maxcompl[maxcomp]maxcap[maxcap]</span>")
	if(cap == 0)
		return 0
	if(cap>maxcap)
		return 0
	if(compl>maxcomp)
		return 0
	if(chap[4] != "values")   //if there is only one word,there is no values
		elements_input = splittext( chap[4] ,"^%^")
		if(debug)
			visible_message( "<span class='notice'>values[elements_input.len]</span>")
		i=0
		elements = list()
		for(var/elem in elements_input)
			i=i+1
			if(i>1)
				elements.Add(elem)
		if(debug)
			visible_message( "<span class='notice'>values[elements.len]</span>")
		if(elements.len>0)
			if(debug)
				visible_message( "<span class='notice'>setting values[elements.len]</span>")
			for(var/E in elements)
				element = splittext( E ,":+:")
				if(debug)
					visible_message( "<span class='notice'>[E]</span>")
				if(!ioa[element[1]])
					return 0
				if(element[2]=="text")
					continue
				else if(element[2]=="num")
					continue
				else if(element[2]=="list")
					continue
				else
					return 0

	if(chap[5] != "wires")   //if there is only one word,there is no wires
		elements_input = splittext( chap[5] ,"^%^")
		i=0
		elements = list()
		if(debug)
			visible_message( "<span class='notice'>wires[elements_input.len]</span>")
		for(var/elem in elements_input)
			i=i+1
			if(i>1)
				elements.Add(elem)
		if(debug)
			visible_message( "<span class='notice'>wires[elements.len]</span>")
		if(elements.len>0)
			if(debug)
				visible_message( "<span class='notice'>setting wires[elements.len]</span>")
			for(var/E in elements)
				element = splittext( E ,"=-=")
				if(debug)
					visible_message( "<span class='notice'>[E]</span>")
				IO = ioa[element[1]]
				IO2 = ioa[element[2]]
				if(!((element[2]+"=-="+element[1]) in elements))
					return 0
				if(!IO)
					return 0
				if(!IO2)
					return 0
				if(initial(IO.io_type) != initial(IO2.io_type))
					return 0
	return metalcost