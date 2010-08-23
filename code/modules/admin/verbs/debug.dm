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

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"
	if(!src.authenticated || !src.holder)
		src << "Only administrators may use this command."
		return
	var/target = null
	var/arguments = null
	var/returnval = null
	//var/class = null

	switch(alert("Proc owned by obj?",,"Yes","No"))
		if("Yes")
			target = input("Enter target:","Target",null) as obj|mob|area|turf in world
		if("No")
			target = null

	var/procname = input("Procpath","path:", null)

	if (target)
		arguments = input("Arguments","Arguments:", null)
		usr << "\blue Calling '[procname]' with arguments '[arguments]' on '[target]'"
		returnval = call(target,procname)(arguments)
	else
		arguments = input("Arguments","Arguments:", null)
		usr << "\blue Calling '[procname]' with arguments '[arguments]'"
		returnval = call(procname)(arguments)

	usr << "\blue Proc returned: [returnval ? returnval : "null"]"
/*
	var/argnum = input("Number of arguments:","Number",null) as num


	var/i
	for(i=0, i<argnum, i++)

		class = input("Type of Argument #[i]","Variable Type", default) in list("text","num","type","reference","mob reference", "icon","file","cancel")
		switch(class)
			if("cancel")
				return

			if("text")
				var/"argu"+i = input("Enter new text:","Text",null) as text

			if("num")
				O.vars[variable] = input("Enter new number:","Num",\
					O.vars[variable]) as num

			if("type")
				O.vars[variable] = input("Enter type:","Type",O.vars[variable]) \
					in typesof(/obj,/mob,/area,/turf)

			if("reference")
				O.vars[variable] = input("Select reference:","Reference",\
					O.vars[variable]) as mob|obj|turf|area in world

			if("mob reference")
				O.vars[variable] = input("Select reference:","Reference",\
					O.vars[variable]) as mob in world

			if("file")
				O.vars[variable] = input("Pick file:","File",O.vars[variable]) \
					as file

			if("icon")
				O.vars[variable] = input("Pick icon:","Icon",O.vars[variable]) \
					as icon
		spawn(0)
			call(T,wproc)(warg)
*/



/client/proc/Cell()
	set category = "Debug"
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
	set category = "Debug"
	set name = "Robotize"

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
	set category = "Debug"
	set name = "Alienize"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] is attempting to alienize [M.key].")
		spawn(10)
			M:Alienize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_changelinginize(var/mob/M in world)
	set category = "Debug"
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
	set category = "Debug"
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
	set category = "Debug"
	set name = "Toggle Aliens"

	aliens_allowed = !aliens_allowed
	log_admin("[key_name(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [aliens_allowed ? "on" : "off"].", 0)