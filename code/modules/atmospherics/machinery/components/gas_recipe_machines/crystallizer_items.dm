/obj/item/hypernoblium_crystal
	name = "Hypernoblium Crystal"
	desc = "Crystalized oxygen and hypernoblium stored in a bottle that can turn the SM offline or stop reactions occuring in portable atmospheric devices."
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "hypernoblium_crystal"

/obj/item/hypernoblium_crystal/afterattack(obj/target_object, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	var/obj/machinery/portable_atmospherics/atmos_device = target_object
	if(istype(atmos_device))
		if(atmos_device.nob_crystal_inserted)
			to_chat(user, span_warning("[atmos_device] already has a hypernoblium crystal inserted in it!"))
			return
		atmos_device.nob_crystal_inserted = TRUE
		to_chat(user, span_notice("You insert the [src] into [atmos_device]."))
	if(!istype(atmos_device))
		to_chat(user, span_warning("The crystal can only be used on the SM or portable atmospheric devices!"))
		return
