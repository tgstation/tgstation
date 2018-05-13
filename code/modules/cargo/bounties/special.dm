/datum/bounty/item/alien_organs
	name = "Alien Organs"
	description = "Nanotrasen is interested in studying Xenomorph biology. Ship a set of organs and you will be thouroughly compensated."
	reward = 25000
	required_count = 3
	wanted_types = list(/obj/item/organ/brain/alien, /obj/item/organ/alien, /obj/item/organ/body_egg/alien_embryo)

/datum/bounty/item/syndicate_documents
	name = "Syndicate Documents"
	description = "Intel regarding the syndicate is highly prized at CentCom. If you find syndicate documents, ship them. You could save lives."
	reward = 10000
	wanted_types = list(/obj/item/documents/syndicate, /obj/item/documents/photocopy)

/datum/bounty/item/syndicate_documents/applies_to(obj/O)
	if(!..())
		return FALSE
	if(istype(O, /obj/item/documents/photocopy))
		var/obj/item/documents/photocopy/Copy = O
		return (Copy.copy_type && ispath(Copy.copy_type, /obj/item/documents/syndicate))
	return TRUE
