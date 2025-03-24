///Regular lockbox
/datum/storage/lockbox
	max_total_storage = 14
	max_slots = 4

///Medal lockbox
/datum/storage/lockbox/medal
	max_slots = 10
	max_total_storage = 20
	max_specific_storage = WEIGHT_CLASS_SMALL

/datum/storage/lockbox/medal/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/clothing/accessory/medal)

///Bit running lockbox
/datum/storage/lockbox/bitrunning
	max_specific_storage = WEIGHT_CLASS_NORMAL
	max_slots = 1
	max_total_storage = 3
	locked = STORAGE_NOT_LOCKED

///Dueling lockbox
/datum/storage/lockbox/dueling
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_slots = 2

/datum/storage/lockbox/dueling/New(atom/parent, max_slots, max_specific_storage, max_total_storage)
	. = ..()

	set_holdable(/obj/item/gun/energy/dueling)
