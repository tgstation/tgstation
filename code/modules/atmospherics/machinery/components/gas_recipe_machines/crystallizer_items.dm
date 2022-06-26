/obj/item/hypernoblium_crystal
	name = "Hypernoblium Crystal"
	desc = "Crystalized oxygen and hypernoblium to pressureproof your clothes."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "hypernoblium_crystal"
	var/uses = 2

/obj/item/hypernoblium_crystal/afterattack(obj/item/clothing/worn_item, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(worn_item))
		to_chat(user, span_warning("The crystal can only be used on clothing!"))
		return
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
