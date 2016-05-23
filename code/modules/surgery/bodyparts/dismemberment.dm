
/obj/item/bodypart/proc/can_dismember(obj/item/I)
	. = (get_damage() >= (max_damage - I.armour_penetration/2))

//Dismember a limb
/obj/item/bodypart/proc/dismember(dam_type = BRUTE)
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || (NODISMEMBER in H.dna.species.specflags)) // species don't allow dismemberment
		return 0

	var/obj/item/bodypart/affecting = H.get_bodypart("chest")
	affecting.take_damage(Clamp(brute_dam/2, 15, 50), Clamp(burn_dam/2, 0, 50)) //Damage the chest based on limb's existing damage
	H.visible_message("<span class='danger'><B>[H]'s [src.name] has been violently dismembered!</B></span>")
	H.emote("scream")
	drop_limb()

	if(dam_type == BURN)
		burn()
		return 1
	add_blood(H)
	var/turf/location = H.loc
	if(istype(location))
		location.add_blood(H)
	var/direction = pick(cardinal)
	var/t_range = rand(2,max(throw_range/2, 2))
	var/turf/target_turf = get_turf(src)
	for(var/i in 1 to t_range-1)
		var/turf/new_turf = get_step(target_turf, direction)
		target_turf = new_turf
		if(new_turf.density)
			break
	throw_at_fast(target_turf, throw_range, throw_speed)
	return 1


/obj/item/bodypart/chest/dismember()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || (NODISMEMBER in H.dna.species.specflags)) //human's species don't allow dismemberment
		return 0

	var/organ_spilled = 0
	var/turf/T = get_turf(H)
	T.add_blood(H)
	playsound(get_turf(owner), 'sound/misc/splort.ogg', 80, 1)
	for(var/X in owner.internal_organs)
		var/obj/item/organ/O = X
		if(O.zone != "chest")
			continue
		O.Remove(owner)
		O.loc = T
		organ_spilled = 1
	if(cavity_item)
		cavity_item.loc = T
		cavity_item = null
		organ_spilled = 1

	if(organ_spilled)
		owner.visible_message("<span class='danger'><B>[owner]'s internal organs spill out onto the floor!</B></span>")
	return 1



//limb removal. The "special" argument is used for swapping a limb with a new one without the effects of losing a limb kicking in.
/obj/item/bodypart/proc/drop_limb(special)
	if(!ishuman(owner))
		return
	var/turf/T = get_turf(owner)
	var/mob/living/carbon/human/H = owner
	if(!no_update)
		update_limb(1)
	H.bodyparts -= src
	owner = null

	for(var/X in H.surgeries) //if we had an ongoing surgery on that limb, we stop it.
		var/datum/surgery/S = X
		if(S.organ == src)
			H.surgeries -= S
			qdel(S)
			break

	for(var/obj/item/I in embedded_objects)
		embedded_objects -= I
		I.loc = src
	if(!H.has_embedded_objects())
		H.clear_alert("embeddedobject")

	if(!special)
		for(var/X in H.dna.mutations) //some mutations require having specific limbs to be kept.
			var/datum/mutation/human/MT = X
			if(MT.limb_req && MT.limb_req == body_zone)
				MT.force_lose(H)

		for(var/X in H.internal_organs) //internal organs inside the dismembered limb are dropped.
			var/obj/item/organ/O = X
			var/org_zone = check_zone(O.zone)
			if(org_zone != body_zone)
				continue
			O.transfer_to_limb(src, H)

	update_icon_dropped()
	src.loc = T
	H.update_health_hud() //update the healthdoll
	H.update_body()
	H.update_hair()
	H.update_canmove()


//when a limb is dropped, the internal organs are removed from the mob and put into the limb
/obj/item/organ/proc/transfer_to_limb(obj/item/bodypart/LB, mob/living/carbon/human/H)
	Remove(H)
	loc = LB

/obj/item/organ/brain/transfer_to_limb(obj/item/bodypart/head/LB, mob/living/carbon/human/H)
	if(H.mind && H.mind.changeling)
		LB.brain = new //changeling doesn't lose its real brain organ, we drop a decoy.
		LB.brain.loc = LB
	else			//if not a changeling, we put the brain organ inside the dropped head
		Remove(H)	//and put the player in control of the brainmob
		loc = LB
		LB.brain = src
		LB.brainmob = brainmob
		brainmob = null
		LB.brainmob.loc = LB
		LB.brainmob.container = LB
		LB.brainmob.stat = DEAD


/obj/item/bodypart/chest/drop_limb(special)
	return

/obj/item/bodypart/r_arm/drop_limb(special)
	var/mob/living/carbon/human/H = owner
	..()
	if(istype(H) && !special)
		if(H.handcuffed)
			H.handcuffed.loc = H.loc
			H.handcuffed.dropped(H)
			H.handcuffed = null
			H.update_handcuffed()
		if(H.hud_used)
			var/obj/screen/inventory/R = H.hud_used.inv_slots[slot_r_hand]
			if(R)
				R.update_icon()
		if(H.r_hand)
			H.unEquip(H.r_hand, 1)
		if(H.gloves)
			H.unEquip(H.gloves, 1)
		H.update_inv_gloves() //to remove the bloody hands overlay


