//Stores all away mission slot datums so we can retrieve them anywhere.
var/global/list/datum/away_slot/all_away_slots = list()

//Link the /areas to their appropriate datums and add the datums to the list.
proc/initialize_awayslots()
	all_away_slots = null
	all_away_slots = list()

	for(var/area/away/R in world)
		var/datum/away_slot/AS = new()
		AS.area = R
		if(R.slot == 1 || R.slot == 2) //Large size.
			AS.size_x = 50
			AS.size_y = 50
		else
			AS.size_x = 20
			AS.size_y = 20

		R.slot_dat = AS
		AS.num = R.slot
		AS.x_start = R.x_start
		AS.y_start = R.y_start
		AS.z_start = R.z
		AS.x_end = R.x_start + AS.size_x -1
		AS.y_end = R.y_start + AS.size_y -1
		AS.z_end = R.z //Same only z level for now..

		all_away_slots += AS

	sleep(0)
	world << "Away slots initialized : <B>[all_away_slots.len]</b>"

/datum/away_slot/Destroy() //Should never happen, I dont think these should ever get qdel'd
	if(istype(area,/area/away))
		area:slot_dat = null
	all_away_slots -= src
	return ..()

/datum/away_slot/proc/recycle_block()
	if(count_players() > 0 )
		message_admins("Warning: Tried to recycle slot [src.num] but can't due to players present.")
		return //Never recycle it if there's actual players here.

	message_admins("Notice: Recycling away slot: [num].")

	for(var/X in block(locate(x_start,y_start,z_start),locate(x_end,y_end,z_end)))
		for(var/H in X)
			if(!istype(H,/mob/dead) && !istype(H,/turf)) //Try not to wipe the ghosts. Or the turfs, they get overwritten anyway.
				qdel(H)

		if(!istype(X,/mob/dead) && !isturf(X)) //Somehow. Nothing should be not on a turf
			qdel(X)

	return

//How many players are here? Also updates the current count.
/datum/away_slot/proc/count_players()
	var/area/away/A = src.area
	if(!istype(A))
		message_admins("Warning: Count_players() failed due to missing area!")
		return //No associated /area slot. Abort

	src.players_here = 0

	for(var/mob/living/carbon/M in A)
		if(M.client && M.client.holder.rank.rights & R_ADMIN)
			continue //Admins don't count.
		if((M.client || M.key))
			src.players_here++

	return src.players_here

//TODO: Add transporter waypoints to these!

//Takes a map file name, fills the correct slot with it.
/datum/away_slot/proc/fill_with_dmm(var/map)
	if(in_use)
		recycle_block()

	if(!maploader)
		message_admins("Warning! Maploader not found! Aborting dmm fill.")
		return



	var/file = file(map)
	if(isfile(file))
		maploader.load_map(file,x_start-1,y_start-1,z_start) //For some reason it starts 1 ahead.
	else
		file = file("_maps/map_files/Star_Trek/away_missions/[map]")
		if(!isfile(file))
			message_admins("Warning! fill_with_dmm failed to load map!")
			return
		else
			maploader.load_map(file,x_start-1,y_start-1,z_start) //For some reason it starts 1 ahead.

	in_use = 1
	message_admins("Away block [num] generated using [map]")
	//DMMS overwrite areas so we need to re-add it every time.
	sleep(-1)
	rebuild_area()
	return

//Okay, when we insert a new dmm, all the old stuff in the /area disappears. So we have to re-add manually.
/datum/away_slot/proc/rebuild_area()
	if(!area)
		message_admins("Tried to rebuild_area, but it was missing!")
		return

	for(var/T in block(locate(x_start,y_start,z_start),locate(x_end,y_end,z_end)))
		area.contents += T

	message_admins("Rebuild_area complete! Contents: [area.contents.len]")
	return

//Takes a mapgenerator (such as "nature"), and fills the space with it.
/datum/away_slot/proc/fill_with_random(var/M = "nature")
	if(in_use)
		recycle_block()

	if(!M || isnull(M) || M == "")
		return

	var/Q = text2path("/datum/mapGenerator/[M]")
	var/N = new Q

	if(!istype(N,/datum/mapGenerator)) //Bad mapgenerator!
		message_admins("Warning! Bad MapGenerator passed to fill_with_random, aborting!")
		qdel(N)
		return

	N:defineRegion(locate(x_start,y_start,z_start),locate(x_end,y_end,z_end))
	N:generate()
	message_admins("Random map '[M]' generated in slot [num].")
	in_use = 1
	return

proc/find_empty_slot(var/size)
	if(size != 20 && size != 50)
		size = 20

	for(var/datum/away_slot/D in all_away_slots)
		if(size == 50)
			if(D.size_x == size)
				if(D.num == 1 && D.in_use)
					continue //Check the next one.
				else
					return D
				if(D.num == 2 && D.in_use) //Shit, both taken. Abort
					return null
				else
					return D
		else
			if(D.size_x > 20 || D.in_use) continue //Skip it.

			return D

	//Nothing.
	return null

proc/fill_next_slot(var/type,var/value,var/size)

	var/datum/away_slot/D = find_empty_slot(size)

	if(isnull(D))	 //All slots are in use. Let's find the next one without players.
		for(var/datum/away_slot/S in all_away_slots)
			if(S.count_players() > 0) continue //There's people here!
			if(S.size_x == size) //Found one without players, with the correct size. Fill it!
				D.recycle_block()
				D = S
				break

	if(!istype(D) || isnull(D))   //ALL slots are full of people? That sucks.
		message_admins("Attention: Fill_next_slot tried to fill an away mission slot, but failed. Probably full?")
		return 0

	if(type == "dmm")
		D.fill_with_dmm(value) //Value in this case is the full map dmm file path, starting with "_maps".
	else
		D.fill_with_random(value) //Value in this case is the procedural generator module type. nature, desert, etc.

	return 1