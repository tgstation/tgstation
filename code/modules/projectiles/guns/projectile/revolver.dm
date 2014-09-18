/obj/item/weapon/gun/projectile/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "revolver"
	icon_state = "detective"
	max_shells = 6
	caliber = list("38" = 1, "357" = 1)
	origin_tech = "combat=2;materials=2"
	ammo_type = /obj/item/ammo_casing/c38
	var/perfect = 0

	special_check(var/mob/living/carbon/human/M) //to see if the gun fires 357 rounds safely. A non-modified revolver randomly blows up
		if(loaded.len) //this is a good check, I like this check
			var/obj/item/ammo_casing/AC = loaded[1]
			if(caliber["38"] == 0) //if it's been modified, this is true
				return 1
			if(istype(AC, /obj/item/ammo_casing/a357) && !perfect && prob(70 - (loaded.len * 10)))	//minimum probability of 10, maximum of 60
				M << "<span class='danger'>[src] blows up in your face.</span>"
				M.take_organ_damage(0,20)
				M.drop_item()
				del(src)
				return 0
		return 1

	verb/rename_gun()
		set name = "Name Gun"
		set category = "Object"
		set desc = "Click to rename your gun. If you're the detective."

		var/mob/M = usr
		if(!M.mind)	return 0
		if(!M.mind.assigned_role == "Detective")
			M << "<span class='notice'>You don't feel cool enough to name this gun, chump.</span>"
			return 0

		var/input = stripped_input(usr,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

		if(src && input && !M.stat && in_range(M,src))
			name = input
			M << "You name the gun [input]. Say hello to your new friend."
			return 1

	attackby(var/obj/item/A as obj, mob/user as mob)
		..()
		if(isscrewdriver(A) || istype(A, /obj/item/weapon/conversion_kit))
			var/obj/item/weapon/conversion_kit/CK
			if(istype(A, /obj/item/weapon/conversion_kit))
				CK = A
				if(!CK.open)
					user << "<span class='notice'>This [CK.name] is useless unless you open it first. </span>"
					return
			if(caliber["38"])
				user << "<span class='notice'>You begin to reinforce the barrel of [src].</span>"
				if(loaded.len)
					afterattack(user, user)	//you know the drill
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, 30))
					if(loaded.len)
						user << "<span class='notice'>You can't modify it!</span>"
						return
					caliber["38"] = 0
					desc = "The barrel and chamber assembly seems to have been modified."
					user << "<span class='warning'>You reinforce the barrel of [src]! Now it will fire .357 rounds.</span>"
					if(CK && istype(CK))
						perfect = 1
			else
				user << "<span class='notice'>You begin to revert the modifications to [src].</span>"
				if(loaded.len)
					afterattack(user, user)	//and again
					playsound(user, fire_sound, 50, 1)
					user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
					return
				if(do_after(user, 30))
					if(loaded.len)
						user << "<span class='notice'>You can't modify it!</span>"
						return
					caliber["38"] = 1
					desc = initial(desc)
					user << "<span class='warning'>You remove the modifications on [src]! Now it will fire .38 rounds.</span>"
					perfect = 0




/obj/item/weapon/gun/projectile/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/weapon/gun/projectile/russian
	name = "Russian Revolver"
	desc = "A Russian made revolver. Uses .357 ammo. It has a single slot in it's chamber for a bullet."
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
	if(istype(A, /obj/item/ammo_storage/magazine))

		if((load_method == 2) && loaded.len)	return
		var/obj/item/ammo_storage/magazine/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			if(getAmmo() > 0 || loaded.len >= max_shells)
				break
			if(caliber[AC.caliber] && loaded.len < max_shells)
				AC.loc = src
				AM.stored_ammo -= AC
				loaded += AC
				num_loaded++
			break
		A.update_icon()

	if(num_loaded)
		user.visible_message("<span class='warning'>[user] loads a single bullet into the revolver and spins the chamber.</span>", "<span class='warning'>You load a single bullet into the chamber and spin it.</span>")
	else
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
	if(getAmmo() > 0)
		Spin()
	update_icon()
	return

/obj/item/weapon/gun/projectile/russian/attack_self(mob/user as mob)

	user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
	if(getAmmo() > 0)
		Spin()

/obj/item/weapon/gun/projectile/russian/attack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)

	if(!loaded.len)
		user.visible_message("\red *click*", "\red *click*")
		playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		return

	if(isliving(target) && isliving(user))
		if(target == user)
			var/datum/organ/external/affecting = user.zone_sel.selecting
			if(affecting == "head")

				var/obj/item/ammo_casing/AC = loaded[1]
				if(!process_chambered())
					user.visible_message("\red *click*", "\red *click*")
					playsound(user, 'sound/weapons/empty.ogg', 100, 1)
					return
				if(!in_chamber)
					return
				var/obj/item/projectile/P = new AC.projectile_type
				playsound(user, fire_sound, 50, 1)
				user.visible_message("<span class='danger'>[user.name] fires [src] at \his head!</span>", "<span class='danger'>You fire [src] at your head!</span>", "You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
				if(!P.nodamage)
					user.apply_damage(300, BRUTE, affecting) // You are dead, dead, dead.
				return
	..()

