/////////////////////////////
///// Part Fabricator ///////
/////////////////////////////

/obj/machinery/mecha_part_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "Exosuit Fabricator"
	desc = "Nothing is being built."
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 5000
	req_access = list(access_robotics)
	var/time_coeff = 1.5 //can be upgraded with research
	var/resource_coeff = 1.5 //can be upgraded with research
	var/res_max_amount = 200000
	var/datum/research/files
	var/id
	var/sync = 0
	var/part_set
	var/obj/being_built
	var/obj/output
	var/list/queue = list()
	var/list/datum/material/materials = list()
	var/processing_queue = 0
	var/screen = "main"
	var/opened = 0
	var/temp
	var/list/part_sets = list( //set names must be unique
	"Robot"=list(
						/obj/item/robot_parts/robot_suit,
						/obj/item/robot_parts/chest,
						/obj/item/robot_parts/head,
						/obj/item/robot_parts/l_arm,
						/obj/item/robot_parts/r_arm,
						/obj/item/robot_parts/l_leg,
						/obj/item/robot_parts/r_leg,
						/obj/item/robot_parts/robot_component/binary_communication_device,
						/obj/item/robot_parts/robot_component/radio,
						/obj/item/robot_parts/robot_component/actuator,
						/obj/item/robot_parts/robot_component/diagnosis_unit,
						/obj/item/robot_parts/robot_component/camera,
						/obj/item/robot_parts/robot_component/armour
					),
	"Ripley"=list(
						/obj/item/mecha_parts/chassis/ripley,
						/obj/item/mecha_parts/part/ripley_torso,
						/obj/item/mecha_parts/part/ripley_left_arm,
						/obj/item/mecha_parts/part/ripley_right_arm,
						/obj/item/mecha_parts/part/ripley_left_leg,
						/obj/item/mecha_parts/part/ripley_right_leg
					),
	"Odysseus"=list(
						/obj/item/mecha_parts/chassis/odysseus,
						/obj/item/mecha_parts/part/odysseus_torso,
						/obj/item/mecha_parts/part/odysseus_head,
						/obj/item/mecha_parts/part/odysseus_left_arm,
						/obj/item/mecha_parts/part/odysseus_right_arm,
						/obj/item/mecha_parts/part/odysseus_left_leg,
						/obj/item/mecha_parts/part/odysseus_right_leg
					),

	"Gygax"=list(
						/obj/item/mecha_parts/chassis/gygax,
						/obj/item/mecha_parts/part/gygax_torso,
						/obj/item/mecha_parts/part/gygax_head,
						/obj/item/mecha_parts/part/gygax_left_arm,
						/obj/item/mecha_parts/part/gygax_right_arm,
						/obj/item/mecha_parts/part/gygax_left_leg,
						/obj/item/mecha_parts/part/gygax_right_leg,
						/obj/item/mecha_parts/part/gygax_armour
					),
	"Durand"=list(
						/obj/item/mecha_parts/chassis/durand,
						/obj/item/mecha_parts/part/durand_torso,
						/obj/item/mecha_parts/part/durand_head,
						/obj/item/mecha_parts/part/durand_left_arm,
						/obj/item/mecha_parts/part/durand_right_arm,
						/obj/item/mecha_parts/part/durand_left_leg,
						/obj/item/mecha_parts/part/durand_right_leg,
						/obj/item/mecha_parts/part/durand_armour
					),
	"H.O.N.K"=list(
						/obj/item/mecha_parts/chassis/honker,
						/obj/item/mecha_parts/part/honker_torso,
						/obj/item/mecha_parts/part/honker_head,
						/obj/item/mecha_parts/part/honker_left_arm,
						/obj/item/mecha_parts/part/honker_right_arm,
						/obj/item/mecha_parts/part/honker_left_leg,
						/obj/item/mecha_parts/part/honker_right_leg
						),
	"Phazon"=list(
						/obj/item/mecha_parts/chassis/phazon,
						/obj/item/mecha_parts/part/phazon_torso,
						/obj/item/mecha_parts/part/phazon_head,
						/obj/item/mecha_parts/part/phazon_left_arm,
						/obj/item/mecha_parts/part/phazon_right_arm,
						/obj/item/mecha_parts/part/phazon_left_leg,
						/obj/item/mecha_parts/part/phazon_right_leg
						),
	"Exosuit Equipment"=list(
						/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,
						/obj/item/mecha_parts/mecha_equipment/tool/drill,
						/obj/item/mecha_parts/mecha_equipment/tool/extinguisher,
						/obj/item/mecha_parts/mecha_equipment/tool/cable_layer,
						/obj/item/mecha_parts/mecha_equipment/tool/sleeper,
						/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun,
						/obj/item/mecha_parts/chassis/firefighter,
						///obj/item/mecha_parts/mecha_equipment/repair_droid,
						/obj/item/mecha_parts/mecha_equipment/generator,
						///obj/item/mecha_parts/mecha_equipment/jetpack, //TODO MECHA JETPACK SPRITE MISSING
						/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser,
						/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
						/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar,
						/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar,
						/obj/item/mecha_parts/mecha_equipment/weapon/honker,
						/obj/item/mecha_parts/part/phazon_phase_array
						),

	"Robotic Upgrade Modules" = list(
						/obj/item/borg/upgrade/reset,
						/obj/item/borg/upgrade/rename,
						/obj/item/borg/upgrade/restart,
						/obj/item/borg/upgrade/vtec,
						/obj/item/borg/upgrade/tasercooler,
						/obj/item/borg/upgrade/jetpack
						),

	"Space Pod" = list(
						/obj/item/pod_parts/core
						),
	"Misc"=list(
						/obj/item/mecha_parts/mecha_tracking,
						/obj/item/mecha_parts/janicart_upgrade
						)
	)




