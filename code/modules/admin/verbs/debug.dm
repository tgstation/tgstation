/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!holder)
		src << "Only administrators may use this command."
		return
	if(holder.rank == "Game Admin")
		Debug2 = !Debug2

		world << "Debugging [Debug2 ? "On" : "Off"]"
		log_admin("[key_name(src)] toggled debugging to [Debug2]")
	else if(holder.rank == "Game Master")
		Debug2 = !Debug2

		world << "Debugging [Debug2 ? "On" : "Off"]"
		log_admin("[key_name(src)] toggled debugging to [Debug2]")
	else
		alert("Coders only baby")
		return
//	feedback_add_details("admin_verb","DG2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



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
	set name = "Advanced ProcCall (TG Version)"
	if(!holder)
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
					target = input("Enter target:","Target",usr) as mob in getmobs()
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
				switch(alert("Would you like to enter a specific object, or search for it from the world?","Choose!","Specifc UID (Hexadecimal number)", "Search"))
					if("Specifc UID (Hexadecimal number)")
						var/UID = input("Type in UID, without the leading 0x","Type in UID") as text|null
						if(!UID) return
						if(length(UID) != 7)
							usr << "ERROR.  UID must be 7 digits"
						var/temp_variable = locate("\[0x[UID]\]")
						if(!temp_variable)
							usr << "ERROR.  Could not locate referenced object."
							return
						switch(alert("You have chosen [temp_variable], in [get_area(temp_variable)].  Are you sure?","You sure?","Yes","NONOCANCEL!"))
							if("Yes")
								lst[i] = temp_variable
							if("NONOCANCEL!")
								return
					if("Search")
						lst[i] = input("Select reference:","Reference") as null|mob|obj|turf|area in world

			if("mob reference")
				lst[i] = input("Select reference:","Reference",usr) as mob in getmobs()

			if("file")
				lst[i] = input("Pick file:","File") as file

			if("icon")
				lst[i] = input("Pick icon:","Icon") as icon

			if("client")
				var/list/keys = list()
				for(var/mob/M in world)
					keys += M.client
				sortList(keys)
				lst[i] = input("Please, select a player!", "Selection", null, null) as null|anything in keys

			if("mob's area")
				var/mob/temp = input("Select mob", "Selection", usr) as mob in getmobs()
				lst[i] = temp.loc


	spawn(0)
		if(target)
			log_admin("[key_name(src)] called [target]'s [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(target,procname)(arglist(lst)) // Pass the lst as an argument list to the proc
		else
			log_admin("[key_name(src)] called [procname]() with [lst.len ? "the arguments [list2params(lst)]":"no arguments"].")
			returnval = call(procname)(arglist(lst)) // Pass the lst as an argument list to the proc
	usr << "\blue Proc returned: [returnval ? returnval : "null"]"

/client/proc/callprocgen()
	set category = "Debug"
	set name = "ProcCall (BS12 Version)"
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	var/class = null
	var/returnval = null
	var/procname = input("Procpath (in full)","path", null)

	var/argNum = input("Number of arguments:","Number",null) as num //input("Arguments","Arguments:", null)
	var/list/argL = new/list()

	var/i
	for(i=0; i<argNum; i++)
		class = input("Type of Argument #[i]","Variable Type", "text") in list("text","num","type","reference","icon","file","marked datum","cancel")
		switch(class)
			if("cancel")
				return

			if("text")
				argL.Add( input("Enter new text:","Text",null) as text )

			if("num")
				argL.Add( input("Enter new number:","Num",null) as num )

			if("type")
				argL.Add( input("Enter type:","Type",null) in typesof(/obj,/mob,/area,/turf) )

			if("reference")
				switch(alert("Would you like to enter a specific object, or search for it from the world?","Choose!","Specifc UID (Hexadecimal number)", "Search"))
					if("Specifc UID (Hexadecimal number)")
						var/UID = input("Type in UID, without the leading 0x","Type in UID") as text|null
						if(!UID) return
						if(length(UID) != 7)
							usr << "ERROR.  UID must be 7 digits"
						var/temp_variable = locate("\[0x[UID]\]")
						if(!temp_variable)
							usr << "ERROR.  Could not locate referenced object."
							return
						switch(alert("You have chosen [temp_variable], in [get_area(temp_variable)].  Are you sure?","You sure?","Yes","NONOCANCEL!"))
							if("Yes")
								argL.Add(temp_variable)
							if("NONOCANCEL!")
								return
					if("Search")
						argL.Add(input("Select reference:","Reference") as null|mob|obj|turf|area in world)

			if("icon")
				argL.Add( input("Pick icon:","Icon",null) as icon )

			if("file")
				argL.Add( input("Pick file:","File",null) as file )

			if("marked datum")
				argL.Add(holder.marked_datum)

	usr << "\blue Calling '[procname]'"
	returnval = call(procname)(arglist(argL))

	usr << "\blue Proc returned: [returnval ? returnval : "null"]"


/client/proc/callprocobj(var/target as obj|mob|area|turf in world)
	set category = "Debug"
	set name = "Object ProcCall (BS12 Version)"
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	var/class = null
	var/returnval = null
	var/procname = input("Procpath (e.g. just \"update\" for lights)","path:", null) as null|text

	if(!procname || procname == "") return

	if(procname == "") return

	var/argNum = input("Number of arguments:","Number",null) as num //input("Arguments","Arguments:", null)
	var/list/argL = new/list()

	var/i
	for(i=0; i<argNum; i++)
		class = input("Type of Argument #[i]","Variable Type", "text") in list("text","num","type","reference","icon","file","marked datum","cancel")
		switch(class)
			if("cancel")
				return

			if("text")
				argL.Add( input("Enter new text:","Text",null) as text )

			if("num")
				argL.Add( input("Enter new number:","Num",null) as num )

			if("type")
				argL.Add( input("Enter type:","Type",null) in typesof(/obj,/mob,/area,/turf) )

			if("reference")
				switch(alert("Would you like to enter a specific object, or search for it from the world?","Choose!","Specifc UID (Hexadecimal number)", "Search"))
					if("Specifc UID (Hexadecimal number)")
						var/UID = input("Type in UID, without the leading 0x","Type in UID") as text|null
						if(!UID) return
						if(length(UID) != 7)
							usr << "ERROR.  UID must be 7 digits"
						var/temp_variable = locate("\[0x[UID]\]")
						if(!temp_variable)
							usr << "ERROR.  Could not locate referenced object."
							return
						switch(alert("You have chosen [temp_variable], in [get_area(temp_variable)].  Are you sure?","You sure?","Yes","NONOCANCEL!"))
							if("Yes")
								argL.Add(temp_variable)
							if("NONOCANCEL!")
								return
					if("Search")
						argL.Add(input("Select reference:","Reference") as null|mob|obj|turf|area in world)

			if("icon")
				argL.Add( input("Pick icon:","Icon",null) as icon )

			if("file")
				argL.Add( input("Pick file:","File",null) as file )

			if("marked datum")
				argL.Add(holder.marked_datum)

	usr << "\blue Calling '[procname]' on '[target]'"
	returnval = call(target,procname)(arglist(argL))

	usr << "\blue Proc returned: [returnval ? returnval : "null"]"


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

/client/proc/cmd_admin_robotize(var/mob/M in world)
	set category = "Fun"
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

/client/proc/makepAI(var/turf/T in world)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a key to play that pAI"

	var/list/available = list()
	for(var/mob/C in world)
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
	card.pai = pai
	for(var/datum/paiCandidate/candidate in paiController.pai_candidates)
		if(candidate.key == choice.key)
			paiController.pai_candidates.Remove(candidate)

/client/proc/cmd_admin_alienize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Alien"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has alienized [M.key].")
		spawn(10)
			M:Alienize()
	else
		alert("Invalid mob")

