<<<<<<< HEAD
/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)

	if(!has_active_hand()) //can't attack without a hand.
		src << "<span class='notice'>You look at your arm and sigh.</span>"
		return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A,1))
		return

	var/override = 0

	for(var/datum/mutation/human/HM in dna.mutations)
		override += HM.on_attack_hand(src, A)

	if(override)
		return

	A.attack_hand(src)

/atom/proc/attack_hand(mob/user)
	return

/atom/proc/interact(mob/user)
	return

/*
/mob/living/carbon/human/RestrainedClickOn(var/atom/A) ---carbons will handle this
	return
*/

/mob/living/carbon/RestrainedClickOn(atom/A)
	return 0

/mob/living/carbon/human/RangedAttack(atom/A)
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A,0)) // for magic gloves
			return

	for(var/datum/mutation/human/HM in dna.mutations)
		HM.on_ranged_attack(src, A)

	var/turf/T = A
	if(istype(T) && get_dist(src,T) <= 1)
		src.Move_Pulled(T)

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A)
	A.attack_animal(src)

/atom/proc/attack_animal(mob/user)
	return
/mob/living/RestrainedClickOn(atom/A)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(atom/A)
	A.attack_paw(src)
/atom/proc/attack_paw(mob/user)
	return

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(atom/A)
	if(..())
		return
	if(a_intent != "harm" || !ismob(A))
		return
	if(is_muzzled())
		return
	var/mob/living/carbon/ML = A
	var/dam_zone = pick("chest", "l_hand", "r_hand", "l_leg", "r_leg")
	var/obj/item/bodypart/affecting = null
	if(ishuman(ML))
		var/mob/living/carbon/human/H = ML
		affecting = H.get_bodypart(ran_zone(dam_zone))
	var/armor = ML.run_armor_check(affecting, "melee")
	if(prob(75))
		ML.apply_damage(rand(1,3), BRUTE, affecting, armor)
		ML.visible_message("<span class='danger'>[name] bites [ML]!</span>", \
						"<span class='userdanger'>[name] bites [ML]!</span>")
		if(armor >= 2)
			return
		for(var/datum/disease/D in viruses)
			ML.ForceContractDisease(D)
	else
		ML.visible_message("<span class='danger'>[src] has attempted to bite [ML]!</span>")

/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/UnarmedAttack(atom/A)
	A.attack_alien(src)
/atom/proc/attack_alien(mob/user)
	attack_paw(user)
	return
/mob/living/carbon/alien/RestrainedClickOn(atom/A)
	return

// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(atom/A)
	A.attack_larva(src)
/atom/proc/attack_larva(mob/user)
	return


/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/UnarmedAttack(atom/A)
	A.attack_slime(src)
/atom/proc/attack_slime(mob/user)
	return
/mob/living/simple_animal/slime/RestrainedClickOn(atom/A)
	return

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/ClickOn()
	return
=======
/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(var/atom/A, var/proximity, var/params)
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	if(proximity && istype(G) && G.Touch(A, src, 1))
		return

	if(a_intent == "hurt" && A.loc != src)

		switch(attack_type) //Special attacks - kicks, bites
			if(ATTACK_KICK)
				if(can_kick(A))

					delayNextAttack(10)

					if(!A.kick_act(src)) //kick_act returns 1 if the kick failed or couldn't be done
						return

					delayNextAttack(-10) //This is only called when the kick fails
				else
					set_attack_type() //Reset attack type

			if(ATTACK_BITE)
				if(can_bite(A))

					delayNextAttack(10)

					if(!A.bite_act(src)) //bite_act returns 1 if the bite failed or couldn't be done
						return

					delayNextAttack(-10) //This is only called when the bite fails
				else
					set_attack_type() //Reset attack type

	if(ismob(A))
		delayNextAttack(10)

	if(src.can_use_hand())
		A.attack_hand(src, params)
	else
		A.attack_stump(src, params)
	return