/obj/machinery/mecha_part_fabricator/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/mechfab,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/console_screen
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

/obj/machinery/mecha_part_fabricator/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	res_max_amount = (187500+(T * 37500))
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

/obj/machinery/mecha_part_fabricator/Destroy()
	for(var/atom/A in src)
		del A
	..()
	return

/obj/machinery/mecha_part_fabricator/proc/operation_allowed(mob/M)
	if(isrobot(M) || isAI(M))
		return 1
	if(!istype(req_access) || !req_access.len)
		return 1
	else if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		for(var/ID in list(H.get_active_hand(), H.wear_id, H.belt))
			if(src.check_access(ID))
				return 1
	M << "<font color='red'>You don't have required permissions to use [src]</font>"
	return 0

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

/obj/machinery/mecha_part_fabricator/proc/convert_part_set(set_name as text)
	var/list/parts = part_sets[set_name]
	if(istype(parts, /list))
		for(var/i=1;i<=parts.len;i++)
			var/path = parts[i]
			var/part = new path(src)
			if(part)
				parts[i] = part
			//debug below
			if(!istype(parts[i],/obj/item)) return 0
	return


/obj/machinery/mecha_part_fabricator/proc/add_part_set(set_name as text,parts=null)
	if(set_name in part_sets)//attempt to create duplicate set
		return 0
	if(isnull(parts))
		part_sets[set_name] = list()
	else
		part_sets[set_name] = parts
	convert_part_set(set_name)
	return 1

/obj/machinery/mecha_part_fabricator/proc/add_part_to_set(set_name as text,part)
	if(!part) return 0
	src.add_part_set(set_name)//if no "set_name" set exists, create
	var/list/part_set = part_sets[set_name]
	var/atom/apart
	if(ispath(part))
		apart = new part(src)
	else
		apart = part
	if(!istype(apart)) return 0
	for(var/obj/O in part_set)
		if(O.type == apart.type)
			del apart
			return 0
	part_set[++part_set.len] = apart
	return 1

/obj/machinery/mecha_part_fabricator/proc/remove_part_set(set_name as text)
	for(var/i=1,i<=part_sets.len,i++)
		if(part_sets[i]==set_name)
			part_sets.Cut(i,++i)
	return

