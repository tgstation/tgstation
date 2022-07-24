/obj/item/storage/alert_safe
	name = "alert safe"
	desc = "A wall-mounted safe containing emergency supplies. Will only unlock during Red Alert."

	anchored = TRUE
	density = FALSE // Because it's a wallmount.

	icon = 'icons/obj/alert_safe.dmi'
	icon_state = "alertsafe"

	/// The Station Alert Level the locker is currently set to. This string is used to automatically select the icon_state for the alert level display on the safe.
	var/alert_level = "green"

MAPPING_DIRECTIONAL_HELPERS(/obj/item/storage/alert_safe, 32)

/obj/item/storage/alert_safe/Initialize(mapload)
	. = ..()
	RegisterSignal(SSsecurity_level, COMSIG_SECURITY_LEVEL_CHANGED, .proc/alert_level_update)
	alert_level_update()

	atom_storage.animated = FALSE

/obj/item/storage/alert_safe/update_overlays()
	. = ..()

	. += "overlay_[alert_level]"
	. += emissive_appearance(icon, "overlay_[alert_level]")

	if(atom_storage.locked)
		. += "alertsafe_locked"
		. += emissive_appearance(icon, "alertsafe_unlocked")

	else
		. += "alertsafe_unlocked"
		. += emissive_appearance(icon, "alertsafe_locked")

		if(SSsecurity_level.get_current_level_as_number()  >= SEC_LEVEL_DELTA)
			. += "detailing_flashing"
			. += emissive_appearance(icon, "detailing_flashing")
		else
			. += "detailing"
			. += emissive_appearance(icon, "detailing")

// This proc is called every time the Alert Level gets updated. It determines whether the current Level should unlock the safe, and prepares it to get a new overlay for the Alert Level.
/obj/item/storage/alert_safe/proc/alert_level_update()
	SIGNAL_HANDLER

	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		atom_storage.locked = FALSE
	else
		atom_storage.locked = TRUE
		atom_storage.close_all()

	alert_level = SSsecurity_level.get_current_level_as_text()
	update_appearance()

/obj/item/storage/alert_safe/PopulateContents()
	..()

	new /obj/item/clothing/head/helmet/space/orange(src)
	new /obj/item/clothing/head/helmet/space/orange(src)

	new /obj/item/clothing/suit/space/orange(src)
	new /obj/item/clothing/suit/space/orange(src)

	new /obj/item/clothing/mask/gas(src)
	new /obj/item/clothing/mask/gas(src)

	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/tank/internals/oxygen/red(src)

	new /obj/item/pickaxe/emergency(src)
	new /obj/item/pickaxe/emergency(src)

	new /obj/item/bodybag/environmental(src)
	new /obj/item/bodybag/environmental(src)
	new /obj/item/bodybag/environmental(src)

	new /obj/item/survivalcapsule(src)
	new /obj/item/storage/toolbox/emergency(src)

// If the Alert Safe moves on a shuttle (like an escape pod), it will unlock. Ignores the movement of the shuttle from the transit level to the station level while loading in.
/obj/item/storage/alert_safe/afterShuttleMove(turf/oldT, list/movement_force, shuttle_dir, shuttle_preferred_direction, move_dir, rotation)
	. = ..()
	if (oldT && !is_reserved_level(oldT.z))
		atom_storage.locked = FALSE
		update_appearance()
