/obj/item/weapon/gun/projectile/detective
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	name = ".38 revolver"
	icon_state = "detective"
	caliber = "38"
	origin_tech = "combat=2;materials=2"

	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing/c38(src)
		update_icon()

	special_check(var/mob/living/carbon/human/M)
		if(istype(M))
			if(istype(M.w_uniform, /obj/item/clothing/under/det) && istype(M.head, /obj/item/clothing/head/det_hat) && istype(M.wear_suit, /obj/item/clothing/suit/det_suit))
				return 1
			M << "\red You just don't feel cool enough to use this gun looking like that."
		return 0

	verb
		rename_gun()
			set name = "Name Gun"
			set desc = "Click to rename your gun. If you're the detective."

			var/mob/U = usr
			if(ishuman(U)&&U.mind&&U.mind.assigned_role=="Detective")
				var/input = input("What do you want to name the gun?",,"")
				input = sanitize(input)
				if(input)
					if(in_range(U,src)&&(!isnull(src))&&!U.stat)
						name = input
						U << "You name the gun [input]. Say hello to your new friend."
					else
						U << "\red Can't let you do that, detective!"
			else
				U << "\red You don't feel cool enough to name this gun, chump."



/obj/item/weapon/gun/projectile/mateba
	name = "mateba"
	desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."
	icon_state = "mateba"
	origin_tech = "combat=2;materials=2"



/obj/item/weapon/gun/projectile/shotgun
	name = "shotgun"
	desc = "Useful for sweeping alleys."
	icon_state = "shotgun"
	max_shells = 2
	w_class = 4.0
	force = 10
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	caliber = "shotgun"
	origin_tech = "combat=2;materials=2"
	var/recentpump = 0 // to prevent spammage

	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing/shotgun/beanbag(src)
		update_icon()

	attack_self(mob/living/user as mob)
		if(recentpump) return
		pump()
		recentpump = 1
		sleep(10)
		recentpump = 0
		return

	proc/pump(mob/M)
		playsound(M, 'shotgunpump.ogg', 60, 1)
		pumped = 0
		for(var/obj/item/ammo_casing/AC in Storedshots)
			Storedshots -= AC //Remove casing from loaded list.
			AC.loc = get_turf(src) //Eject casing onto ground.



/obj/item/weapon/gun/projectile/shotgun/combat
	name = "combat shotgun"
	icon_state = "cshotgun"
	w_class = 4.0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	max_shells = 8
	origin_tech = "combat=3"
	maxpump = 1
	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing/shotgun(src)
		update_icon()



/obj/item/weapon/gun/projectile/shotgun/combat2
	name = "security combat shotgun"
	icon_state = "cshotgun"
	w_class = 4.0
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	max_shells = 4
	origin_tech = "combat=3"
	maxpump = 1
	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing/shotgun/beanbag(src)
		update_icon()



/obj/item/weapon/gun/projectile/automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
	name = "Submachine Gun"
	desc = "A lightweight, fast firing gun. Uses 9mm rounds."
	icon_state = "saber"
	w_class = 3.0
	max_shells = 18
	caliber = "9mm"
	origin_tech = "combat=4;materials=2"

	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing/c9mm(src)
		update_icon()



/obj/item/weapon/gun/projectile/automatic/mini_uzi
	name = "Mini-Uzi"
	desc = "A lightweight, fast firing gun, for when you REALLY need someone dead. Uses .45 rounds."
	icon_state = "mini-uzi"
	w_class = 3.0
	max_shells = 20
	caliber = ".45"
	origin_tech = "combat=5;materials=2;syndicate=8"

	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing/c45(src)
		update_icon()



/obj/item/weapon/gun/projectile/silenced
	name = "Silenced Pistol"
	desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
	icon_state = "silenced_pistol"
	w_class = 3.0
	max_shells = 12
	caliber = ".45"
	silenced = 1
	origin_tech = "combat=2;materials=2;syndicate=8"

	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing/c45(src)
		update_icon()



/obj/item/weapon/gun/projectile/deagle
	name = "Desert Eagle"
	desc = "A robust handgun that uses 357 magnum ammo"
	icon_state = "deagle"
	w_class = 3.0
	force = 14.0
	max_shells = 9
	caliber = "357"
	origin_tech = "combat=2;materials=2"

	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing(src)
		update_icon()



/obj/item/weapon/gun/projectile/deagleg
	name = "Desert Eagle"
	desc = "A gold plated gun folded over a million times by superior martian gunsmiths. Uses 357 ammo."
	icon_state = "deagleg"
	item_state = "deagleg"
	w_class = 3.0
	max_shells = 9
	caliber = "357"
	origin_tech = "combat=2;materials=2"

	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing(src)
		update_icon()



/obj/item/weapon/gun/projectile/deaglecamo
	name = "Desert Eagle"
	desc = "A Deagle brand Deagle for operators operating operationally. Uses 357 ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"
	w_class = 3.0
	max_shells = 9
	caliber = "357"
	origin_tech = "combat=2;materials=2"

	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing(src)
		update_icon()



/obj/item/weapon/gun/projectile/gyropistol
	name = "Gyrojet Pistol"
	desc = "A bulky pistol designed to fire self propelled rounds"
	icon_state = "gyropistol"
	w_class = 3.0
	max_shells = 8
	caliber = "a75"
	fire_sound = 'Explosion1.ogg'
	origin_tech = "combat=3"

	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing/a75(src)
		update_icon()