/obj/item/clothing/shoes/spacestation413/cluwne
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge!"
	name = "clown shoes"
	icon_state = "cluwne"
	item_state = "cluwne"
	item_color = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = DROPDEL
	slowdown = SHOES_SLOWDOWN+1
	var/footstep = 1
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes/clown

/obj/item/clothing/shoes/spacestation413/cluwne/Initialize()
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)

/obj/item/clothing/shoes/spacestation413/cluwne/step_action()
	if(footstep > 1)
		playsound(src, "clownstep", 50, 1)
		footstep = 0
	else
		footstep++

/obj/item/clothing/shoes/spacestation413/cluwne/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == SLOT_SHOES)
		var/mob/living/carbon/human/H = user
		H.dna.add_mutation(CLUWNEMUT)
	return
