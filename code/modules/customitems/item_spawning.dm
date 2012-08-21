//switch this out to use a database at some point
//list of ckey/ real_name and item paths
//gives item to specific people when they join if it can
//for multiple items just add mutliple entries, unless i change it to be a listlistlist
//yes, it has to be an item, you can't pick up nonitems

/proc/EquipCustomItems(mob/living/carbon/human/M)
	// load lines
	var/file = file2text("config/custom_items.txt")
	var/lines = dd_text2list(file, "\n")

	for(var/line in lines)
		// split & clean up
		var/list/Entry = dd_text2list(line, ":")
		for(var/i = 1 to Entry.len)
			Entry[i] = trim(Entry[i])

		if(Entry.len < 3)
			continue;

		if(Entry[1] == M.ckey && Entry[2] == M.real_name)
			var/list/Paths = dd_text2list(Entry[3], ",")
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
						//I.over_jumpsuit = C.over_jumpsuit
						//I.blood_type = C.blood_type
						//I.dna_hash = C.dna_hash
						//I.fingerprint_hash = C.fingerprint_hash
						//I.pin = C.pin

						//custom stuff
						if(M.ckey == "fastler" && M.real_name == "Fastler Greay") //This is a Lifetime ID
							I.name = "[M.real_name]'s Lifetime ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
						else if(M.ckey == "nerezza" && M.real_name == "Asher Spock") //This is an Odysseus Specialist ID
							I.name = "[M.real_name]'s Odysseus Specialist ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
							I.access += list(access_robotics) //Station-based mecha pilots need this to access the recharge bay.

						//replace old ID
						del(C)
						ok = M.equip_to_slot_or_del(I, slot_wear_id)	//if 1, last argument deletes on fail
						break
				else if(istype(M.back,/obj/item/weapon/storage) && M.back:contents.len < M.back:storage_slots) // Try to place it in something on the mob's back
					Item.loc = M.back
					ok = 1

				else
					for(var/obj/item/weapon/storage/S in M.contents) // Try to place it in any item that can store stuff, on the mob.
						if (S:len < S:storage_slots)
							Item.loc = S
							ok = 1
							break

				skip:
				if (ok == 0) // Finally, since everything else failed, place it on the ground
					Item.loc = get_turf(M.loc)