/obj/item/weapon/bikehorn/golden/retardhorn
	origin_tech = "engineering=4;syndicate=3" //Science can uncover if this is a regular bike horn or not using science goggles.

/obj/item/weapon/bikehorn/golden/retardhorn/attack()
	flip_mobs()
	retardify()
	return ..()

/obj/item/weapon/bikehorn/golden/retardhorn/attack_self(mob/user)
	flip_mobs()
	retardify()
	..()

/obj/item/weapon/bikehorn/golden/retardhorn/proc/retardify(mob/living/carbon/M, mob/user)
	if(!(next_usable > world.time))
		var/turf/T = get_turf(src)
		for(M in ohearers(7, T))
			if(ishuman(M) && M.can_hear())
				var/mob/living/carbon/human/H = M
				if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
					continue
			M.adjustBrainLoss(10)
