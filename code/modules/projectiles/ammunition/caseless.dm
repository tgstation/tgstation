
// Caseless Ammunition

/obj/item/ammo_casing/caseless
	desc = "A caseless bullet casing."
	firing_effect_type = null

/obj/item/ammo_casing/caseless/fire_casing(atom/target, mob/living/user, params, distro, quiet, zone_override, spread)
	if (..()) //successfully firing
		loc = null
		return 1
	else
		return 0

/obj/item/ammo_casing/caseless/update_icon()
	..()
	icon_state = "[initial(icon_state)]"

/obj/item/ammo_casing/caseless/a75
	desc = "A .75 bullet casing."
	caliber = "75"
	icon_state = "s-casing-live"
	projectile_type = /obj/item/projectile/bullet/gyro

/obj/item/ammo_casing/caseless/a84mm
	desc = "An 84mm anti-armour rocket."
	caliber = "84mm"
	icon_state = "s-casing-live"
	projectile_type = /obj/item/projectile/bullet/a84mm

/obj/item/ammo_casing/caseless/magspear
	name = "magnetic spear"
	desc = "A reusable spear that is typically loaded into kinetic spearguns."
	projectile_type = /obj/item/projectile/bullet/reusable/magspear
	caliber = "speargun"
	icon_state = "magspear"
	throwforce = 15 //still deadly when thrown
	throw_speed = 3


/obj/item/ammo_casing/caseless/laser
 	name = "laser casing"
 	desc = "You shouldn't be seeing this."
 	caliber = "laser"
 	icon_state = "s-casing-live"
 	projectile_type = /obj/item/projectile/beam
 	fire_sound = 'sound/weapons/laser.ogg'
 	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy

/obj/item/ammo_casing/caseless/laser/gatling
	projectile_type = /obj/item/projectile/beam/weak
	variance = 0.8
	click_cooldown_override = 1


/obj/item/ammo_casing/caseless/foam_dart
	name = "foam dart"
	desc = "Its nerf or nothing! Ages 8 and up."
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart
	caliber = "foam_force"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart"
	var/modified = 0

/obj/item/ammo_casing/caseless/foam_dart/update_icon()
	..()
	if (modified)
		icon_state = "foamdart_empty"
		desc = "Its nerf or nothing! ... Although, this one doesn't look too safe."
		if(BB)
			BB.icon_state = "foamdart_empty"
	else
		icon_state = initial(icon_state)
		desc = "Its nerf or nothing! Ages 8 and up."
		if(BB)
			BB.icon_state = initial(BB.icon_state)


/obj/item/ammo_casing/caseless/foam_dart/attackby(obj/item/A, mob/user, params)
	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	if (istype(A, /obj/item/weapon/screwdriver) && !modified)
		modified = 1
		FD.modified = 1
		FD.damage_type = BRUTE
		to_chat(user, "<span class='notice'>You pop the safety cap off of [src].</span>")
		update_icon()
	else if (istype(A, /obj/item/weapon/pen))
		if(modified)
			if(!FD.pen)
				if(!user.transferItemToLoc(A, FD))
					return
				FD.pen = A
				FD.damage = 5
				FD.nodamage = 0
				to_chat(user, "<span class='notice'>You insert [A] into [src].</span>")
			else
				to_chat(user, "<span class='warning'>There's already something in [src].</span>")
		else
			to_chat(user, "<span class='warning'>The safety cap prevents you from inserting [A] into [src].</span>")
	else
		return ..()

/obj/item/ammo_casing/caseless/foam_dart/attack_self(mob/living/user)
	var/obj/item/projectile/bullet/reusable/foam_dart/FD = BB
	if(FD.pen)
		FD.damage = initial(FD.damage)
		FD.nodamage = initial(FD.nodamage)
		user.put_in_hands(FD.pen)
		to_chat(user, "<span class='notice'>You remove [FD.pen] from [src].</span>")
		FD.pen = null

/obj/item/ammo_casing/caseless/foam_dart/riot
	name = "riot foam dart"
	desc = "Whose smart idea was it to use toys as crowd control? Ages 18 and up."
	projectile_type = /obj/item/projectile/bullet/reusable/foam_dart/riot
	icon_state = "foamdart_riot"

/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stab, stab, stab."
	icon_state = "arrow"
	force = 10
	sharpness = IS_SHARP
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	caliber = "arrow"
