/turf/simulated/floor/lava_pool
		icon_state = "lava"
		name = "lava pool"
		desc = "A deadly pool of molten rock that incinerates almost anything on contact."
		luminosity = 3

/turf/simulated/floor/lava_pool/Entered(var/mob/living/carbon/C)
	if(!istype(C))
		return

	SSobj.processing |= src
	if(istype(C, /mob/living/carbon/human))
		if(check_suit(C))
			C.visible_message("<span class='warning'>Your reinforced suit protects you from [src]! </span>")
			return

	apply_lava_damage(C)
	C.emote("scream")
	C.visible_message("<span class='warning'>[C] falls into[src]!   </span>", "<span class='userdanger'>You fall into [src]!   </span>", "<span class='warning'>You hear a splash followed   by a scream! </span>")

/turf/simulated/floor/lava_pool/process()
	var/mobpresent = 0

	for(var/mob/living/carbon/human/H in src)
		mobpresent = 1
		if(check_suit(H))
			return

		apply_lava_damage(H)//Defaults to 0 for message

	if(!mobpresent)
		SSobj.processing.Remove(src)

/turf/simulated/floor/lava_pool/proc/check_suit(mob/living/carbon/human/H) // Check for goliath plated suit
	if(istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit/mining))
		var/obj/item/clothing/suit/space/hardsuit/mining/M = H.wear_suit
		if(M.armor["melee"] >= 80)
			return 1
	return 0

/turf/simulated/floor/lava_pool/proc/apply_lava_damage(mob/living/carbon/C)
	C.adjustFireLoss(10)
	C.adjust_fire_stacks(5)
	C.Weaken(3)
	C.IgniteMob()