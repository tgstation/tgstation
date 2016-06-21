/datum/locking_category/frog_climb

//HOPPER LEGIONARIES
//Weak and slow hostile mobs (30 hp, 1-10 damage)
//- Can use spears: they can grab spears from the floor and use them in melee combat (boosting melee damage to respectable 10-18), as well as throw them
//- Ability to leap: when not holding a spear, they can leap on top of their enemies and hold onto them. While holding onto an enemy, they attack twice and gain a 10% chance of stunning them with each primary attack (double attack doesn't stun)
//Starts without a spear

//HOPPER CENTURIONS
//Like legionaries, but start with one spear.

//HOPPER JAVELINEERS
//Like centurions, but start with 5 spears and try to run away from their enemies, bombarding them with spears

/mob/living/simple_animal/hostile/frog
	name = "hopper legionary"
	desc = "A small carnivorous monster roughly the size of a housecat, resembling a frog through both its appearance and its ability to leap. It kills its prey by grabbing onto them and violently beating them with their vigorous arms. They're known for their ability to use tools and spears."

	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"

	health = 30
	maxHealth = 30

	speak_chance = 1
	emote_hear = list("croaks", "mumbles something")
	emote_see = list("looks around")

	ranged = 1
	ranged_cooldown_cap = 8
	ranged_message = "leaps"

	move_to_delay = 6
	speed = 2

	harm_intent_damage = 6
	melee_damage_lower = 1
	melee_damage_upper = 10
	attacktext = "bashes"
	attack_sound = "punch"

	size = SIZE_SMALL

	var/holding_spear = 0

/mob/living/simple_animal/hostile/frog/examine(mob/user)
	..()

	if(holding_spear)
		user.show_message("<span class='notice'>It's holding a spear.</span>", MESSAGE_SEE)

/mob/living/simple_animal/hostile/frog/Shoot()
	if(locked_to) //Don't leap/throw spear if already on top of a mob
		return 0

	for(var/obj/item/weapon/spear/S in contents) //Look for a spear in inventory
		S.forceMove(get_turf(src))

		S.throw_at(target, 10, 4)
		ranged_message = "throws \a [S]"

		update_spear()
		return 1

	ranged_message = "leaps"
	src.throw_at(get_turf(target), 7, 1)
	return 1

/mob/living/simple_animal/hostile/frog/Bump(atom/A)
	if(throwing && isliving(A) && CanAttack(A)) //Hit somebody when flying
		attach(A)

	.=..()

/mob/living/simple_animal/hostile/frog/Die()
	for(var/obj/item/I in contents)
		I.forceMove(get_turf(src))

	update_spear()
	..()

/mob/living/simple_animal/hostile/frog/Cross(obj/item/weapon/spear/S)
	.=..()

	if(!locked_to && !throwing && !isDead() && istype(S) && S.throwing && isturf(S.loc))
		visible_message("<span class='notice'>\The [src] catches \the [S]!</span>")
		S.forceMove(src)
		update_spear()

/mob/living/simple_animal/hostile/frog/Move()
	..()

	if(!isDead() && isturf(loc) && !locked_to && !throwing)
		for(var/obj/item/weapon/spear/S in loc)
			S.forceMove(src)
			update_spear()

/mob/living/simple_animal/hostile/frog/update_icon()
	update_spear()
	..()

/mob/living/simple_animal/hostile/frog/Life()
	.=..()

	update_climb()

/mob/living/simple_animal/hostile/frog/proc/update_climb()
	var/mob/living/L = locked_to

	if(!istype(L))
		return

	if(incapacitated())
		return detach()

	if(!CanAttack(L))
		return detach()

/mob/living/simple_animal/hostile/frog/proc/update_spear()
	if(locate(/obj/item/weapon/spear) in contents)
		icon_state = "frog_spear"
		icon_living = "frog_spear"
		melee_damage_lower = 10
		melee_damage_upper = 18
		holding_spear = 1
		attacktext = "impales"
		attack_sound = 'sound/weapons/bladeslice.ogg'
	else
		icon_state = "frog"
		icon_living = "frog"
		melee_damage_lower = 1
		melee_damage_upper = 10
		holding_spear = 0
		attacktext = "bashes"
		attack_sound = "punch"

/mob/living/simple_animal/hostile/frog/proc/detach()
	unlock_from()

	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)

/mob/living/simple_animal/hostile/frog/proc/attach(mob/living/victim)
	victim.lock_atom(src, /datum/locking_category/frog_climb)

	to_chat(victim, "<span class='danger'>\The [src] climbs on top of you!</span>")

	pixel_x = rand(-8,8)
	pixel_y = rand(-8,8)

/mob/living/simple_animal/hostile/frog/AttackingTarget()
	.=..()

	if(locked_to == target && isliving(target))
		var/mob/living/L = target

		if(prob(10))
			to_chat(L, "<span class='userdanger'>\The [src] throws you to the ground!</span>")
			L.Weaken(rand(2,5))

/mob/living/simple_animal/hostile/frog/adjustBruteLoss(amount)
	.=..()

	if(locked_to && prob(amount * 5))
		detach()


/mob/living/simple_animal/hostile/frog/centurion
	name = "hopper centurion"
	desc = "A legionary that has proven to be a mighty fighter. They often carry spears that they use for both melee and ranged combat."

	health = 50
	maxHealth = 50

	ranged_cooldown_cap = 4 //Shorter leap / spear throw cooldown

/mob/living/simple_animal/hostile/frog/centurion/New()
	..()

	new /obj/item/weapon/spear(src)
	update_spear()

/mob/living/simple_animal/hostile/frog/javelineer
	name = "hopper javelineer"
	desc = "A legionary with great marksmanship, it carries a bag of spears that it uses to harass its enemies from distance."

	health = 35
	maxHealth = 35

	retreat_distance = 3
	minimum_distance = 3

	ranged_cooldown_cap = 4 //Shorter leap / spear throw cooldown

/mob/living/simple_animal/hostile/frog/javelineer/New()
	..()

	for(var/i = 0 to 3)
		new /obj/item/weapon/spear(src)

	update_spear()
