//In this file: C4 and Syndicate Bombs

/obj/item/weapon/c4
	name = "C-4"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = NOBLUDGEON
	w_class = 2.0
	origin_tech = "syndicate=2"
	var/datum/wires/explosive/c4/wires = null
	var/timer = 10
	var/atom/target = null
	var/open_panel = 0
	var/image_overlay = null

/obj/item/weapon/c4/New()
	wires = new(src)
	image_overlay = image('icons/obj/assemblies.dmi', "plastic-explosive2")
	..()

/obj/item/weapon/c4/suicide_act(var/mob/user)
	user.visible_message("<span class='suicide'>[user] activates the [src.name] and holds it above his head! It looks like \he's going out with a bang!</span>")
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
	user.say(message_say)
	target = user
	message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) suicided with [src.name] at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	sleep(10)
	explode(get_turf(user))
	user.gib()

/obj/item/weapon/c4/attackby(var/obj/item/I, var/mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"
	else if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler))
		wires.Interact(user)
	else
		..()

/obj/item/weapon/c4/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(user.get_active_hand() == src)
		newtime = Clamp(newtime, 10, 60000)
		timer = newtime
		user << "Timer set for [timer] seconds."

/obj/item/weapon/c4/afterattack(atom/movable/target, mob/user, flag)
	if (!flag)
		return
	if (ismob(target) || istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage/))
		return
	if(loc == target)
		return

	user << "<span class='notice'>You start planting the bomb...</span>"

	if(do_after(user, 50) && in_range(user, target))
		user.drop_item()
		src.target = target
		loc = null

		if (ismob(target))
			add_logs(user, target, "planted [name] on")
			user.visible_message("<span class='warning'>[user.name] finished planting an explosive on [target.name].</span>", "<span class='notice'>You finish planting an explosive on [target.name].</span>")
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted [src.name] on [key_name(target)](<A HREF='?_src_=holder;adminmoreinfo=\ref[target]'>?</A>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted [src.name] on [key_name(target)] with [timer] second fuse")

		else
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted [src.name] on [target.name] at ([target.x],[target.y],[target.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted [src.name] on [target.name] at ([target.x],[target.y],[target.z]) with [timer] second fuse")

		target.overlays += image_overlay
		user << "<span class='notice'>You plant the bomb. Timer counting down from [timer].</span>"
		spawn(timer*10)
			if(target && !target.gc_destroyed)
				explode(get_turf(target))
			else
				qdel(src)

/obj/item/weapon/c4/proc/explode(var/turf/location)
	location.ex_act(2, target)
	explosion(location,0,0,3)
	if(target)
		target.overlays -= image_overlay
	qdel(src)

/obj/item/weapon/c4/attack(mob/M as mob, mob/user as mob, def_zone)
	return
