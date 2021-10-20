/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."
	firing_effect_type = null
	heavy_metal = FALSE

/obj/item/ammo_casing/caseless/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread, atom/fired_from)
	if (!..()) //failed firing
		return FALSE
	if(istype(fired_from, /obj/item/gun))
		var/obj/item/gun/shot_from = fired_from
		if(shot_from.chambered == src)
			shot_from.chambered = null //Nuke it. Nuke it now.
	qdel(src)
	return TRUE

/obj/item/ammo_casing/caseless/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)]"
