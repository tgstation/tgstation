//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//TODO: Make these simple_animals

var/const/MIN_IMPREGNATION_TIME = 100 //time it takes to impregnate someone
var/const/MAX_IMPREGNATION_TIME = 150

var/const/MIN_ACTIVE_TIME = 200 //time between being dropped and going idle
var/const/MAX_ACTIVE_TIME = 400

/obj/item/clothing/mask/facehugger
	name = "facehugger" //Let's call this 'alien' what it is. Come on Bay
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //note: can be picked up by aliens unlike most other items of w_class below 4
	flags = FPRINT  | MASKINTERNALS | PROXMOVE
	throw_range = 5
	health = 5
	var/real = 1 //Facehuggers are real, toys are not.

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case

	var/sterile = 0

	var/strength = 5

	var/attached = 0
	var/target_time = 0.5 // seconds
	var/walk_speed = 1
	var/nextwalk = 0
	var/mob/living/carbon/human/target = null

/obj/item/clothing/mask/facehugger/can_contaminate()
	return 0

/obj/item/clothing/mask/facehugger/Destroy()
	processing_objects.Remove(src)
	target = null
	..()


/obj/item/clothing/mask/facehugger/process()
	healthcheck()
	followtarget()

/obj/item/clothing/mask/facehugger/proc/findtarget()
	if(!real) return
	for(var/mob/living/carbon/human/T in hearers(src,4))
		if(!CanHug(T))
			continue
		if(T && (T.stat != DEAD && T.stat != UNCONSCIOUS) )

			if(get_dist(src.loc, T.loc) <= 4)
				target = T
/obj/item/clothing/mask/facehugger/proc/followtarget()
	if(!real) return // Why are you trying to path stupid toy
	if(!target || target.stat == DEAD || target.stat == UNCONSCIOUS || target.status_flags & XENO_HOST)
		findtarget()
		return
	if(src.loc && src.loc == get_turf(src) && attached == 0 && stat == 0 && nextwalk <= world.time)
		nextwalk = world.time + walk_speed
		var/dist = get_dist(src.loc, target.loc)
		if(dist > 4)
			return //We'll let the facehugger do nothing for a bit, since it's fucking up.
		var/obj/item/mask = target.get_body_part_coverage(MOUTH)
		if(mask && istype(mask, /obj/item/clothing/mask/facehugger))
			var/obj/item/clothing/mask/facehugger/F = mask
			if(F.sterile) // Toy's won't prevent real huggers
				findtarget()
				return
		else
			step_towards(src, target, 0)
			if(dist <= 1)
				if(CanHug(target))
					Attach(target)
					return
				else
					target = null
					walk(src,0)
					findtarget()
					return

//END HUGGER MOVEMENT AI


/obj/item/clothing/mask/facehugger/attack_paw(user as mob) //can be picked up by aliens
	if(isalien(user))
		attack_hand(user)
		return
	else
		..()
		return

/obj/item/clothing/mask/facehugger/attack_hand(user as mob)
	if((stat == CONSCIOUS && !sterile) && !isalien(user))
		Attach(user)
		return

	// Colonial Marines code related to alien carriers
	// else
	// 	var/mob/living/carbon/alien/humanoid/carrier/carr = user
	//
	// 	if(carr && istype(carr, /mob/living/carbon/alien/humanoid/carrier))
	// 		if(carr.facehuggers >= 6)
	// 			carr << "You can't hold anymore facehuggers. You pick it up"
	// 			..()
	// 			return
	// 		if(stat != DEAD)
	// 			carr << "You pick up a facehugger"
	// 			carr.facehuggers += 1
	// 			del(src)
	//
	// 		else
	// 			user << "This facehugger is dead."
	// 			..()
	else
		..()
		return

/obj/item/clothing/mask/facehugger/proc/healthcheck()
	if(health <= 0)
		icon_state = "[initial(icon_state)]_dead"
		Die()

/obj/item/clothing/mask/facehugger/attack(mob/living/M as mob, mob/user as mob)
	..()
	user.drop_from_inventory(src)
	Attach(M)

/obj/item/clothing/mask/facehugger/New()
	if(aliens_allowed)
		..()
		if(real) // Lamarr still tries to couple with heads, but toys won't
			processing_objects.Add(src)

	else
		qdel(src)

/obj/item/clothing/mask/facehugger/examine(mob/user)
	..()
	if(!real) //Toy facehuggers are a child, avoid confusing examine text.
		return
	switch(stat)
		if(DEAD,UNCONSCIOUS)
			to_chat(user, "<span class='deadsay'>\The [src] is not moving.</span>")
		if(CONSCIOUS)
			to_chat(user, "<span class='danger'>\The [src] seems active.</span>")
	if (sterile)
		to_chat(user, "<span class='danger'>It looks like \the [src]'s proboscis has been removed.</span>")
	return

/obj/item/clothing/mask/facehugger/attackby()
	Die()
	return

/obj/item/clothing/mask/facehugger/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	return

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()
	return

/obj/item/clothing/mask/facehugger/equipped(mob/M)
	Attach(M)

/obj/item/clothing/mask/facehugger/Crossed(atom/target) // Instead of HasEntered. Probably the right proc, probably.
	HasProximity(target)
	return

/obj/item/clothing/mask/facehugger/on_found(mob/finder as mob)
	if(stat == CONSCIOUS)
		return HasProximity(finder)
	return 0

