/obj/item/clothing/mask/hippie/cluwne
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	flags_cover = MASKCOVERSEYES
	icon_state = "cluwne"
	item_state = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODROP_1 | MASKINTERNALS_1 | DROPDEL_1
	flags_inv = HIDEEARS|HIDEEYES

/obj/item/clothing/mask/hippie/cluwne/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_wear_mask)
		var/mob/living/carbon/human/H = user
		H.dna.add_mutation(CLUWNEMUT)
	return

/obj/item/clothing/mask/hippie/cluwne/happy_cluwne
	name = "Happy Cluwne Mask"
	desc = "The mask of a poor cluwne that has been scrubbed of its curse by the Nanotrasen supernatural machinations division. Guaranteed to be %99 curse free and %99.9 not haunted. "
	flags_1 = MASKINTERNALS_1
	alternate_screams = list('hippiestation/sound/voice/cluwnelaugh1.ogg','hippiestation/sound/voice/cluwnelaugh2.ogg','hippiestation/sound/voice/cluwnelaugh3.ogg')

/obj/item/clothing/mask/hippie/cluwne/happy_cluwne/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(slot == slot_wear_mask)
		H.add_screams(src.alternate_screams)
	else
		H.reindex_screams()
	if(prob(1)) // Its %99 curse free!
		log_admin("[key_name(H)] was made into a cluwne by [src]")
		message_admins("[key_name(H)] got cluwned by [src]")
		to_chat(H, "<span class='userdanger'>The masks straps suddenly tighten to your face and your thoughts are erased by a horrible green light!</span>")
		H.dropItemToGround(src)
		H.cluwneify()
		qdel(src)
	else if(prob(0.1)) //And %99.9 free form being haunted by vengeful jester-like entites.
		var/turf/T = get_turf(src)
		var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
		S.Acquire_Victim(user)
		log_admin("[key_name(user)] summoned a floor cluwne using the [src]")
		message_admins("[key_name(user)] summoned a floor cluwne using the [src]")
		to_chat(H, "<span class='warning'>The mask suddenly slips off your face and... slides under the floor?</span>")
		to_chat(H, "<i>...dneirf uoy ot gnoleb ton seod tahT</i>")
		qdel(src)
