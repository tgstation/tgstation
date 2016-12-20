

/mob/living/carbon/monkey
	var/aggressive=0
	var/frustration=0
	var/pickupTimer=0
	var/vision_range = 9
	var/list/enemies = list()
	var/mob/living/target
	var/obj/item/pickupTarget
	var/mode = MONKEY_IDLE
	var/list/myPath = list()
	var/list/blacklistItems = list()
	var/maxStepsTick = 6
	var/best_force = 0
	var/martial_art = new/datum/martial_art
	var/resisting = FALSE
	var/obj/machinery/disposal/bodyDisposal = null

// taken from /mob/living/carbon/human/interactive/
/mob/living/carbon/monkey/proc/walk2derpless(target)
	if(!target || resisting)
		return 0

	if(myPath.len <= 0)
		myPath = get_path_to(src, get_turf(target), /turf/proc/Distance, MAX_RANGE_FIND + 1, 250,1)

	if(myPath)
		if(myPath.len > 0)
			for(var/i = 0; i < maxStepsTick; ++i)
				if(!IsDeadOrIncap())
					if(myPath.len >= 1)
						walk_to(src,myPath[1],0,5)
						myPath -= myPath[1]
			return 1
	return 0

// taken from /mob/living/carbon/human/interactive/
/mob/living/carbon/monkey/proc/IsDeadOrIncap(checkDead = TRUE)
	if(!canmove)
		return 1
	if(health <= 0 && checkDead)
		return 1
//	if(restrained())
//		return 1
	if(paralysis)
		return 1
	if(stunned)
		return 1
	if(stat)
		return 1
	return 0

/mob/living/carbon/monkey/proc/equip_item(var/obj/item/I)

	if(I.loc == src)
		return TRUE

	// WEAPONS
	if(istype(I, /obj/item/weapon))
		var/obj/item/weapon/W = I
		if(W.force >= best_force)
			put_in_hands(W)
			best_force = W.force
			return TRUE

	// CLOTHING
	else if(istype(I,/obj/item/clothing))
		var/obj/item/clothing/C = I
		monkeyDrop(C)
		spawn(5)
			if(!equip_to_appropriate_slot(C))
				unEquip(get_item_by_slot(C)) // remove the existing item if worn
				spawn(5)
					equip_to_appropriate_slot(C)
		return TRUE

	// EVERYTHING ELSE
	else
		if(!get_item_for_held_index(1) || !get_item_for_held_index(2))
			put_in_hands(I)
			return TRUE

	blacklistItems[I] ++
	return FALSE

/mob/living/carbon/monkey/resist_restraints()
	var/obj/item/I = null
	if(handcuffed)
		I = handcuffed
	else if(legcuffed)
		I = legcuffed
	if(I)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		cuff_resist(I, 900)

/mob/living/carbon/monkey/proc/handle_combat()

	if(on_fire || buckled || restrained())
		if(!resisting && prob(50))
			resisting = TRUE
			walk_to(src,0)
			resist()
	else
		resisting = FALSE


	if(IsDeadOrIncap())
		return TRUE

	// have we been disarmed
	if(!locate(/obj/item/weapon) in held_items)
		best_force = 0

	if(restrained() || blacklistItems[pickupTarget])
		pickupTarget = null

	if(!resisting && pickupTarget)
		pickupTimer++

		// next to target
		if(Adjacent(pickupTarget) || Adjacent(pickupTarget.loc))
			walk2derpless(pickupTarget.loc)

			// who cares about these items, i want that one!
			for(var/obj/item/I in held_items)
				if(I)
					monkeyDrop(I)

			// on floor
			if(isturf(pickupTarget.loc))
				equip_item(pickupTarget)

			// in someones hand
			else if(ismob(pickupTarget.loc))
				var/mob/M = pickupTarget.loc
				M.visible_message("[src] starts trying to take [pickupTarget] from [M]", "[src] tries to take [pickupTarget]!")
				if(do_mob(src, M, 20) && pickupTarget)
					for(var/obj/item/I in M.held_items)
						if(I == pickupTarget)
							M.visible_message("<span class='danger'>[src] snatches [pickupTarget] from [M].</span>", "<span class='userdanger'>[src] snatched [pickupTarget]!</span>")
							M.unEquip(pickupTarget)
							equip_item(pickupTarget)
							return TRUE

			pickupTarget = null
			pickupTimer = 0
		else
			if(pickupTimer >= 8)
				blacklistItems[pickupTarget] ++
				pickupTarget = null
				pickupTimer = 0
			else
				walk2derpless(pickupTarget.loc)

		return TRUE

	// nuh uh you don't pull me!
	if(pulledby && (mode != MONKEY_IDLE || prob(5)))
		if(Adjacent(pulledby))
			a_intent = INTENT_DISARM
			pulledby.attack_paw(src)
			retaliate(pulledby)
			return TRUE

	// nrrr, RARRRGH
