/obj/item/weapon/grenade/plastic
	name = "plastic explosive"
	desc = "Used to put holes in specific areas without too much extra hole."
	icon_state = "plastic-explosive0"
	item_state = "plastic-explosive"
	flags = NOBLUDGEON
	det_time = 10
	display_timer = 0
	var/atom/target = null
	var/image_overlay = null
	var/obj/item/device/assembly_holder/nadeassembly = null
	var/assemblyattacher

/obj/item/weapon/grenade/plastic/New()
	image_overlay = image('icons/obj/grenade.dmi', "[item_state]2")
	..()

/obj/item/weapon/grenade/plastic/Destroy()
	qdel(nadeassembly)
	nadeassembly = null
	target = null
	..()

/obj/item/weapon/grenade/plastic/attackby(obj/item/I, mob/user, params)
	if(!nadeassembly && istype(I, /obj/item/device/assembly_holder))
		var/obj/item/device/assembly_holder/A = I
		if(!user.unEquip(I))
			return ..()
		nadeassembly = A
		A.master = src
		A.loc = src
		assemblyattacher = user.ckey
		user << "<span class='notice'>You add [A] to the [name].</span>"
		playsound(src, 'sound/weapons/tap.ogg', 20, 1)
		update_icon()
		return
	if(nadeassembly && istype(I, /obj/item/weapon/wirecutters))
		playsound(src, I.usesound, 20, 1)
		nadeassembly.loc = get_turf(src)
		nadeassembly.master = null
		nadeassembly = null
		update_icon()
		return
	..()

//assembly stuff
/obj/item/weapon/grenade/plastic/receive_signal()
	prime()

/obj/item/weapon/grenade/plastic/Crossed(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.Crossed(AM)

/obj/item/weapon/grenade/plastic/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)

/obj/item/weapon/grenade/plastic/attack_self(mob/user)
	if(nadeassembly)
		nadeassembly.attack_self(user)
		return
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(user.get_active_held_item() == src)
		newtime = Clamp(newtime, 10, 60000)
		det_time = newtime
		user << "Timer set for [det_time] seconds."

/obj/item/weapon/grenade/plastic/afterattack(atom/movable/AM, mob/user, flag)
	if (!flag)
		return
	if (istype(AM, /mob/living/carbon))
		return
	user << "<span class='notice'>You start planting the [src]. The timer is set to [det_time]...</span>"

	if(do_after(user, 50, target = AM))
		if(!user.unEquip(src))
			return
		src.target = AM
		loc = null

		message_admins("[ADMIN_LOOKUPFLW(user)] planted [name] on [target.name] at [ADMIN_COORDJMP(target)] with [det_time] second fuse",0,1)
		log_game("[key_name(user)] planted [name] on [target.name] at [COORD(src)] with [det_time] second fuse")

		target.add_overlay(image_overlay, 1)
		if(!nadeassembly)
			user << "<span class='notice'>You plant the bomb. Timer counting down from [det_time].</span>"
			addtimer(src, "prime", det_time*10)

/obj/item/weapon/grenade/plastic/suicide_act(mob/user)
	message_admins("[key_name_admin(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) suicided with [src] at ([user.x],[user.y],[user.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)",0,1)
	message_admins("[key_name(user)] suicided with [src] at ([user.x],[user.y],[user.z])")
	user.visible_message("<span class='suicide'>[user] activates the [src] and holds it above [user.p_their()] head! It looks like [user.p_theyre()] going out with a bang!</span>")
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
	explosion(user,0,2,0) //Cheap explosion imitation because putting prime() here causes runtimes
	user.gib(1, 1)
	qdel(src)

/obj/item/weapon/grenade/plastic/update_icon()
	if(nadeassembly)
		icon_state = "[item_state]1"
	else
		icon_state = "[item_state]0"

//////////////////////////
///// The Explosives /////
//////////////////////////

/obj/item/weapon/grenade/plastic/c4
	name = "C4"
	desc = "Used to put holes in specific areas without too much extra hole. A saboteur's favorite."

/obj/item/weapon/grenade/plastic/c4/prime()
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
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)

// X4 is an upgraded directional variant of c4 which is relatively safe to be standing next to. And much less safe to be standing on the other side of.
// C4 is intended to be used for infiltration, and destroying tech. X4 is intended to be used for heavy breaching and tight spaces.
// Intended to replace C4 for nukeops, and to be a randomdrop in surplus/random traitor purchases.

/obj/item/weapon/grenade/plastic/x4
	name = "X4"
	desc = "A shaped high-explosive breaching charge. Designed to ensure user safety and wall nonsafety."
	var/aim_dir = NORTH
	icon_state = "plasticx40"
	item_state = "plasticx4"

/obj/item/weapon/grenade/plastic/x4/prime()
	var/turf/location
	if(target)
		if(!qdeleted(target))
			location = get_turf(target)
			target.overlays -= image_overlay
			target.priority_overlays -= image_overlay
	else
		location = get_turf(src)
	if(location)
		if(istype(loc, /obj/item/weapon/twohanded/spear) || !target)
			explosion(location, 0, 2, 3)
		else if(target && target.density)
			var/turf/T = get_step(location, aim_dir)
			explosion(get_step(T, aim_dir),0,0,3)
			explosion(T,0,2,0)
			location.ex_act(2, target)
		else
			explosion(location, 0, 2, 3)
			location.ex_act(2, target)
	if(istype(target, /mob))
		var/mob/M = target
		M.gib()
	qdel(src)

/obj/item/weapon/grenade/plastic/x4/afterattack(atom/movable/AM, mob/user, flag)
	aim_dir = get_dir(user,AM)
	..()
