/obj/machinery/mecha_part_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "Nothing is being built."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000
	req_access = list(access_robotics)
	var/time_coeff = 1
	var/resource_coeff = 1
	var/time_coeff_tech = 1
	var/resource_coeff_tech = 1
	var/list/resources = list(
								"$metal"=0,
								"$glass"=0,
								"$bananium"=0,
								"$diamond"=0,
								"$gold"=0,
								"$plasma"=0,
								"$silver"=0,
								"$uranium"=0
								)
	var/res_max_amount = 200000
	var/datum/research/files
	var/id
	var/sync = 0
	var/part_set
	var/datum/design/being_built
	var/list/queue = list()
	var/processing_queue = 0
	var/screen = "main"
	var/temp
	var/list/part_sets = list(
								"Cyborg",
								"Ripley",
								"Firefighter",
								"Odysseus",
								"Gygax",
								"Durand",
								"H.O.N.K",
								"Phazon",
								"Exosuit Equipment",
								"Cyborg Upgrade Modules",
								"Misc"
								)

/obj/machinery/mecha_part_fabricator/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/mechfab(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()
	files = new /datum/research(src) //Setup the research data holder.

/obj/machinery/mecha_part_fabricator/RefreshParts()
	var/T = 0

	//maximum stocking amount (max 412000)
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	res_max_amount = (187000+(T * 37500))

	//ressources adjustment coefficient (1 -> 0.88 -> 0.75)
	T = -1
	for(var/obj/item/weapon/stock_parts/micro_laser/Ma in component_parts)
		T += Ma.rating
	resource_coeff = round(initial(resource_coeff) - (initial(resource_coeff)*(T))/8,0.01)

	//building time adjustment coefficient (1 -> 0.8 -> 0.6)
	T = -1
	for(var/obj/item/weapon/stock_parts/manipulator/Ml in component_parts)
		T += Ml.rating
	time_coeff = round(initial(time_coeff) - (initial(time_coeff)*(T))/5,0.01)


/obj/machinery/mecha_part_fabricator/check_access(obj/item/weapon/card/id/I)
	if(istype(I, /obj/item/device/pda))
		var/obj/item/device/pda/pda = I
		I = pda.id
	if(!istype(I) || !I.access) //not ID or no access
		return 0
	for(var/req in req_access)
		if(!(req in I.access)) //doesn't have this access
			return 0
	return 1

/obj/machinery/mecha_part_fabricator/proc/emag()
	switch(emagged)
		if(0)
			emagged = 0.5
			visible_message("\icon[src] <b>\The [src]</b> beeps: \"DB error \[Code 0x00F1\]\"")
			sleep(10)
			visible_message("\icon[src] <b>\The [src]</b> beeps: \"Attempting auto-repair\"")
			sleep(15)
			visible_message("\icon[src] <b>\The [src]</b> beeps: \"User DB corrupted \[Code 0x00FA\]. Truncating data structure...\"")
			sleep(30)
			visible_message("\icon[src] <b>\The [src]</b> beeps: \"User DB truncated. Please contact your Nanotrasen system operator for future assistance.\"")
			req_access = null
			emagged = 1
		if(0.5)
			visible_message("\icon[src] <b>\The [src]</b> beeps: \"DB not responding \[Code 0x0003\]...\"")
		if(1)
			visible_message("\icon[src] <b>\The [src]</b> beeps: \"No records in User DB\"")
	return

/obj/machinery/mecha_part_fabricator/proc/output_parts_list(set_name)
	var/output = ""
	for(var/datum/design/D in files.known_designs)
		if(D.build_type & MECHFAB)
			if(!(set_name in D.category))
				continue
			var/resources_available = check_resources(D)
			output += "<div class='part'>[output_part_info(D)]<br>\[[resources_available?"<a href='?src=\ref[src];part=[D.id]'>Build</a> | ":null]<a href='?src=\ref[src];add_to_queue=[D.id]'>Add to queue</a>\]\[<a href='?src=\ref[src];part_desc=[D.id]'>?</a>\]</div>"
	return output

/obj/machinery/mecha_part_fabricator/proc/output_part_info(datum/design/D)
	var/output = "[initial(D.name)] (Cost: [output_part_cost(D)]) [get_construction_time_w_coeff(D)/10]sec"
	return output

/obj/machinery/mecha_part_fabricator/proc/output_part_cost(datum/design/D)
	var/i = 0
	var/output
	for(var/c in D.materials)
		if(c in resources)
			output += "[i?" | ":null][get_resource_cost_w_coeff(D,c)] [material2name(c)]"
			i++
	return output

/obj/machinery/mecha_part_fabricator/proc/output_available_resources()
	var/output
	for(var/resource in resources)
		var/amount = min(res_max_amount, resources[resource])
		output += "<span class=\"res_name\">[material2name(resource)]: </span>[amount] cm&sup3;"
		if(amount>0)
			output += "<span style='font-size:80%;'>- Remove \[<a href='?src=\ref[src];remove_mat=1;material=[resource]'>1</a>\] | \[<a href='?src=\ref[src];remove_mat=10;material=[resource]'>10</a>\] | \[<a href='?src=\ref[src];remove_mat=[resources[resource] / MINERAL_MATERIAL_AMOUNT];material=[resource]'>All</a>\]</span>"
		output += "<br/>"
	return output

/obj/machinery/mecha_part_fabricator/proc/remove_resources(datum/design/D)
	for(var/resource in D.materials)
		if(resource in resources)
			resources[resource] -= get_resource_cost_w_coeff(D,resource)

/obj/machinery/mecha_part_fabricator/proc/check_resources(datum/design/D)
	for(var/R in D.materials)
		if(R in resources)
			if(resources[R] < get_resource_cost_w_coeff(D, R))
				return 0
		else
			return 0
	return 1

/obj/machinery/mecha_part_fabricator/proc/build_part(datum/design/D)
	being_built = D
	desc = "It's building \a [initial(D.name)]."
	remove_resources(D)
	overlays += "fab-active"
	use_power = 2
	updateUsrDialog()
	sleep(get_construction_time_w_coeff(D))
	use_power = 1
	overlays -= "fab-active"
	desc = initial(desc)

	var/location = get_step(src,SOUTH)
	var/obj/item/I = new D.build_path(location)
	I.m_amt = get_resource_cost_w_coeff(D,"$metal")
	I.g_amt = get_resource_cost_w_coeff(D,"$glass")
	visible_message("\icon[src] <b>\The [src]</b> beeps, \"\The [I] is complete.\"")
	being_built = null

	updateUsrDialog()
	return 1

/obj/machinery/mecha_part_fabricator/proc/update_queue_on_page()
	send_byjax(usr,"mecha_fabricator.browser","queue",list_queue())
	return

/obj/machinery/mecha_part_fabricator/proc/add_part_set_to_queue(set_name)
	if(set_name in part_sets)
		for(var/datum/design/D in files.known_designs)
			if(D.build_type & MECHFAB)
				if(set_name in D.category)
					add_to_queue(D)

/obj/machinery/mecha_part_fabricator/proc/add_to_queue(D)
	if(!istype(queue))
		queue = list()
	if(D)
		queue[++queue.len] = D
	return queue.len

/obj/machinery/mecha_part_fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index<1 || index>queue.len))
		return 0
	queue.Cut(index,++index)
	return 1

