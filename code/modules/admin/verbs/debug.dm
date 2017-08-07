/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))
		return

	if(GLOB.Debug2)
		GLOB.Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		GLOB.Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	SSblackbox.add_details("admin_verb","Toggle Debug Two") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



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
	set waitfor = 0

	if(!check_rights(R_DEBUG)) return

	var/datum/target = null
	var/targetselected = 0
	var/returnval = null

	switch(alert("Proc owned by something?",,"Yes","No"))
		if("Yes")
			targetselected = 1
			var/list/value = vv_get_value(default_class = VV_ATOM_REFERENCE, classes = list(VV_ATOM_REFERENCE, VV_DATUM_REFERENCE, VV_MOB_REFERENCE, VV_CLIENT))
			if (!value["class"] || !value["value"])
				return
			target = value["value"]
		if("No")
			target = null
			targetselected = 0

	var/procname = input("Proc path, eg: /proc/fake_blood","Path:", null) as text|null
	if(!procname)
		return

	//hascall() doesn't support proc paths (eg: /proc/gib(), it only supports "gib")
	var/testname = procname
	if(targetselected)
		//Find one of the 3 possible ways they could have written /proc/PROCNAME
		if(findtext(procname, "/proc/"))
			testname = replacetext(procname, "/proc/", "")
		else if(findtext(procname, "/proc"))
			testname = replacetext(procname, "/proc", "")
		else if(findtext(procname, "proc/"))
			testname = replacetext(procname, "proc/", "")
		//Clear out any parenthesis if they're a dummy
		testname = replacetext(testname, "()", "")

	if(targetselected && !hascall(target,testname))
		to_chat(usr, "<font color='red'>Error: callproc(): type [target.type] has no proc named [procname].</font>")
		return
	else
		var/procpath = text2path(procname)
		if (!procpath)
			to_chat(usr, "<font color='red'>Error: callproc(): proc [procname] does not exist. (Did you forget the /proc/ part?)</font>")
			return
	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(targetselected)
		if(!target)
			to_chat(usr, "<font color='red'>Error: callproc(): owner of proc no longer exists.</font>")
			return
		var/msg = "[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
		log_admin(msg)
		message_admins(msg)
		admin_ticket_log(target, msg)
		returnval = WrapAdminProcCall(target, procname, lst) // Pass the lst as an argument list to the proc
	else
		//this currently has no hascall protection. wasn't able to get it working.
		log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		message_admins("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
		returnval = WrapAdminProcCall(GLOBAL_PROC, procname, lst) // Pass the lst as an argument list to the proc
	. = get_callproc_returnval(returnval, procname)
	if(.)
		to_chat(usr, .)
	SSblackbox.add_details("admin_verb","Advanced ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

GLOBAL_VAR_INIT(AdminProcCaller, null)
GLOBAL_PROTECT(AdminProcCaller)
GLOBAL_VAR_INIT(AdminProcCallCount, 0)
GLOBAL_PROTECT(AdminProcCallCount)

/proc/WrapAdminProcCall(target, procname, list/arguments)
	var/current_caller = GLOB.AdminProcCaller
	var/ckey = usr.client.ckey
	if(current_caller && current_caller != ckey)
		to_chat(usr, "<span class='adminnotice'>Another set of admin called procs are still running, your proc will be run after theirs finish.</span>")
		UNTIL(!GLOB.AdminProcCaller)
		to_chat(usr, "<span class='adminnotice'>Running your proc</span>")
	GLOB.AdminProcCaller = ckey	//if this runtimes, too bad for you
	++GLOB.AdminProcCallCount
	. = world.WrapAdminProcCall(target, procname, arguments)
	if(--GLOB.AdminProcCallCount == 0)
		GLOB.AdminProcCaller = null

//adv proc call this, ya nerds
/world/proc/WrapAdminProcCall(target, procname, list/arguments)
	if(target == GLOBAL_PROC)
		return call(procname)(arglist(arguments))
	else
		return call(target, procname)(arglist(arguments))

/proc/IsAdminAdvancedProcCall()
#ifdef TESTING
	return FALSE
#else
	return usr && usr.client && GLOB.AdminProcCaller == usr.client.ckey
#endif

/client/proc/callproc_datum(datum/A as null|area|mob|obj|turf)
	set category = "Debug"
	set name = "Atom ProcCall"
	set waitfor = 0

	if(!check_rights(R_DEBUG))
		return

	var/procname = input("Proc name, eg: fake_blood","Proc:", null) as text|null
	if(!procname)
		return
	if(!hascall(A,procname))
		to_chat(usr, "<font color='red'>Error: callproc_datum(): type [A.type] has no proc named [procname].</font>")
		return
	var/list/lst = get_callproc_args()
	if(!lst)
		return

	if(!A || !IsValidSrc(A))
		to_chat(usr, "<span class='warning'>Error: callproc_datum(): owner of proc no longer exists.</span>")
		return
	log_admin("[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
	var/msg = "[key_name(src)] called [A]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"]."
	message_admins(msg)
	admin_ticket_log(A, msg)
	SSblackbox.add_details("admin_verb","Atom ProcCall") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	var/returnval = WrapAdminProcCall(A, procname, lst) // Pass the lst as an argument list to the proc
	. = get_callproc_returnval(returnval,procname)
	if(.)
		to_chat(usr, .)



/client/proc/get_callproc_args()
	var/argnum = input("Number of arguments","Number:",0) as num|null
	if(isnull(argnum))
		return

	. = list()
	var/list/named_args = list()
	while(argnum--)
		var/named_arg = input("Leave blank for positional argument. Positional arguments will be considered as if they were added first.", "Named argument") as text|null
		var/value = vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
		if (!value["class"])
			return
		if(named_arg)
			named_args[named_arg] = value["value"]
		else
			. += value["value"]
	if(LAZYLEN(named_args))
		. += named_args

/client/proc/get_callproc_returnval(returnval,procname)
	. = ""
	if(islist(returnval))
		var/list/returnedlist = returnval
		. = "<font color='blue'>"
		if(returnedlist.len)
			var/assoc_check = returnedlist[1]
			if(istext(assoc_check) && (returnedlist[assoc_check] != null))
				. += "[procname] returned an associative list:"
				for(var/key in returnedlist)
					. += "\n[key] = [returnedlist[key]]"

			else
				. += "[procname] returned a list:"
				for(var/elem in returnedlist)
					. += "\n[elem]"
		else
			. = "[procname] returned an empty list"
		. += "</font>"

	else
		. = "<font color='blue'>[procname] returned: [!isnull(returnval) ? returnval : "null"]</font>"


/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/T = mob.loc

	if(!isturf(T))
		return

	var/datum/gas_mixture/env = T.return_air()
	var/list/env_gases = env.gases

	var/t = ""
	for(var/id in env_gases)
		if(id in GLOB.hardcoded_gases || env_gases[id][MOLES])
			t+= "[env_gases[id][GAS_META][META_GAS_NAME]] : [env_gases[id][MOLES]]\n"

	to_chat(usr, t)
	SSblackbox.add_details("admin_verb","Air Status In Location") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		var/mob/living/carbon/human/H = M
		spawn(0)
			H.Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_blobize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Blob"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has blobized [M.key].")
		var/mob/living/carbon/human/H = M
		spawn(0)
			var/mob/camera/blob/B = H.become_overmind(FALSE)
			B.place_blob_core(B.base_point_rate, -1) //place them wherever they are

	else
		alert("Invalid mob")


/client/proc/cmd_admin_animalize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(0)
		M.Animalize()


/client/proc/makepAI(turf/T in GLOB.mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.key)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in available
	if(!choice)
		return 0
	if(!isobserver(choice))
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
	SSblackbox.add_details("admin_verb","Make pAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_alienize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Alien"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(0)
			M:Alienize()
			SSblackbox.add_details("admin_verb","Make Alien") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] made [key_name(M)] into an alien.</span>")
	else
		alert("Invalid mob")

/client/proc/cmd_admin_slimeize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make slime"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has slimeized [M.key].")
		spawn(0)
			M:slimeize()
			SSblackbox.add_details("admin_verb","Make Slime") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a slime.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] made [key_name(M)] into a slime.</span>")
	else
		alert("Invalid mob")

