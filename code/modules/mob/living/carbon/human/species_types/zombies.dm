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
	var/static/list/spooks = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	disliked_food = NONE
	liked_food = GROSS | MEAT | RAW

/datum/species/zombie/infectious
	name = "Infectious Zombie"
	id = "memezombies"
	limbs_id = "zombie"
	mutanthands = /obj/item/zombie_hand
	armor = 20 // 120 damage to KO a zombie, which kills it
	speedmod = 2
	mutanteyes = /obj/item/organ/eyes/night_vision/zombie

/datum/species/zombie/infectious/spec_stun(mob/living/carbon/human/H,amount)
	. = min(2, amount)

/datum/species/zombie/infectious/spec_life(mob/living/carbon/C)
	. = ..()
	C.a_intent = INTENT_HARM // THE SUFFERING MUST FLOW
	C.heal_overall_damage(4,4)
	if(prob(4))
		playsound(C, pick(spooks), 50, TRUE, 10)
	if(C.InCritical())
		C.death()
		// Zombies only move around when not in crit, they instantly
		// succumb otherwise, and will standup again soon

/datum/species/zombie/infectious/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()

	// Deal with the source of this zombie corruption
	//  Infection organ needs to be handled separately from mutant_organs
	//  because it persists through species transitions
	var/obj/item/organ/zombie_infection/infection
	infection = C.getorganslot("zombie_infection")
	if(!infection)
		infection = new()
		infection.Insert(C)


// Your skin falls off
/datum/species/krokodil_addict
	name = "Human"
	id = "goofzombies"
	limbs_id = "zombie" //They look like zombies
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	mutant_organs = list(/obj/item/organ/tongue/zombie)
