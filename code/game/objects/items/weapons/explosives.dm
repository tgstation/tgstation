<<<<<<< HEAD
//In this file: C4

/obj/item/weapon/c4
	name = "C-4"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = NOBLUDGEON
	w_class = 2
	origin_tech = "syndicate=1"
	var/timer = 10
	var/open_panel = 0
	parent_type = /obj/item/weapon/grenade/plastic/c4

/obj/item/weapon/c4/New()
	wires = new /datum/wires/explosive/c4(src)
	image_overlay = image('icons/obj/grenade.dmi', "plastic-explosive2")
	..()

/obj/item/weapon/c4/Destroy()
	qdel(wires)
	wires = null
	target = null
	return ..()

/obj/item/weapon/c4/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] activates the [src.name] and holds it above \his head! It looks like \he's going out with a bang!</span>")
	var/message_say = "FOR NO RAISIN!"
	if(user.mind)
		if(user.mind.special_role)
			var/role = lowertext(user.mind.special_role)
			if(role == "traitor" || role == "syndicate")
				message_say = "FOR THE SYNDICATE!"
			else if(role == "changeling")
				message_say = "FOR THE HIVE!"
			else if(role == "cultist")
				message_say = "FOR NAR-SIE!"
			else if(role == "revolutionary" || role == "head revolutionary")
				message_say = "VIVA LA REVOLUTION!"
			else if(user.mind.gang_datum)
				message_say = "[uppertext(user.mind.gang_datum.name)] RULES!"
	user.say(message_say)
	target = user
	message_admins("[key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) suicided with [src.name] at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	message_admins("[key_name(user)] suicided with [src.name] at ([x],[y],[z])")
	sleep(10)
	explode(get_turf(user))
	user.gib(1, 1)

/obj/item/weapon/c4/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"
	else if(is_wire_tool(I))
		wires.interact(user)
	else
		return ..()

/obj/item/weapon/c4/attack_self(mob/user)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(user.get_active_hand() == src)
		newtime = Clamp(newtime, 10, 60000)
		timer = newtime
		user << "Timer set for [timer] seconds."

/obj/item/weapon/c4/afterattack(atom/movable/AM, mob/user, flag)
	if (!flag)
		return
	if (ismob(AM))
		return
	if(loc == AM)
		return
	if((istype(AM, /obj/item/weapon/storage/)) && !((istype(AM, /obj/item/weapon/storage/secure)) || (istype(AM, /obj/item/weapon/storage/lockbox)))) //If its storage but not secure storage OR a lockbox, then place it inside.
		return
	if((istype(AM,/obj/item/weapon/storage/secure)) || (istype(AM, /obj/item/weapon/storage/lockbox)))
		var/obj/item/weapon/storage/secure/S = AM
		if(!S.locked) //Literal hacks, this works for lockboxes despite incorrect type casting, because they both share the locked var. But if its unlocked, place it inside, otherwise PLANTING C4!
			return

	user << "<span class='notice'>You start planting the bomb...</span>"

	if(do_after(user, 50, target = AM))
		if(!user.unEquip(src))
			return
		src.target = AM
		loc = null

		message_admins("[key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) planted [src.name] on [target.name] at ([target.x],[target.y],[target.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>) with [timer] second fuse",0,1)
		log_game("[key_name(user)] planted [src.name] on [target.name] at ([target.x],[target.y],[target.z]) with [timer] second fuse")

		target.add_overlay(image_overlay, 1)
		user << "<span class='notice'>You plant the bomb. Timer counting down from [timer].</span>"
		addtimer(src, "explode", timer * 10)

/obj/item/weapon/c4/proc/explode()
	if(qdeleted(src))
		return
	var/turf/location
	if(target)
		if(!qdeleted(target))
			location = get_turf(target)
			target.overlays -= image_overlay
			target.priority_overlays -= image_overlay
	else
		location = get_turf(src)
	if(location)
		location.ex_act(2, target)
		explosion(location,0,0,3)
	qdel(src)

/obj/item/weapon/c4/attack(mob/M, mob/user, def_zone)
	return
=======


/obj/item/weapon/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = FPRINT
	w_class = W_CLASS_SMALL
	origin_tech = "syndicate=2"
	var/datum/wires/explosive/plastic/wires = null
	var/timer = 10
	var/atom/target = null
	var/open_panel = 0

/obj/item/weapon/plastique/New()
	. = ..()
	wires = new(src)

/obj/item/weapon/plastique/Destroy()
	if(wires)
		qdel(wires)
		wires = null

	..()

/obj/item/weapon/plastique/suicide_act(var/mob/user)
	. = (BRUTELOSS)
	to_chat(viewers(user), "<span class='danger'>[user] activates the C4 and holds it above his head! It looks like \he's going out with a bang!</span>")
	var/message_say = "FOR NO RAISIN!"
	if(user.mind)
		if(user.mind.special_role)
			var/role = lowertext(user.mind.special_role)
			if(role == "traitor" || role == "syndicate")
				message_say = "FOR THE SYNDICATE!"
			else if(role == "changeling")
				message_say = "FOR THE HIVE!"
			else if(role == "cultist")
				message_say = "FOR NARSIE!"
	user.say(message_say)
	target = user
	explode(get_turf(user))
	return .

/obj/item/weapon/plastique/attackby(var/obj/item/I, var/mob/user)
	if(isscrewdriver(I))
		open_panel = !open_panel
		to_chat(user, "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>")
	else if(iswiretool(I))
		wires.Interact(user)
	else
		..()

/obj/item/weapon/plastique/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(newtime > 60000)
		newtime = 60000
	timer = newtime
	to_chat(user, "Timer set for [timer] seconds.")

/obj/item/weapon/plastique/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage/))
		return
	to_chat(user, "Planting explosives...")
	if(ismob(target))

		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target:real_name] ([target:ckey])</font>"
		msg_admin_attack("[user.real_name] ([user.ckey]) tried planting [name] on [target:real_name] ([target:ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		user.visible_message("<span class='warning'>[user.name] is trying to plant some kind of explosive on [target.name]!</span>")

	if(do_after(user, target, 50) && user.Adjacent(target))
		var/glue_act = 0 //If 1, the C4 is superglued to the guy's hands - produce a funny message

		if(user.drop_item(src))
			src.target = target
		else //User can't drop this normally -> stick it to him (but drop it anyways, to prevent unintended features)
			to_chat(user, "<span class='danger'>\The [src] are glued to your hands!</span>") //Honk
			src.target = user
			target = user
			glue_act = 1
			user.drop_item(src, force_drop = 1)

		loc = null

		if (ismob(target))
			var/mob/M=target
			target:attack_log += "\[[time_stamp()]\]<font color='orange'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"

			if(!glue_act)
				user.visible_message("<span class='warning'>[user.name] finished planting an explosive on [target.name]!</span>")
			else
				user.visible_message("<span class='warning'>[user] found \himself unable to drop \the [src] after setting the timer on them!</span>")

			playsound(get_turf(target), 'sound/weapons/c4armed.ogg', 60, 1)
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user
		target.overlays += image('icons/obj/assemblies.dmi', "plastic-explosive2")
		to_chat(user, "Bomb has been planted. Timer counting down from [timer].")
		spawn(timer*10)
			explode(get_turf(target))

/obj/item/weapon/plastique/proc/explode(var/location)


	if(!target)
		target = get_holder_at_turf_level(src)
	if(!target)
		target = src
	if(location)
		explosion(location, -1, -1, 2, 3)

	if(target)
		target.overlays -= image('icons/obj/assemblies.dmi', "plastic-explosive2")
		if (istype(target, /turf/simulated/wall))
			target:dismantle_wall(1)
		else
			target.ex_act(1)
		if (isobj(target))
			if (target)
				qdel(target)
				target = null
	qdel(src)

/obj/item/weapon/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