/proc/make_types_fancy(var/list/types)
	if (ispath(types))
		types = list(types)
	. = list()
	for(var/type in types)
		var/typename = "[type]"
		var/static/list/TYPES_SHORTCUTS = list(
			/obj/effect/decal/cleanable = "CLEANABLE",
			/obj/item/device/radio/headset = "HEADSET",
			/obj/item/clothing/head/helmet/space = "SPESSHELMET",
			/obj/item/weapon/book/manual = "MANUAL",
			/obj/item/weapon/reagent_containers/food/drinks = "DRINK", //longest paths comes first
			/obj/item/weapon/reagent_containers/food = "FOOD",
			/obj/item/weapon/reagent_containers = "REAGENT_CONTAINERS",
			/obj/item/weapon = "WEAPON",
			/obj/machinery/atmospherics = "ATMOS_MECH",
			/obj/machinery/portable_atmospherics = "PORT_ATMOS",
			/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack = "MECHA_MISSILE_RACK",
			/obj/item/mecha_parts/mecha_equipment = "MECHA_EQUIP",
			/obj/item/organ = "ORGAN",
			/obj/item = "ITEM",
			/obj/machinery = "MACHINERY",
			/obj/effect = "EFFECT",
			/obj = "O",
			/datum = "D",
			/turf/open = "OPEN",
			/turf/closed = "CLOSED",
			/turf = "T",
			/mob/living/carbon = "CARBON",
			/mob/living/simple_animal = "SIMPLE",
			/mob/living = "LIVING",
			/mob = "M"
		)
		for (var/tn in TYPES_SHORTCUTS)
			if (copytext(typename,1, length("[tn]/")+1)=="[tn]/" /*findtextEx(typename,"[tn]/",1,2)*/ )
				typename = TYPES_SHORTCUTS[tn]+copytext(typename,length("[tn]/"))
				break
		.[typename] = type

