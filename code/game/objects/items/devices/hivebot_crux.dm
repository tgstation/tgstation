//Hivebot cruxes are dropped by hivebot swarm cores. When used, they create a friendly hivebot that understands limited speech and responds to its master's commands.
//If the hivebot dies, a new one can be created from the crux after some time.
//The crux acts as the hivebot's senses, and everything the hivebot does can be traced back to the crux that controls it.
/obj/item/device/hivebot_crux
	name = "hivebot crux"
	desc = "A smooth, metallic metal cylinder with an indigo screen."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "hive_main-crash"
	flags = CONDUCT | NOBLUDGEON
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL = 500, MAT_GLASS = 1000)
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "engineering=5;magnets=4;programming=4"
	var/hivebot_name //If applicable, a custom name for the summoned hivebot

/obj/item/device/hivebot_crux/examine(mob/user)
	..()
	user << "<span class='notice'>[hivebot_name ? "It's labelled \"[hivebot_name]\"." : "Use a pen or crayon to change its label."]</span>"

/obj/item/device/hivebot_crux/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/toy/crayon))
		hivebot_name = stripped_input(user, "Enter a name for your worker hivebot.", "Worker Name", "", MAX_NAME_LEN)
		if(hivebot_name)
			user << "<span class='notice'>You change your worker's name to [hivebot_name].</span>"

/obj/item/device/hivebot_crux/attack_self(mob/living/user)
	if(child)
		user << "<span class='warning'>A worker is already active! Attack it with [src] to dismiss it.</span>"
		return
	user.visible_message("<span class='notice'>[user] touches [src], and it comes to life!</span>", \
						"<span class='notice'>You gently touch [src], and it hums to life as a tiny robot materializes in front of you!</span>")
	child = new(get_turf(user))
	if(hivebot_name)
		child.name = "\proper [hivebot_name]"
		child.real_name = "\proper [hivebot_name]"
		child.faction = user.faction
	child.say("Hello World!")
	child.orbit(user, 20)
	child.parent = src

#warn Todo: bot hearing
