//switch this out to use a database at some point
//list of ckey/ real_name and item paths
//gives item to specific people when they join if it can
//for multiple items just add mutliple entries, unless i change it to be a listlistlist
//yes, it has to be an item, you can't pick up nonitems
var/list/CustomItemList = list(
		//    ckey        real_name   item path
	//	list("miniature","Dave Booze",/obj/item/toy/crayonbox)	//screw this i dont want crayons, it's an example okay
	)

/proc/EquipCustomItems(mob/living/carbon/human/M)
	for(var/list/test in CustomItemList)
		if(test[1] == M.ckey && test[2] == M.real_name)
			var/path = test[3]
			var/obj/item/item = new path()
			if(istype(M.back,/obj/item/weapon/storage))
				item.loc = M.back
			else
				for(var/obj/item/weapon/storage/S in M.contents)
					item.loc = S
					return
				message_admins("Attempted to give [M.real_name]([M.key]) a [item] but there was nowhere to put it!")
				M << "You were meant to recieve a [item] but there was nowhere to put it. Sorry. :("