/client/proc/cmd_admin_metroidize(var/mob/M in world)
	set category = "Fun"
	set name = "Make Metroid"

	if(!ticker)
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has metroidized [M.key].")
		spawn(10)
			M:Metroidize()
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
/client/proc/make_cultist(var/mob/M in world) // -- TLE, modified by Urist
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

/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.", 0)

/client/proc/cmd_debug_tog_aliens()
	set category = "Server"
	set name = "Toggle Aliens"

	aliens_allowed = !aliens_allowed
	log_admin("[key_name(src)] has turned aliens [aliens_allowed ? "on" : "off"].")
	message_admins("[key_name_admin(src)] has turned aliens [aliens_allowed ? "on" : "off"].", 0)

/client/proc/cmd_admin_grantfullaccess(var/mob/M in world)
	set category = "Admin"
	set name = "Grant Full Access"

	if (!ticker)
		alert("Wait until the game starts")
		return
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if (H.wear_id)
			var/obj/item/weapon/card/id/id = H.wear_id
			if(istype(H.wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/pda = H.wear_id
				id = pda.id
			log_admin("[key_name(src)] has granted [M.key] full access.")
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
		else
			var/obj/item/weapon/card/id/id = new/obj/item/weapon/card/id(M);
			log_admin("[key_name(src)] has granted [M.key] full access.")
			id.icon_state = "gold"
			id:access = get_all_accesses()+get_all_centcom_access()+get_all_syndicate_access()
			id.registered_name = H.real_name
			id.assignment = "Captain"
			id.name = "[id.registered_name]'s ID Card ([id.assignment])"
			H.equip_if_possible(id, H.slot_wear_id)
			H.update_clothing()
	else
		alert("Invalid mob")
	//feedback_add_details("admin_verb","GFA") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins("\blue [key_name_admin(usr)] has granted [M.key] full access.", 1)

/client/proc/cmd_assume_direct_control(var/mob/M in world)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(M.ckey)
		if(alert("This mob is being controlled by [M.ckey]. Are you sure you wish to assume control of it? [M.ckey] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer()
			ghost.ckey = M.ckey;
	var/mob/adminmob = src.mob
	M.ckey = src.ckey;
	if( isobserver(adminmob) )
		del(adminmob)
	//feedback_add_details("admin_verb","ADC") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] assumed direct control of [M].")
	message_admins("\blue [key_name_admin(usr)] assumed direct control of [M].", 1)



/client/proc/cmd_admin_dress(var/mob/living/carbon/human/M in world)
	set category = "Fun"
	set name = "Select equipment"
	if(!ishuman(M))
		alert("Invalid mob")
		return
	//log_admin("[key_name(src)] has alienized [M.key].")
	var/list/dresspacks = list(
		"strip",
		"standard space gear",
		"tournament standard red",
		"tournament standard green",
		"tournament gangster",
		"tournament chef",
		"tournament janitor",
		"pirate",
		"space pirate",
		"soviet admiral",
		"tunnel clown",
		"masked killer",
		"assassin",
		"death commando",
		"syndicate commando",
		"response team",
		"centcom official",
		"centcom commander",
		"special ops officer",
		"blue wizard",
		"red wizard",
		"marisa wizard",
		)
	var/dresscode = input("Select dress for [M]", "Robust quick dress shop") as null|anything in dresspacks
	if (isnull(dresscode))
		return
	//feedback_add_details("admin_verb","SEQ") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	for (var/obj/item/I in M)
		if (istype(I, /obj/item/weapon/implant))
			continue
		del(I)
	switch(dresscode)
		if ("strip")
			//do nothing
		if ("standard space gear")
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)

			M.equip_if_possible(new /obj/item/clothing/under/color/grey(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/space(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/space(M), M.slot_head)
			var /obj/item/weapon/tank/jetpack/J = new /obj/item/weapon/tank/jetpack/oxygen(M)
			M.equip_if_possible(J, M.slot_back)
			J.toggle()
			M.equip_if_possible(new /obj/item/clothing/mask/breath(M), M.slot_wear_mask)
			J.Topic(null, list("stat" = 1))
		if ("tournament standard red","tournament standard green") //we think stunning weapon is too overpowered to use it on tournaments. --rastaf0
			if (dresscode=="tournament standard red")
				M.equip_if_possible(new /obj/item/clothing/under/color/red(M), M.slot_w_uniform)
			else
				M.equip_if_possible(new /obj/item/clothing/under/color/green(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)

			M.equip_if_possible(new /obj/item/clothing/suit/armor/vest(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/thunderdome(M), M.slot_head)

			M.equip_if_possible(new /obj/item/weapon/gun/energy/pulse_rifle/destroyer(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/smokebomb(M), M.slot_r_store)


		if ("tournament gangster") //gangster are supposed to fight each other. --rastaf0
			M.equip_if_possible(new /obj/item/clothing/under/det(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)

			M.equip_if_possible(new /obj/item/clothing/suit/storage/det_suit(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/monocle(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/head/det_hat(M), M.slot_head)

			M.equip_if_possible(new /obj/item/weapon/cloaking_device(M), M.slot_r_store)

			M.equip_if_possible(new /obj/item/weapon/gun/projectile(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/ammo_magazine/a357(M), M.slot_l_store)

		if ("tournament chef") //Steven Seagal FTW
			M.equip_if_possible(new /obj/item/clothing/under/rank/chef(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/storage/chef(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/head/chefhat(M), M.slot_head)

			M.equip_if_possible(new /obj/item/weapon/kitchen/rollingpin(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_s_store)

		if ("tournament janitor")
			M.equip_if_possible(new /obj/item/clothing/under/rank/janitor(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			var/obj/item/weapon/storage/backpack/backpack = new(M)
			for(var/obj/item/I in backpack)
				del(I)
			M.equip_if_possible(backpack, M.slot_back)

			M.equip_if_possible(new /obj/item/weapon/mop(M), M.slot_r_hand)
			var/obj/item/weapon/reagent_containers/glass/bucket/bucket = new(M)
			bucket.reagents.add_reagent("water", 70)
			M.equip_if_possible(bucket, M.slot_l_hand)

			M.equip_if_possible(new /obj/item/weapon/chem_grenade/cleaner(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/chem_grenade/cleaner(M), M.slot_l_store)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)
			M.equip_if_possible(new /obj/item/stack/tile/plasteel(M), M.slot_in_backpack)

		if ("pirate")
			M.equip_if_possible(new /obj/item/clothing/under/pirate(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/brown(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/head/bandana(M), M.slot_head)
			M.equip_if_possible(new /obj/item/clothing/glasses/eyepatch(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/weapon/melee/energy/sword/pirate(M), M.slot_r_hand)

		if ("space pirate")
			M.equip_if_possible(new /obj/item/clothing/under/pirate(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/brown(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/suit/space/pirate(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/space/pirate(M), M.slot_head)
			M.equip_if_possible(new /obj/item/clothing/glasses/eyepatch(M), M.slot_glasses)

			M.equip_if_possible(new /obj/item/weapon/melee/energy/sword/pirate(M), M.slot_r_hand)

/*
		if ("soviet soldier")
			M.equip_if_possible(new /obj/item/clothing/under/soviet(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/head/ushanka(M), M.slot_head)
*/

		if("tunnel clown")//Tunnel clowns rule!
			M.equip_if_possible(new /obj/item/clothing/under/rank/clown(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/clown_shoes(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/black(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/clothing/mask/gas/clown_hat(M), M.slot_wear_mask)
			M.equip_if_possible(new /obj/item/clothing/head/chaplain_hood(M), M.slot_head)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/monocle(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/suit/storage/chaplain_hoodie(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/weapon/reagent_containers/food/snacks/grown/banana(M), M.slot_l_store)
			M.equip_if_possible(new /obj/item/weapon/bikehorn(M), M.slot_r_store)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Tunnel Clown!"
			W.registered_name = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

			var/obj/item/weapon/twohanded/fireaxe/fire_axe = new(M)
			M.equip_if_possible(fire_axe, M.slot_r_hand)

		if("masked killer")
			M.equip_if_possible(new /obj/item/clothing/under/overalls(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/white(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/latex(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/clothing/mask/surgical(M), M.slot_wear_mask)
			M.equip_if_possible(new /obj/item/clothing/head/helmet/welding(M), M.slot_head)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/monocle(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/suit/storage/apron(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/weapon/kitchenknife(M), M.slot_l_store)
			M.equip_if_possible(new /obj/item/weapon/scalpel(M), M.slot_r_store)

			var/obj/item/weapon/twohanded/fireaxe/fire_axe = new(M)
			M.equip_if_possible(fire_axe, M.slot_r_hand)

			for(var/obj/item/carried_item in M.contents)
				if(!istype(carried_item, /obj/item/weapon/implant))//If it's not an implant.
					carried_item.add_blood(M)//Oh yes, there will be blood...

		if("assassin")
			M.equip_if_possible(new /obj/item/clothing/under/suit_jacket(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/black(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/sunglasses(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/suit/storage/wcoat(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/weapon/melee/energy/sword(M), M.slot_l_store)
			M.equip_if_possible(new /obj/item/weapon/cloaking_device(M), M.slot_r_store)

			var/obj/item/weapon/secstorage/sbriefcase/sec_briefcase = new(M)
			for(var/obj/item/briefcase_item in sec_briefcase)
				del(briefcase_item)
			for(var/i=3, i>0, i--)
				sec_briefcase.contents += new /obj/item/weapon/spacecash/c1000
			sec_briefcase.contents += new /obj/item/weapon/gun/energy/crossbow
			sec_briefcase.contents += new /obj/item/weapon/gun/projectile/mateba
			sec_briefcase.contents += new /obj/item/ammo_magazine/a357
			sec_briefcase.contents += new /obj/item/weapon/plastique
			M.equip_if_possible(sec_briefcase, M.slot_l_hand)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "Reaper"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, M.slot_belt)

			var/obj/item/weapon/card/id/syndicate/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.access = get_all_accesses()
			W.assignment = "Reaper"
			W.registered_name = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

		if("death commando")//Was looking to add this for a while.
			M.equip_death_commando()

		if("syndicate commando")
			M.equip_syndicate_commando()

		if("response team")
			M.equip_strike_team()

		if("centcom official")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom_officer(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/shoes/black(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/hop(M), M.slot_ears)
			var/obj/item/clothing/suit/storage/armoredundersuit/K = new(M)
			var/obj/item/clothing/glasses/sunglasses/V = new(M)
			V.loc = K
			M.equip_if_possible(K, M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/weapon/gun/energy/gun(M), M.slot_s_store)

			var/obj/item/device/pda/heads/pda = new(M)
			pda.owner = M.real_name
			pda.ownjob = "CentCom Review Official"
			pda.name = "PDA-[M.real_name] ([pda.ownjob])"

			M.equip_if_possible(pda, M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/clipboard(M), M.slot_l_store)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.item_state = "id_inv"
			W.access = get_all_accesses()
			W.access += list("VIP Guest","Custodian","Thunderdome Overseer","Intel Officer","Medical Officer","Death Commando","Research Officer")
			W.assignment = "CentCom Review Official"
			W.registered_name = M.real_name
			W.over_jumpsuit = 0
			M.equip_if_possible(W, M.slot_wear_id)

		if("centcom commander")
			M.equip_if_possible(new /obj/item/clothing/under/rank/centcom_commander(M), M.slot_w_uniform)
			var/obj/item/clothing/suit/storage/armoredundersuit/K = new(M)
			var/obj/item/clothing/glasses/eyepatch/G = new(M)
			G.loc = K
			M.equip_if_possible(K, M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/swat(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/white(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/mask/cigarette/cigar/cohiba(M), M.slot_wear_mask)
			M.equip_if_possible(new /obj/item/clothing/head/centhat(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/gun/projectile/mateba(M), M.slot_s_store)
			M.equip_if_possible(new /obj/item/weapon/lighter/zippo(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/ammo_magazine/a357(M), M.slot_l_store)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "CentCom Commanding Officer"
			W.registered_name = M.real_name
			W.over_jumpsuit = 0
			M.equip_if_possible(W, M.slot_wear_id)

		if("special ops officer")
			M.equip_if_possible(new /obj/item/clothing/under/syndicate/combat(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/storage/officer(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/combat(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/combat(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/eyepatch(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/mask/cigarette/cigar/havana(M), M.slot_wear_mask)
			M.equip_if_possible(new /obj/item/clothing/head/deathsquad/beret(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/gun/energy/pulse_rifle/M1911(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/weapon/lighter/zippo(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack/satchel(M), M.slot_back)

			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Special Operations Officer"
			W.registered_name = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

		if("blue wizard")
			M.equip_if_possible(new /obj/item/clothing/under/lightpurple(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/wizrobe(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/sandal(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/head/wizard(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/teleportation_scroll(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/spellbook(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/staff(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/weapon/storage/box(M), M.slot_in_backpack)

		if("red wizard")
			M.equip_if_possible(new /obj/item/clothing/under/lightpurple(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/wizrobe/red(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/sandal(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/head/wizard/red(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/teleportation_scroll(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/spellbook(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/staff(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/weapon/storage/box(M), M.slot_in_backpack)

		if("marisa wizard")
			M.equip_if_possible(new /obj/item/clothing/under/lightpurple(M), M.slot_w_uniform)
			M.equip_if_possible(new /obj/item/clothing/suit/wizrobe/marisa(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/clothing/shoes/sandal/marisa(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/device/radio/headset(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/head/wizard/marisa(M), M.slot_head)
			M.equip_if_possible(new /obj/item/weapon/teleportation_scroll(M), M.slot_r_store)
			M.equip_if_possible(new /obj/item/weapon/spellbook(M), M.slot_r_hand)
			M.equip_if_possible(new /obj/item/weapon/staff(M), M.slot_l_hand)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack(M), M.slot_back)
			M.equip_if_possible(new /obj/item/weapon/storage/box(M), M.slot_in_backpack)
		if("soviet admiral")
			M.equip_if_possible(new /obj/item/clothing/head/hgpiratecap(M), M.slot_head)
			M.equip_if_possible(new /obj/item/clothing/shoes/combat(M), M.slot_shoes)
			M.equip_if_possible(new /obj/item/clothing/gloves/combat(M), M.slot_gloves)
			M.equip_if_possible(new /obj/item/device/radio/headset/heads/captain(M), M.slot_ears)
			M.equip_if_possible(new /obj/item/clothing/glasses/thermal/eyepatch(M), M.slot_glasses)
			M.equip_if_possible(new /obj/item/clothing/suit/hgpirate(M), M.slot_wear_suit)
			M.equip_if_possible(new /obj/item/weapon/storage/backpack/bandolier(M), M.slot_back)
			M.equip_if_possible(new /obj/item/weapon/gun/projectile/mateba(M), M.slot_belt)
			M.equip_if_possible(new /obj/item/clothing/under/soviet(M), M.slot_w_uniform)
			var/obj/item/weapon/card/id/W = new(M)
			W.name = "[M.real_name]'s ID Card"
			W.icon_state = "centcom"
			W.access = get_all_accesses()
			W.access += get_all_centcom_access()
			W.assignment = "Admiral"
			W.registered_name = M.real_name
			M.equip_if_possible(W, M.slot_wear_id)

	M.update_clothing()

	log_admin("[key_name(usr)] changed the equipment of [key_name(M)] to [dresscode].")
	message_admins("\blue [key_name_admin(usr)] changed the equipment of [key_name_admin(M)] to [dresscode]..", 1)
	return

/client/proc/startSinglo()

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/emitter/E in world)
		if(E.anchored)
			E.active = 1

	for(var/obj/machinery/field_generator/F in world)
		if(F.anchored)
			F.Varedit_start = 1
	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in world)
			if(G.anchored)
				var/obj/machinery/singularity/S = new /obj/machinery/singularity(get_turf(G), 50)
				spawn(0)
					del(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = '224x224.dmi'
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
				var/obj/item/weapon/tank/plasma/Plasma = new/obj/item/weapon/tank/plasma(Rad)
				Plasma.air_contents.toxins = 70
				Rad.drainratio = 0
				Rad.P = Plasma
				Plasma.loc = Rad

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in world)
		if(SMES.anchored)
			SMES.chargemode = 1