/obj/machinery/mecha_part_fabricator/proc/output_parts_list(set_name)
	var/output = ""
	var/list/part_set = listgetindex(part_sets, set_name)
	if(istype(part_set))
		for(var/obj/item/part in part_set)
			var/resources_available = check_resources(part)
			output += "<div class='part'>[output_part_info(part)]<br>\[[resources_available?"<a href='?src=\ref[src];part=\ref[part]'>Build</a> | ":null]<a href='?src=\ref[src];add_to_queue=\ref[part]'>Add to queue</a>\]\[<a href='?src=\ref[src];part_desc=\ref[part]'>?</a>\]</div>"
	return output

/obj/machinery/mecha_part_fabricator/proc/output_part_info(var/obj/item/part)
	var/output = "[part.name] (Cost: [output_part_cost(part)]) [get_construction_time_w_coeff(part)/10]sec"
	return output

/obj/machinery/mecha_part_fabricator/proc/output_part_cost(var/obj/item/part)
	var/i = 0
	var/output
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))//The most efficient way to go about this. Not all objects have these vars, but if they don't then they CANNOT be made by the mech fab. Doing it this way reduces a major amount of typecasting and switches, while cutting down maintenece for them as well -Sieve
		for(var/c in part:construction_cost)//The check should ensure that anything without the var doesn't make it to this point
			if(c=="metal")
				c="iron"
			if(c in materials)
				var/datum/material/material = materials[c]
				output += "[i?" | ":null][get_resource_cost_w_coeff(part,c)] [material.processed_name]"
				i++
			else
				testing("Unknown matID [c] in [part.type]!")
		return output
	else
		return 0

/obj/machinery/mecha_part_fabricator/proc/output_available_resources()
	var/output
	for(var/matID in materials)
		var/datum/material/material = materials[matID]
		output += "<span class=\"res_name\">[material.processed_name]: </span>[material.stored] cm&sup3;"
		if(material.stored>0)
			output += "<span style='font-size:80%;'> - Remove \[<a href='?src=\ref[src];remove_mat=1;material=[matID]'>1</a>\] | \[<a href='?src=\ref[src];remove_mat=10;material=[matID]'>10</a>\] | \[<a href='?src=\ref[src];remove_mat=[res_max_amount];material=[matID]'>All</a>\]</span>"
		output += "<br/>"
	return output

/obj/machinery/mecha_part_fabricator/proc/remove_resources(var/obj/item/part)
//Be SURE to add any new equipment to this switch, but don't be suprised if it spits out children objects
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))
		for(var/matID in part:construction_cost)
			if(matID=="metal")
				matID="iron"
			if(matID in src.materials)
				var/datum/material/material = materials[matID]
				material.stored -= get_resource_cost_w_coeff(part,matID)
				materials[matID]=material
	else
		return

/obj/machinery/mecha_part_fabricator/proc/check_resources(var/obj/item/part)
//		if(istype(part, /obj/item/robot_parts) || istype(part, /obj/item/mecha_parts) || istype(part,/obj/item/borg/upgrade))
//Be SURE to add any new equipment to this switch, but don't be suprised if it spits out children objects
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))
		for(var/matID in part:construction_cost)
			if(matID=="metal")
				matID="iron"
			if(matID in src.materials)
				var/datum/material/material = materials[matID]
				if(material.stored < get_resource_cost_w_coeff(part,matID))
					return 0
		return 1
	else
		return 0

