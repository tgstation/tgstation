/obj/item/hypernoblium_crystal
	name = "Hypernoblium Crystal"
	desc = "Crystalized oxygen and hypernoblium stored in a bottle to pressureproof your clothes or stop reactions occuring in portable atmospheric devices."
	icon = 'icons/obj/atmospherics/atmos.dmi'
	icon_state = "hypernoblium_crystal"
	var/uses = 1

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
	var/obj/item/clothing/worn_item = target_object
	if(!istype(worn_item) && !istype(atmos_device))
		to_chat(user, span_warning("The crystal can only be used on clothing and portable atmospheric devices!"))
		return
	if(istype(worn_item))
		if(istype(worn_item, /obj/item/clothing/suit/space))
			to_chat(user, span_warning("The [worn_item] is already pressure-resistant!"))
			return
		if(worn_item.min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT && worn_item.clothing_flags & STOPSPRESSUREDAMAGE)
			to_chat(user, span_warning("[worn_item] is already pressure-resistant!"))
			return
		to_chat(user, span_notice("You see how the [worn_item] changes color, it's now pressure proof."))
		worn_item.name = "pressure-resistant [worn_item.name]"
		worn_item.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		worn_item.add_atom_colour("#00fff7", FIXED_COLOUR_PRIORITY)
		worn_item.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		worn_item.cold_protection = worn_item.body_parts_covered
		worn_item.clothing_flags |= STOPSPRESSUREDAMAGE
	uses--
	if(!uses)
		qdel(src)
