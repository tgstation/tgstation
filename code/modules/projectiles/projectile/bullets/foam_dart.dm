/obj/projectile/bullet/foam_dart
	name = "foam dart"
	desc = "I hope you're wearing eye protection."
	damage = 0 // It's a damn toy.
	damage_type = OXY
	icon = 'icons/obj/weapons/guns/toy.dmi'
	icon_state = "foamdart_proj"
	base_icon_state = "foamdart_proj"
	range = 10
	embedding = null
	var/modified = FALSE
	var/obj/item/pen/pen = null

/obj/projectile/bullet/foam_dart/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PROJECTILE_ON_SPAWN_DROP, PROC_REF(handle_drop))

/obj/projectile/bullet/foam_dart/proc/handle_drop(datum/source, obj/item/ammo_casing/foam_dart/newcasing)
	SIGNAL_HANDLER
	newcasing.modified = modified
	var/obj/projectile/bullet/foam_dart/newdart = newcasing.loaded_projectile
	newdart.modified = modified
	newdart.damage_type = damage_type
	if(pen)
		newdart.pen = pen
		pen.forceMove(newdart)
		pen = null
		newdart.damage = 5
	newdart.update_appearance()

/obj/projectile/bullet/foam_dart/Destroy()
	pen = null
	return ..()

/obj/projectile/bullet/foam_dart/riot
	name = "riot foam dart"
	icon_state = "foamdart_riot_proj"
	base_icon_state = "foamdart_riot_proj"
	stamina = 25