/obj/machinery/mecha_part_fabricator/proc/build_part(var/obj/item/part)
	if(!part) return

	 // critical exploit prevention, do not remove unless you replace it -walter0o
	if( !(locate(part, src.contents)) || !(part.vars.Find("construction_time")) || !(part.vars.Find("construction_cost")) ) // these 3 are the current requirements for an object being buildable by the mech_fabricator
		return

	src.being_built = new part.type(src)
	src.desc = "It's building [src.being_built]."
	src.remove_resources(part)
	src.overlays += "fab-active"
	src.use_power = 2
	src.updateUsrDialog()
	sleep(get_construction_time_w_coeff(part))
	src.use_power = 1
	src.overlays -= "fab-active"
	src.desc = initial(src.desc)
	if(being_built)
		src.visible_message("\icon[src] <b>[src]</b> beeps, \"The following has been completed: [src.being_built] is built\".")
		if(istype(being_built,/obj/item/mecha_parts/mecha_equipment/weapon)&&!istype(being_built,/obj/item/mecha_parts/mecha_equipment/weapon/honker)&&!istype(being_built,/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar)&&!istype(being_built,/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar))//Check if it's a mech weapon that's not clown gear
			var/obj/item/weapon/storage/lockbox/L = new/obj/item/weapon/storage/lockbox //Make a lockbox
			being_built.loc = L //Put the thing in the lockbox
			L.name += " ([being_built.name])"
			being_built = L //Building the lockbox now, with the thing in it
		src.being_built.Move(get_turf(output))
		src.being_built = null
	src.updateUsrDialog()
	return 1

/obj/machinery/mecha_part_fabricator/proc/update_queue_on_page()
	send_byjax(usr,"mecha_fabricator.browser","queue",src.list_queue())
	return

/obj/machinery/mecha_part_fabricator/proc/add_part_set_to_queue(set_name)
	if(set_name in part_sets)
		var/list/part_set = part_sets[set_name]
		if(islist(part_set))
			for(var/obj/item/part in part_set)
				add_to_queue(part)
	return

/obj/machinery/mecha_part_fabricator/proc/add_to_queue(part)
	if(!istype(queue))
		queue = list()
	if(part)
		queue[++queue.len] = part
	return queue.len

/obj/machinery/mecha_part_fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !istype(queue) || (index<1 || index>queue.len))
		return 0
	queue.Cut(index,++index)
	return 1

/obj/machinery/mecha_part_fabricator/proc/process_queue()
	var/obj/item/part = listgetindex(src.queue, 1)
	if(!part)
		remove_from_queue(1)
		if(src.queue.len)
			return process_queue()
		else
			return
	if(!(part.vars.Find("construction_time")) || !(part.vars.Find("construction_cost")))//If it shouldn't be printed
		remove_from_queue(1)//Take it out of the quene
		return process_queue()//Then reprocess it
	temp = null
	while(part)
		if(stat&(NOPOWER|BROKEN))
			return 0
		if(!check_resources(part))
			src.visible_message("\icon[src] <b>[src]</b> beeps, \"Not enough resources. Queue processing stopped\".")
			temp = {"<font color='red'>Not enough resources to build next part.</font><br>
						<a href='?src=\ref[src];process_queue=1'>Try again</a> | <a href='?src=\ref[src];clear_temp=1'>Return</a><a>"}
			return 0
		remove_from_queue(1)
		build_part(part)
		part = listgetindex(src.queue, 1)
	src.visible_message("\icon[src] <b>[src]</b> beeps, \"Queue processing finished successfully\".")
	return 1

/obj/machinery/mecha_part_fabricator/proc/list_queue()
	var/output = "<b>Queue contains:</b>"
	if(!istype(queue) || !queue.len)
		output += "<br>Nothing"
	else
		output += "<ol>"
		for(var/i=1;i<=queue.len;i++)
			var/obj/item/part = listgetindex(src.queue, i)
			if(istype(part))
				if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))
					output += "<li[!check_resources(part)?" style='color: #f00;'":null]>[part.name] - [i>1?"<a href='?src=\ref[src];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] [i<queue.len?"<a href='?src=\ref[src];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] <a href='?src=\ref[src];remove_from_queue=[i]'>Remove</a></li>"
				else//Prevents junk items from even appearing in the list, and they will be silently removed when the fab processes
					remove_from_queue(i)//Trash it
					return list_queue()//Rebuild it

		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\game\mecha\mech_fabricator.dm:441: output += "</ol>"
		output += {"</ol>
			\[<a href='?src=\ref[src];process_queue=1'>Process queue</a> | <a href='?src=\ref[src];clear_queue=1'>Clear queue</a>\]"}
		// END AUTOFIX
	return output

/obj/machinery/mecha_part_fabricator/proc/convert_designs()
	if(!files) return
	var/i = 0
	for(var/datum/design/D in files.known_designs)
		if(D.build_type&16)
			if(D.category in part_sets)//Checks if it's a valid category
				if(add_part_to_set(D.category, D.build_path))//Adds it to said category
					i++
			else
				if(add_part_to_set("Misc", D.build_path))//If in doubt, chunk it into the Misc
					i++
	return i

/obj/machinery/mecha_part_fabricator/proc/update_tech()
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


/obj/machinery/mecha_part_fabricator/proc/sync(silent=null)
	var/new_data=0
	var/found = 0
	for(var/obj/machinery/computer/rdconsole/RDC in area_contents(areaMaster))
		if(!RDC) continue
		if(!RDC.sync)
			continue
		found = 1
		for(var/datum/tech/T in RDC.files.known_tech)
			if(T)
				files.AddTech2Known(T)
		for(var/datum/design/D in RDC.files.known_designs)
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


/obj/machinery/mecha_part_fabricator/proc/get_resource_cost_w_coeff(var/obj/item/part as obj,var/resource as text, var/roundto=1)
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))
		if (resource=="iron" && !("iron" in part:construction_cost))
			resource="metal"
		return round(part:construction_cost[resource]*resource_coeff, roundto)
	else
		return 0

