/obj/projectile/bullet/foam_dart
	name = "foam dart"
	desc = "I hope you're wearing eye protection."
	damage = 0 // It's a damn toy.
	damage_type = OXY
	icon = 'icons/obj/weapons/guns/toy.dmi'
	icon_state = "foamdart_proj"
	base_icon_state = "foamdart"
	range = 10
	shrapnel_type = null
	embed_type = null
	var/modified = FALSE
	var/obj/item/pen/pen = null

/obj/projectile/bullet/foam_dart/Initialize(mapload)
	. = ..()
	RegisterSignals(src, list(COMSIG_PROJECTILE_ON_SPAWN_DROP, COMSIG_PROJECTILE_ON_SPAWN_EMBEDDED), PROC_REF(handle_drop))

/obj/projectile/bullet/foam_dart/proc/handle_drop(datum/source, obj/item/ammo_casing/foam_dart/newcasing)
	SIGNAL_HANDLER
	newcasing.modified = modified
	newcasing.update_appearance()
	var/obj/projectile/bullet/foam_dart/newdart = newcasing.loaded_projectile
	newdart.modified = modified
	newdart.damage_type = damage_type
	newdart.update_appearance()

/obj/projectile/bullet/foam_dart/Destroy()
	pen = null
	return ..()

/obj/projectile/bullet/foam_dart/riot
	name = "riot foam dart"
	icon_state = "foamdart_riot_proj"
	base_icon_state = "foamdart_riot"
	stamina = 25