//	if(buckled)
//		resist_buckle()

	switch(mode)

		if(MONKEY_IDLE)		// idle

			var/list/around = view(src, vision_range)
			bodyDisposal = locate(/obj/machinery/disposal/) in around

			// scan for enemies
			for(var/mob/living/L in around)
				if(enemies[L])
					if(L.stat == CONSCIOUS)
						emote(pick("roar","screech"))
						retaliate(L)
						return TRUE
					else if(bodyDisposal)
						target = L
						mode = MONKEY_DISPOSE
						return TRUE

			// pickup any nearby objects
			if(!pickupTarget && prob(5))
				var/obj/item/I = locate(/obj/item/) in oview(5,src)
				if(I && !blacklistItems[I])
					pickupTarget = I

			// I WANNA STEAL
			if(!pickupTarget && prob(5))
				var/mob/living/carbon/human/H = locate(/mob/living/carbon/human/) in oview(5,src)
				if(H)
					pickupTarget = pick(H.held_items)

			// clear any combat walking
			if(!resisting)
				walk_to(src,0)

			return resisting

		if(MONKEY_HUNT)		// hunting for attacker
			if(health < 50)
				mode = MONKEY_FLEE
				spawn(1)
					handle_combat()

			if(target != null)
				walk2derpless(target)

			// pickup any nearby weapon
			if(!pickupTarget && prob(20))
				var/obj/item/weapon/W = locate(/obj/item/weapon/) in oview(2,src)
				if(W && !blacklistItems[W] && W.force > best_force)
					pickupTarget = W

			// recruit other monkies
			var/list/around = view(src, vision_range)
			for(var/mob/living/carbon/monkey/M in around)
				if(M.mode == MONKEY_IDLE && prob(25))
					M.emote(pick("roar","screech"))
					M.target = target
					M.mode = MONKEY_HUNT

			// switch targets
			for(var/mob/living/L in around)
				if(L != target && enemies[L] && L.stat == CONSCIOUS && prob(25))
					target = L
					return TRUE

			// if can't reach target for long enough, go idle
			if(frustration >= 8)
				back_to_idle()
				return TRUE

			if(target && target.stat == CONSCIOUS)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc))	// if right next to perp
					var/obj/item/weapon/Weapon = locate(/obj/item/weapon) in held_items

					// attack with weapon if we have one
					if(Weapon)

						// if the target has a weapon, 50% change to disarm them
						if((locate(/obj/item/weapon) in target.held_items) && prob(50))

							pickupTarget = locate(/obj/item/weapon) in target.held_items

							a_intent = INTENT_DISARM
							target.attackby(Weapon, src)
							attacked(target)

						else
							a_intent = INTENT_HARM
							target.attackby(Weapon, src)
							attacked(target)
					else

						// if the target has a weapon, 50% change to disarm them
						if((locate(/obj/item/weapon) in target.held_items) && prob(50))

							pickupTarget = locate(/obj/item/weapon) in target.held_items

							a_intent = INTENT_DISARM
							target.attack_paw(src)
							attacked(target)

						else
							a_intent = INTENT_HARM
							target.attack_paw(src)
							attacked(target)
					return TRUE

				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(MONKEY_FLEE)
			var/list/around = view(src, vision_range)
			target = null
			for(var/mob/living/carbon/C in around)
				if(enemies[C] && C.stat == CONSCIOUS)
					target = C

			if(target != null)
				walk_away(src, target, vision_range, 5)
			else
				mode = MONKEY_IDLE

			return TRUE

		if(MONKEY_DISPOSE)

			// if can't dispose of body go back to idle
			if(!target || !bodyDisposal || frustration >= 16)
				back_to_idle()
				return TRUE

			if(target.pulledby != src)

				walk2derpless(target.loc)

				if(Adjacent(target) && isturf(target.loc))
					a_intent = INTENT_GRAB
					target.grabbedby(src)
				else
					var/turf/olddist = get_dist(src, target)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0

			else
				walk2derpless(bodyDisposal.loc)

				if(Adjacent(bodyDisposal))
					bodyDisposal.stuff_mob_in(target, src)
				else
					var/turf/olddist = get_dist(src, bodyDisposal)
					if((get_dist(src, bodyDisposal)) >= (olddist))
						frustration++
					else
						frustration = 0

			return TRUE



	return resisting

