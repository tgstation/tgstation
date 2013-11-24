
/proc/EquipCustomItems(mob/living/carbon/human/M)
	testing("\[CustomItem\] Checking for custom items for [M.ckey] ([M.real_name])...")
	if(!establish_db_connection())
		return

	// SCHEMA
	/**
	* CustomUserItems
	*
	* cuiCKey VARCHAR(36) NOT NULL,
	* cuiRealName VARCHAR(60) NOT NULL,
	* cuiPath VARCHAR(255) NOT NULL,
	* cuiDescription TEXT NOT NULL,
	* cuiReason TEXT NOT NULL,
	* cuiPropAdjust TEXT NOT NULL,
	* cuiJobMask TEXT NOT NULL,
	* PRIMARY KEY(cuiCkey,cuiRealName,cuiPath)
	*/

	// Grab the info we want.
	var/DBQuery/query = dbcon.NewQuery("SELECT cuiPath, cuiPropAdjust, cuiJobMask FROM CustomUserItems WHERE cuiCKey='[M.ckey]' AND (cuiRealName='[M.real_name]' OR cuiRealName='*')")
	query.Execute()

	while(query.NextRow())
		var/path = text2path(query.item[1])
		var/propadjust = query.item[2]
		var/jobmask = query.item[3]
		testing("\[CustomItem\] Setting up [path] for [M.ckey] ([M.real_name]).  jobmask=[jobmask];propadjust=[propadjust]")
		var/ok=0
		if(jobmask!="*")
			var/allowed_jobs = text2list(jobmask,",")
			var/alt_blocked=0
			if(M.mind.role_alt_title)
				if(!(M.mind.role_alt_title in allowed_jobs))
					alt_blocked=1
			if(!(M.mind.assigned_role in allowed_jobs) || alt_blocked)
				testing("Failed to apply custom item for [M.ckey]: Role(s) [M.mind.assigned_role][M.mind.role_alt_title ? " (nor "+M.mind.role_alt_title+")" : ""] are not in allowed_jobs ([english_list(allowed_jobs)])")
				continue


		var/obj/item/Item = new path()
		testing("Adding new custom item [query.item[1]] to [key_name_admin(M)]...")
		if(istype(Item,/obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/I = Item
			for(var/obj/item/weapon/card/id/C in M)
				//default settings
				I.name = "[M.real_name]'s ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
				I.registered_name = M.real_name
				I.access = C.access
				I.assignment = C.assignment
				I.blood_type = C.blood_type
				I.dna_hash = C.dna_hash
				I.fingerprint_hash = C.fingerprint_hash
				//I.pin = C.pin
				//replace old ID
				del(C)
				ok = M.equip_if_possible(I, slot_wear_id, 0)	//if 1, last argument deletes on fail
				break
			testing("Replaced ID!")
		else if(istype(M.back,/obj/item/weapon/storage) && M.back:contents.len < M.back:storage_slots) // Try to place it in something on the mob's back
			Item.loc = M.back
			ok = 1
			testing("Added to [M.back.name]!")
			M << "\blue Your [Item.name] has been added to your [M.back.name]."
		else
			for(var/obj/item/weapon/storage/S in M.contents) // Try to place it in any item that can store stuff, on the mob.
				if (S.contents.len < S.storage_slots)
					Item.loc = S
					ok = 1
					testing("Added to [S]!")
					M << "\blue Your [Item.name] has been added to your [S.name]."
					break

		//skip:
		if (ok == 0) // Finally, since everything else failed, place it on the ground
			testing("Plopped onto the ground!")
			Item.loc = get_turf(M.loc)

		HackProperties(Item,propadjust)


// This is hacky, but since it's difficult as fuck to make a proper parser in BYOND without killing the server, here it is. - N3X
/proc/HackProperties(var/mob/living/carbon/human/M,var/obj/item/I,var/script)
	/*
	A=string:b lol {REALNAME} {ROLE} {ROLE_ALT};
	B=icon:icons/dmi/lol.dmi:STATE;
	B=number:29;
	*/
	var/list/statements=text2list(script,";")
	if(statements.len==0)
		return // Don't even bother.
	for(var/statement in statements)
		var/list/assignmentChunks = text2list(statement,"=")
		var/varname = assignmentChunks[1]
		//var/operator = "="

		var/list/typeChunks=text2list(script,":")
		var/desiredType=typeChunks[1]
		//var/value
		switch(desiredType)
			if("string")
				var/output = typeChunks[2]
				output = replacetext(output,"{REALNAME}", M.real_name)
				output = replacetext(output,"{ROLE}",     M.mind.assigned_role)
				output = replacetext(output,"{ROLE_ALT}", "[M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role]")
				I.vars[varname]=output
			if("number")
				I.vars[varname]=text2num(typeChunks[2])
			if("icon")
				if(typeChunks.len==2)
					I.vars[varname]=new /icon(typeChunks[2])
				if(typeChunks.len==3)
					I.vars[varname]=new /icon(typeChunks[2],typeChunks[3])



//switch this out to use a database at some point
//list of ckey/ real_name and item paths
//gives item to specific people when they join if it can
//for multiple items just add mutliple entries, unless i change it to be a listlistlist
//yes, it has to be an item, you can't pick up nonitems
/* Old as fuck, not SQL-based, hardcoded keys.
/proc/EquipCustomItems(mob/living/carbon/human/M)
	// load lines
	var/file = file2text("config/custom_items.txt")
	var/lines = text2list(file, "\n")

	for(var/line in lines)
		// split & clean up
		var/list/Entry = text2list(line, ":")
		for(var/i = 1 to Entry.len)
			Entry[i] = trim(Entry[i])

		if(Entry.len < 3)
			continue;

		if(Entry[1] == M.ckey && Entry[2] == M.real_name)
			var/list/Paths = text2list(Entry[3], ",")
			for(var/P in Paths)
				var/ok = 0  // 1 if the item was placed successfully
				P = trim(P)
				var/path = text2path(P)
				var/obj/item/Item = new path()
				if(istype(Item,/obj/item/weapon/card/id))
					//id card needs to replace the original ID
					if(M.ckey == "nerezza" && M.real_name == "Asher Spock" && M.mind.role_alt_title && M.mind.role_alt_title != "Emergency Physician")
						//only spawn ID if asher is joining as an emergency physician
						ok = 1
						del(Item)
						goto skip
					var/obj/item/weapon/card/id/I = Item
					for(var/obj/item/weapon/card/id/C in M)
						//default settings
						I.name = "[M.real_name]'s ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
						I.registered_name = M.real_name
						I.access = C.access
						I.assignment = C.assignment
						I.blood_type = C.blood_type
						I.dna_hash = C.dna_hash
						I.fingerprint_hash = C.fingerprint_hash
						//I.pin = C.pin

						//custom stuff
						if(M.ckey == "fastler" && M.real_name == "Fastler Greay") //This is a Lifetime ID
							I.name = "[M.real_name]'s Lifetime ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
						else if(M.ckey == "nerezza" && M.real_name == "Asher Spock") //This is an Odysseus Specialist ID
							I.name = "[M.real_name]'s Odysseus Specialist ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
							I.access += list(access_robotics) //Station-based mecha pilots need this to access the recharge bay.
						else if(M.ckey == "roaper" && M.real_name == "Ian Colm") //This is a Technician ID
							I.name = "[M.real_name]'s Technician ID ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"

						//replace old ID
						del(C)
						ok = M.equip_if_possible(I, slot_wear_id, 0)	//if 1, last argument deletes on fail
						break
				else if(istype(M.back,/obj/item/weapon/storage) && M.back:contents.len < M.back:storage_slots) // Try to place it in something on the mob's back
					Item.loc = M.back
					ok = 1

				else
					for(var/obj/item/weapon/storage/S in M.contents) // Try to place it in any item that can store stuff, on the mob.
						if (S.contents.len < S.storage_slots)
							Item.loc = S
							ok = 1
							break

				skip:
				if (ok == 0) // Finally, since everything else failed, place it on the ground
					Item.loc = get_turf(M.loc)
*/
