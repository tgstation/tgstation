/datum/driver
	VAR_PROTECTED/obj/item/modular_computer/hardware

/datum/driver/New(obj/item/modular_computer/computer)
	. = ..()
	hardware = computer

/datum/driver/Destroy(force)
	. = ..()
	hardware = null
