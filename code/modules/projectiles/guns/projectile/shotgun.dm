/obj/item/weapon/gun/projectile/shotgun
	name = "shotgun"
	desc = "Useful for sweeping alleys."
	icon_state = "shotgun"
	max_shells = 2
	w_class = 4.0
	force = 10
	flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
	caliber = "shotgun"
	origin_tech = "combat=3;materials=1"
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


	proc/pump(mob/M)
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
		return 1



/obj/item/weapon/gun/projectile/shotgun/combat
	name = "combat shotgun"
	icon_state = "cshotgun"
	max_shells = 8
	ammo_type = "/obj/item/ammo_casing/shotgun"



/obj/item/weapon/gun/projectile/shotgun/combat2
	name = "security combat shotgun"
	icon_state = "cshotgun"
	max_shells = 4

