
/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

/mob/living/carbon/human/canBeHandcuffed()
	return 1

//gets assignment from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job")
	var/obj/item/weapon/card/id/id = get_idcard()
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
	var/obj/item/weapon/card/id/id = get_idcard()
	if(id)
		return id.registered_name
	var/obj/item/device/pda/pda = wear_id
	if(istype(pda))
		return pda.owner
	return if_no_id

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
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
	var/obj/item/organ/limb/O = get_organ("head")
	if( (status_flags&DISFIGURED) || (O.brutestate+O.burnstate)>2 || cloneloss>50 || !real_name )	//disfigured. use id-name if possible
		return if_no_face
	return real_name

//gets name from ID or PDA itself, ID inside PDA doesn't matter
//Useful when player is being seen by other mobs
/mob/living/carbon/human/proc/get_id_name(if_no_id = "Unknown")
	var/obj/item/weapon/storage/wallet/wallet = wear_id
	var/obj/item/device/pda/pda = wear_id
	var/obj/item/weapon/card/id/id = wear_id
	if(istype(wallet))		id = wallet.front_id
	if(istype(id))			. = id.registered_name
	else if(istype(pda))	. = pda.owner
	if(!.) 					. = if_no_id	//to prevent null-names making the mob unclickable
	return

//gets ID card object from special clothes slot or null.
/mob/living/carbon/human/proc/get_idcard()
	if(wear_id)
		return wear_id.GetID()

///checkeyeprot()
///Returns a number between -1 to 2
/mob/living/carbon/human/check_eye_prot()
	var/number = 0
	if(istype(src.head, /obj/item/clothing/head))			//are they wearing something on their head
		var/obj/item/clothing/head/HFP = src.head			//if yes gets the flash protection value from that item
		number += HFP.flash_protect
	if(istype(src.glasses, /obj/item/clothing/glasses))		//glasses
		var/obj/item/clothing/glasses/GFP = src.glasses
		number += GFP.flash_protect
	if(istype(src.wear_mask, /obj/item/clothing/mask))		//mask
		var/obj/item/clothing/mask/MFP = src.wear_mask
		number += MFP.flash_protect
	var/obj/item/cybernetic_implant/eyes/EFP = locate() in src
	if(EFP)
		number += EFP.flash_protect
	return number

/mob/living/carbon/human/check_ear_prot()
	if((ears && (ears.flags & EARBANGPROTECT)) || (head && (head.flags & HEADBANGPROTECT)))
		return 1

///tintcheck()
///Checks eye covering items for visually impairing tinting, such as welding masks
///Checked in life.dm. 0 & 1 = no impairment, 2 = welding mask overlay, 3 = You can see jack, but you can't see shit.
/mob/living/carbon/human/tintcheck()
	var/tinted = 0
	if(istype(src.head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = src.head
		tinted += HT.tint
	if(istype(src.glasses, /obj/item/clothing/glasses))
		var/obj/item/clothing/glasses/GT = src.glasses
		tinted += GT.tint
	if(istype(src.wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/MT = src.wear_mask
		tinted += MT.tint
	return tinted

/mob/living/carbon/human/abiotic(full_body = 0)
	if(full_body && ((src.l_hand && !( src.l_hand.flags&ABSTRACT )) || (src.r_hand && !( src.r_hand.flags&ABSTRACT )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.ears || src.gloves)))
		return 1

	if( (src.l_hand && !(src.l_hand.flags&ABSTRACT)) || (src.r_hand && !(src.r_hand.flags&ABSTRACT)) )
		return 1

	return 0

/mob/living/carbon/human/IsAdvancedToolUser()
	return 1//Humans can use guns and such

/mob/living/carbon/human/InCritical()
	return (health <= config.health_threshold_crit && stat == UNCONSCIOUS)

/mob/living/carbon/human/reagent_check(datum/reagent/R)
	if(dna)
		var/bypass = dna.species.handle_chemicals(R,src)
		return bypass	// if it returns 0, it will run the usual on_mob_life for that reagent. otherwise, it will stop after running handle_chemicals for the species.
	else
		return 0

/mob/living/carbon/human/can_track(mob/living/user)
	if(wear_id && istype(wear_id.GetID(), /obj/item/weapon/card/id/syndicate))
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