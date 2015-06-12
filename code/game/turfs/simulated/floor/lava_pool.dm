/turf/simulated/floor/lava_pool
		icon_state = "lava"
		name = "lava pool"
		desc = "A deadly pool of molten rock that incinerates almost anything on contact."
		luminosity = 3
		var/list/blacklist = list(/obj/item/clothing/suit/space/hardsuit/mining, /obj/item/asteroid/goliath_hide)
		var/processing = 0

/turf/simulated/floor/lava_pool/Entered(var/mob/living/carbon/C)
	Incinerate(C) //To catch items before other things get processed
	if(!istype(C))
		return
	if(!processing)
		SSobj.processing |= src
		processing = 1
	if(istype(C, /mob/living/carbon/human))
		if(check_suit(C))
			return

	apply_lava_damage(C)
	C.emote("scream")
	C.visible_message("<span class='warning'>[C] falls into [src]!   </span>", "<span class='userdanger'>You fall into [src]!   </span>", "<span class='warning'>You hear a splash followed by a howling scream! </span>")

/turf/simulated/floor/lava_pool/proc/process()
	var/mobpresent = 0
	for(var/mob/living/carbon/human/H in src)
		mobpresent = 1
		if(check_suit(H))
			continue

		apply_lava_damage(H)//Defaults to 0 for message
	if(!mobpresent)
		SSobj.processing.Remove(src)
		processing = 0

/turf/simulated/floor/lava_pool/proc/check_suit(mob/living/carbon/human/H) // Checks for goliath plated suit
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
	Incinerate(C) //To delete mobs burning up on the tile

/turf/simulated/floor/lava_pool/proc/Incinerate()
	for(var/mob/living/C in src)
		if(C)
			if(C.getFireLoss() > 400)
				del(C)
				processing = 0

	for(var/obj/I in src)
		if(istype(I,/obj/item))
			del(I)