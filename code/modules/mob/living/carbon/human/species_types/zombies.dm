/datum/species/zombie
	// 1spooky
	name = "High Functioning Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	blacklisted = 1
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOBLOOD,RADIMMUNE,NOZOMBIE,EASYDISMEMBER,EASYLIMBATTACHMENT)
	mutant_organs = list(/obj/item/organ/tongue/zombie)

/datum/species/zombie/infectious
	name = "Infectious Zombie"
	id = "memezombies"
	limbs_id = "zombie"
	no_equip = list(slot_wear_mask, slot_head)
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 2

/datum/species/zombie/infectious/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = INTENT_HARM // THE SUFFERING MUST FLOW
	if(C.InCritical())
		C.death()
		// Zombies only move around when not in crit, they instantly
		// succumb otherwise, and will standup again soon

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	// Drop items in hands
	// If you're a zombie lucky enough to have a NODROP item, then it stays.
	for(var/V in C.held_items)
		var/obj/item/I = V
		if(istype(I))
			if(C.dropItemToGround(I))
				var/obj/item/zombie_hand/zh = new /obj/item/zombie_hand()
				C.put_in_hands(zh)
		else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
			var/obj/item/zombie_hand/zh = new /obj/item/zombie_hand()
			C.put_in_hands(zh)

	// Next, deal with the source of this zombie corruption
	var/obj/item/organ/zombie_infection/infection
	infection = C.getorganslot("zombie_infection")
	if(!infection)
		infection = new(C)

/datum/species/zombie/infectious/on_species_loss(mob/living/carbon/C)
	. = ..()
	for(var/obj/item/I in C.held_items)
		if(istype(I, /obj/item/zombie_hand))
			qdel(I)


// Your skin falls off
/datum/species/krokodil_addict
	name = "Human"
	id = "goofzombies"
	limbs_id = "zombie" //They look like zombies
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	mutant_organs = list(/obj/item/organ/tongue/zombie)
