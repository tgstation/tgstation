
/mob/living/carbon/human/restrained(ignore_grab)
	. = ((wear_suit && wear_suit.breakouttime) || ..())


/mob/living/carbon/human/canBeHandcuffed()
	if(get_num_arms() >= 2)
		return TRUE
	else
		return FALSE

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job")
	var/obj/item/card/id/id = get_idcard()
	if(id)
		. = id.assignment
	else
		var/obj/item/device/pda/pda = wear_id
		if(istype(pda))
			. = pda.ownjob
		else
			return if_no_id
	if(!.)
		return if_no_job

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(if_no_id = "Unknown")
	var/obj/item/card/id/id = get_idcard()
	if(id)
		return id.registered_name
	var/obj/item/device/pda/pda = wear_id
	if(istype(pda))
		return pda.owner
	return if_no_id

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a separate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name()
	var/face_name = get_face_name("")
	var/id_name = get_id_name("")
	if(name_override)
		return name_override
	if(face_name)
		if(id_name && (id_name != face_name))
			return "[face_name] (as [id_name])"
		return face_name
	if(id_name)
		return id_name
	return "Unknown"

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when Fluacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name(if_no_face="Unknown")
	if( wear_mask && (wear_mask.flags_inv&HIDEFACE) )	//Wearing a mask which hides our face, use id-name if possible
		return if_no_face
	if( head && (head.flags_inv&HIDEFACE) )
		return if_no_face		//Likewise for hats
	var/obj/item/bodypart/O = get_bodypart("head")
	if( !O || (status_flags&DISFIGURED) || (O.brutestate+O.burnstate)>2 || cloneloss>50 || !real_name )	//disfigured. use id-name if possible
		return if_no_face
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(if_no_id = "Unknown")
	var/obj/item/storage/wallet/wallet = wear_id
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/card/id/id = wear_id
	var/obj/item/device/modular_computer/tablet/tablet = wear_id
	if(istype(wallet))
		id = wallet.front_id
	if(istype(id))
		. = id.registered_name
	else if(istype(pda))
		. = pda.owner
	else if(istype(tablet))
		var/obj/item/computer_hardware/card_slot/card_slot = tablet.all_components[MC_CARD]
		if(card_slot && (card_slot.stored_card2 || card_slot.stored_card))
			if(card_slot.stored_card2) //The second card is the one used for authorization in the ID changing program, so we prioritize it here for consistency
				. = card_slot.stored_card2.registered_name
			else
				if(card_slot.stored_card)
					. = card_slot.stored_card.registered_name
	if(!.)
		. = if_no_id	//to prevent null-names making the mob unclickable
	return

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/get_idcard()
	if(wear_id)
		return wear_id.GetID()


/mob/living/carbon/human/abiotic(full_body = 0)
	var/abiotic_hands = FALSE
	for(var/obj/item/I in held_items)
		if(!(I.flags & NODROP))
			abiotic_hands = TRUE
			break
	if(full_body && abiotic_hands && ((back && !(back.flags&NODROP)) || (wear_mask && !(wear_mask.flags&NODROP)) || (head && !(head.flags&NODROP)) || (shoes && !(shoes.flags&NODROP)) || (w_uniform && !(w_uniform.flags&NODROP)) || (wear_suit && !(wear_suit.flags&NODROP)) || (glasses && !(glasses.flags&NODROP)) || (ears && !(ears.flags&NODROP)) || (gloves && !(gloves.flags&NODROP)) ) )
		return TRUE
	return abiotic_hands


/mob/living/carbon/human/IsAdvancedToolUser()
	return 1//Humans can use guns and such

/mob/living/carbon/human/InCritical()
	return (health <= HEALTH_THRESHOLD_CRIT && stat == UNCONSCIOUS)

/mob/living/carbon/human/reagent_check(datum/reagent/R)
	return dna.species.handle_chemicals(R,src)
	// if it returns 0, it will run the usual on_mob_life for that reagent. otherwise, it will stop after running handle_chemicals for the species.


/mob/living/carbon/human/can_track(mob/living/user)
	if(wear_id && istype(wear_id.GetID(), /obj/item/card/id/syndicate))
		return 0
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		if(hat.blockTracking)
			return 0

	return ..()

/mob/living/carbon/human/get_permeability_protection()
	var/list/prot = list("hands"=0, "chest"=0, "groin"=0, "legs"=0, "feet"=0, "arms"=0, "head"=0)
	for(var/obj/item/I in get_equipped_items())
		if(I.body_parts_covered & HANDS)
			prot["hands"] = max(1 - I.permeability_coefficient, prot["hands"])
		if(I.body_parts_covered & CHEST)
			prot["chest"] = max(1 - I.permeability_coefficient, prot["chest"])
		if(I.body_parts_covered & GROIN)
			prot["groin"] = max(1 - I.permeability_coefficient, prot["groin"])
		if(I.body_parts_covered & LEGS)
			prot["legs"] = max(1 - I.permeability_coefficient, prot["legs"])
		if(I.body_parts_covered & FEET)
			prot["feet"] = max(1 - I.permeability_coefficient, prot["feet"])
		if(I.body_parts_covered & ARMS)
			prot["arms"] = max(1 - I.permeability_coefficient, prot["arms"])
		if(I.body_parts_covered & HEAD)
			prot["head"] = max(1 - I.permeability_coefficient, prot["head"])
	var/protection = (prot["head"] + prot["arms"] + prot["feet"] + prot["legs"] + prot["groin"] + prot["chest"] + prot["hands"])/7
	return protection

/mob/living/carbon/human/can_use_guns(var/obj/item/G)
	. = ..()

	if(G.trigger_guard == TRIGGER_GUARD_NORMAL)
		if(src.dna.check_mutation(HULK))
			to_chat(src, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
			return 0
		if(NOGUNS in src.dna.species.species_traits)
			to_chat(src, "<span class='warning'>Your fingers don't fit in the trigger guard!</span>")
			return 0
	if(mind)
		if(mind.martial_art && mind.martial_art.no_guns) //great dishonor to famiry
			to_chat(src, "<span class='warning'>Use of ranged weaponry would bring dishonor to the clan.</span>")
			return 0

	return .
