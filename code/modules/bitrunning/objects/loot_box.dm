/obj/item/storage/lockbox/bitrunning
	name = "base class curiosity"
	desc = "Talk to a coder."
	req_access = list(ACCESS_INACCESSIBLE)
	icon_state = "bitrunning+l"
	inhand_icon_state = "bitrunning"
	base_icon_state = "bitrunning"
	icon_locked = "bitrunning+l"
	icon_closed = "bitrunning"
	icon_broken = "bitrunning+b"
	icon_open = "bitrunning"

/obj/item/storage/lockbox/bitrunning/encrypted
	name = "encrypted curiosity"
	desc = "Needs to be decrypted at the safehouse to be opened."
	resistance_flags =  INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Path for the loot we are assigned
	var/loot_path

/obj/item/storage/lockbox/bitrunning/encrypted/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE

/obj/item/storage/lockbox/bitrunning/decrypted
	name = "decrypted curiosity"
	desc = "Compiled from the virtual domain. An extra reward of a successful bitrunner."
	/// What virtual domain did we come from.
	var/datum/lazy_template/virtual_domain/source_domain

/obj/item/storage/lockbox/bitrunning/decrypted/Initialize(
	mapload,
	datum/lazy_template/virtual_domain/completed_domain,
	)

	if(isnull(completed_domain))
		log_runtime("Decrypted curiosity was created with no source domain.")
		return INITIALIZE_HINT_QDEL

	if(!istype(completed_domain, /datum/lazy_template/virtual_domain)) // Check if this is a proper virtual domain before doing anything with it
		log_runtime("Decrypted curiosity was created with an invalid source domain. [completed_domain.name] ([completed_domain.type]).")
		return INITIALIZE_HINT_QDEL

	source_domain = completed_domain

	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_slots = 1
	atom_storage.max_total_storage = 3
	atom_storage.locked = STORAGE_NOT_LOCKED
	icon_state = icon_closed
	playsound(src, 'sound/magic/blink.ogg', 50, TRUE)

/obj/item/storage/lockbox/bitrunning/decrypted/PopulateContents()
	var/choice = SSbitrunning.pick_secondary_loot(source_domain)
	new choice(src)
