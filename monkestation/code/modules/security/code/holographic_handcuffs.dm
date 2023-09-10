
/**
 * Handcuffs
 * the handcuffs themselfes should be un-obtainable, /used version is applied on our actual target
 * as strong zipties, take 50% longer to handcuff someone with
 */

/obj/item/restraints/handcuffs/holographic
	name = "holographic energy field"
	desc = "A weirdly solid holographic field... how did you get this? this item gives you the permission to scream at coders."
	icon_state = "handcuffAlien"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	breakouttime = 45 SECONDS
	trashtype = /obj/item/restraints/handcuffs/holographic/used
	flags_1 = NONE

//	var/obj/item/holosign_creator/projector // used to keep track of the handcuffs by its projector

/* Needs to have proper projector thingies added
/obj/item/restraints/handcuffs/holographic/Initialize(source_projector)
	. = ..()
	if(source_projector)
		projector = source_projector
		LAZYADD(projector.signs, src)
*/

/obj/item/restraints/handcuffs/holographic/used
	desc = "A holographic projection of handcuffs, suprisingly hard to break out of"
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/holographic/used/dropped(mob/user)
	user.visible_message(span_danger("[user]'s [name] dissapears!"), \
							span_userdanger("[user]'s [name] dissapears!"))
	. = ..()

/**
 * Gives the security holographic projector ability to handcuff targets
 */

/obj/item/holosign_creator/security/afterattack(atom/target, mob/user, proximity_flag)
	if(iscarbon(target)) // dont start setting up a holo barrier if we click on a hooman
		return
	return ..()

/obj/item/holosign_creator/security/attack(mob/living/target, mob/living/user)
	var/time_to_handcuff = 4.5 SECONDS
	if(!iscarbon(target))
		return
	var/mob/living/carbon/Human = target
	if(!Human.handcuffed) // is our target already handcuffed?
		if(Human.canBeHandcuffed()) // does he actually have arms?
			log_combat(user, Human, "attempted to handcuff")
			playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
			Human.visible_message(span_danger("[user] begins restraining [Human] with [src]!"), \
									span_userdanger("[user] begins shaping a holographic field around your hands!"))
			if(do_after(user, time_to_handcuff, Human) && Human.canBeHandcuffed()) // he is up for grabs, so lets handcuff them
				if(!Human.handcuffed) // you cant trust people that they wont handcuff the person whilst someone else is handcuffing
					Human.set_handcuffed(new /obj/item/restraints/handcuffs/holographic/used(Human))
					Human.update_handcuffed()
					to_chat(user, span_notice("You restrain [Human]."))
					log_combat(user, Human, "handcuffed")
			else
				to_chat(user, span_warning("You fail to restrain [Human]."))
		else
			to_chat(user, span_warning("[Human] doesn't have two hands..."))
