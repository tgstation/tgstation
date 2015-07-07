/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))	return

	if(Debug2)
		Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	feedback_add_details("admin_verb","DG2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/Dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/callproc()
	set category = "Debug"
	set name = "Advanced ProcCall"

	if(!check_rights(R_DEBUG)) return

	spawn(0)
		var/target = null
		var/targetselected = 0
		var/returnval = null
		var/class = null

		switch(alert("Proc owned by something?",,"Yes","No"))
			if("Yes")
				targetselected = 1
				class = input("Proc owned by...","Owner",null) as null|anything in list("Obj","Mob","Area or Turf","Client")
				switch(class)
					if("Obj")
						target = input("Enter target:","Target",usr) as obj in world
					if("Mob")
						target = input("Enter target:","Target",usr) as mob in world
					if("Area or Turf")
						target = input("Enter target:","Target",usr.loc) as area|turf in world
					if("Client")
						var/list/keys = list()
						for(var/client/C)
							keys += C
						target = input("Please, select a player!", "Selection", null, null) as null|anything in keys
					else
						return
			if("No")
				target = null
				targetselected = 0

		var/procname = input("Proc path, eg: /proc/fake_blood","Path:", null) as text|null
		if(!procname)	return

		var/list/lst = get_callproc_args()
		if(!lst)
			return

		if(targetselected)
			if(!target)
				usr << "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>"
				return
			if(!hascall(target,procname))
				usr << "<font color='red'>Error: callproc(): target has no such call [procname].</font>"
				return
			log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(target,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
		else
			//this currently has no hascall protection. wasn't able to get it working.
			log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc

		usr << "<font color='blue'>[procname] returned: [returnval ? returnval : "null"]</font>"
		feedback_add_details("admin_verb","APC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/callproc_datum(var/A as null|area|mob|obj|turf)
	set category = "Debug"
	set name = "Atom ProcCall"

	if(!check_rights(R_DEBUG))
		return

	var/procname = input("Proc name, eg: fake_blood","Proc:", null) as text|null
	if(!procname)
		return

	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(!A || !IsValidSrc(A))
		usr << "<span class='warning'>Error: callproc_datum(): owner of proc no longer exists.</span>"
		return
	if(!hascall(A,procname))
		usr << "<span class='warning'>Error: callproc_datum(): target has no such call [procname].</span>"
		return
	log_admin("[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")

	spawn()
		var/returnval = call(A,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
		usr << "<span class='notice'>[procname] returned: [returnval ? returnval : "null"]</span>"

	feedback_add_details("admin_verb","DPC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/get_callproc_args()
	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(!argnum && (argnum!=0))	return

	var/list/lst = list()
	//TODO: make a list to store whether each argument was initialised as null.
	//Reason: So we can abort the proccall if say, one of our arguments was a mob which no longer exists
	//this will protect us from a fair few errors ~Carn

	while(argnum--)
		// Make a list with each index containing one variable, to be given to the proc
		var/class = input("What kind of variable?","Variable Type") in list("text","num","type","reference","mob reference","icon","file","client","mob's area","CANCEL")
		switch(class)
			if("CANCEL")
				return null

			if("text")
				lst += input("Enter new text:","Text",null) as text

			if("num")
				lst += input("Enter new number:","Num",0) as num

			if("type")
				lst += input("Enter type:","Type") in typesof(/obj,/mob,/area,/turf)

			if("reference")
				lst += input("Select reference:","Reference",src) as mob|obj|turf|area in world

			if("mob reference")
				lst += input("Select reference:","Reference",usr) as mob in world

			if("file")
				lst += input("Pick file:","File") as file

			if("icon")
				lst += input("Pick icon:","Icon") as icon

			if("client")
				var/list/keys = list()
				for(var/mob/M in world)
					keys += M.client
				lst += input("Please, select a player!", "Selection", null, null) as null|anything in keys

			if("mob's area")
				var/mob/temp = input("Select mob", "Selection", usr) as mob in world
				lst += temp.loc
	return lst


/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = mob.loc

	if (!( istype(T, /turf) ))
		return

	var/datum/gas_mixture/env = T.return_air()

	var/t = ""
	t+= "Nitrogen : [env.nitrogen]\n"
	t+= "Oxygen : [env.oxygen]\n"
	t+= "Plasma : [env.toxins]\n"
	t+= "CO2: [env.carbon_dioxide]\n"

	usr.show_message(t, 1)
	feedback_add_details("admin_verb","ASL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has robotized [M.key].")
		var/mob/living/carbon/human/H = M
		spawn(10)
			H.Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_blobize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Blob"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has blobized [M.key].")
		var/mob/living/carbon/human/H = M
		spawn(10)
			H.Blobize()

	else
		alert("Invalid mob")


/client/proc/cmd_admin_animalize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!ticker)
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(istype(M, /mob/new_player))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(10)
		M.Animalize()


/client/proc/makepAI(var/turf/T in mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!istype(choice, /mob/dead/observer))
		var/confirm = input("[choice.key] isn't ghosting right now. Are you sure you want to yank him out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return 0
	var/obj/item/device/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	pai.name = input(choice, "Enter your pAI name:", "pAI Name", "Personal AI") as text
	pai.real_name = pai.name
	pai.key = choice.key
	card.setPersonality(pai)
	for(var/datum/paiCandidate/candidate in SSpai.candidates)
		if(candidate.key == choice.key)
			SSpai.candidates.Remove(candidate)
	feedback_add_details("admin_verb","MPAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_alienize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make Alien"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
			feedback_add_details("admin_verb","MKAL") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] made [key_name(M)] into an alien.</span>")
	else
		alert("Invalid mob")

/client/proc/cmd_admin_slimeize(var/mob/M in mob_list)
	set category = "Fun"
	set name = "Make slime"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has slimeized [M.key].")
		spawn(10)
			M:slimeize()
			feedback_add_details("admin_verb","MKMET") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a slime.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] made [key_name(M)] into a slime.</span>")
	else
		alert("Invalid mob")

/*
/client/proc/cmd_admin_monkeyize(var/mob/M in world)
	set category = "Fun"
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
	set category = "Fun"
	set name = "Make Changeling"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] a changeling.")
		spawn(10)
			M.absorbed_dna[M.real_name] = M.dna
			M.make_changeling()
			if(M.mind)
				M.mind.special_role = "Changeling"
	else
		alert("Invalid mob")
*/
/*
/client/proc/cmd_admin_abominize(var/mob/M in world)
	set category = null
	set name = "Make Abomination"

	usr << "Ruby Mode disabled. Command aborted."
	return
	if(!ticker)
		alert("Wait until the game starts.")
		return
	if(istype(M, /mob/living/carbon/human))
		log_admin("[key_name(src)] has made [M.key] an abomination.")

	//	spawn(10)
	//		M.make_abomination()

*/
/*
/client/proc/make_cultist(var/mob/M in world)
	set category = "Fun"
	set name = "Make Cultist"
	set desc = "Makes target a cultist"
	if(!wordtravel)
		runerandom()
	if(M)
		if(M.mind in ticker.mode.cult)
			return
		else
			if(alert("Spawn that person a tome?",,"Yes","No")=="Yes")
				M << "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie. A tome, a message from your new master, appears on the ground."
				new /obj/item/weapon/tome(M.loc)
			else
				M << "\red You catch a glimpse of the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie."
			var/glimpse=pick("1","2","3","4","5","6","7","8")
			switch(glimpse)
				if("1")
					M << "\red You remembered one thing from the glimpse... [wordtravel] is travel..."
				if("2")
					M << "\red You remembered one thing from the glimpse... [wordblood] is blood..."
				if("3")
					M << "\red You remembered one thing from the glimpse... [wordjoin] is join..."
				if("4")
					M << "\red You remembered one thing from the glimpse... [wordhell] is Hell..."
				if("5")
					M << "\red You remembered one thing from the glimpse... [worddestr] is destroy..."
				if("6")
					M << "\red You remembered one thing from the glimpse... [wordtech] is technology..."
				if("7")
					M << "\red You remembered one thing from the glimpse... [wordself] is self..."
				if("8")
					M << "\red You remembered one thing from the glimpse... [wordsee] is see..."

			if(M.mind)
				M.mind.special_role = "Cultist"
				ticker.mode.cult += M.mind
			src << "Made [M] a cultist."
*/

var/list/TYPES_SHORTCUTS = list(
	/obj/effect/decal/cleanable = "CLEANABLE",
	/obj/item/device/radio/headset = "HEADSET",
	/obj/item/clothing/head/helmet/space = "SPESSHELMET",
	/obj/item/weapon/book/manual = "MANUAL",
	/obj/item/weapon/reagent_containers/food/drinks = "DRINK", //longest paths comes first
	/obj/item/weapon/reagent_containers/food = "FOOD",
	/obj/item/weapon/reagent_containers = "REAGENT_CONTAINERS",
	/obj/machinery/atmospherics = "ATMOS",
	/obj/machinery/portable_atmospherics = "PORT_ATMOS",
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/missile_rack = "MECHA_MISSILE_RACK",
	/obj/item/mecha_parts/mecha_equipment = "MECHA_EQUIP",
)

var/global/list/g_fancy_list_of_types = null
/proc/get_fancy_list_of_types()
	if (isnull(g_fancy_list_of_types)) //init
		var/list/temp = sortList(typesof(/atom) - typesof(/area) - /atom - /atom/movable)
		g_fancy_list_of_types = new(temp.len)
		for(var/type in temp)
			var/typename = "[type]"
			for (var/tn in TYPES_SHORTCUTS)
				if (copytext(typename,1, length("[tn]/")+1)=="[tn]/" /*findtextEx(typename,"[tn]/",1,2)*/ )
					typename = TYPES_SHORTCUTS[tn]+copytext(typename,length("[tn]/"))
					break
			g_fancy_list_of_types[typename] = type
	return g_fancy_list_of_types

/proc/filter_fancy_list(list/L, filter as text)
	var/list/matches = new
	for(var/key in L)
		var/value = L[key]
		if(findtext("[key]", filter) || findtext("[value]", filter))
			matches[key] = value
	return matches

//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all(var/object as text)
	set category = "Debug"
	set name = "Del-All"

	var/list/matches = get_fancy_list_of_types()
	if (!isnull(object) && object!="")
		matches = filter_fancy_list(matches, object)

	if(matches.len==0)
		return
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in matches
	if(hsbitem)
		hsbitem = matches[hsbitem]
		var/counter = 0
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				counter++
				qdel(O)
		log_admin("[key_name(src)] has deleted all ([counter]) instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all ([counter]) instances of [hsbitem].", 0)
		feedback_add_details("admin_verb","DELA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachine.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)
	feedback_add_details("admin_verb","MPWN") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if (!ticker)
		alert("Wait until the game starts")
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/worn = H.wear_id
		var/obj/item/weapon/card/id/id = null
		if(worn)
			id = worn.GetID()
		if(id)
			id.icon_state = "gold"
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			id = new /obj/item/weapon/card/id/gold(H.loc)
			id.access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.update_label()

			if(worn)
				if(istype(worn,/obj/item/device/pda))
					worn:id = id
					id.loc = worn
				else if(istype(worn,/obj/item/weapon/storage/wallet))
					worn:front_id = id
					id.loc = worn
					worn.update_icon()
			else
				H.equip_to_slot(id,slot_wear_id)

	else
		alert("Invalid mob")
	feedback_add_details("admin_verb","GFA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has granted [M.key] full access.</span>")

/client/proc/cmd_assume_direct_control(var/mob/M in mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] assumed direct control of [M].</span>")
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = src.mob
	M.ckey = src.ckey
	if( isobserver(adminmob) )
		qdel(adminmob)
	feedback_add_details("admin_verb","ADC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_areatest()
	set category = "Mapping"
	set name = "Test areas"

	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()

	for(var/area/A in world)
		if(!(A.type in areas_all))
			areas_all.Add(A.type)

	for(var/obj/machinery/power/apc/APC in world)
		var/area/A = get_area(APC)
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/alarm/alarm in world)
		var/area/A = get_area(alarm)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in world)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in world)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in world)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/device/radio/intercom/I in world)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in world)
		var/area/A = get_area(C)
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	world << "<b>AREAS WITHOUT AN APC:</b>"
	for(var/areatype in areas_without_APC)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT AN AIR ALARM:</b>"
	for(var/areatype in areas_without_air_alarm)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>"
	for(var/areatype in areas_without_RC)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT ANY LIGHTS:</b>"
	for(var/areatype in areas_without_light)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT A LIGHT SWITCH:</b>"
	for(var/areatype in areas_without_LS)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT ANY INTERCOMS:</b>"
	for(var/areatype in areas_without_intercom)
		world << "* [areatype]"

	world << "<b>AREAS WITHOUT ANY CAMERAS:</b>"
	for(var/areatype in areas_without_camera)
		world << "* [areatype]"