/obj/machinery/mecha_part_fabricator/proc/process_queue()
	var/datum/design/D = queue[1]
	if(!D)
		remove_from_queue(1)
		if(queue.len)
			return process_queue()
		else
			return
	temp = null
	while(D)
		if(stat&(NOPOWER|BROKEN))
			return 0
		if(!check_resources(D))
			visible_message("\icon[src] <b>\The [src]</b> beeps, \"Not enough resources. Queue processing stopped.\"")
			temp = {"<span class='alert'>Not enough resources to build next part.</span><br>
						<a href='?src=\ref[src];process_queue=1'>Try again</a> | <a href='?src=\ref[src];clear_temp=1'>Return</a><a>"}
			return 0
		remove_from_queue(1)
		build_part(D)
		D = listgetindex(queue, 1)
	visible_message("\icon[src] <b>\The [src]</b> beeps, \"Queue processing finished successfully.\"")

/obj/machinery/mecha_part_fabricator/proc/list_queue()
	var/output = "<b>Queue contains:</b>"
	if(!istype(queue) || !queue.len)
		output += "<br>Nothing"
	else
		output += "<ol>"
		var/i = 0
		for(var/datum/design/D in queue)
			i++
			var/obj/part = D.build_path
			output += "<li[!check_resources(D)?" style='color: #f00;'":null]>[initial(part.name)] - [i>1?"<a href='?src=\ref[src];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] [i<queue.len?"<a href='?src=\ref[src];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] <a href='?src=\ref[src];remove_from_queue=[i]'>Remove</a></li>"

		output += "</ol>"
		output += "\[<a href='?src=\ref[src];process_queue=1'>Process queue</a> | <a href='?src=\ref[src];clear_queue=1'>Clear queue</a>\]"
	return output

