/datum/bounty/item/alien_organs
	name = "Alien Organs"
	description = "Nanotrasen is interested in studying Xenomorph biology. Ship a set of organs to be thoroughly compensated."
	reward = CARGO_CRATE_VALUE * 50
	required_count = 3
	wanted_types = list(
		/obj/item/organ/brain/alien = TRUE,
		/obj/item/organ/alien = TRUE,
		/obj/item/organ/body_egg/alien_embryo = TRUE,
		/obj/item/organ/liver/alien = TRUE,
		/obj/item/organ/tongue/alien = TRUE,
		/obj/item/organ/eyes/alien = TRUE,
	)

/datum/bounty/item/syndicate_documents
	name = "Syndicate Documents"
	description = "Intel regarding the syndicate is highly prized at CentCom. If you find syndicate documents, ship them. You could save lives."
	reward = CARGO_CRATE_VALUE * 30
	wanted_types = list(
		/obj/item/documents/syndicate = TRUE,
		/obj/item/documents/photocopy = TRUE,
	)

/datum/bounty/item/syndicate_documents/applies_to(obj/O)
	if(!..())
		return FALSE
	if(istype(O, /obj/item/documents/photocopy))
		var/obj/item/documents/photocopy/Copy = O
		return (Copy.copy_type && ispath(Copy.copy_type, /obj/item/documents/syndicate))
	return TRUE

/datum/bounty/item/adamantine
	name = "Adamantine"
	description = "Nanotrasen's anomalous materials division is in desparate need of adamantine. Send them a large shipment and we'll make it worth your while."
	reward = CARGO_CRATE_VALUE * 70
	required_count = 10
	wanted_types = list(/obj/item/stack/sheet/mineral/adamantine = TRUE)

/datum/bounty/item/trash
	name = "Trash"
	description = "Recently a group of janitors have run out of trash to clean up, and CentCom wants to fire them to cut costs. Send a shipment of trash to keep them employed, and they'll give you a small compensation."
	reward = CARGO_CRATE_VALUE * 2
	required_count = 10
	wanted_types = list(/obj/item/trash = TRUE)
