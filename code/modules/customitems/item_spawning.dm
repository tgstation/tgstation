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

				if(istype(M.back,/obj/item/weapon/storage) && M.back:contents.len < M.back:storage_slots) // Try to place it in something on the mob's back first
					Item.loc = M.back
					ok = 1
				else if(istype(Item,/obj/item/weapon/card/id)) //player wants a custom ID card - only lifetime cards for now (Nerezza: Not anymore! Custom IDs will be handled differently depending on whose it is. Make sure to note what it is.)
					if(M.ckey == "fastler" && M.real_name == "Fastler Greay") //This is a Lifetime ID
						var/obj/item/weapon/card/id/I = Item
						for(var/obj/item/weapon/card/id/C in M)
							I.registered_name = M.real_name
							I.name = "[M.real_name]'s Lifetime ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
							I.access = C.access
							I.assignment = C.assignment
							I.over_jumpsuit = C.over_jumpsuit
							I.blood_type = C.blood_type
							I.dna_hash = C.dna_hash
							I.fingerprint_hash = C.fingerprint_hash
							//
							I.loc = C.loc
							ok = 1
							del(C)
							break
					if(M.ckey == "nerezza" && M.real_name == "Asher Spock") //This is an Odysseus Specialist ID
						var/obj/item/weapon/card/id/I = Item
						if(M.mind.role_alt_title && M.mind.role_alt_title == "Emergency Physician") //Only spawn if the character is an emergency physician.
							for(var/obj/item/weapon/card/id/C in M)
								I.registered_name = M.real_name
								I.name = "[M.real_name]'s Odysseus Specialist ID Card ([M.mind.role_alt_title ? M.mind.role_alt_title : M.mind.assigned_role])"
								I.access = C.access
								I.access += list(ACCESS_ROBOTICS) //Station-based mecha pilots need this to access the recharge bay.
								I.assignment = C.assignment
								I.over_jumpsuit = C.over_jumpsuit
								I.blood_type = C.blood_type
								I.dna_hash = C.dna_hash
								I.fingerprint_hash = C.fingerprint_hash
								//
								I.loc = C.loc
								ok = 1
								del(C)
								break
						else //Was not the right job position, gotta delete the custom item.
							del(I)
				else
					for(var/obj/item/weapon/storage/S in M.contents) // Try to place it in any item that can store stuff, on the mob.
						if (S:len < S:storage_slots)
							Item.loc = S
							ok = 1
							break

				if (ok == 0) // Finally, since everything else failed, place it on the ground
					Item.loc = get_turf(M.loc)