/obj/item/clothing/mask/facehugger/HasProximity(atom/movable/AM as mob|obj)
	if(CanHug(AM))
		return Attach(AM)
	return 0

/obj/item/clothing/mask/facehugger/throw_at(atom/target, range, speed)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]_thrown"
		spawn(15)
			if(icon_state == "[initial(icon_state)]_thrown")
				icon_state = "[initial(icon_state)]"

/obj/item/clothing/mask/facehugger/throw_impact(atom/hit_atom)
	..()
	if(stat == CONSCIOUS)
		icon_state = "[initial(icon_state)]"
		Attach(hit_atom)

/obj/item/clothing/mask/facehugger/proc/Attach(mob/living/M as mob)
	var/preggers = rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME)
	if( (!iscorgi(M) && !iscarbon(M)) || isalien(M))
		return 0
	if(iscarbon(M) && M.status_flags & XENO_HOST)
		visible_message("<span class='danger'>An alien tries to place a facehugger on [M] but it refuses sloppy seconds!</span>")
		return
	if(attached)
		return 0
	if(!src.Adjacent(M))
		return 0
	else
		attached++
		spawn(MAX_IMPREGNATION_TIME)
			attached = 0

	var/mob/living/L = M //just so I don't need to use :

	if(loc == L)
		return 0
	if(stat != CONSCIOUS)
		return 0
	if(!sterile)
		L.take_organ_damage(strength, 0) //done here so that even borgs and humans in helmets take damage

	L.visible_message("<span class='danger'>\The [src] leaps at [L]'s face!</span>")

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/mouth_protection = H.get_body_part_coverage(MOUTH)
		if(!real && mouth_protection)
			return //Toys really shouldn't be forcefully removing gear
		var/obj/item/clothing/mask/facehugger/hugger = H.wear_mask
		if(istype(hugger) && !hugger.sterile && !src.sterile) // Lamarr won't fight over faces and neither will normal huggers.
			return

		if(mouth_protection && mouth_protection != H.wear_mask) //can't be protected with your own mask, has to be a hat
			stat_collection.xeno.proper_head_protection++
			var/rng = 50
			if(istype(mouth_protection, /obj/item/clothing/head/helmet/space/rig))
				rng = 15
			if(prob(rng)) // Temporary balance change, all mouth-covering hats will be more effective
				H.visible_message("<span class='danger'>\The [src] smashes against [H]'s [mouth_protection], and rips it off in the process!</span>")
				H.drop_from_inventory(mouth_protection)
				GoIdle(15)
				return
			else
				H.visible_message("<span class='danger'>\The [src] bounces off of the [mouth_protection]!</span>")
				if(prob(75) && sterile == 0)
					Die()
				else
					GoIdle(15)
					return

	if(iscarbon(M))
		var/mob/living/carbon/target = L

		if(target.wear_mask)
			if(prob(20))
				return 0
			var/obj/item/clothing/W = target.wear_mask
			if(!W.canremove)
				return 0
			target.drop_from_inventory(W)

			target.visible_message("<span class='danger'>\The [src] tears \the [W] off of [target]'s face!</span>")

		src.loc = target
		target.equip_to_slot(src, slot_wear_mask)
		target.update_inv_wear_mask()

		if(!sterile) L.Paralyse((preggers/10)+10) //something like 25 ticks = 20 seconds with the default settings
	else if (iscorgi(M))
		var/mob/living/simple_animal/corgi/C = M
		src.loc = C
		C.facehugger = src
		C.wear_mask = src
		//C.regenerate_icons()

	GoIdle(150) //so it doesn't jump the people that tear it off

	spawn(preggers)
		Impregnate(L)

	return 0

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target as mob)
	if(!target || target.wear_mask != src || target.stat == DEAD) //was taken off or something
		return

	if(!sterile)
		var/obj/item/alien_embryo/E = new (target)
		target.status_flags |= XENO_HOST
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/T = target
			var/datum/organ/external/chest/affected = T.get_organ("chest")
			affected.implants += E
		target.visible_message("<span class='danger'>\The [src] falls limp after violating [target]'s face !</span>")
		stat_collection.xeno.faces_hugged++

		Die()
		icon_state = "[initial(icon_state)]_impregnated"

		if(iscorgi(target))
			var/mob/living/simple_animal/corgi/C = target
			src.loc = get_turf(C)
			C.facehugger = null
	else
		target.visible_message("<span class='danger'>\The [src] violates [target]'s face !</span>")
	return

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = "[initial(icon_state)]"
	return

/obj/item/clothing/mask/facehugger/proc/GoIdle(var/delay)
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

/*		RemoveActiveIndicators()	*/
	target = null
	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"
	if(!delay)
		delay = rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME)
	spawn(delay)
		GoActive()
	return

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD || real == 0)
		return
	target = null
/*		RemoveActiveIndicators()	*/
	processing_objects.Remove(src)
	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD

	src.visible_message("<span class='danger'>\The [src] curls up into a ball!</span>")

	return

/proc/CanHug(var/mob/M)


	if(iscorgi(M))
		return 1

	if(!iscarbon(M) || isalien(M) || isslime(M))
		return 0

	var/mob/living/carbon/C = M
	if(C && (istype(C.wear_mask, /obj/item/clothing/mask/facehugger) || C.status_flags & XENO_HOST))
		return 0
	return 1
