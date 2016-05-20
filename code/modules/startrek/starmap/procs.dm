//Helper and other procs for the starmap system.

//Initialize all the nodes. Loop through the entire grid.
/datum/starmap/proc/initiate()

	if(!all_away_slots.len)
		initialize_awayslots()

	if(max_x < 1 || max_x > 20 || max_y < 1 || max_y > 20 ||max_z < 1 || max_z > 20)
		message_admins("Starmap failed to initiate! Bad values!")
		return //Nope.

	var/min_x = 0
	var/min_y = 0
	var/min_z = 0
	var/i = 0

	if(negative_allowed)
		min_x = -max_x
		min_y = -max_y
		min_z = -max_z

	for(var/cur_x = min_x to max_x)
		for(var/cur_y = min_y to max_y)
			for(var/cur_z = min_z to max_z)
				create_node(cur_x,cur_y,cur_z)
				i++
	sleep(0)
	world << "<B>Starmap</b> [max_x][max_y][max_z] completed! Total sector nodes: [i]."

//Create a new node datum and link it to the master starmap.
/datum/starmap/proc/create_node(var/x,var/y,var/z)
	var/datum/sm_node/node = new()
	node.x = x
	node.y = y
	node.z = z
	node.master = src
	all_nodes += node
	node.populate_node()
	if(node.x >= round(max_x * mission_ratio) && node.y >= round(max_y * mission_ratio) && node.z >= round(max_z * mission_ratio) && mission_selected == 0)
		node.mission_objective = 1
		mission_selected = 1
		//Do mission stuff here!

//Populate a node with random stuff.
/datum/sm_node/proc/populate_node()

	if(rand(100) > 75) //25% chance of a star.
		create_sector_object("star") //This will fill in all the planets, and the planets will add stuff too.
		sleep(0)

	var/spawn_num = pick(0,0,1,2,2,2,2,3) //How much extra shit is there here?

	if(x == 0 && y == 0 && z == 0) //Yay starbase!
		ship_here = 1
		faction = "Federation" //Game always starts here when a new starmap is born.
		create_sector_object("fed_starbase")
		create_sector_object("starship/pc")
		return
	else
		if(rand(0,1) == 0) //50% base chance of it being claimed.
			if(rand(0,2) == 0)
				faction = "Federation"
			else if(rand(0,4) == 0)
				faction = "Romulan"
			else if(rand(0,4) == 0)
				faction = "Klingon"
			else if(rand(0,6) == 0)
				faction = "Ferengi"
			else if(rand(0,4) == 0)
				faction = "Pirate"
			else if(rand(0,3) == 0)
				faction = "Cardassian"
			else if(rand(0,2) == 0)
				faction = "Borg"
			else
				faction = "Neutral"

	if(!spawn_num) //Nothing here!
		return

	for(var/i = 1 to spawn_num)
		randomize_sector_object() //Fill in extra stuff.

//Take every sector obj type that exists with a chance > 0 (master.all_objects)
//Flip through them looking for something that beats its competitors twice in a row.
//Slap that shit in there and finish.
/datum/sm_node/proc/randomize_sector_object()
	if(!istype(master,/datum/starmap)) //Somehow
		message_admins("Bad sm_node!")
		return

	if(!all_so_types.len)
		all_so_types = subtypesof(/datum/sector_object) //Not set? Well, set it. It should be though.

	var/datum/sector_object/selected_obj = null
	var/temp_obj
	var/stahp = 10

	while(isnull(selected_obj))
		stahp--
		if(stahp < 0)
			return //Nope. 10 tries is enough.

		if(all_so_types.len)
			temp_obj = pick(all_so_types)
		else
			message_admins("Something went wrong with RSO: SO types missing!")
			return //Our subtypes are empty! Wat the hecks?

		selected_obj = new temp_obj()

		if(istype(selected_obj,/datum/sector_object))
			if(selected_obj.chance == 0) //Nope
				temp_obj = null
				qdel(selected_obj)
				continue
		else
			all_so_types -= temp_obj //What's this non-object object doing in our list?
			qdel(selected_obj)
			continue

		var/final_inspection = selected_obj.chance + rand(0,10) //We know the chance var is fine to use.
		if(selected_obj.faction == src.faction) final_inspection += 25

		if(final_inspection < rand(100)) //Failure! Shit.
			qdel(selected_obj)
			continue

		selected_obj.master = src
		sector_stuff += selected_obj
		all_sector_objects += selected_obj
		selected_obj.initialize()
		break

	if(!istype(selected_obj))
		return 0 //Just forget it.
	selected_obj.master = src
	return 1

//Creates a sector object if given the code name, ie. "fed_starbase" for /datum/sector_object/fed_starbase
/datum/sm_node/proc/create_sector_object(so_name = null)
	if(!so_name || isnull(so_name) || so_name == "" || so_name == "Sector Thingy")
		return

	if(!master || isnull(master)) //This should be shitting out warnings
		message_admins("CSO went bad uhoh. Call a coder")
		return

	var/fullpath = text2path("/datum/sector_object/[so_name]")


	if(!isnull(fullpath))
		//This both creates the new object, links it to the node, and adds it to the global list, all up in New()
		var/datum/sector_object/new_object = new fullpath()
		new_object.master = src
		sector_stuff += new_object
		all_sector_objects += new_object
		new_object.initialize()
		return 1

	return 0

/datum/sector_object/proc/initialize()
	if(number_in_name)
		obj_name = obj_name + " [rand(0,999)]"

