/obj/item/weapon/katana/energy
	name = "energy katana"
	desc = "A katana infused with strong energy."
	icon_state = "energy_katana"
	item_state = "energy_katana"
	force = 40
	throwforce = 20
	armour_penetration = 50
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/datum/effect_system/spark_spread/spark_system

/obj/item/weapon/katana/energy/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!user || !target)
		return

	if(proximity_flag)
		if(isobj(target) || issilicon(target))
			spark_system.start()
			playsound(user, "sparks", 50, 1)
			playsound(user, 'sound/weapons/blade1.ogg', 50, 1)
			target.emag_act(user)


//If we hit the Ninja who owns this Katana, they catch it.
//Works for if the Ninja throws it or it throws itself or someone tries
//To throw it at the ninja
/obj/item/weapon/katana/energy/throw_impact(atom/hit_atom)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if(istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
			var/obj/item/clothing/suit/space/space_ninja/SN = H.wear_suit
			if(SN.energyKatana == src)
				returnToOwner(H, 0, 1)
				return

	..()

/obj/item/weapon/katana/energy/proc/returnToOwner(mob/living/carbon/human/user, doSpark = 1, caught = 0)
	if(!istype(user))
		return
	forceMove(get_turf(user))

	if(doSpark)
		spark_system.start()
		playsound(get_turf(src), "sparks", 50, 1)

	var/msg = ""

	if(user.put_in_hands(src))
		msg = "Your Energy Katana teleports into your hand!"
	else if(user.equip_to_slot_if_possible(src, slot_belt, 0, 1, 1))
		msg = "Your Energy Katana teleports back to you, sheathing itself as it does so!</span>"
	else
		msg = "Your Energy Katana teleports to your location!"

	if(caught)
		if(loc == user)
			msg = "You catch your Energy Katana!"
		else
			msg = "Your Energy Katana lands at your feet!"

	if(msg)
		user << "<span class='notice'>[msg]</span>"

/obj/item/weapon/katana/energy/New()
	..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/weapon/katana/energy/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()