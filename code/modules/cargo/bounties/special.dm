/datum/bounty/item/alien_organs
	name = "Alien Organs"
	description = "Nanotrasen is interested in studying Xenomorph biology. Ship a set of organs to be thoroughly compensated."
	reward = CARGO_CRATE_VALUE * 50
	required_count = 3
	wanted_types = list(/obj/item/organ/brain/alien, /obj/item/organ/alien, /obj/item/organ/body_egg/alien_embryo, /obj/item/organ/liver/alien, /obj/item/organ/tongue/alien, /obj/item/organ/eyes/night_vision/alien)

/datum/bounty/item/syndicate_documents
	name = "Syndicate Documents"
	description = "Intel regarding the syndicate is highly prized at CentCom. If you find syndicate documents, ship them. You could save lives."
	reward = CARGO_CRATE_VALUE * 30
	wanted_types = list(/obj/item/documents/syndicate, /obj/item/documents/photocopy)

/datum/bounty/item/syndicate_documents/applies_to(obj/O)
	if(!..())
		return FALSE
	if(istype(O, /obj/item/documents/photocopy))
		var/obj/item/documents/photocopy/Copy = O
		return (Copy.copy_type && ispath(Copy.copy_type, /obj/item/documents/syndicate))
	return TRUE

/datum/bounty/item/adamantine
	name = "Adamantine"
	description = "Nanotrasen's anomalous materials division is in desparate need for Adamantine. Send them a large shipment and we'll make it worth your while."
	reward = CARGO_CRATE_VALUE * 70
	required_count = 10
	wanted_types = list(/obj/item/stack/sheet/mineral/adamantine)

/datum/bounty/item/trash
	name = "Trash"
	description = "Recently a group of janitors have run out of trash to clean up, without any trash CentCom wants to fire them to cut costs. Send a shipment of trash to keep them employed, and they'll give you a small compensation."
	reward = CARGO_CRATE_VALUE * 2
	required_count = 10
	wanted_types = list(/obj/item/trash)
