

/obj/item/weapon/gun/grenadelauncher
	name = "grenade launcher"
	icon = 'icons/obj/gun.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = 4.0
	throw_speed = 2
	throw_range = 10
	force = 5.0
	var/list/grenades = new/list()
	var/max_grenades = 3
	m_amt = 2000
	w_type = RECYK_METAL

	examine()
		set src in view()
		//..() //Redundant
		if (!(usr in view(2)) && usr!=src.loc) return
		usr << "This is a \icon [src] [src.name]."
		if(!(grenades.len))
			usr << "It is empty."
			return
		usr << "\blue It has [grenades.len] / [max_grenades] grenades loaded."
		for(var/obj/item/weapon/grenade/G in grenades)
			usr << "\icon [G] [G.name]"
		return

	attackby(obj/item/I as obj, mob/user as mob)

		if((istype(I, /obj/item/weapon/grenade)))
			if(grenades.len < max_grenades)
				user.drop_item()
				I.loc = src
				grenades += I
				user << "\blue You load the [I.name] into the [src.name]."
				user << "\blue [grenades.len] / [max_grenades] grenades loaded."
			else
				user << "\red The [src.name] cannot hold more grenades."

	afterattack(obj/target, mob/user , flag)

		if (istype(target, /obj/item/weapon/storage/backpack ))
			return

		else if (locate (/obj/structure/table, src.loc))
			return

		else if(target == user)
			return

		if(grenades.len)
			spawn(0) fire_grenade(target,user)
		else
			usr << "\red The [src.name] is empty."

	proc
		fire_grenade(atom/target, mob/user)
			for(var/mob/O in viewers(world.view, user))
				O.show_message(text("\red [] fired a grenade!", user), 1)
			user << "\red You fire the grenade launcher!"
			var/obj/item/weapon/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
			grenades -= F
			F.loc = user.loc
			F.throw_at(target, 30, 2)
			message_admins("[key_name_admin(user)] fired [F.name] from [src.name].")
			log_game("[key_name_admin(user)] launched [F.name] from [src.name].")
			F.active = 1
			F.icon_state = initial(icon_state) + "_active"
			playsound(user.loc, 'sound/weapons/grenadelauncher.ogg', 50, 1, -3)
			spawn(15)
				F.prime()