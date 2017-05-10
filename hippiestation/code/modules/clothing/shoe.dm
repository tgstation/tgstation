/obj/item/clothing/shoes/hippie/cluwne
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge!"
	name = "clown shoes"
	icon_state = "cluwne"
	item_state = "cluwne"
	item_color = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags = NODROP | DROPDEL
	slowdown = SHOES_SLOWDOWN+1
	var/footstep = 1
	pockets = /obj/item/weapon/storage/internal/pocket/shoes/clown

/obj/item/clothing/shoes/hippie/cluwne/step_action()
	if(footstep > 1)
		playsound(src, "clownstep", 50, 1)
		footstep = 0
	else
		footstep++

/obj/item/clothing/shoes/hippie/cluwne/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_shoes)
		var/mob/living/carbon/human/H = user
		H.dna.add_mutation(CLUWNEMUT)
	return

/obj/item/clothing/shoes/blastco
	name = "BlastCo(tm) rollerskates"
	desc = "A pair of roller skates, syndicate style. Will make you go faster."
	icon_state = "magboots-old1"
	item_state = "magboots-old1"
	slowdown = -1
	resistance_flags = FIRE_PROOF | ACID_PROOF
