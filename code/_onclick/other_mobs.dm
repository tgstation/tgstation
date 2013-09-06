
// Humans
/mob/living/carbon/human/UnarmedAttack(var/atom/A, var/proximity)
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.

	if(proximity && istype(G) && G.Touch(A,1))
		return

	A.attack_hand(src)
/atom/proc/attack_hand(mob/user as mob)
	return

/mob/living/carbon/human/RestrainedClickOn(var/atom/A)
	A.hand_h(src)
/atom/proc/hand_h(mob/user as mob)			//human (hand) - restrained
	return

/mob/living/carbon/human/RangedAttack(var/atom/A)
	var/obj/item/clothing/gloves/G = gloves
	if((LASER in mutations) && a_intent == "harm")
		LaserEyes(A) // moved into a proc below

	else if(istype(G) && G.Touch(A,0)) // for magic gloves
		return

	else if(TK in mutations)
		switch(get_dist(src,A))
			if(1 to 5) // not adjacent may mean blocked by window
				next_move += 2
			if(5 to 7)
				next_move += 5
			if(8 to 15)
				next_move += 10
			if(16 to 128)
				return
		A.attack_tk(src)


// Animals & All Unspecified
/mob/living/UnarmedAttack(var/atom/A)
	A.attack_animal(src)
/atom/proc/attack_animal(mob/user as mob)
	return
/mob/living/RestrainedClickOn(var/atom/A)
	A.hand_a(src)
/atom/proc/hand_an(mob/user as mob)
	return


// Monkeys
/mob/living/carbon/monkey/UnarmedAttack(var/atom/A)
	A.attack_paw(src)
/atom/proc/attack_paw(mob/user as mob)
	return
/mob/living/carbon/monkey/RestrainedClickOn(var/atom/A)
	A.hand_p(src)
/atom/proc/hand_p(mob/user as mob)			//monkey (paw) - restrained
	return


//Aliens - Defaults to same as monkey in most places
/mob/living/carbon/alien/humanoid/UnarmedAttack(var/atom/A)
	A.attack_alien(src)
/atom/proc/attack_alien(mob/user as mob)
	attack_paw(user)
	return
/mob/living/carbon/alien/humanoid/RestrainedClickOn(var/atom/A)
	A.hand_al(src)
/atom/proc/hand_al(mob/user as mob)			//alien - restrained
	hand_p(user)
	return

// Babby aliens
/mob/living/carbon/alien/larva/UnarmedAttack(var/atom/A)
	A.attack_larva(src)
/atom/proc/attack_larva(mob/user as mob)
	return


// Slimes
/mob/living/carbon/slime/UnarmedAttack(var/atom/A)
	A.attack_slime(src)
/atom/proc/attack_slime(mob/user as mob)
	return
/mob/living/carbon/slime/RestrainedClickOn(var/atom/A)
	A.hand_s(src)
/atom/proc/hand_s(mob/user as mob)			//slime - restrained
	return

/mob/new_player/ClickOn()
	return


// Allow ventcrawling - Monkeys, aliens, and slimes
/obj/machinery/atmospherics/unary/vent_pump/AltClick(var/mob/living/carbon/ML)
	if(!istype(ML))
		return
	var/list/ventcrawl_verbs = list(/mob/living/carbon/monkey/verb/ventcrawl, /mob/living/carbon/alien/verb/ventcrawl, /mob/living/carbon/slime/verb/ventcrawl)
	if(length(ML.verbs & ventcrawl_verbs)) // alien queens have this removed, an istype would be coplicated
		ML.handle_ventcrawl(src)
