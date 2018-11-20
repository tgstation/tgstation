/obj/item/c4_ex
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags_1 = NOBLUDGEON_1
	w_class = 2.0
	//origin_tech = "syndicate=2"
	var/timer = 10
	var/atom/target = null
	var/open_panel = 0
	var/image_overlay = null
	var/list/explosion_size = list(-1, -1, 4, 4)

/obj/item/c4_ex/New()
	image_overlay = image('icons/obj/assemblies.dmi', "plastic-explosive2")
	..()

/obj/item/c4_ex/suicide_act(var/mob/user)
	. = (BRUTELOSS)
	user.visible_message("<span class='suicide'>[user] activates the C4 and holds it above his head! It looks like \he's going out with a bang!</span>")
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
	message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) suicided with C4 at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	explode(get_turf(user))
	return .


/obj/item/c4_ex/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(user.get_active_held_item() == src)
		newtime = CLAMP(newtime, 10, 60000)
		timer = newtime
		to_chat(user, "Timer set for [timer] seconds.")

/obj/item/c4_ex/afterattack(atom/movable/target, mob/user, flag)
	if (!flag)
		return
	if (istype(target, /turf/closed/indestructible) || istype(target, /obj/item/storage/))
		return

	to_chat(user, "Planting explosives...")
	if(ismob(target))
		add_logs(user, target, "tried to plant explosives on", object="[name]")
		user.visible_message("\red [user.name] is trying to plant some kind of explosive on [target.name]!")


	if(do_after(user, 50) && in_range(user, target))
		user.dropItemToGround(src)
		src.target = target
		loc = null

		if (ismob(target))
			add_logs(user, target, "planted [name] on")
			user.visible_message("\red [user.name] finished planting an explosive on [target.name]!")
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted C4 on [key_name(target)](<A HREF='?_src_=holder;adminmoreinfo=\ref[target]'>?</A>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted C4 on [key_name(target)] with [timer] second fuse")

		else
			message_admins("[key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) planted C4 on [target.name] at ([target.x],[target.y],[target.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[target.x];Y=[target.y];Z=[target.z]'>JMP</a>) with [timer] second fuse",0,1)
			log_game("[key_name(user)] planted C4 on [target.name] at ([target.x],[target.y],[target.z]) with [timer] second fuse")

		target.overlays += image_overlay
		to_chat(user, "Bomb has been planted. Timer counting down from [timer].")
		spawn(timer*10)
			explode(get_turf(target))

/obj/item/c4_ex/proc/explode()
	if(QDELETED(src))
		return
	var/turf/location
	if(target)
		if(!QDELETED(target))
			location = get_turf(target)
			if (target.overlays)
				target.overlays -= image_overlay
			if (target.priority_overlays)
				target.priority_overlays -= image_overlay
		if(istype(target,/mob))
			var/mob/T = target
			T.gib(1, 1)
		else
			target.ex_act(1)
	else
		location = get_turf(src)
	if(location)
		if (explosion_size.len)
			location.ex_act(2, target)
			explosion(location,explosion_size[1],explosion_size[2],explosion_size[3],explosion_size[4])
		else
			playsound(location, "explosion", 100, 1, 6)
	qdel(src)

/obj/item/c4_ex/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/*
* Breach Charge
*/

/obj/item/c4_ex/breach
	name = "breaching charge"
	icon = 'icons/oldschool/perseus.dmi'
	desc = "Deploys a controlled explosion to breach walls and doors."
	icon_state = "breachcharge"
	explosion_size = list()

	New()
		..()
		image_overlay = image('icons/oldschool/perseus.dmi', "breachcharge_ticking")