/obj/machinery/mecha_part_fabricator/proc/get_construction_time_w_coeff(var/obj/item/part as obj, var/roundto=1)
//Be SURE to add any new equipment to this switch, but don't be suprised if it spits out children objects
	if(part.vars.Find("construction_time") && part.vars.Find("construction_cost"))
		return round(part:construction_time*time_coeff, roundto)
	else
		return 0


/obj/machinery/mecha_part_fabricator/attack_hand(mob/user as mob)
	var/dat, left_part
	if (..())
		return
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
	user << browse(dat, "window=mecha_fabricator;size=1000x400")
	onclose(user, "mecha_fabricator")
	return

/obj/machinery/mecha_part_fabricator/proc/exploit_prevention(var/obj/Part, mob/user as mob, var/desc_exploit)
// critical exploit prevention, feel free to improve or replace this, but do not remove it -walter0o

	if(!Part || !user || !istype(Part) || !istype(user)) // sanity
		return 1

	if( !(locate(Part, src.contents)) || !(Part.vars.Find("construction_time")) || !(Part.vars.Find("construction_cost")) ) // these 3 are the current requirements for an object being buildable by the mech_fabricator

		var/turf/LOC = get_turf(user)
		message_admins("[key_name_admin(user)] tried to exploit an Exosuit Fabricator to [desc_exploit ? "get the desc of" : "duplicate"] <a href='?_src_=vars;Vars=\ref[Part]'>[Part]</a> ! ([LOC ? "<a href='?_src_=holder;adminplayerobservecoodjump=1;X=[LOC.x];Y=[LOC.y];Z=[LOC.z]'>JMP</a>" : "null"])", 0)
		log_admin("EXPLOIT : [key_name(user)] tried to exploit an Exosuit Fabricator to [desc_exploit ? "get the desc of" : "duplicate"] [Part] !")
		return 1

	return null

/obj/machinery/mecha_part_fabricator/Topic(href, href_list)

	if(..()) // critical exploit prevention, do not remove unless you replace it -walter0o
		return

	var/datum/topic_input/filter = new /datum/topic_input(href,href_list)
	if(href_list["part_set"])
		var/tpart_set = filter.getStr("part_set")
		if(tpart_set)
			if(tpart_set=="clear")
				src.part_set = null
			else
				src.part_set = tpart_set
				screen = "parts"
	if(href_list["part"])
		var/obj/part = filter.getObj("part")

		// critical exploit prevention, do not remove unless you replace it -walter0o
		if(src.exploit_prevention(part, usr))
			return

		if(!processing_queue)
			build_part(part)
		else
			add_to_queue(part)
	if(href_list["add_to_queue"])
		var/obj/part = filter.getObj("add_to_queue")

		// critical exploit prevention, do not remove unless you replace it -walter0o
		if(src.exploit_prevention(part, usr))
			return

		add_to_queue(part)

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
/*
		if(href_list["list_queue"])
			list_queue()
*/
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

