/obj/item/device/guncrafting/module
	name = "Prototype Weapon Module {ENERGY}"
	desc = "A module designed to be installed into a prototype gun. Doesn't seem to do much, though."
	icon = 'icons/obj/guncrafting/modules'
	icon_state = "default"
	item_state = ""
	w_class = 2
	var/requires_processing = 0
	var/projectile_name_append = ""	//Projectile name appends
	var/gun_name_append = ""	//Forced gun name appends

/obj/item/device/guncrafting/module/process()
	return TRUE

/obj/item/device/guncrafting/module/on_hit(atom/target, blocked)
	return TRUE

/obj/item/device/guncrafting/module/on_fire(atom/target, mob/living/user, params, distro, quiet, zone_override, spread)
	return TRUE

/obj/item/device/guncrafting/module/on_range(turf/T)
	return FALSE

/obj/item/device/guncrafting/module/check_volume()
	return 0

/obj/item/device/guncrafting/module/check_spread()
	return 0

