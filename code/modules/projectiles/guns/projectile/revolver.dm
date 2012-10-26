/obj/item/weapon/gun/projectile/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "revolver"
	icon_state = "detective"
	caliber = "38"
	origin_tech = "combat=2;materials=2"
	ammo_type = "/obj/item/ammo_magazine/c38"

/*
	special_check(var/mob/living/carbon/human/M)
		if(ishuman(M))
			if(istype(M.w_uniform, /obj/item/clothing/under/det) && istype(M.head, /obj/item/clothing/head/det_hat) && \
				(istype(M.wear_suit, /obj/item/clothing/suit/det_suit) || istype(M.wear_suit, /obj/item/clothing/suit/armor/det_suit)))
				return 1
			M << "\red You just don't feel cool enough to use this gun looking like that."
		return 0
*/

	verb/rename_gun()
		set name = "Name Gun"
		set category = "Object"
		set desc = "Click to rename your gun. If you're the detective."

		var/mob/M = usr
		if(!M.mind)	return 0
		if(!M.mind.assigned_role == "Detective")
			M << "\red You don't feel cool enough to name this gun, chump."
			return 0

		var/input = stripped_input(usr,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

		if(src && input && !M.stat && in_range(M,src))
			name = input
			M << "You name the gun [input]. Say hello to your new friend."
			return 1



/obj/item/weapon/gun/projectile/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/weapon/gun/projectile/russian
	name = "Russian Revolver"
	desc = "A Russian made revolver. Uses 357 ammo. It has a single slot in it's chamber for a bullet."
	max_shells = 6
	origin_tech = "combat=2;materials=2"

/obj/item/weapon/gun/projectile/russian/New()
	Spin()
	update_icon()

/obj/item/weapon/gun/projectile/russian/proc/Spin()

	for(var/obj/item/ammo_casing/AC in loaded)
		del(AC)
	loaded = list()
	var/random = rand(1, max_shells)
	for(var/i = 1; i <= max_shells; i++)
		if(i != random)
			loaded += i // Basically null
		else
			loaded += new ammo_type(src)


/obj/item/weapon/gun/projectile/russian/attackby(var/obj/item/A as obj, mob/user as mob)

	if(!A) return

	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_magazine))

		if((load_method == 2) && loaded.len)	return
		var/obj/item/ammo_magazine/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			if(getAmmo() > 0 || loaded.len >= max_shells)
				break
			if(AC.caliber == caliber && loaded.len < max_shells)
				AC.loc = src
				AM.stored_ammo -= AC
				loaded += AC
				num_loaded++
			break
		A.update_icon()

	if(num_loaded)
		user.visible_message("[user] loads a single bullet into the revolver and spins the chamber.", "You load a single bullet into the chamber and spin it.")
	else
		user.visible_message("[user] spins the chamber of the revolver.", "You spin the revolver's chamber.")
	if(getAmmo() > 0)
		Spin()
	update_icon()
	return

/obj/item/weapon/gun/projectile/russian/attack_self(mob/user as mob)

	user.visible_message("[user] spins the chamber of the revolver.", "You spin the revolver's chamber.")
	if(getAmmo() > 0)
		Spin()

/obj/item/weapon/gun/projectile/russian/attack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)

	if(!loaded.len)
		user.visible_message("\red *click*", "\red *click*")
		return

	if(isliving(target) && isliving(user))
		if(target == user)
			var/datum/organ/external/affecting = user.zone_sel.selecting
			if(affecting == "head")

				var/obj/item/ammo_casing/AC = loaded[1]
				if(!load_into_chamber())
					user.visible_message("\red *click*", "\red *click*")
					return
				if(!in_chamber)
					return
				var/obj/item/projectile/P = new AC.projectile_type
				playsound(user, fire_sound, 50, 1)
				user.visible_message("\red [user.name] fires the [src.name] at his head!", "\red You fire the [src.name] at your head!", "\blue You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
				if(!P.nodamage)
					user.apply_damage(300, BRUTE, affecting) // You are dead, dead, dead.
				return
	..()

