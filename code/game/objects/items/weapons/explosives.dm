//In this file: Plastic explosives (C4) and Syndicate Bombs

/obj/item/weapon/plastique
	name = "plastic explosives"
	desc = "Used to put holes in specific areas without too much extra hole."
	gender = PLURAL
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "plastic-explosive0"
	item_state = "plasticx"
	flags = FPRINT | TABLEPASS | NOBLUDGEON
	w_class = 2.0
	origin_tech = "syndicate=2"
	var/datum/wires/explosive/plastic/wires = null
	var/timer = 10
	var/atom/target = null
	var/open_panel = 0

/obj/item/weapon/plastique/New()
	wires = new(src)
	..()

/obj/item/weapon/plastique/suicide_act(var/mob/user)
	. = (BRUTELOSS)
	viewers(user) << "\red <b>[user] activates the C4 and holds it above his head! It looks like \he's going out with a bang!</b>"
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
	if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"
	else if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler ))
		wires.Interact(user)
	else
		..()

/obj/item/weapon/plastique/attack_self(mob/user as mob)
	var/newtime = input(usr, "Please set the timer.", "Timer", 10) as num
	if(user.get_active_hand() == src)
		newtime = Clamp(newtime, 10, 60000)
		timer = newtime
		user << "Timer set for [timer] seconds."

/obj/item/weapon/plastique/afterattack(atom/target as obj|turf, mob/user as mob, flag)
	if (!flag)
		return
	if (istype(target, /turf/unsimulated) || istype(target, /turf/simulated/shuttle) || istype(target, /obj/item/weapon/storage/))
		return
	user << "Planting explosives..."
	if(ismob(target))
		user.attack_log += "\[[time_stamp()]\] <font color='red'> [user.real_name] tried planting [name] on [target:real_name] ([target:ckey])</font>"
		log_attack("<font color='red'> [user.real_name] ([user.ckey]) tried planting [name] on [target:real_name] ([target:ckey])</font>")
		user.visible_message("\red [user.name] is trying to plant some kind of explosive on [target.name]!")


	if(do_after(user, 50) && in_range(user, target))
		user.drop_item()
		src.target = target
		loc = null

		if (ismob(target))
			target:attack_log += "\[[time_stamp()]\]<font color='orange'> Had the [name] planted on them by [user.real_name] ([user.ckey])</font>"
			user.visible_message("\red [user.name] finished planting an explosive on [target.name]!")

		target.overlays += image('icons/obj/assemblies.dmi', "plastic-explosive2")
		user << "Bomb has been planted. Timer counting down from [timer]."
		spawn(timer*10)
			explode(get_turf(target))

/obj/item/weapon/plastique/proc/explode(var/location)

	if(!target)
		target = get_atom_on_turf(src)
	if(!target)
		target = src
	if(location)
		explosion(location, -1, -1, 4, 4)

	if(target)
		if (istype(target, /turf/simulated/wall))
			target:dismantle_wall(1)
		else
			target.ex_act(1)
		if (isobj(target))
			if (target)
				del(target)
	del(src)

/obj/item/weapon/plastique/attack(mob/M as mob, mob/user as mob, def_zone)
	return