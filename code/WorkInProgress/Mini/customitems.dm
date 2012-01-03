//switch this out to use a database at some point
//list of ckey/ real_name and item paths
//gives item to specific people when they join if it can
//for multiple items just add mutliple entries, unless i change it to be a listlistlist
//yes, it has to be an item, you can't pick up nonitems
var/list/CustomItemList = list(
		//    ckey        real_name   item path
	//	list("miniature","Dave Booze",/obj/item/toy/crayonbox)	//screw this i dont want crayons, it's an example okay
	list("skymarshal", "Phillip Oswald", /obj/item/weapon/coin/silver),	//Phillip likes to chew on cigars.  Just unlit cigars, don't ask me why.  Must be a clone thing.  (Cigarette machines dispense cigars if they have a coin in them)  --SkyMarshal
	list("spaceman96", "Trenna Seber", /obj/item/weapon/pen/multi),	//For Spesss.
	list("asanadas", "Book Berner", /obj/item/clothing/under/chameleon/psyche)
	)

/proc/EquipCustomItems(mob/living/carbon/human/M)
	for(var/list/Entry in CustomItemList)
		if(Entry[1] == M.ckey && Entry[2] == M.real_name)
			var/ok = 0  // 1 if the item was placed successfully
			var/path = Entry[3]
			var/obj/item/Item = new path()

			if(istype(M.back,/obj/item/weapon/storage) && M.back:contents.len < M.back:storage_slots) // Try to place it in something on the mob's back first
				Item.loc = M.back
				ok = 1
			else
				for(var/obj/item/weapon/storage/S in M.contents) // Try to place it in any item that can store stuff, on the mob.
					if (S:len < S:storage_slots)
						Item.loc = S
						ok = 1
						break

			if (ok == 0) // Finally, since everything else failed, place it on the ground
				Item.loc = get_turf(M.loc)