/mob/living/carbon/monkey/proc/back_to_idle()
	mode = MONKEY_IDLE
	target = null
	a_intent = INTENT_HELP
	frustration = 0

// handle de-aggro
/mob/living/carbon/monkey/proc/attacked(mob/living/carbon/H)
	if(prob(25))
		enemies[H] --

	if(enemies[H] <= 0)
		enemies.Remove(H)
		if( target == H )
			back_to_idle()

/mob/living/carbon/monkey/proc/retaliate(mob/living/L)
	mode = MONKEY_HUNT
	target = L
	enemies[L] += 4

	if(a_intent != INTENT_HARM)
		emote(pick("roar","screech"))
		a_intent = INTENT_HARM

/mob/living/carbon/monkey/attack_hand(mob/living/L)
	if(L.a_intent == INTENT_HARM && prob(95))
		retaliate(L)
	else if(L.a_intent == INTENT_DISARM && prob(20))
		retaliate(L)
	return ..()

/mob/living/carbon/monkey/attack_paw(mob/living/L)
	if(L.a_intent == INTENT_HARM && prob(95))
		retaliate(L)
	else if(L.a_intent == INTENT_DISARM && prob(20))
		retaliate(L)
	return ..()

/mob/living/carbon/monkey/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if((W.force) && (!target) && (W.damtype != STAMINA) )
		retaliate(user)

/mob/living/carbon/monkey/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health)
				retaliate(Proj.firer)
	..()

/mob/living/carbon/monkey/hitby(atom/movable/AM, skipcatch = 0, hitpush = 1, blocked = 0)
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		if(I.throwforce < src.health && I.thrownby && ishuman(I.thrownby))
			var/mob/living/carbon/human/H = I.thrownby
			retaliate(H)
	..()

/mob/living/carbon/monkey/Crossed(atom/movable/AM)
	if(!IsDeadOrIncap() && ismob(AM) && target)
		var/mob/living/carbon/C = AM
		if(!istype(C) || !C || in_range(src, target))
			return
		C.visible_message("<span class='warning'>[pick( \
						  "[C] dives out of [src]'s way!", \
						  "[C] stumbles over [src]!", \
						  "[C] jumps out of [src]'s path!", \
						  "[C] trips over [src] and falls!", \
						  "[C] topples over [src]!", \
						  "[C] leaps out of [src]'s way!")]</span>")
		C.Weaken(2)
		return
	..()

/mob/living/carbon/monkey/proc/take_to_slot(obj/item/G)
	var/list/slots = list ("left hand" = slot_hands,"right hand" = slot_hands)
	G.loc = src
	if(G.force && G.force > best_force)
		best_force = G.force
	equip_in_one_of_slots(G, slots)
	// update_hands = 1

/mob/living/carbon/monkey/proc/monkeyDrop(var/obj/item/A)
	if(A)
		unEquip(A)
		A.loc = get_turf(src) // drop item works inconsistently
		update_icons()