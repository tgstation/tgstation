/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a mob. What this means is that these datums
have ways of interacting with a specific mob and control it.
*/
///HISS HISSSSSS HISSS (Hello good sirs, do you by chance have a boot for me to chill out in? please no step, thank you :))

/datum/ai_controller/snake
	blackboard = list(
	BB_SNAKE_ENEMIES = list(),
	BB_SNAKE_FRIENDS = list(),
	BB_SNAKE_BOOT = null,
	BB_SNAKE_CURRENT_RETREAT_TARGET = null,
	BB_SNAKE_CURRENT_ATTACK_TARGET = null,
	BB_SNAKE_CURRENT_ATTACK_TARGET)

/datum/ai_controller/snake/TryPossessPawn(atom/new_pawn)
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, .proc/on_attack_hand)
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_PAW, .proc/on_attack_paw)
	RegisterSignal(new_pawn, COMSIG_ATOM_BULLET_ACT, .proc/on_bullet_act)
	RegisterSignal(new_pawn, COMSIG_ATOM_HITBY, .proc/on_hitby)
	RegisterSignal(new_pawn, COMSIG_LIVING_START_PULL, .proc/on_startpulling)
	RegisterSignal(new_pawn, COMSIG_ATOM_HULK_ATTACK, .proc/on_attack_hulk)
	return ..() //Run parent at end

/datum/ai_controller/snake/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_LIVING_START_PULL, COMSIG_ATOM_HULK_ATTACK))
	return ..() //Run parent at end

/datum/ai_controller/snake/proc/went_in_boot()
	RegisterSignal(pawn, COMSIG_MOVABLE_MOVED, .proc/on_moved)

/datum/ai_controller/snake/proc/on_moved(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER

	if(mover.loc != oldloc) //out of the boot :^(
		UnregisterSignal(mover, COMSIG_MOVABLE_MOVED)
		blackboard[BB_SNAKE_BOOT] = null

/datum/ai_controller/snake/able_to_run()
	var/mob/living/living_pawn = pawn

	if(living_pawn.stat)
		return FALSE
	return ..()

/datum/ai_controller/snake/SelectBehaviors(delta_time)
	current_behaviors = list()
	var/mob/living/living_pawn = pawn

	var/obj/item/clothing/shoes/cowboy/foundboot = blackboard[BB_SNAKE_BOOT]

	if(foundboot)
		return //eh, we're just vibing in here

	var/list/enemies = blackboard[BB_SNAKE_ENEMIES]
	var/mob/living/retreating = blackboard[BB_SNAKE_CURRENT_RETREAT_TARGET]

	if(length(enemies)) //We have enemies

		var/mob/living/selected_enemy

		for(var/mob/living/possible_enemy in view(7, living_pawn))
			if(possible_enemy == living_pawn || (!enemies[possible_enemy])) //Are they an enemy? (And do we even care?)
				continue

			selected_enemy = possible_enemy
			break
		if(selected_enemy) //we merely care that we have an enemy, not their status or anything. again, it's not a kill thing! just a revenge thing.
			blackboard[BB_SNAKE_CURRENT_ATTACK_TARGET] = selected_enemy
			current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/snake_attack_mob)
			return //Focus on this
	else if(retreating)
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/snake_flee)
	else
		for(var/mob/living/simple_animal/mouse/snack in view(7, living_pawn))//gonna try looking for mice
			retaliate(snack)

	if(!foundboot && DT_PROB(SNAKE_SHENANIGAN_PROB, delta_time))
		if(TryFindBoot()) //Found a boot!!
			return

///let's find a boot!
/datum/ai_controller/snake/proc/TryFindBoot()
	var/mob/living/living_pawn = pawn

	var/obj/item/clothing/shoes/cowboy/suitable_boot = locate(/obj/item/clothing/shoes/cowboy) in oview(2, living_pawn)

	if(suitable_boot && !suitable_boot.occupants.len)
		blackboard[BB_SNAKE_BOOT] = suitable_boot
		current_movement_target = suitable_boot
		current_behaviors += GET_AI_BEHAVIOR(/datum/ai_behavior/snake_boot)

///Reactive events to being hit, a little bit different than monkey AI as it adds one bite to an enemy per offense. After it runs out of bites it will try to flee
/datum/ai_controller/snake/proc/retaliate(mob/living/L)

	var/list/friends = blackboard[BB_SNAKE_FRIENDS]
	if(friends[L]) //friendship broken, but not enemies yet.
		friends.Remove(L)
		return

	var/list/enemies = blackboard[BB_SNAKE_ENEMIES]
	enemies[L] += ONE_SNAKE_BITE

//Makes attacking the snake only lose friendship instead of have it bite you, it will now fall asleep around you, you can drag it, etc.
/datum/ai_controller/snake/proc/start_friendship(mob/living/L)
	var/list/friends = blackboard[BB_SNAKE_FRIENDS]
	friends |= L

/datum/ai_controller/snake/proc/on_attackby(datum/source, obj/item/I, mob/user)
	SIGNAL_HANDLER

	if(istype(I, /obj/item/food/deadmouse)) //taming (:pogofgreed:)
		start_friendship(user)
		var/mob/living/living_pawn = pawn
		living_pawn.visible_message("<span class='notice'>[living_pawn] consumes [I] in a single gulp!</span>", "<span class='notice'>You consume [I] in a single gulp!</span>")
		QDEL_NULL(I)
		living_pawn.adjustBruteLoss(-2)
		return

	var/list/friends = blackboard[BB_SNAKE_FRIENDS]
	if(friends[user])
		return //no worries

	if(I.force && I.damtype != STAMINA)
		retaliate(user)

/datum/ai_controller/snake/proc/on_attack_hand(datum/source, mob/living/L)
	SIGNAL_HANDLER

	var/list/friends = blackboard[BB_SNAKE_FRIENDS]
	if(friends[L])
		return //no worries

	retaliate(L)

/datum/ai_controller/snake/proc/on_attack_paw(datum/source, mob/living/L)
	SIGNAL_HANDLER

	var/list/friends = blackboard[BB_SNAKE_FRIENDS]
	if(friends[L])
		return //no worries

	retaliate(L)

/datum/ai_controller/snake/proc/on_bullet_act(datum/source, obj/projectile/Proj)
	SIGNAL_HANDLER
	var/mob/living/living_pawn = pawn
	if(istype(Proj , /obj/projectile/beam)||istype(Proj, /obj/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < living_pawn.health && isliving(Proj.firer))
				retaliate(Proj.firer)

/datum/ai_controller/snake/proc/on_hitby(datum/source, atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(istype(AM, /obj/item))
		var/mob/living/living_pawn = pawn
		var/obj/item/I = AM
		if(I.throwforce < living_pawn.health && ishuman(I.thrownby))
			var/mob/living/carbon/human/H = I.thrownby
			retaliate(H)

/datum/ai_controller/snake/proc/on_startpulling(datum/source, atom/movable/puller, state, force)
	SIGNAL_HANDLER

	var/list/friends = blackboard[BB_SNAKE_FRIENDS]
	if(friends[puller]) //unless you're their friend...
		return TRUE

	var/mob/living/living_pawn = pawn
	if(!living_pawn.stat) // ...snakes hate this shit man just trust me
		retaliate(living_pawn.pulledby)
		return TRUE

/datum/ai_controller/snake/proc/on_attack_hulk(datum/source, mob/user)
	SIGNAL_HANDLER
	retaliate(user)

