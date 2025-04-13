///Normal lockbox
/datum/storage/lockbox
	max_total_storage = 14
	max_slots = 4

/datum/storage/lockbox/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_locked(STORAGE_FULLY_LOCKED)

///Medal lockbox
/datum/storage/lockbox/medal
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_slots = 10
	max_total_storage = 20

/datum/storage/lockbox/medal/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/clothing/accessory/medal)

///Dueling lockbox
/datum/storage/lockbox/dueling
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_slots = 2

/datum/storage/lockbox/dueling/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()
	set_holdable(/obj/item/gun/energy/dueling)

///Bitrunning decrypted lockbox
/datum/storage/lockbox/bitrunning_decrypted
	max_slots = 1
	max_total_storage = 3
	locked = STORAGE_NOT_LOCKED