/obj/machinery/mecha_part_fabricator/proc/update_tech()
	if(!files)
		return
	var/output
	for(var/datum/tech/T in files.known_tech)
		if(T && T.level > 1)
			var/diff
			switch(T.id)
				if("materials")
					//one materials level is 1/32, so that max level is 0.75 coefficient
					diff = round(initial(resource_coeff_tech) - (initial(resource_coeff_tech)*(T.level-1))/32,0.01)
					if(resource_coeff_tech>diff)
						resource_coeff_tech = diff
						output+="Production efficiency increased.<br>"
				if("programming")
					//one materials level is 1/40, so that max level is 0.8 coefficient
					diff = round(initial(time_coeff_tech) - (initial(time_coeff_tech)*(T.level-1))/40,0.1)
					if(time_coeff_tech>diff)
						time_coeff_tech = diff
						output+="Production routines updated.<br>"
	return output


/obj/machinery/mecha_part_fabricator/proc/sync()
	temp = "Updating local R&D database..."
	updateUsrDialog()
	sleep(30) //only sleep if called by user

	for(var/obj/machinery/computer/rdconsole/RDC in area_contents(get_area(src)))
		if(!RDC.sync)
			continue
		for(var/datum/tech/T in RDC.files.known_tech)
			files.AddTech2Known(T)
		for(var/datum/design/D in RDC.files.known_designs)
			files.AddDesign2Known(D)
		files.RefreshResearch()
		temp = "Processed equipment designs.<br>"
		//check if the tech coefficients have changed
		temp += update_tech()
		temp += "<a href='?src=\ref[src];clear_temp=1'>Return</a>"

		updateUsrDialog()
		visible_message("\icon[src] <b>\The [src]</b> beeps, \"Successfully synchronized with R&D server.\"")
		return

	temp = "Unable to connect to local R&D Database.<br>Please check your connections and try again.<br><a href='?src=\ref[src];clear_temp=1'>Return</a>"
	updateUsrDialog()
	return

/obj/machinery/mecha_part_fabricator/proc/get_resource_cost_w_coeff(datum/design/D, resource, roundto = 1)
	return round(D.materials[resource]*resource_coeff*resource_coeff_tech, roundto)

/obj/machinery/mecha_part_fabricator/proc/get_construction_time_w_coeff(datum/design/D, roundto = 1) //aran
	return round(initial(D.construction_time)*time_coeff*time_coeff_tech, roundto)

/obj/machinery/mecha_part_fabricator/attack_hand(mob/user)
	if(!(..()))
		return interact(user)