/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_list
	if (!pre_generated_list) //init
		pre_generated_list = make_types_fancy(typesof(/atom))
	return pre_generated_list


/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_list
	if (!pre_generated_list) //init
		pre_generated_list = make_types_fancy(sortList(typesof(/datum) - typesof(/atom)))
	return pre_generated_list


/proc/filter_fancy_list(list/L, filter as text)
	var/list/matches = new
	for(var/key in L)
		var/value = L[key]
		if(findtext("[key]", filter) || findtext("[value]", filter))
			matches[key] = value
	return matches

//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all(object as text)
	set category = "Debug"
	set name = "Del-All"

	var/list/matches = get_fancy_list_of_atom_types()
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
			CHECK_TICK
		log_admin("[key_name(src)] has deleted all ([counter]) instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all ([counter]) instances of [hsbitem].", 0)
		SSblackbox.add_details("admin_verb","Delete All") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)
	SSblackbox.add_details("admin_verb","Make Powernets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
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
				if(istype(worn, /obj/item/device/pda))
					worn:id = id
					id.loc = worn
				else if(istype(worn, /obj/item/weapon/storage/wallet))
					worn:front_id = id
					id.loc = worn
					worn.update_icon()
			else
				H.equip_to_slot(id,slot_wear_id)

	else
		alert("Invalid mob")
	SSblackbox.add_details("admin_verb","Grant Full Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] has granted [M.key] full access.</span>")

/client/proc/cmd_assume_direct_control(mob/M in GLOB.mob_list)
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
	SSblackbox.add_details("admin_verb","Assume Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

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

	for(var/obj/machinery/power/apc/APC in GLOB.apcs_list)
		var/area/A = APC.area
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)

	for(var/obj/machinery/airalarm/AA in GLOB.machines)
		var/area/A = get_area(AA)
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)

	for(var/obj/machinery/requests_console/RC in GLOB.machines)
		var/area/A = get_area(RC)
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)

	for(var/obj/machinery/light/L in GLOB.machines)
		var/area/A = get_area(L)
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)

	for(var/obj/machinery/light_switch/LS in GLOB.machines)
		var/area/A = get_area(LS)
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)

	for(var/obj/item/device/radio/intercom/I in GLOB.machines)
		var/area/A = get_area(I)
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)

	for(var/obj/machinery/camera/C in GLOB.machines)
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

	to_chat(world, "<b>AREAS WITHOUT AN APC:</b>")
	for(var/areatype in areas_without_APC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT AN AIR ALARM:</b>")
	for(var/areatype in areas_without_air_alarm)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A REQUEST CONSOLE:</b>")
	for(var/areatype in areas_without_RC)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY LIGHTS:</b>")
	for(var/areatype in areas_without_light)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT A LIGHT SWITCH:</b>")
	for(var/areatype in areas_without_LS)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY INTERCOMS:</b>")
	for(var/areatype in areas_without_intercom)
		to_chat(world, "* [areatype]")

	to_chat(world, "<b>AREAS WITHOUT ANY CAMERAS:</b>")
	for(var/areatype in areas_without_camera)
		to_chat(world, "* [areatype]")

/client/proc/cmd_admin_dress(mob/living/carbon/human/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Select equipment"
	if(!ishuman(M))
		alert("Invalid mob")
		return


	var/list/outfits = list("Naked","Custom","As Job...")
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job)
	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path


	var/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in outfits
	if (isnull(dresscode))
		return

	if (outfits[dresscode])
		dresscode = outfits[dresscode]

	if (dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path

		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in job_outfits
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return


	var/datum/outfit/custom = null
	if (dresscode == "Custom")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Select outfit", "Robust quick dress shop") as null|anything in custom_names
		custom = custom_names[selected_name]
		if(isnull(custom))
			return

	SSblackbox.add_details("admin_verb","Select Equipment") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for (var/obj/item/I in M.get_equipped_items())
		qdel(I)
	switch(dresscode)
		if ("Naked")
			//do nothing
		if ("Custom")
			//use custom one
			M.equipOutfit(custom)
		else
			M.equipOutfit(dresscode)


	M.regenerate_icons()

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode].</span>")

/client/proc/startSinglo()

	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in GLOB.machines)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field/generator/F in GLOB.machines)
		if(F.active == 0)
			F.active = 1
			F.state = 2
			F.power = 250
			F.anchored = TRUE
			F.warming_up = 3
			F.start_fields()
			F.update_icon()

	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in GLOB.machines)
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

	for(var/obj/machinery/power/rad_collector/Rad in GLOB.machines)
		if(Rad.anchored)
			if(!Rad.loaded_tank)
				var/obj/item/weapon/tank/internals/plasma/Plasma = new/obj/item/weapon/tank/internals/plasma(Rad)
				Plasma.air_contents.assert_gas("plasma")
				Plasma.air_contents.gases["plasma"][MOLES] = 70
				Rad.drainratio = 0
				Rad.loaded_tank = Plasma
				Plasma.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in GLOB.machines)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs","Clients","Joined Clients"))
		if("Players")
			to_chat(usr, jointext(GLOB.player_list,","))
		if("Admins")
			to_chat(usr, jointext(GLOB.admins,","))
		if("Mobs")
			to_chat(usr, jointext(GLOB.mob_list,","))
		if("Living Mobs")
			to_chat(usr, jointext(GLOB.living_mob_list,","))
		if("Dead Mobs")
			to_chat(usr, jointext(GLOB.dead_mob_list,","))
		if("Clients")
			to_chat(usr, jointext(GLOB.clients,","))
		if("Joined Clients")
			to_chat(usr, jointext(GLOB.joined_player_list,","))

