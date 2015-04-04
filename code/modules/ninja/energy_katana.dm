
/obj/item/weapon/katana/energy
	name = "energy katana"
	desc = "a katana infused with a strong energy"
	icon_state = "energy_katana"
	item_state = "energy_katana"
	force = 40
	throwforce = 20
	var/datum/effect/effect/system/spark_spread/spark_system

/obj/item/weapon/katana/energy/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user || !target)
		return

	if(proximity_flag)
		if(isobj(target) || issilicon(target))
			spark_system.start()
			playsound(user, "sparks", 50, 1)
			playsound(user, 'sound/weapons/blade1.ogg', 50, 1)
			target.emag_act(user)

/obj/item/weapon/katana/energy/proc/returnToOwner(var/mob/living/carbon/human/user, var/doSpark = 1, var/caught = 0)
	if(!istype(user))
		return
	loc = get_turf(src)

	if(doSpark)
		spark_system.start()
		playsound(get_turf(src), "sparks", 50, 1)

	var/msg = ""

	if(user.put_in_hands(src))
		msg = "<span class='notice'>Your Energy Katana teleports into your hand!</span>"
	else if(user.equip_to_slot_if_possible(src, slot_belt, 0, 1, 1))
		msg = "<span class='notice'>Your Energy Katana teleports back to you, sheathing itself as it does so!</span>"
	else
		loc = get_turf(user)
		msg = "<span class='notice'>Your Energy Katana teleports to your location!</span>"

	if(caught)
		msg = "You catch your Energy Katana!"

	if(msg)
		user << "<span class='notice'>[msg]</span>"

/obj/item/weapon/katana/energy/New()
	..()
	spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)