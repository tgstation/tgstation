/////////////////////////////
///// Part Fabricator ///////
/////////////////////////////

/obj/machinery/mecha_part_fabricator/pod_fabricator
	name = "Spacepod Fabricator"
	desc = "Nothing is being built."
	part_sets = list( //set names must be unique
	"Pod Frame" = list(
						/obj/item/pod_parts/pod_frame/fore_port,
						/obj/item/pod_parts/pod_frame/fore_starboard,
						/obj/item/pod_parts/pod_frame/aft_port,
						/obj/item/pod_parts/pod_frame/aft_starboard
						),
	"Pod Armor" = list(
						/obj/item/pod_parts/armor
						),
	"Pod Parts" = list(
						/obj/item/pod_parts/core
						),
	"Misc" = list(
						)
	)

/obj/machinery/mecha_part_fabricator/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/podfab,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/micro_laser
	)

	RefreshParts()

	//	part_sets["Cyborg Upgrade Modules"] = typesof(/obj/item/borg/upgrade/) - /obj/item/borg/upgrade/  // Eh.  This does it dymaically, but to support having the items referenced otherwhere in the code but not being constructable, going to do it manaully.

	for(var/part_set in part_sets)
		convert_part_set(part_set)
	files = new /datum/research(src) //Setup the research data holder.

	// Start materials system
	for(var/mattype in typesof(/datum/material) - /datum/material)
		var/datum/material/material = new mattype
		materials[material.id]=material

	// Define initial output.
	output=src
	for(var/direction in cardinal)
		var/O = locate(/obj/machinery/mineral/output, get_step(src, dir))
		if(O)
			output=O
			break
	return

/obj/machinery/mecha_part_fabricator/pod_fabricator/convert_designs()
	if(!files) return
	var/i = 0
	for(var/datum/design/D in files.known_designs)
		if(D.build_type&32) //32 is the pod id
			if(D.category in part_sets)//Checks if it's a valid category
				if(add_part_to_set(D.category, D.build_path))//Adds it to said category
					i++
			else
				if(add_part_to_set("Misc", D.build_path))//If in doubt, chunk it into the Misc
					i++
	return i

/obj/machinery/mecha_part_fabricator/pod_fabricator/emag()
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

/obj/machinery/mecha_part_fabricator/pod_fabricator/attack_hand(mob/user as mob)
	var/dat, left_part
	if(!operation_allowed(user))
		return
	user.set_machine(src)
	var/turf/exit = get_turf(output)
	if(exit.density)
		src.visible_message("\icon[src] <b>[src]</b> beeps, \"Error! Part outlet is obstructed\".")
		return
	if(temp)
		left_part = temp
	else if(src.being_built)
		left_part = {"<TT>Building [src.being_built.name].<BR>
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
			  <title>[src.name]</title>
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
				<td style='width: 70%; padding-right: 10px;'>
				[left_part]
				</td>
				<td style='width: 30%; background: #ccc;' id='queue'>
				[list_queue()]
				</td>
				<tr>
				</table>
				</body>
				</html>"}
	user << browse(dat, "window=pod_fabricator;size=1000x400")
	onclose(user, "pod_fabricator")
	return

/obj/machinery/mecha_part_fabricator/pod_fabricator/update_queue_on_page()
	send_byjax(usr,"pod_fabricator.browser","queue",src.list_queue())
	return