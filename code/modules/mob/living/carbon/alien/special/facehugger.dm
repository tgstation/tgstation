//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

//TODO: Make these simple_animals

var/const/MIN_IMPREGNATION_TIME = 100 //time it takes to impregnate someone
var/const/MAX_IMPREGNATION_TIME = 150

var/const/MIN_ACTIVE_TIME = 200 //time between being dropped and going idle
var/const/MAX_ACTIVE_TIME = 400

/obj/item/clothing/mask/facehugger
	name = "alien"
	desc = "It has some sort of a tube at the end of its tail."
	icon = 'icons/mob/alien.dmi'
	icon_state = "facehugger"
	item_state = "facehugger"
	w_class = 1 //note: can be picked up by aliens unlike most other items of w_class below 4
	flags = FPRINT | TABLEPASS | MASKCOVERSMOUTH | MASKCOVERSEYES | MASKINTERNALS
	throw_range = 5

	var/stat = CONSCIOUS //UNCONSCIOUS is the idle state in this case

	var/sterile = 0

	var/strength = 5

	var/attached = 0

/obj/item/clothing/mask/facehugger/attack_alien(user as mob) //can be picked up by aliens
	attack_hand(user)
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

/obj/item/clothing/mask/facehugger/examine()
	..()
	switch(stat)
		if(DEAD,UNCONSCIOUS)
			usr << "\red \b [src] is not moving."
		if(CONSCIOUS)
			usr << "\red \b [src] seems to be active."
	if (sterile)
		usr << "\red \b It looks like the proboscis has been removed."
	return

/obj/item/clothing/mask/facehugger/attackby()
	Die()
	return

/obj/item/clothing/mask/facehugger/bullet_act()
	Die()
	return

/obj/item/clothing/mask/facehugger/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
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

	if(loc == L) return 0
	if(stat != CONSCIOUS)	return 0
	if(!sterile) L.take_organ_damage(strength,0) //done here so that even borgs and humans in helmets take damage

	L.visible_message("\red \b [src] leaps at [L]'s face!")

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.head && H.head.flags & HEADCOVERSMOUTH)
			H.visible_message("\red \b [src] smashes against [H]'s [H.head]!")
			Die()
			return 0

	if(iscarbon(M))
		var/mob/living/carbon/target = L

		if(target.wear_mask)
			if(prob(20))	return 0
			var/obj/item/clothing/W = target.wear_mask
			if(!W.canremove)	return 0
			target.drop_from_inventory(W)

			target.visible_message("\red \b [src] tears [W] off of [target]'s face!")

		src.loc = target
		target.equip_to_slot(src, slot_wear_mask,,0)

		if(!sterile) L.Paralyse(MAX_IMPREGNATION_TIME/6) //something like 25 ticks = 20 seconds with the default settings
	else if (iscorgi(M))
		var/mob/living/simple_animal/corgi/C = M
		loc = C
		C.facehugger = src

	GoIdle() //so it doesn't jump the people that tear it off

	spawn(rand(MIN_IMPREGNATION_TIME,MAX_IMPREGNATION_TIME))
		Impregnate(L)

	return 1

/obj/item/clothing/mask/facehugger/proc/Impregnate(mob/living/target as mob)
	if(!target || target.stat == DEAD) //was taken off or something
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.wear_mask != src)
			return

	if(!sterile)
		//target.contract_disease(new /datum/disease/alien_embryo(0)) //so infection chance is same as virus infection chance
		new /obj/item/alien_embryo(target)
		target.status_flags |= XENO_HOST

		target.visible_message("\red \b [src] falls limp after violating [target]'s face!")

		Die()
		icon_state = "[initial(icon_state)]_impregnated"

		if(iscorgi(target))
			var/mob/living/simple_animal/corgi/C = target
			src.loc = get_turf(C)
			C.facehugger = null
	else
		target.visible_message("\red \b [src] violates [target]'s face!")
	return

/obj/item/clothing/mask/facehugger/proc/GoActive()
	if(stat == DEAD || stat == CONSCIOUS)
		return

	stat = CONSCIOUS
	icon_state = "[initial(icon_state)]"

/*		for(var/mob/living/carbon/alien/alien in world)
		var/image/activeIndicator = image('icons/mob/alien.dmi', loc = src, icon_state = "facehugger_active")
		activeIndicator.override = 1
		if(alien && alien.client)
			alien.client.images += activeIndicator	*/

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

	src.visible_message("\red \b[src] curls up into a ball!")

	return

/proc/CanHug(var/mob/M)

	if(iscorgi(M))
		return 1

	if(!iscarbon(M) || isalien(M))
		return 0
	var/mob/living/carbon/C = M
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(H.head && H.head.flags & HEADCOVERSMOUTH)
			return 0
	return 1
