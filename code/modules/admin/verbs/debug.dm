/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	if(src.holder.rank == "Coder")
		Debug2 = !Debug2

		world << "Debugging [Debug2 ? "On" : "Off"]"
		log_admin("[key_name(src)] toggled debugging to [Debug2]")
	else if(src.holder.rank == "Host")
		Debug2 = !Debug2

		world << "Debugging [Debug2 ? "On" : "Off"]"
		log_admin("[key_name(src)] toggled debugging to [Debug2]")
	else
		alert("Coders only baby")
		return



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/make_dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	var/target = null
	var/lst[] // List reference
	lst = new/list() // Make the list
	var/returnval = null
	var/class = null

	switch(alert("Proc owned by something?",,"Yes","No"))
		if("Yes")
			class = input("Proc owned by...","Owner") in list("Obj","Mob","Area or Turf","Client","CANCEL ABORT STOP")
			switch(class)
				if("CANCEL ABORT STOP")
					return
				if("Obj")
					target = input("Enter target:","Target",usr) as obj in world
				if("Mob")
					target = input("Enter target:","Target",usr) as mob in world
				if("Area or Turf")
					target = input("Enter target:","Target",usr.loc) as area|turf in world
				if("Client")
					var/list/keys = list()
					for(var/mob/M in world)
						keys += M.client
					target = input("Please, select a player!", "Selection", null, null) as null|anything in keys
		if("No")
			target = null

	var/procname = input("Proc path, eg: /proc/fake_blood","Path:", null)

	var/argnum = input("Number of arguments","Number:",0) as num

	lst.len = argnum // Expand to right length

	var/i
	for(i=1, i<argnum+1, i++) // Lists indexed from 1 forwards in byond

		// Make a list with each index containing one variable, to be given to the proc
		class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","CANCEL")
		switch(class)
			if("CANCEL")
				return

			if("text")
				lst[i] = input("Enter new text:","Text",null) as text

			if("num")
				lst[i] = input("Enter new number:","Num",0) as num

			if("type")
				lst[i] = input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

			if("reference")
				lst[i] = input("Select reference:","Reference",src) as mob|obj|turf|area in world

			if("mob reference")
				lst[i] = input("Select reference:","Reference",usr) as mob in world

			if("file")
				lst[i] = input("Pick file:","File") as file

			if("icon")
				lst[i] = input("Pick icon:","Icon") as icon

			if("client")
				var/list/keys = list()
				for(var/mob/M in world)
					keys += M.client
				lst[i] = input("Please, select a player!", "Selection", null, null) as null|anything in keys

			if("mob's area")
				var/mob/temp = input("Select mob", "Selection", usr) as mob in world
				lst[i] = temp.loc

	spawn(0)
		if(target)
			returnval = call(target,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
		else
			returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc
	usr << "\blue Proc returned: [returnval ? returnval : "null"]"





/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!src.mob)
		return
	var/turf/T = src.mob.loc

	if (!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = ""
	t+= "Nitrogen : [env.nitrogen]\n"
	t+= "Oxygen : [env.oxygen]\n"
	t+= "Plasma : [env.toxins]\n"
	t+= "CO2: [env.carbon_dioxide]\n"

	usr.show_message(t, 1)

/client/proc/cmd_admin_robotize(var/mob/M in world)
	set category = "Admin"
	set name = "Make Robot"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has robotized [M.key].")
		spawn(10)
			M:Robotize()

	else
		alert("Invalid mob")


/client/proc/cmd_admin_alienize(var/mob/M in world)
	set category = "Admin"
	set name = "Make Alien"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] is attempting to alienize [M.key].")
		spawn(10)
			M:Alienize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_monkeyize(var/mob/M in world)
	set category = "Admin"
	set name = "Make Monkey"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/target = M
		log_admin("[key_name(src)] is attempting to monkeyize [M.key].")
		spawn(10)
			target.monkeyize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_changelinginize(var/mob/M in world)
	set category = "Admin"
	set name = "Make Changeling"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] a changeling.")
		spawn(10)
			M.absorbed_dna[M.real_name] = M.dna
			M.make_changeling()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_abominize(var/mob/M in world)
	set category = "Admin"
	set name = "Make Abomination"

	usr << "Ruby Mode disabled. Command aborted."
	return
	if(!ticker)
		alert("Wait until the game starts.")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] an abomination.")
	/*
		spawn(10)
			M.make_abomination()
		*/

/client/proc/cmd_debug_del_all()
	set category = "Debug"
	set name = "Del-All"

	// to prevent REALLY stupid deletions
	var/blocked = list(/obj, /mob, /mob/living, /mob/living/carbon, /mob/living/carbon/human)
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in typesof(/obj) + typesof(/mob) - blocked
	if(hsbitem)
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				del(O)
		log_admin("[key_name(src)] has deleted all instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all instances of [hsbitem].", 0)

/client/proc/cmd_debug_tog_aliens()
	set category = "Special Verbs"
	set name = "Toggle Aliens"

	aliens_allowed = !aliens_allowed
	log_admin("[key_name(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [aliens_allowed ? "on" : "off"].", 0)