/obj/machinery/mecha_part_fabricator/interact(mob/user as mob)
	var/dat, left_part
	if (..())
		return
	user.set_machine(src)
	var/turf/exit = get_step(src,SOUTH)
	if(exit.density)
		visible_message("\icon[src] <b>\The [src]</b> beeps, \"Error! Part outlet is obstructed.\"")
		return
	if(temp)
		left_part = temp
	else if(being_built)
		var/obj/I = being_built.build_path
		left_part = {"<TT>Building [initial(I.name)].<BR>
							Please wait until completion...</TT>"}
	else
		switch(screen)
			if("main")
				left_part = output_available_resources()+"<hr>"
				left_part += "<a href='?src=\ref[src];sync=1'>Sync with R&D servers</a><hr>"
				for(var/part_set in part_sets)
					left_part += "<a href='?src=\ref[src];part_set=[part_set]'>[part_set]</a> - \[<a href='?src=\ref[src];partset_to_queue=[part_set]'>Add all parts to queue\]<br>"
			if("parts")
				left_part += output_parts_list(part_set)
				left_part += "<hr><a href='?src=\ref[src];screen=main'>Return</a>"
	dat = {"<html>
			  <head>
			  <title>[name]</title>
				<style>
				.res_name {font-weight: bold; text-transform: capitalize;}
				.red {color: #f00;}
				.part {margin-bottom: 10px;}
				.arrow {text-decoration: none; font-size: 10px;}
				body, table {height: 100%;}
				td {vertical-align: top; padding: 5px;}
				html, body {padding: 0px; margin: 0px;}
				h1 {font-size: 18px; margin: 5px 0px;}
				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
				</head><body>
				<body>
				<table style='width: 100%;'>
				<tr>
				<td style='width: 65%; padding-right: 10px;'>
				[left_part]
				</td>
				<td style='width: 35%; background: #ccc;' id='queue'>
				[list_queue()]
				</td>
				<tr>
				</table>
				</body>
				</html>"}
	user << browse(dat, "window=mecha_fabricator;size=1000x430")
	onclose(user, "mecha_fabricator")
	return

/obj/machinery/mecha_part_fabricator/Topic(href, href_list)
	if(..())
		return
	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
	if(href_list["part_set"])
		var/tpart_set = filter.getStr("part_set")
		if(tpart_set)
			if(tpart_set=="clear")
				part_set = null
			else
				part_set = tpart_set
				screen = "parts"
	if(href_list["part"])
		var/T = filter.getStr("part")
		for(var/datum/design/D in files.known_designs)
			if(D.build_type & MECHFAB)
				if(D.id == T)
					if(!processing_queue)
						build_part(D)
					else
						add_to_queue(D)
					break
	if(href_list["add_to_queue"])
		var/T = filter.getStr("add_to_queue")
		for(var/datum/design/D in files.known_designs)
			if(D.build_type & MECHFAB)
				if(D.id == T)
					add_to_queue(D)
					break
		return update_queue_on_page()
	if(href_list["remove_from_queue"])
		remove_from_queue(filter.getNum("remove_from_queue"))
		return update_queue_on_page()
	if(href_list["partset_to_queue"])
		add_part_set_to_queue(filter.get("partset_to_queue"))
		return update_queue_on_page()
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
		screen = href_list["screen"]
	if(href_list["queue_move"] && href_list["index"])
		var/index = filter.getNum("index")
		var/new_index = index + filter.getNum("queue_move")
		if(isnum(index) && isnum(new_index))
			if(IsInRange(new_index,1,queue.len))
				queue.Swap(index,new_index)
		return update_queue_on_page()
	if(href_list["clear_queue"])
		queue = list()
		return update_queue_on_page()
	if(href_list["sync"])
		sync()
	if(href_list["part_desc"])
		var/T = filter.getStr("part_desc")
		for(var/datum/design/D in files.known_designs)
			if(D.build_type & MECHFAB)
				if(D.id == T)
					var/obj/part = D.build_path
					temp = {"<h1>[initial(part.name)] description:</h1>
								[initial(part.desc)]<br>
								<a href='?src=\ref[src];clear_temp=1'>Return</a>
								"}
					break

	if(href_list["remove_mat"] && href_list["material"])
		var/amount = text2num(href_list["remove_mat"])
		var/material = href_list["material"]
		if(amount < 0 || amount > resources[material]) //href protection
			return

		var/removed = remove_material(material,amount)
		if(removed == -1)
			temp = "Not enough [material2name(material)] to produce a sheet."
		else
			temp = "Ejected [removed] of [material2name(material)]"
		temp += "<br><a href='?src=\ref[src];clear_temp=1'>Return</a>"

	updateUsrDialog()
	return

/obj/machinery/mecha_part_fabricator/proc/remove_material(var/mat_string, var/amount)
	if(resources[mat_string] < MINERAL_MATERIAL_AMOUNT) //not enough mineral for a sheet
		return -1
	var/type
	switch(mat_string)
		if("$metal")
			type = /obj/item/stack/sheet/metal
		if("$glass")
			type = /obj/item/stack/sheet/glass
		if("$gold")
			type = /obj/item/stack/sheet/mineral/gold
		if("$silver")
			type = /obj/item/stack/sheet/mineral/silver
		if("$diamond")
			type = /obj/item/stack/sheet/mineral/diamond
		if("$plasma")
			type = /obj/item/stack/sheet/mineral/plasma
		if("$uranium")
			type = /obj/item/stack/sheet/mineral/uranium
		if("$bananium")
			type = /obj/item/stack/sheet/mineral/bananium
		else
			return 0
	var/result = 0

	while(amount > 50)
		new type(get_turf(src),50)
		amount -= 50
		result += 50
		resources[mat_string] -= 50 * MINERAL_MATERIAL_AMOUNT

	var/total_amount = round(resources[mat_string]/MINERAL_MATERIAL_AMOUNT)
	if(total_amount)//if there's still enough material for sheets
		var/obj/item/stack/sheet/res = new type(get_turf(src),min(amount,total_amount))
		resources[mat_string] -= res.amount*MINERAL_MATERIAL_AMOUNT
		result += res.amount

	return result


/obj/machinery/mecha_part_fabricator/attackby(obj/W as obj, mob/user as mob, params)
	if(default_deconstruction_screwdriver(user, "fab-o", "fab-idle", W))
		return

	if(exchange_parts(user, W))
		return

	if(panel_open)
		if(istype(W, /obj/item/weapon/crowbar))
			for(var/material in resources)
				remove_material(material, resources[material]/MINERAL_MATERIAL_AMOUNT)
			default_deconstruction_crowbar(W)
			return 1
		else
			user << "<span class='warning'>You can't load \the [name] while it's opened!</span>"
			return 1

	if(istype(W, /obj/item/stack))
		var/material
		switch(W.type)
			if(/obj/item/stack/sheet/mineral/gold)
				material = "$gold"
			if(/obj/item/stack/sheet/mineral/silver)
				material = "$silver"
			if(/obj/item/stack/sheet/mineral/diamond)
				material = "$diamond"
			if(/obj/item/stack/sheet/mineral/plasma)
				material = "$plasma"
			if(/obj/item/stack/sheet/metal)
				material = "$metal"
			if(/obj/item/stack/sheet/glass)
				material = "$glass"
			if(/obj/item/stack/sheet/mineral/bananium)
				material = "$bananium"
			if(/obj/item/stack/sheet/mineral/uranium)
				material = "$uranium"
			else
				return ..()

		if(being_built)
			user << "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>"
			return
		if(res_max_amount - resources[material] < MINERAL_MATERIAL_AMOUNT) //overstuffing the fabricator
			user << "<span class='warning'>\The [src] [material2name(material)] storage is full!</span>"
			return
		var/obj/item/stack/sheet/stack = W
		var/sname = "[stack.name]"
		if(resources[material] < res_max_amount)
			overlays += "fab-load-[material2name(material)]"//loading animation is now an overlay based on material type. No more spontaneous conversion of all ores to metal. -vey

			var/transfer_amount = min(stack.amount, round((res_max_amount - resources[material])/MINERAL_MATERIAL_AMOUNT,1))
			resources[material] += transfer_amount * MINERAL_MATERIAL_AMOUNT
			stack.use(transfer_amount)
			user << "<span class='notice'>You insert [transfer_amount] [sname] sheet\s into \the [src].</span>"
			sleep(10)
			updateUsrDialog()
			overlays -= "fab-load-[material2name(material)]" //No matter what the overlay shall still be deleted
		else
			user << "<span class='warning'>\The [src] cannot hold any more [sname] sheet\s!</span>"
		return

/obj/machinery/mecha_part_fabricator/proc/material2name(var/ID)
	return copytext(ID,2)

/obj/machinery/mecha_part_fabricator/emag_act()
	emag()