/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Displays a list of things that have failed to GC this round"

	var/dat = "<B>List of things that failed to GC this round</B><BR><BR>"
	for(var/path in SSgarbage.didntgc)
		dat += "[path] - [SSgarbage.didntgc[path]] times<BR>"

	dat += "<B>List of paths that did not return a qdel hint in Destroy()</B><BR><BR>"
	for(var/path in SSgarbage.noqdelhint)
		dat += "[path]<BR>"

	dat += "<B>List of paths that slept in Destroy()</B><BR><BR>"
	for(var/path in SSgarbage.sleptDestroy)
		dat += "[path]<BR>"

	usr << browse(dat, "window=dellog")

/client/proc/cmd_display_init_log()
	set category = "Debug"
	set name = "Display Initialzie() Log"
	set desc = "Displays a list of things that didn't handle Initialize() properly"

	usr << browse(replacetext(SSatoms.InitLog(), "\n", "<br>"), "window=initlog")

/client/proc/debug_huds(i as num)
	set category = "Debug"
	set name = "Debug HUDs"
	set desc = "Debug the data or antag HUDs"

	if(!holder)
		return
	debug_variables(GLOB.huds[i])

/client/proc/jump_to_ruin()
	set category = "Debug"
	set name = "Jump to Ruin"
	set desc = "Displays a list of all placed ruins to teleport to."
	if(!holder)
		return
	var/list/names = list()
	for(var/i in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = i
		var/datum/map_template/ruin/template = ruin_landmark.ruin_template

		var/count = 1
		var/name = template.name
		var/original_name = name

		while(name in names)
			count++
			name = "[original_name] ([count])"

		names[name] = ruin_landmark

	var/ruinname = input("Select ruin", "Jump to Ruin") as null|anything in names


	var/obj/effect/landmark/ruin/landmark = names[ruinname]

	if(istype(landmark))
		var/datum/map_template/ruin/template = landmark.ruin_template
		usr.forceMove(get_turf(landmark))
		to_chat(usr, "<span class='name'>[template.name]</span>")
		to_chat(usr, "<span class='italics'>[template.description]</span>")

/client/proc/clear_dynamic_transit()
	set category = "Debug"
	set name = "Clear Dynamic Transit"
	set desc = "Deallocates all transit space, restoring it to round start conditions."
	if(!holder)
		return
	SSshuttle.clear_transit = TRUE
	message_admins("<span class='adminnotice'>[key_name_admin(src)] cleared dynamic transit space.</span>")
	SSblackbox.add_details("admin_verb","Clear Dynamic Transit") // If...
	log_admin("[key_name(src)] cleared dynamic transit space.")


/client/proc/toggle_medal_disable()
	set category = "Debug"
	set name = "Toggle Medal Disable"
	set desc = "Toggles the safety lock on trying to contact the medal hub."
	if(!holder)
		return

	global.medals_enabled = !global.medals_enabled

	message_admins("<span class='adminnotice'>[key_name_admin(src)] [global.medals_enabled ? "disabled" : "enabled"] the medal hub lockout.</span>")
	SSblackbox.add_details("admin_verb","Toggle Medal Disable") // If...
	log_admin("[key_name(src)] [global.medals_enabled ? "disabled" : "enabled"] the medal hub lockout.")

/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the runtime Viewer"

	if(!holder)
		return

	GLOB.error_cache.show_to(src)

/client/proc/pump_random_event()
	set category = "Debug"
	set name = "Pump Random Event"
	set desc = "Schedules the event subsystem to fire a new random event immediately. Some events may fire without notification."
	if(!holder)
		return

	SSevents.scheduled = world.time

	message_admins("<span class='adminnotice'>[key_name_admin(src)] pumped a random event.</span>")
	SSblackbox.add_details("admin_verb","Pump Random Event")
	log_admin("[key_name(src)] pumped a random event.")
