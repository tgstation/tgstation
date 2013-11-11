/obj/item/weapon/gun/projectile/revolver
	desc = "A classic revolver. Uses 357 ammo"
	name = "revolver"
	icon_state = "revolver"
	ammo_type = /obj/item/ammo_casing/a357
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder

/obj/item/weapon/gun/projectile/revolver/chamber_round()
	if (chambered || !magazine)
		return
	else if (magazine.ammo_count())
		chambered = magazine.get_round(1)
	return

/obj/item/weapon/gun/projectile/revolver/process_chambered()
	var/obj/item/ammo_casing/AC = chambered //Find chambered round
	if(isnull(AC) || !istype(AC))
		return 0
	chambered = null
	chamber_round()
	if(AC.BB)
		in_chamber = AC.BB //Load projectile into chamber.
		AC.BB.loc = src //Set projectile loc to gun.
		AC.BB = null
		AC.update_icon()
		return 1
	return 0

/obj/item/weapon/gun/projectile/revolver/attackby(var/obj/item/A as obj, mob/user as mob)
	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			if(magazine.give_round(AC))
				AM.stored_ammo -= AC
				num_loaded++
			else
				break
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(magazine.give_round(AC))
			user.drop_item()
			AC.loc = src
			num_loaded++
	if(num_loaded)
		user << "<span class='notice'>You load [num_loaded] shell\s into \the [src]!</span>"
		A.update_icon()
		update_icon()
		chamber_round()

/obj/item/weapon/gun/projectile/revolver/attack_self(mob/living/user as mob)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.loc = get_turf(src.loc)
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		user << "<span class = 'notice'>You unload [num_unloaded] shell\s from [src]!</span>"
	else
		user << "<span class='notice'>[src] is empty.</span>"

/obj/item/weapon/gun/projectile/revolver/get_ammo(var/countchambered = 0, var/countempties = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/weapon/gun/projectile/revolver/examine()
	..()
	usr << "[get_ammo(0,0)] of those are live rounds."

/obj/item/weapon/gun/projectile/revolver/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = "revolver"
	icon_state = "detective"
	origin_tech = "combat=2;materials=2"
	ammo_type = /obj/item/ammo_casing/c38
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev38


/obj/item/weapon/gun/projectile/revolver/detective/special_check(var/mob/living/carbon/human/M)
	if(magazine.caliber == initial(magazine.caliber))
		return 1
	if(prob(70 - (magazine.ammo_count() * 10)))	//minimum probability of 10, maximum of 60
		M << "<span class='danger'>[src] blows up in your face.</span>"
		M.take_organ_damage(0,20)
		M.drop_item()
		del(src)
		return 0
	return 1

/obj/item/weapon/gun/projectile/revolver/detective/verb/rename_gun()
	set name = "Name Gun"
	set category = "Object"
	set desc = "Click to rename your gun."

	var/mob/M = usr
	var/input = stripped_input(M,"What do you want to name the gun?", ,"", MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src))
		name = input
		M << "You name the gun [input]. Say hello to your new friend."
		return 1

/obj/item/weapon/gun/projectile/revolver/detective/verb/reskin_gun()
	set name = "Reskin gun"
	set category = "Object"
	set desc = "Click to reskin your gun."

	var/mob/M = usr
	var/list/options = list()
	options["The Original"] = "detective"
	options["Leopard Spots"] = "detective_leopard"
	options["Black Panther"] = "detective_panther"
	options["Gold Trim"] = "detective_gold"
	options["The Peacemaker"] = "detective_peacemaker"
	var/choice = input(M,"What do you want to skin the gun to?","Reskin Gun") in options

	if(src && choice && !M.stat && in_range(M,src))
		icon_state = options[choice]
		M << "Your gun is now skinned as [choice]. Say hello to your new friend."
		return 1

