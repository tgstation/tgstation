

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
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_METAL

/obj/item/weapon/gun/grenadelauncher/examine(mob/user)
	..()
	if(!(grenades.len))
		to_chat(user, "<span class='info'>It is empty.</span>")
		return
	to_chat(user, "<span class='info'>It has [grenades.len] / [max_grenades] grenades loaded.</span>")
	for(var/obj/item/weapon/grenade/G in grenades)
		to_chat(user, "\icon [G] [G.name]")

/obj/item/weapon/gun/grenadelauncher/attackby(obj/item/I as obj, mob/user as mob)

	if((istype(I, /obj/item/weapon/grenade)))
		if(grenades.len < max_grenades)
			user.drop_item(I, src)
			grenades += I
			to_chat(user, "<span class='notice'>You load the [I.name] into the [src.name].</span>")
			to_chat(user, "<span class='notice'>[grenades.len] / [max_grenades] grenades loaded.</span>")
		else
			to_chat(user, "<span class='warning'>The [src.name] cannot hold more grenades.</span>")

/obj/item/weapon/gun/grenadelauncher/afterattack(obj/target, mob/user , flag)

	if (istype(target, /obj/item/weapon/storage/backpack ))
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(grenades.len)
		spawn(0) fire_grenade(target,user)
	else
		to_chat(usr, "<span class='warning'>The [src.name] is empty.</span>")

/obj/item/weapon/gun/grenadelauncher/proc/fire_grenade(atom/target, mob/user)
	for(var/mob/O in viewers(world.view, user))
		O.show_message(text("<span class='warning'>[] fired a grenade!</span>", user), 1)
	to_chat(user, "<span class='warning'>You fire the grenade launcher!</span>")
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