/obj/machinery/mecha_part_fabricator/proc/remove_material(var/matID, var/amount)
	if(matID in materials)
		var/datum/material/material = materials[matID]
		//var/obj/item/stack/sheet/res = new material.sheettype(src)
		var/total_amount = min(round(material.stored/material.cc_per_sheet),amount)
		var/to_spawn = total_amount

		while(to_spawn > 0)
			var/obj/item/stack/sheet/res = new material.sheettype(src)
			if(to_spawn > res.max_amount)
				res.amount = res.max_amount
				to_spawn -= res.max_amount
			else
				res.amount = to_spawn
				to_spawn = 0

			material.stored -= res.amount * res.perunit
			//materials[matID]=material - why?
			res.loc = src.loc
		return total_amount
	return 0


/obj/machinery/mecha_part_fabricator/attackby(obj/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/screwdriver))
		if (!opened)
			opened = 1
			icon_state = "fab-o"
			user << "You open the maintenance hatch of [src]."
		else
			opened = 0
			icon_state = "fab-idle"
			user << "You close the maintenance hatch of [src]."
		return
	if (istype(W, /obj/item/device/multitool))
		if(!opened)
			var/result = input("Set your location as output?") in list("Yes","No","Machine Location")
			switch(result)
				if("Yes")
					var/found=0
					for(var/direction in cardinal)
						if(locate(user) in get_step(src,direction))
							found=1
					if(!found)
						user << "\red Cannot set this as the output location; You're too far away."
						return
					if(istype(output,/obj/machinery/mineral/output))
						del(output)
					output=new /obj/machinery/mineral/output(usr.loc)
					user << "\blue Output set."
				if("No")
					return
				if("Machine Location")
					if(istype(output,/obj/machinery/mineral/output))
						del(output)
					output=src
					user << "\blue Output set."
		return
	if (opened)
		if(istype(W, /obj/item/weapon/crowbar))
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
			M.state = 2
			M.icon_state = "box_1"
			for(var/obj/I in component_parts)
				if(I.reliability != 100 && crit_fail)
					I.crit_fail = 1
				I.loc = src.loc
			for(var/id in materials)
				var/datum/material/material=materials[id]
				if(material.stored >= material.cc_per_sheet)
					var/obj/item/stack/sheet/S=new material.sheettype(src.loc)
					S.amount = round(material.stored / material.cc_per_sheet)
			del(src)
			return 1
		else
			user << "\red You can't load the [src.name] while it's opened."
			return 1

	if(istype(W, /obj/item/weapon/card/emag))
		emag()
		return
	var/datum/material/material=null
	for(var/matID in materials)
		var/datum/material/mat=materials[matID]
		if(W.type == mat.sheettype)
			material=mat
	if(!material)
		return ..()

	if(src.being_built)
		user << "The fabricator is currently processing. Please wait until completion."
		return
	var/obj/item/stack/sheet/stack = W
	var/sname = "[stack.name]"
	var/amnt = stack.perunit
	if(material.stored < res_max_amount)
		var/count = 0
		src.overlays += "fab-load-[material]"//loading animation is now an overlay based on material type. No more spontaneous conversion of all ores to metal. -vey
		sleep(10)
		if(stack && stack.amount)
			while(material.stored < res_max_amount && stack)
				if(stack.amount <= 0 || !stack)
					user.drop_item(stack)
					qdel(stack)
					break
				material.stored += amnt
				stack.use(1)
				count++
			materials[material.id]=material
			src.overlays -= "fab-load-[material]"
			user << "You insert [count] [sname] into the fabricator."
			src.updateUsrDialog()
	else
		user << "The fabricator cannot hold more [sname]."
	return
