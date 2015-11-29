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
	body_parts_covered = HEAD|MOUTH|EYES
	throw_range = 5
	var/real = 1 //Facehuggers are real, toys are not.

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case

	var/sterile = 0

	var/strength = 5

	var/attached = 0

/obj/item/clothing/mask/facehugger/can_contaminate()
	return 0

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
	else
		..()
		return

/obj/item/clothing/mask/facehugger/attack(mob/living/M as mob, mob/user as mob)
	..()
	user.drop_from_inventory(src)
	Attach(M)

/obj/item/clothing/mask/facehugger/New()
	if(aliens_allowed)
		..()
	else
		del(src)

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

/obj/item/clothing/mask/facehugger/attackby()
	Die()
	return

/obj/item/clothing/mask/facehugger/bullet_act()
	Die()
	return

/obj/item/clothing/mask/facehugger/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		Die()
	return

/obj/item/clothing/mask/facehugger/equipped(mob/M)
	Attach(M)

/obj/item/clothing/mask/facehugger/Crossed(atom/target)
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

/obj/item/clothing/mask/facehugger/proc/Attach(M as mob)
	if( (!iscorgi(M) && !iscarbon(M)) || isalien(M))
		return 0
	if(attached)
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

	L.visible_message("<span class='danger'>\The [src] leaps at [L]'s face !</span>")

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/obj/item/mouth_protection = H.get_body_part_coverage(MOUTH)
		if(mouth_protection && mouth_protection != H.wear_mask) //can't be protected with your own mask, has to be a hat
			H.visible_message("<span class='danger'>\The [src] smashes against [H]'s [mouth_protection] !</span>")
			Die()
			return 0

	if(iscarbon(M))
		var/mob/living/carbon/target = L

		if(target.wear_mask)
			if(prob(20))
				return 0
			var/obj/item/clothing/W = target.wear_mask
			if(!W.canremove)
				return 0
			target.drop_from_inventory(W)

			target.visible_message("<span class='danger'>\The [src] tears \the [W] off of [target]'s face !</span>")

		target.equip_to_slot(src, slot_wear_mask)

		if(!sterile) L.Paralyse(MAX_IMPREGNATION_TIME/6) //something like 25 ticks = 20 seconds with the default settings
	else if(iscorgi(M))
		var/mob/living/simple_animal/corgi/C = M
		src.loc = C
		C.facehugger = src
		C.wear_mask = src
		//C.regenerate_icons()

	GoIdle() //so it doesn't jump the people that tear it off

	spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
		Impregnate(L)

	return 0

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target as mob)
	if(!target || target.wear_mask != src || target.stat == DEAD) //was taken off or something
		return

	if(!sterile)
		new /obj/item/alien_embryo(target)
		target.status_flags |= XENO_HOST

		target.visible_message("<span class='danger'>\The [src] falls limp after violating [target]'s face !</span>")

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

/obj/item/clothing/mask/facehugger/proc/GoIdle()
	if(stat == DEAD || stat == UNCONSCIOUS)
		return

/*		RemoveActiveIndicators()	*/

	stat = UNCONSCIOUS
	icon_state = "[initial(icon_state)]_inactive"

	spawn(rand(MIN_ACTIVE_TIME,MAX_ACTIVE_TIME))
		GoActive()
	return

/obj/item/clothing/mask/facehugger/proc/Die()
	if(stat == DEAD)
		return

/*		RemoveActiveIndicators()	*/

	icon_state = "[initial(icon_state)]_dead"
	stat = DEAD

	src.visible_message("<span class='danger'>\The [src] curls up into a ball !</span>")

	return

/proc/CanHug(var/mob/M)


	if(iscorgi(M))
		return 1

	if(!iscarbon(M) || isalien(M))
		return 0

	var/mob/living/carbon/C = M
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.check_body_part_coverage(MOUTH) || (locate(/obj/item/alien_embryo) in H))
			return 0
	return 1
