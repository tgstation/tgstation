/obj/projectile/bullet/reusable/foam_dart
	name = "foam dart"
	desc = "I hope you're wearing eye protection."
	damage = 0 // It's a damn toy.
	damage_type = OXY
	icon = 'icons/obj/weapons/guns/toy.dmi'
	icon_state = "foamdart_proj"
	base_icon_state = "foamdart_proj"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart
	range = 10
	var/modified = FALSE
	var/obj/item/pen/pen = null

/obj/projectile/bullet/reusable/foam_dart/handle_drop()
	if(dropped)
		return
	var/turf/T = get_turf(src)
	dropped = 1
	var/obj/item/ammo_casing/caseless/foam_dart/newcasing = new ammo_type(T)
	newcasing.modified = modified
	var/obj/projectile/bullet/reusable/foam_dart/newdart = newcasing.loaded_projectile
	newdart.modified = modified
	newdart.damage_type = damage_type
	if(pen)
		newdart.pen = pen
		pen.forceMove(newdart)
		pen = null
		newdart.damage = 5
	newdart.update_appearance()


/obj/projectile/bullet/reusable/foam_dart/Destroy()
	pen = null
	return ..()

/obj/projectile/bullet/reusable/foam_dart/riot
	name = "riot foam dart"
	icon_state = "foamdart_riot_proj"
	base_icon_state = "foamdart_riot_proj"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/riot
	stamina = 25
