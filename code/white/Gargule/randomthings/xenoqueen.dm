mob/living/carbon/alien/humanoid/royal/queen/tamed
	has_fine_manipulation = 1

/mob/living/carbon/alien/humanoid/royal/queen/tamed/Initialize()
	..()
	for(var/X in src.internal_organs)
		var/obj/item/organ/I = X
		if(istype(I,/obj/item/organ/alien/eggsac))
			qdel(I)
	grant_language(/datum/language/common)
	name = "Smarty"
	real_name = "Smarty"
	wear_id = new /obj/item/card/id/gold(src)
	wear_id.access = get_all_accesses()
	wear_id.registered_name = real_name
	wear_id.assignment = "Captain's pet"
	wear_id.update_label()


/mob/living/carbon/alien/humanoid/royal/queen/tamed/UnarmedAttack(atom/A)
	if(!has_active_hand()) //can't attack without a hand.
		to_chat(src, "<span class='notice'>You look at your arm and sigh.</span>")
		return
	if(src.a_intent == INTENT_HELP && !ismob(A))
		A.attack_hand(src)
	else
		..()

/mob/living/carbon/alien/humanoid/royal/queen/tamed/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE)
	if(incapacitated() || lying )
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(!Adjacent(M) && (M.loc != src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/living/carbon/alien/humanoid/royal/queen/tamed/get_idcard()
	return wear_id

//mob/living/carbon/alien/humanoid/royal/queen/tamed/create_mob_hud() //indevelop
//	if(client && !hud_used)
//		hud_used = new /datum/hud/test(src)

///mob/living/carbon/alien/humanoid/royal/queen/tamed/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
//	switch(slot)
//		if(SLOT_BACK)
//			if(back)
//				return FALSE
//			if( !(I.slot_flags & ITEM_SLOT_BACK) )  ///shitforHUD
//				return FALSE
//			return TRUE
//		if(SLOT_WEAR_ID)
//			if(wear_id)
//				return FALSE
//			if( !(I.slot_flags & ITEM_SLOT_ID) )
//				return FALSE
//			return TRUE
//	return FALSE

///mob/living/carbon/alien/humanoid/royal/queen/tamed/get_item_by_slot(slot_id)
//	switch(slot_id)
//		if(SLOT_BACK)
//			return back
//		if(SLOT_WEAR_ID)
//			return wear_id
//	return null


/obj/structure/closet/crate/critter/xenoqueen
	name = "Captain's pet"
	desc = "A crate designed for safe transport of LARGE animals. It has an oxygen tank for safe transport in space."
	max_mob_size = MOB_SIZE_LARGE
	secure = 1
	anchorable = TRUE
	req_access = list(20)

/obj/structure/closet/crate/critter/xenoqueen/full

/obj/structure/closet/crate/critter/xenoqueen/full/Initialize()
	contents += new /mob/living/carbon/alien/humanoid/royal/queen/tamed