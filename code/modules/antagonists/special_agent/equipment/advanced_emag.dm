/*! 
This item is an EMAG but it looks and behaves just like an ID card.
*/

/obj/item/card/id/advemag
	var/prox_check = TRUE

/obj/item/card/id/advemag/attack()
	return

/obj/item/card/id/advemag/afterattack(atom/target, mob/user, proximity)
	. = ..()
	var/atom/A = target
	if(!proximity && prox_check)
		return
	log_combat(user, A, "attempted to emag")
	A.emag_act(user)