/atom/proc/attack_hand(mob/user as mob, params)
	return

//called when we try to click but have no hand
//good for general purposes
/atom/proc/attack_stump(mob/user as mob, params)
	if(!requires_dexterity(user))
		attack_hand(user) //if the object doesn't need dexterity, we can use our stump
	else
		to_chat(user, "Your [user.get_index_limb_name(user.active_hand)] is not fine enough for this action.")

/atom/proc/requires_dexterity(mob/user)
	return 0

/mob/living/carbon/human/RestrainedClickOn(var/atom/A)
	return

/mob/living/carbon/human/RangedAttack(var/atom/A)
	if(!gloves && !mutations.len) return
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A, src, 0)) // for magic gloves
			return
	if(mutations.len)
		if((M_LASER in mutations) && a_intent == I_HURT)
			LaserEyes(A) // moved into a proc below

		else if(M_TK in mutations)
			/*switch(get_dist(src,A))
				if(1 to 5) // not adjacent may mean blocked by window
					Next_move += 2
				if(5 to 7)
					Next_move += 5
				if(8 to 15)
					Next_move += 10
				if(16 to 128)
					return
			*/
			A.attack_tk(src)

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(var/atom/A)
	if(ismob(A))
		delayNextAttack(10)
	A.attack_animal(src)
	return

/atom/proc/attack_animal(mob/user as mob)
	return
/mob/living/RestrainedClickOn(var/atom/A)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(var/atom/A)
	if(ismob(A))
		delayNextAttack(10)
	A.attack_paw(src)
	return

/atom/proc/attack_paw(mob/user as mob)
	return

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(var/atom/A)
	if(a_intent != I_HURT || !ismob(A)) return
	delayNextAttack(10)
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/mob/living/carbon/ML = A
	var/dam_zone = ran_zone(pick(LIMB_CHEST, LIMB_LEFT_HAND, LIMB_RIGHT_HAND, LIMB_LEFT_LEG, LIMB_RIGHT_LEG))
	var/armor = ML.run_armor_check(dam_zone, "melee")
	if(prob(75))
		ML.apply_damage(rand(1,3), BRUTE, dam_zone, armor)
		for(var/mob/O in viewers(ML, null))
			O.show_message("<span class='danger'>[name] has bit [ML]!</span>", 1)
		if(armor >= 2) return
		if(ismonkey(ML))
			for(var/datum/disease/D in viruses)
				if(istype(D, /datum/disease/jungle_fever))
					ML.contract_disease(D,1,0)
	else
		for(var/mob/O in viewers(ML, null))
			O.show_message("<span class='danger'>[src] has attempted to bite [ML]!</span>", 1)

/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/UnarmedAttack(var/atom/A)
	if(ismob(A))
		delayNextAttack(10)
	A.attack_alien(src)
	return

/atom/proc/attack_alien(mob/user as mob)
	attack_paw(user)
	return
/mob/living/carbon/alien/RestrainedClickOn(var/atom/A)
	return

// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(var/atom/A)
	if(ismob(A))
		delayNextAttack(10)
	A.attack_larva(src)
	return

/atom/proc/attack_larva(mob/user as mob)
	return


/*
	Slimes
	Nothing happening here
*/
/mob/living/carbon/slime/UnarmedAttack(var/atom/A)
	A.attack_slime(src)
	return
/atom/proc/attack_slime(mob/user as mob)
	return
/mob/living/carbon/slime/RestrainedClickOn(var/atom/A)
	return

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/ClickOn()
	return

/*
	Constructs
*/

/mob/living/simple_animal/construct/UnarmedAttack(atom/A)
	if(ismob(A))
		delayNextAttack(10)
	if(!A.attack_construct(src))//does attack_construct do something to that atom? if no, just do attack_animal
		A.attack_animal(src)

/mob/living/simple_animal/construct/RangedAttack(atom/A)
	A.attack_construct(src)

/atom/proc/attack_construct(mob/user as mob,var/dist = null)
	return 0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
