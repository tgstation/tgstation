/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity, modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		if(src == A)
			check_self_for_injuries()
		return
	if(!has_active_hand()) //can't attack without a hand.
		var/obj/item/bodypart/check_arm = get_active_hand()
		if(check_arm?.bodypart_disabled)
			to_chat(src, "<span class='warning'>Your [check_arm.name] is in no condition to be used.</span>")
			return

		to_chat(src, "<span class='notice'>You look at your arm and sigh.</span>")
		return

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines
	if(proximity && istype(G) && G.Touch(A,1))
		return
	//This signal is needed to prevent gloves of the north star + hulk.
	if(SEND_SIGNAL(src, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, A, proximity, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return
	SEND_SIGNAL(src, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, A, proximity, modifiers)

	if(dna?.species?.spec_unarmedattack(src, A, modifiers)) //Because species like monkeys dont use attack hand
		return
	A.attack_hand(src, modifiers)

/// Return TRUE to cancel other attack hand effects that respect it. Modifiers is the assoc list for click info such as if it was a right click.
/atom/proc/attack_hand(mob/user, modifiers)
	. = FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND))
		add_fingerprint(user)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		. = TRUE
	if(interaction_flags_atom & INTERACT_ATOM_ATTACK_HAND)
		. = _try_interact(user)

//Return a non FALSE value to cancel whatever called this from propagating, if it respects it.
/atom/proc/_try_interact(mob/user)
	if(isAdminGhostAI(user))		//admin abuse
		return interact(user)
	if(can_interact(user))
		return interact(user)
	return FALSE

/atom/proc/can_interact(mob/user)
	if(!user.can_interact_with(src))
		return FALSE
	if((interaction_flags_atom & INTERACT_ATOM_REQUIRES_DEXTERITY) && !ISADVANCEDTOOLUSER(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(!(interaction_flags_atom & INTERACT_ATOM_IGNORE_INCAPACITATED) && user.incapacitated((interaction_flags_atom & INTERACT_ATOM_IGNORE_RESTRAINED), !(interaction_flags_atom & INTERACT_ATOM_CHECK_GRAB)))
		return FALSE
	return TRUE

/atom/ui_status(mob/user)
	. = ..()
	if(!can_interact(user))
		. = min(., UI_UPDATE)

/atom/movable/can_interact(mob/user)
	. = ..()
	if(!.)
		return
	if(!anchored && (interaction_flags_atom & INTERACT_ATOM_REQUIRES_ANCHORED))
		return FALSE

/atom/proc/interact(mob/user)
	if(interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_INTERACT)
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	if(interaction_flags_atom & INTERACT_ATOM_UI_INTERACT)
		return ui_interact(user)
	return FALSE


/mob/living/carbon/human/RangedAttack(atom/A, mouseparams)
	. = ..()
	if(.)
		return
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		if(istype(G) && G.Touch(A,0)) // for magic gloves
			return TRUE

	if(isturf(A) && get_dist(src,A) <= 1)
		Move_Pulled(A)
		return TRUE

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A, proximity, modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_animal(src, modifiers)

/atom/proc/attack_animal(mob/user, modifiers)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_ANIMAL, user)

///Attacked by monkey
/atom/proc/attack_paw(mob/user, modifiers)
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_PAW, user) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	return FALSE


/*
	Aliens
	Defaults to same as monkey in most places
*/
/mob/living/carbon/alien/UnarmedAttack(atom/A, proximity, modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_alien(src, modifiers)

/atom/proc/attack_alien(mob/living/carbon/alien/user, modifiers)
	attack_paw(user)
	return


// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_larva(src)

/atom/proc/attack_larva(mob/user)
	return


/*
	Slimes
	Nothing happening here
*/
/mob/living/simple_animal/slime/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(isturf(A))
		return ..()
	A.attack_slime(src)

/atom/proc/attack_slime(mob/user)
	return


/*
	Drones
*/
/mob/living/simple_animal/drone/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_drone(src)

/atom/proc/attack_drone(mob/living/simple_animal/drone/user)
	attack_hand(user) //defaults to attack_hand. Override it when you don't want drones to do same stuff as humans.


/*
	Brain
*/

/mob/living/brain/UnarmedAttack(atom/A)//Stops runtimes due to attack_animal being the default
	return


/*
	pAI
*/

/mob/living/silicon/pai/UnarmedAttack(atom/A)//Stops runtimes due to attack_animal being the default
	return


/*
	Simple animals
*/

/mob/living/simple_animal/UnarmedAttack(atom/A, proximity, modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	if(!dextrous)
		return ..()
	if(!ismob(A))
		A.attack_hand(src, modifiers)
		update_inv_hands()


/*
	Hostile animals
*/

/mob/living/simple_animal/hostile/UnarmedAttack(atom/A)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	target = A
	if(dextrous && !ismob(A))
		..()
	else
		AttackingTarget(A)



/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/dead/new_player/ClickOn()
	return
