/*! 
This item is an EMAG but it looks and behaves just like an ID card.
*/

/obj/item/card/id/advemag
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	slot_flags = ITEM_SLOT_ID
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/list/access = list()
	var/registered_name = null // The name registered_name on the card
	var/assignment = null
	var/access_txt // mapping aid
	var/datum/bank_account/registered_account
	var/obj/machinery/paystand/my_store
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