/obj/item/bodypart/l_arm/drop_limb(special)
	var/mob/living/carbon/human/H = owner
	..()
	if(istype(H) && !special)
		if(H.handcuffed)
			H.handcuffed.loc = H.loc
			H.handcuffed.dropped(H)
			H.handcuffed = null
			H.update_handcuffed()
		if(H.hud_used)
			var/obj/screen/inventory/L = H.hud_used.inv_slots[slot_l_hand]
			if(L)
				L.update_icon()
		if(H.l_hand)
			H.unEquip(H.l_hand, 1)
		if(H.gloves)
			H.unEquip(H.gloves, 1)
		H.update_inv_gloves() //to remove the bloody hands overlay


/obj/item/bodypart/r_leg/drop_limb(special)
	if(owner && !special)
		owner.Weaken(2)
		if(owner.legcuffed)
			owner.legcuffed.loc = owner.loc
			owner.legcuffed.dropped(owner)
			owner.legcuffed = null
			owner.update_inv_legcuffed()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.shoes)
				H.unEquip(H.shoes, 1)
	..()

/obj/item/bodypart/l_leg/drop_limb(special) //copypasta
	if(owner && !special)
		owner.Weaken(2)
		if(owner.legcuffed)
			owner.legcuffed.loc = owner.loc
			owner.legcuffed.dropped(owner)
			owner.legcuffed = null
			owner.update_inv_legcuffed()
		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(H.shoes)
				H.unEquip(H.shoes, 1)
	..()

/obj/item/bodypart/head/drop_limb(special)
	var/mob/living/carbon/human/H = owner
	if(istype(H))
		if(!special)
			//Drop all worn head items
			for(var/X in list(H.glasses, H.ears, H.wear_mask, H.head))
				var/obj/item/I = X
				H.unEquip(I, 1)
		name = "[H]'s head"
	..()






//Attach a limb to a human and drop any existing limb of that type.
/obj/item/bodypart/proc/replace_limb(mob/living/carbon/human/H, special)
	if(!istype(H))
		return
	var/obj/item/bodypart/O = locate(src.type) in H.bodyparts

	if(O)
		O.drop_limb(1)
	attach_limb(H, special)

/obj/item/bodypart/head/replace_limb(mob/living/carbon/human/H, special)
	if(!istype(H))
		return
	var/obj/item/bodypart/head/O = locate(src.type) in H.bodyparts
	if(O)
		if(!special)
			return
		else
			O.drop_limb(1)
	attach_limb(H, special)

/obj/item/bodypart/proc/attach_limb(mob/living/carbon/human/H, special)
	loc = null
	owner = H
	H.bodyparts += src

	if(special) //non conventional limb attachment
		for(var/X in H.surgeries) //if we had an ongoing surgery to attach a new limb, we stop it.
			var/datum/surgery/S = X
			var/surgery_zone = check_zone(S.location)
			if(surgery_zone == body_zone)
				H.surgeries -= S
				qdel(S)
				break

	update_bodypart_damage_state()
	H.updatehealth()
	H.update_body()
	H.update_hair()
	H.update_damage_overlays()
	H.update_canmove()


/obj/item/bodypart/r_arm/attach_limb(mob/living/carbon/human/H, special)
	..()
	if(H.hud_used)
		var/obj/screen/inventory/R = H.hud_used.inv_slots[slot_r_hand]
		if(R)
			R.update_icon()

/obj/item/bodypart/l_arm/attach_limb(mob/living/carbon/human/H, special)
	..()
	if(H.hud_used)
		var/obj/screen/inventory/L = H.hud_used.inv_slots[slot_l_hand]
		if(L)
			L.update_icon()

/obj/item/bodypart/head/attach_limb(mob/living/carbon/human/H, special)
	//Transfer some head appearance vars over
	if(brain)
		brainmob.container = null //Reset brainmob head var.
		brainmob.loc = brain //Throw mob into brain.
		brain.brainmob = brainmob //Set the brain to use the brainmob
		brainmob = null //Set head brainmob var to null
		brain.Insert(H) //Now insert the brain proper
		brain = null //No more brain in the head

	H.hair_color = hair_color
	H.hair_style = hair_style
	H.facial_hair_color = facial_hair_color
	H.facial_hair_style = facial_hair_style
	H.eye_color = eye_color
	H.lip_style = lip_style
	H.lip_color = lip_color
	if(real_name)
		H.real_name = real_name
	real_name = ""
	name = initial(name)
	..()


//Regenerates all limbs. Returns amount of limbs regenerated
/mob/living/proc/regenerate_limbs(noheal)
	return 0

/mob/living/carbon/human/regenerate_limbs(noheal)
	var/list/limb_list = list("head", "chest", "r_arm", "l_arm", "r_leg", "l_leg")
	for(var/Z in limb_list)
		. += regenerate_limb(Z, noheal)

/mob/living/proc/regenerate_limb(limb_zone, noheal)
	return

/mob/living/carbon/human/regenerate_limb(limb_zone, noheal)
	var/obj/item/bodypart/L
	if(get_bodypart(limb_zone))
		return 0
	L = newBodyPart(limb_zone, 0, 0, src)
	if(L)
		if(!noheal)
			L.brute_dam = 0
			L.burn_dam = 0
			L.burn_state = 0

		L.attach_limb(src, 1)
		return 1
