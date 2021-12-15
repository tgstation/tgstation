/**
 * DRONE EVOLUTION ABILITY
 */
/obj/effect/proc_holder/alien/evolve
	name = "Evolve to Praetorian"
	desc = "Praetorian"
	plasma_cost = 500

	action_icon_state = "alien_evolve_drone"

/obj/effect/proc_holder/alien/evolve/fire(mob/living/carbon/human/species/alien/user)
	var/obj/item/organ/alien/hivenode/node = user.getorgan(/obj/item/organ/alien/hivenode)
	if(!node) //Players are Murphy's Law. We may not expect there to ever be a living xeno with no hivenode, but they _WILL_ make it happen.
		to_chat(user, span_danger("Without the hivemind, you can't possibly hold the responsibility of leadership!"))
		return FALSE
	if(node.recent_queen_death)
		to_chat(user, span_danger("Your thoughts are still too scattered to take up the position of leadership."))
		return FALSE

	if(!isturf(user.loc))
		to_chat(user, span_warning("You can't evolve here!"))
		return FALSE
	if(!get_alien_type(/mob/living/carbon/human/species/alien/royal))
		var/mob/living/carbon/human/species/alien/royal/praetorian/new_xeno = new (user.loc)
		user.alien_evolve(new_xeno)
		return TRUE
	else
		to_chat(user, span_warning("We already have a living royal!"))
		return FALSE

/**
 * PRAETORIAN EVOLUTION ABILITY
 */
/obj/effect/proc_holder/alien/royal/praetorian/evolve
	name = "Evolve"
	desc = "Produce an internal egg sac capable of spawning children. Only one queen can exist at a time."
	plasma_cost = 500

	action_icon_state = "alien_evolve_praetorian"

/obj/effect/proc_holder/alien/royal/praetorian/evolve/fire(mob/living/carbon/human/species/alien/user)
	var/obj/item/organ/alien/hivenode/node = user.getorgan(/obj/item/organ/alien/hivenode)
	if(!node) //Just in case this particular Praetorian gets violated and kept by the RD as a replacement for Lamarr.
		to_chat(user, span_warning("Without the hivemind, you would be unfit to rule as queen!"))
		return FALSE
	if(node.recent_queen_death)
		to_chat(user, span_warning("You are still too burdened with guilt to evolve into a queen."))
		return FALSE
	if(!get_alien_type(/mob/living/carbon/human/species/alien/royal/queen))
		var/mob/living/carbon/human/species/alien/royal/queen/new_xeno = new (user.loc)
		user.alien_evolve(new_xeno)
		return TRUE
	else
		to_chat(user, span_warning("We already have an alive queen!"))
		return FALSE

/**
 * QUEEN PROMOTION ABILITY
 */

//Button to let queen choose her praetorian.
/obj/effect/proc_holder/alien/royal/queen/promote
	name = "Create Royal Parasite"
	desc = "Produce a royal parasite to grant one of your children the honor of being your Praetorian."
	plasma_cost = 500 //Plasma cost used on promotion, not spawning the parasite.

	action_icon_state = "alien_queen_promote"



/obj/effect/proc_holder/alien/royal/queen/promote/fire(mob/living/carbon/human/species/alien/user)
	var/obj/item/queenpromote/prom
	if(get_alien_type(/mob/living/carbon/human/species/alien/royal/praetorian/))
		to_chat(user, span_noticealien("You already have a Praetorian!"))
		return
	else
		for(prom in user)
			to_chat(user, span_noticealien("You discard [prom]."))
			qdel(prom)
			return

		prom = new (user.loc)
		if(!user.put_in_active_hand(prom, 1))
			to_chat(user, span_warning("You must empty your hands before preparing the parasite."))
			return
		else //Just in case telling the player only once is not enough!
			to_chat(user, span_noticealien("Use the royal parasite on one of your children to promote her to Praetorian!"))
	return

/obj/item/queenpromote
	name = "\improper royal parasite"
	desc = "Inject this into one of your grown children to promote her to a Praetorian!"
	icon_state = "alien_medal"
	item_flags = ABSTRACT | DROPDEL
	icon = 'icons/mob/alien.dmi'

/obj/item/queenpromote/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/queenpromote/attack(mob/living/M, mob/living/carbon/human/species/alien/user)
	if(!isalienadult(M) || isalienroyal(M))
		to_chat(user, span_noticealien("You may only use this with your adult, non-royal children!"))
		return
	if(get_alien_type(/mob/living/carbon/human/species/alien/royal/praetorian/))
		to_chat(user, span_noticealien("You already have a Praetorian!"))
		return

	var/mob/living/carbon/human/species/alien/A = M
	if(A.stat == CONSCIOUS && A.mind && A.key)
		if(!user.usePlasma(500))
			to_chat(user, span_noticealien("You must have 500 plasma stored to use this!"))
			return

		to_chat(A, span_noticealien("The queen has granted you a promotion to Praetorian!"))
		user.visible_message(span_alertalien("[A] begins to expand, twist and contort!"))
		var/mob/living/carbon/human/species/alien/royal/praetorian/new_prae = new (A.loc)
		A.mind.transfer_to(new_prae)
		qdel(A)
		qdel(src)
		return
	else
		to_chat(user, span_warning("This child must be alert and responsive to become a Praetorian!"))

/obj/item/queenpromote/attack_self(mob/user)
	to_chat(user, span_noticealien("You discard [src]."))
	qdel(src)