/client/proc/cmd_admin_dress(var/mob/living/carbon/human/M in mob_list)
	set category = "Fun"
	set name = "Select equipment"
	if(!ishuman(M))
		alert("Invalid mob")
		return
	//log_admin("[key_name(src)] has alienized [M.key].")
	var/list/dresspacks = list(
		"naked",
		"as job...",
		"standard space gear",
		"tournament standard red",
		"tournament standard green",
		"tournament gangster",
		"tournament chef",
		"tournament janitor",
		"laser tag red",
		"laser tag blue",
		"pirate",
		"space pirate",
		"soviet admiral",
		"tunnel clown",
		"masked killer",
		"assassin",
		"mobster",
		"death commando",
		"emergency response officer",
		"centcom official",
		"centcom commander",
		"special ops officer",
		"blue wizard",
		"red wizard",
		"marisa wizard",
		"plasmaman"
		)
	var/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in dresspacks
	if (isnull(dresscode))
		return

	var/datum/job/jobdatum
	if (dresscode == "as job...")
		var/jobname = input("Select job", "Robust quick dress shop") as null|anything in get_all_jobs()
		if(isnull(jobname))
			return
		jobdatum = SSjob.GetJob(jobname)


	feedback_add_details("admin_verb","SEQ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for (var/obj/item/I in M)
		if (istype(I, /obj/item/weapon/implant))
			continue
		qdel(I)
	switch(dresscode)
		if ("naked")
			//do nothing

		if ("as job...")
			if(jobdatum)
				dresscode = jobdatum.title
				M.job = jobdatum.title
				jobdatum.equip(M)

		if ("standard space gear")
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space(M), slot_head)
			var /obj/item/weapon/tank/jetpack/J = new /obj/item/weapon/tank/jetpack/oxygen(M)
			M.equip_to_slot_or_del(J, slot_back)
			J.toggle()
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(M), slot_wear_mask)
			J.Topic(null, list("stat" = 1))

		if ("tournament standard red","tournament standard green") //we think stunning weapon is too overpowered to use it on tournaments. --rastaf0
			if (dresscode=="tournament standard red")
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(M), slot_w_uniform)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/vest(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/thunderdome(M), slot_head)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/destroyer(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/knife(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/smokebomb(M), slot_r_store)


		if ("tournament gangster") //gangster are supposed to fight each other. --rastaf0
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/det(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(M), slot_shoes)

			M.equip_to_slot_or_del(new /obj/item/clothing/suit/det_suit(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/det_hat(M), slot_head)

			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/ammo_box/c10mm(M), slot_l_store)

		if ("tournament chef") //Steven Seagal FTW
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chef(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/toggle/chef(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/chefhat(M), slot_head)

			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/rollingpin(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/knife(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/knife(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/knife(M), slot_s_store)

		if ("tournament janitor")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/janitor(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(M), slot_shoes)
			var/obj/item/weapon/storage/backpack/backpack = new(M)
			for(var/obj/item/I in backpack)
				qdel(I)
			M.equip_to_slot_or_del(backpack, slot_back)

			M.equip_to_slot_or_del(new /obj/item/weapon/mop(M), slot_r_hand)
			var/obj/item/weapon/reagent_containers/glass/bucket/bucket = new(M)
			bucket.reagents.add_reagent("water", 70)
			M.equip_to_slot_or_del(bucket, slot_l_hand)

			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/chem_grenade/cleaner(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/grenade/chem_grenade/cleaner(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/stack/tile/plasteel(M), slot_in_backpack)

		if ("laser tag red")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/red(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/red(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/red(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/redtaghelm(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/redtag(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/laser/redtag(M), slot_s_store)

		if ("laser tag blue")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/blue(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/blue(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/blue(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/bluetaghelm(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/bluetag(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/laser/bluetag(M), slot_s_store)

		if ("pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/bandana(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(M), slot_r_hand)

		if ("space pirate")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/pirate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/brown(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/pirate(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/pirate(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)

			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/pirate(M), slot_r_hand)

		if("tunnel clown")//Tunnel clowns rule!
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/chaplain_hoodie(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/bikehorn(M), slot_r_store)

			var/obj/item/weapon/card/id/W = new(M)
			W.access = get_all_accesses()
			W.assignment = "Tunnel Clown!"
			W.registered_name = M.real_name
			W.update_label(M.real_name)
			M.equip_to_slot_or_del(W, slot_wear_id)

			var/obj/item/weapon/twohanded/fireaxe/fire_axe = new(M)
			M.equip_to_slot_or_del(fire_axe, slot_r_hand)

		if("masked killer")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/overalls(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/white(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/latex(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/surgical(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/welding(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/monocle(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/apron(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/kitchen/knife(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/scalpel(M), slot_r_store)

			var/obj/item/weapon/twohanded/fireaxe/fire_axe = new(M)
			M.equip_to_slot_or_del(fire_axe, slot_r_hand)

			for(var/obj/item/carried_item in M.contents)
				if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant.
					carried_item.add_blood(M)//Oh yes, there will be blood...

		if("assassin")
			var/obj/item/clothing/under/U = new /obj/item/clothing/under/suit_jacket(M)
			M.equip_to_slot_or_del(U, slot_w_uniform)
			U.attachTie(new /obj/item/clothing/tie/waistcoat(M))
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/saber(M), slot_l_store)

			var/obj/item/weapon/storage/secure/briefcase/sec_briefcase = new(M)
			for(var/obj/item/briefcase_item in sec_briefcase)
				qdel(briefcase_item)
			for(var/i=3, i>0, i--)
				sec_briefcase.contents += new /obj/item/stack/spacecash/c1000
			sec_briefcase.contents += new /obj/item/weapon/gun/energy/kinetic_accelerator/crossbow
			sec_briefcase.contents += new /obj/item/weapon/gun/projectile/revolver/mateba
			sec_briefcase.contents += new /obj/item/ammo_box/a357
			sec_briefcase.contents += new /obj/item/weapon/c4
			M.equip_to_slot_or_del(sec_briefcase, slot_l_hand)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Reaper"
			pda.update_label()

			M.equip_to_slot_or_del(pda, slot_belt)

			var/obj/item/weapon/card/id/syndicate/W = new(M)
			W.access = get_all_accesses()
			W.assignment = "Reaper"
			W.registered_name = M.real_name
			W.update_label(M.real_name)
			M.equip_to_slot_or_del(W, slot_wear_id)
// DEATH SQUADS
		if("death commando")
			equip_deathsquad(M)

		if("emergency response officer")
			var/alert
			if(alert("Code Red ERT?","Select Response Level","Yes","No")=="Yes")
				alert = 1
			else
				alert = 0
			switch(input("Which class?") in list("Commander","Security","Engineer","Medic"))
				if("Commander")
					equip_emergencyresponsesquad(M, "commander",alert)
				if("Security")
					equip_emergencyresponsesquad(M, "sec",alert)
				if("Engineer")
					equip_emergencyresponsesquad(M, "eng",alert)
				if("Medic")
					equip_emergencyresponsesquad(M, "med",alert)

		if("centcom official")
			equip_centcomofficial(M)

		if("centcom commander")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_commander(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/armor/bulletproof(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cent/commander(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/cohiba(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/centhat(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/mateba(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/weapon/lighter(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/ammo_box/a357(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)

			var/obj/item/weapon/card/id/W = new(M)
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_centcom_access("Centcom Commander")
			W.assignment = "Centcom Commander"
			W.registered_name = M.real_name
			W.update_label()
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("special ops officer")
			var/obj/item/device/radio/headset/R = new /obj/item/device/radio/headset/headset_cent/commander(M)
			R.set_frequency(CENTCOM_FREQ)
			R.freqlock = 1
			M.equip_to_slot_or_del(R, slot_ears)

			M.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/officer(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/havana(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/beret(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/pistol/m1911(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/weapon/lighter(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)

			var/obj/item/weapon/card/id/W = new(M)
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_centcom_access("Special Ops Officer")
			W.assignment = "Special Ops Officer"
			W.registered_name = M.real_name
			W.update_label()
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("blue wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)

		if("red wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)

		if("marisa wizard")
			M.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/marisa(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/marisa(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/marisa(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/spellbook(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/staff(M), slot_l_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)

		if("soviet admiral")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/hgpiratecap(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cent(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/hgpirate(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/mateba(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/soviet(M), slot_w_uniform)

			var/obj/item/weapon/card/id/W = new(M)
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_centcom_access("Admiral")
			W.assignment = "Admiral"
			W.registered_name = M.real_name
			W.update_label()
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("mobster")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/fedora(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/laceup(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/automatic/tommygun(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/suit_jacket/really_black(M), slot_w_uniform)

			var/obj/item/weapon/card/id/W = new(M)
			W.assignment = "Assistant"
			W.registered_name = M.real_name
			W.update_label()
			M.equip_to_slot_or_del(W, slot_wear_id)

		if("plasmaman")
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/hardsuit/plasmaman(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/eva/plasmaman(M),slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/internals/plasmaman/full(M),slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(M),slot_wear_mask)


	M.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode]..</span>")
	return

/client/proc/startSinglo()

	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in world)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field/generator/F in world)
		if(F.anchored)
			F.Varedit_start = 1
	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in world)
			if(G.anchored)
				var/obj/singularity/S = new /obj/singularity(get_turf(G), 50)
//				qdel(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in world)
		if(Rad.anchored)
			if(!Rad.P)
				var/obj/item/weapon/tank/internals/plasma/Plasma = new/obj/item/weapon/tank/internals/plasma(Rad)
				Plasma.air_contents.toxins = 70
				Rad.drainratio = 0
				Rad.P = Plasma
				Plasma.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in world)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs","Clients","Joined Clients"))
		if("Players")
			usr << list2text(player_list,",")
		if("Admins")
			usr << list2text(admins,",")
		if("Mobs")
			usr << list2text(mob_list,",")
		if("Living Mobs")
			usr << list2text(living_mob_list,",")
		if("Dead Mobs")
			usr << list2text(dead_mob_list,",")
		if("Clients")
			usr << list2text(clients,",")
		if("Joined Clients")
			usr << list2text(joined_player_list,",")

/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Displays a list of things that have failed to GC this round"

	var/dat = "<B>List of things that failed to GC this round</B><BR><BR>"

	for(var/path in SSgarbage.didntgc)
		dat += "[path] - [SSgarbage.didntgc[path]] times<BR>"

	usr << browse(dat, "window=dellog")



//Deathsquad
/proc/equip_deathsquad(var/mob/living/carbon/human/M, var/officer)
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/headset_cent/alt(M)
	R.set_frequency(CENTCOM_FREQ)
	R.freqlock = 1
	M.equip_to_slot_or_del(R, slot_ears)

	if(officer)
		M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/beret(M), slot_head)
	//else
	//	M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/deathsquad(M), slot_head)

	M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/hardsuit/deathsquad(M), slot_wear_suit)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/color/green(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
	M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_wear_mask)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/toggle/thermal(M), slot_glasses)

	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(M), slot_back)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)

	M.equip_to_slot_or_del(new /obj/item/ammo_box/a357(M), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/hypospray/combat/nanites(M), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/flashbangs(M), slot_in_backpack)
	M.equip_to_slot_or_del(new /obj/item/device/flashlight(M), slot_in_backpack)

	M.equip_to_slot_or_del(new /obj/item/weapon/c4(M), slot_in_backpack)

	M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/saber(M), slot_l_store)
	M.equip_to_slot_or_del(new /obj/item/weapon/shield/energy(M), slot_r_store)
	M.equip_to_slot_or_del(new /obj/item/weapon/tank/internals/emergency_oxygen(M), slot_s_store)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/projectile/revolver/mateba(M), slot_belt)

	M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/loyalpin(M), slot_r_hand)


	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(M)//Here you go Deuryn
	L.imp_in = M
	L.implanted = 1
	M.sec_hud_set_implants()

	var/obj/item/weapon/card/id/W = new(M)
	W.icon_state = "centcom"
	W.access = get_all_accesses()//They get full station access.
	W.access += get_centcom_access("Death Commando")//Let's add their alloted Centcom access.
	W.assignment = "Death Commando"
	W.registered_name = M.real_name
	W.update_label(W.registered_name, W.assignment)
	M.equip_to_slot_or_del(W, slot_wear_id)

//Emergency Response Team
/proc/equip_emergencyresponsesquad(var/mob/living/carbon/human/M, var/ertrole, var/alert)
	var/obj/item/weapon/card/id/W = null
	var/obj/item/device/radio/R = new /obj/item/device/radio/headset/headset_cent/alt(M)
	R.set_frequency(CENTCOM_FREQ)
	R.freqlock = 1
	M.equip_to_slot_or_del(R, slot_ears)

	switch(ertrole)
		if("commander")
			W = new /obj/item/weapon/card/id/ert(M)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/hardsuit/ert(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/thermal/eyepatch(M), slot_glasses)
			M.equip_to_slot_or_del(W, slot_wear_id)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/captain(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/security/full(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton/loaded(M), slot_in_backpack)

			R.keyslot = new /obj/item/device/encryptionkey/heads/captain

			if(alert)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/pistol/loyalpin(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/melee/energy/sword/saber(M), slot_l_store)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/switchblade(M), slot_l_store)

		if("sec")
			W = new /obj/item/weapon/card/id/ert/Security(M)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/hardsuit/ert/sec(M), slot_wear_suit)
			M.equip_to_slot_or_del(W, slot_wear_id)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/security(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/security/sunglasses(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/handcuffs(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/security/full(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton/loaded(M), slot_in_backpack)

			R.keyslot = new /obj/item/device/encryptionkey/heads/hos

			if(alert)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/carbine/loyalpin(M), slot_in_backpack)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun/advtaser(M), slot_in_backpack)

		if("med")
			W = new /obj/item/weapon/card/id/ert/Medical(M)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/hardsuit/ert/med(M), slot_wear_suit)
			M.equip_to_slot_or_del(W, slot_wear_id)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/medic(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/hud/health(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/medical(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/regular(M), slot_r_hand)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton/loaded(M), slot_in_backpack)

			R.keyslot = new /obj/item/device/encryptionkey/heads/cmo

			if(alert)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/pistol/loyalpin(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/hypospray/combat/nanites(M), slot_in_backpack)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/reagent_containers/hypospray/combat(M), slot_in_backpack)

		if("eng")
			W = new /obj/item/weapon/card/id/ert/Engineer(M)
			M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), slot_w_uniform)
			M.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat/swat(M), slot_shoes)
			M.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(M), slot_gloves)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/hardsuit/ert/engi(M), slot_wear_suit)
			M.equip_to_slot_or_del(W, slot_wear_id)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(M), slot_back)
			M.equip_to_slot_or_del(new /obj/item/clothing/glasses/meson/engine(M), slot_glasses)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/box/engineer(M), slot_in_backpack)
			M.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(M), slot_belt)
			M.equip_to_slot_or_del(new /obj/item/weapon/rcd_ammo/large(M), slot_l_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/melee/baton/loaded(M), slot_in_backpack)

			R.keyslot = new /obj/item/device/encryptionkey/heads/ce

			if(alert)
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer/swat(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/pulse/pistol/loyalpin(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/rcd/combat(M), slot_in_backpack)
			else
				M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/sechailer(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/rcd/loaded(M), slot_in_backpack)

	R.recalculateChannels()

	var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(M)
	L.imp_in = M
	L.implanted = 1
	M.sec_hud_set_implants()

	if (W)
		W.registered_name = M.real_name
		W.update_label(W.registered_name, W.assignment)


/proc/equip_centcomofficial(var/mob/living/carbon/human/M)
	M.equip_to_slot_or_del(new /obj/item/clothing/under/rank/centcom_officer(M), slot_w_uniform)
	M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(M), slot_shoes)
	M.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/black(M), slot_gloves)
	M.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cent(M), slot_ears)
	M.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(M), slot_glasses)
	M.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/gun(M), slot_belt)
	M.equip_to_slot_or_del(new /obj/item/weapon/pen(M), slot_l_store)
	M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(M), slot_back)

	var/obj/item/device/pda/heads/pda = new(M)
	pda.owner = M.real_name
	pda.ownjob = "Centcom Official"
	pda.update_label()

	M.equip_to_slot_or_del(pda, slot_r_store)

	M.equip_to_slot_or_del(new /obj/item/weapon/clipboard(M), slot_l_hand)

	var/obj/item/weapon/card/id/W = new(M)
	W.icon_state = "centcom"
	W.access = get_centcom_access("Centcom Official")
	W.access += access_weapons
	W.assignment = "Centcom Official"
	W.registered_name = M.real_name
	W.update_label()
	M.equip_to_slot_or_del(W, slot_wear_id)
