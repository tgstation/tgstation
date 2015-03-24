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
	if(ismob(A))
		delayNextAttack(10)
	if(proximity && istype(G) && G.Touch(A, src, 1))
		return

	if(src.can_use_active_hand())
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
		user << "Your [user.hand ? "left hand" : "right hand"] is not fine enough for this action."

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
	var/dam_zone = ran_zone(pick("chest", "l_hand", "r_hand", "l_leg", "r_leg"))
	var/armor = ML.run_armor_check(dam_zone, "melee")
	if(prob(75))
		ML.apply_damage(rand(1,3), BRUTE, dam_zone, armor)
		for(var/mob/O in viewers(ML, null))
			O.show_message("\red <B>[name] has bit [ML]!</B>", 1)
		if(armor >= 2) return
		if(ismonkey(ML))
			for(var/datum/disease/D in viruses)
				if(istype(D, /datum/disease/jungle_fever))
					ML.contract_disease(D,1,0)
	else
		for(var/mob/O in viewers(ML, null))
			O.show_message("\red <B>[src] has attempted to bite [ML]!</B>", 1)

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