/obj/item/weapon/gun/projectile/revolver/detective/attackby(var/obj/item/A as obj, mob/user as mob)
	..()
	if(istype(A, /obj/item/weapon/screwdriver))
		if(magazine.caliber == "38")
			user << "<span class='notice'>You begin to reinforce the barrel of [src].</span>"
			if(magazine.ammo_count())
				afterattack(user, user)	//you know the drill
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30))
				if(magazine.ammo_count())
					user << "<span class='notice'>You can't modify it!</span>"
					return
				magazine.caliber = "357"
				desc = "The barrel and chamber assembly seems to have been modified."
				user << "<span class='warning'>You reinforce the barrel of [src]! Now it will fire .357 rounds.</span>"
		else
			user << "<span class='notice'>You begin to revert the modifications to [src].</span>"
			if(magazine.ammo_count())
				afterattack(user, user)	//and again
				user.visible_message("<span class='danger'>[src] goes off!</span>", "<span class='danger'>[src] goes off in your face!</span>")
				return
			if(do_after(user, 30))
				if(magazine.ammo_count())
					user << "<span class='notice'>You can't modify it!</span>"
					return
				magazine.caliber = "38"
				desc = initial(desc)
				user << "<span class='warning'>You remove the modifications on [src]! Now it will fire .38 rounds.</span>"




/obj/item/weapon/gun/projectile/revolver/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."	//>10mm hole >.357
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/weapon/gun/projectile/revolver/russian
	name = "Russian Revolver"
	desc = "A Russian made revolver. Uses .357 ammo. It has a single slot in its chamber for a bullet."
	origin_tech = "combat=2;materials=2"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rus357
	var/spun = 0

/obj/item/weapon/gun/projectile/revolver/russian/New()
	..()
	Spin()
	update_icon()

/obj/item/weapon/gun/projectile/revolver/russian/proc/Spin()
	chambered = null
	var/random = rand(1, magazine.max_ammo)
	if(random <= get_ammo(0,0))
		chamber_round()
	spun = 1

/obj/item/weapon/gun/projectile/revolver/russian/attackby(var/obj/item/A as obj, mob/user as mob)
	var/num_loaded = 0
	if(istype(A, /obj/item/ammo_box))
		var/obj/item/ammo_box/AM = A
		for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
			if(get_ammo() <= 1)
				if(magazine.give_round(AC))
					AM.stored_ammo -= AC
					num_loaded++
			break
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(get_ammo() <= 1)
			magazine.give_round(AC)
			user.drop_item()
			AC.loc = src
			num_loaded++
	if(num_loaded)
		user.visible_message("<span class='warning'>[user] loads a single bullet into the revolver and spins the chamber.</span>", "<span class='warning'>You load a single bullet into the chamber and spin it.</span>")
	else
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
	if(get_ammo() > 0)
		Spin()
	update_icon()
	A.update_icon()
	return

/obj/item/weapon/gun/projectile/revolver/russian/attack_self(mob/user as mob)
	if(!spun && get_ammo(0,0))
		user.visible_message("<span class='warning'>[user] spins the chamber of the revolver.</span>", "<span class='warning'>You spin the revolver's chamber.</span>")
		Spin()
	else
		var/num_unloaded = 0
		while (get_ammo() > 0)
			var/obj/item/ammo_casing/CB
			CB = magazine.get_round()
			chambered = null
			CB.loc = get_turf(src.loc)
			CB.update_icon()
			num_unloaded++
		if (num_unloaded)
			user << "<span class = 'notice'>You unload [num_unloaded] shell\s from [src]!</span>"
		else
			user << "<span class='notice'>[src] is empty.</span>"

/obj/item/weapon/gun/projectile/revolver/russian/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params)
	..()
	spun = 0

/obj/item/weapon/gun/projectile/revolver/russian/attack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj)

	if(!chambered)
		user.visible_message("\red *click*", "\red *click*")
		return

	if(isliving(target) && isliving(user))
		if(target == user)
			var/obj/item/organ/limb/affecting = user.zone_sel.selecting
			if(affecting == "head")
				var/obj/item/ammo_casing/AC = chambered
				if(!process_chambered())
					user.visible_message("\red *click*", "\red *click*")
					return
				if(!in_chamber)
					return
				var/obj/item/projectile/P = new AC.projectile_type
				playsound(user, fire_sound, 50, 1)
				user.visible_message("<span class='danger'>[user.name] fires [src] at \his head!</span>", "<span class='danger'>You fire [src] at your head!</span>", "You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")
				if(!P.nodamage)
					user.apply_damage(300, BRUTE, affecting) // You are dead, dead, dead.
				return

	spun = 0
	..()

