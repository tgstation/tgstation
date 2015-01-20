/*
 * Glass shards
 */
/obj/item/weapon/shard/resetVariables()
	..("icon_state", "pixel_y", "pixel_x")

/obj/item/weapon/shard/Bump()

	spawn( 0 )
		if (prob(20))
			src.force = 15
		else
			src.force = 4
		..()
		return
	return

/obj/item/weapon/shard/New()

	src.icon_state = pick("large", "medium", "small")
	switch(src.icon_state)
		if("small")
			src.pixel_x = rand(-12, 12)
			src.pixel_y = rand(-12, 12)
		if("medium")
			src.pixel_x = rand(-8, 8)
			src.pixel_y = rand(-8, 8)
		if("large")
			src.pixel_x = rand(-5, 5)
			src.pixel_y = rand(-5, 5)
		else
	return

/obj/item/weapon/shard/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if ( istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/glass/glass/NG = new (user.loc)
			for (var/obj/item/stack/sheet/glass/glass/G in user.loc)
				if(G==NG)
					continue
				if(G.amount>=G.max_amount)
					continue
				G.attackby(NG, user)
				usr << "You add the newly-formed glass to the stack. It now contains [NG.amount] sheets."
			//SN src = null
			returnToPool(src)
			return
	return ..()

/obj/item/weapon/shard/Crossed(AM as mob|obj)
	if(ismob(AM))
		var/mob/M = AM
		M << "<span class='danger'>You step in the broken glass!</span>"
		playsound(get_turf(src), 'sound/effects/glass_step.ogg', 50, 1)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if( !H.shoes && ( !H.wear_suit || !(H.wear_suit.body_parts_covered & FEET) ) )
				var/datum/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot"))
				if(affecting.status & (ORGAN_ROBOT|ORGAN_PEG))
					return

				H.Weaken(3)
				if(affecting.take_damage(5, 0))
					H.QueueUpdateDamageIcon()
				H.updatehealth()
	..()