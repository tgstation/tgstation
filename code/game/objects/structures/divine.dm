/obj/structure/sacrificealtar
	name = "sacrificial altar"
	desc = "An altar designed to perform blood sacrifice for a deity."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "sacrificealtar"
	anchored = 1
	density = 0
	can_buckle = 1

/obj/structure/sacrificealtar/attack_hand(mob/living/user)
	..()
	if(!has_buckled_mobs())
		return
	var/mob/living/L = locate() in buckled_mobs
	if(!L)
		return
	user << "<span class='notice'>You attempt to sacrifice [L] by invoking the sacrificial ritual.</span>"
	L.gib()
	message_admins("[key_name_admin(user)] has sacrificed [key_name_admin(L)] on the sacrifical altar.")

/obj/structure/healingfountain
	name = "healing fountain"
	desc = "A fountain containing the waters of life."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "fountain"
	anchored = 1
	density = 1
	var/time_between_uses = 1800
	var/last_process = 0

/obj/structure/healingfountain/attack_hand(mob/living/user)
	if(last_process + time_between_uses > world.time)
		user << "<span class='notice'>The fountain appears to be empty.</span>"
		return
	last_process = world.time
	user << "<span class='notice'>The water feels warm and soothing as you touch it. The fountain immediately dries up shortly afterwards.</span>"
	user.reagents.add_reagent("godblood",20)
	update_icons()
	addtimer(CALLBACK(src, .proc/update_icons), time_between_uses)


/obj/structure/healingfountain/proc/update_icons()
	if(last_process + time_between_uses > world.time)
		icon_state = "fountain"
	else
		icon_state = "fountain-red"