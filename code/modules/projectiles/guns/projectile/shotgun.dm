/obj/item/weapon/gun/projectile/shotgun/pump
	name = "shotgun"
	desc = "Useful for sweeping alleys."
	icon_state = "shotgun"
	item_state = "shotgun"
	max_shells = 4
	w_class = 4.0
	force = 10
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	caliber = "shotgun"
	origin_tech = "combat=4;materials=2"
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"
	var
		recentpump = 0 // to prevent spammage
		pumped = 0
		obj/item/ammo_casing/current_shell = null


	load_into_chamber()
		if(in_chamber)	return 1
		return 0


	attack_self(mob/living/user as mob)
		if(recentpump)	return
		pump()
		recentpump = 1
		spawn(10)
			recentpump = 0
		return


	proc/pump(mob/M as mob)
		playsound(M, 'shotgunpump.ogg', 60, 1)
		pumped = 0
		if(current_shell)//We have a shell in the chamber
			current_shell.loc = get_turf(src)//Eject casing
			current_shell = null
			if(in_chamber)
				in_chamber = null
		if(!loaded.len)	return 0
		var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
		loaded -= AC //Remove casing from loaded list.
		current_shell = AC
		if(AC.BB)
			in_chamber = AC.BB //Load projectile into chamber.
		update_icon()	//I.E. fix the desc
		return 1

/obj/item/weapon/gun/projectile/shotgun/pump/combat
	name = "combat shotgun"
	icon_state = "cshotgun"
	max_shells = 8
	origin_tech = "combat=5;materials=2"
	ammo_type = "/obj/item/ammo_casing/shotgun"

//this is largely hacky and bad :(	-Pete
/obj/item/weapon/gun/projectile/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun"
	max_shells = 2
	w_class = 4.0
	force = 10
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	caliber = "shotgun"
	origin_tech = "combat=3;materials=1"
	ammo_type = "/obj/item/ammo_casing/shotgun/beanbag"

	load_into_chamber()
		if(!loaded.len)	return 0

		var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
		loaded -= AC //Remove casing from loaded list.
		AC.desc += " This one is spent."

		if(AC.BB)
			in_chamber = AC.BB //Load projectile into chamber.
			AC.BB.loc = src //Set projectile loc to gun.
			return 1
		return 0

	attack_self(mob/living/user as mob)
		if(!(locate(/obj/item/ammo_casing/shotgun) in src) && !loaded.len)
			user << "<span class='notice'>\The [src] is empty.</span>"
			return

		for(var/obj/item/ammo_casing/shotgun/shell in src)	//This feels like a hack.	//don't code at 3:30am kids!!
			if(shell in loaded)
				loaded -= shell
			shell.loc = get_turf(src.loc)

		user << "<span class='notice'>You break \the [src].</span>"
		update_icon()

	attackby(var/obj/item/A as obj, mob/user as mob)
		if(istype(A, /obj/item/ammo_casing) && !load_method)
			var/obj/item/ammo_casing/AC = A
			if(AC.caliber == caliber && (loaded.len < max_shells) && (contents.len < max_shells))	//forgive me father, for i have sinned
				user.drop_item()
				AC.loc = src
				loaded += AC
				user << "<span class='notice'>You load a shell into \the [src]!</span>"
		A.update_icon()
		update_icon()
		if(istype(A, /obj/item/weapon/circular_saw) || istype(A, /obj/item/weapon/melee/energy) || istype(A, /obj/item/weapon/pickaxe/plasmacutter))
			user << "<span class='notice'>You begin to shorten the barrel of \the [src].</span>"
			if(loaded.len)
				afterattack(user, user)	//will this work?
				playsound(user, fire_sound, 50, 1)
				user.visible_message("<span class='danger'>The shotgun goes off!</span>", "<span class='danger'>The shotgun goes off in your face!</span>")
				return
			if(do_after(user, 30))	//SHIT IS STEALTHY EYYYYY
				icon_state = "sawnshotgun"
				w_class = 3.0
				item_state = "gun"
				flags &= ~ONBACK	//you can't sling it on your back
				flags |= ONBELT		//but you can wear it on your belt (poorly concealed under a trenchcoat, ideally)
				name = "sawn-off shotgun"
				desc = "Omar's coming!"
				user << "<span class='warning'>You shorten the barrel of \the [src]!</span>"