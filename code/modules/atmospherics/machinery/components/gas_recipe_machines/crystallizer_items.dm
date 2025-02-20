/obj/item/hypernoblium_crystal
	name = "Hypernoblium Crystal"
	desc = "Crystallized oxygen and hypernoblium stored in a bottle to pressure-proof your clothes or stop reactions occurring in portable atmospheric devices."
	icon = 'icons/obj/pipes_n_cables/atmos.dmi'
	icon_state = "hypernoblium_crystal"
	var/uses = 1

/obj/item/hypernoblium_crystal/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/obj/machinery/portable_atmospherics/atmos_device = interacting_with
	var/obj/item/clothing/worn_item = interacting_with
	if(!istype(worn_item) && !istype(atmos_device))
		to_chat(user, span_warning("The crystal can only be used on clothing and portable atmospheric devices!"))
		return ITEM_INTERACT_BLOCKING

	if(istype(atmos_device))
		if(atmos_device.nob_crystal_inserted)
			to_chat(user, span_warning("[atmos_device] already has a hypernoblium crystal inserted in it!"))
			return ITEM_INTERACT_BLOCKING
		atmos_device.insert_nob_crystal()
		to_chat(user, span_notice("You insert the [src] into [atmos_device]."))

	if(istype(worn_item))
		if(istype(worn_item, /obj/item/clothing/suit/space))
			to_chat(user, span_warning("The [worn_item] is already pressure-resistant!"))
			return ITEM_INTERACT_BLOCKING
		if(worn_item.min_cold_protection_temperature == SPACE_SUIT_MIN_TEMP_PROTECT && worn_item.clothing_flags & STOPSPRESSUREDAMAGE)
			to_chat(user, span_warning("[worn_item] is already pressure-resistant!"))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_notice("You see how the [worn_item] changes color, it's now pressure proof."))
		worn_item.name = "pressure-resistant [worn_item.name]"
		worn_item.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		worn_item.add_atom_colour(color_transition_filter("#00fff7", SATURATION_OVERRIDE), FIXED_COLOUR_PRIORITY)
		worn_item.min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
		worn_item.cold_protection = worn_item.body_parts_covered
		worn_item.clothing_flags |= STOPSPRESSUREDAMAGE

	uses--
	if(uses <= 0)
		qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/item/nitrium_crystal
	desc = "A weird brown crystal, it smokes when broken"
	name = "nitrium crystal"
	icon = 'icons/obj/pipes_n_cables/atmos.dmi'
	icon_state = "nitrium_crystal"
	var/cloud_size = 1

/obj/item/nitrium_crystal/attack_self(mob/user)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	var/turf/location = get_turf(src)
	create_reagents(5)
	reagents.add_reagent(/datum/reagent/nitrium_low_metabolization, 3)
	reagents.add_reagent(/datum/reagent/nitrium_high_metabolization, 2)
	smoke.attach(location)
	smoke.set_up(cloud_size, holder = src, location = location, carry = reagents, silent = TRUE)
	smoke.start()
	qdel(src)
