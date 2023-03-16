/area/ruin/space/meateor
	name = "organic asteroid"

/obj/item/paper/fluff/ruins/meateor/letter
	name = "letter"
	default_raw_text = {"We offer our sincerest congratulations, to be chosen to take this journey is an honour and privilege afforded to few.
	<br> While you are walking in the footsteps of the divine, don't forget about the rest of us back at the farm!
	<br> <This letter has been signed by 15 people.>"}

/// Give it an exit wound
/obj/effect/mob_spawn/corpse/human/tigercultist/perforated

/obj/effect/mob_spawn/corpse/human/tigercultist/perforated/special(mob/living/carbon/human/spawned_human)
	. = ..()
	var/datum/wound/pierce/critical/exit_hole = new()
	exit_hole.apply_wound(spawned_human.get_bodypart(BODY_ZONE_CHEST))

/// A fun drink enjoyed by the tiger cooperative, might corrode your brain if you drink the whole bottle
/obj/item/reagent_containers/cup/glass/bottle/ritual_wine
	name = "ritual wine"
	desc = "A bottle filled with liquids of a dubious nature, often enjoyed by members of the Tiger Cooperative."
	icon_state = "winebottle"
	list_reagents = list(
		/datum/reagent/blood = 5,
		/datum/reagent/drug/bath_salts = 5,
		/datum/reagent/drug/cannabis = 10,
		/datum/reagent/medicine/changelinghaste = 30,
		/datum/reagent/toxin/heparin = 10,
		/datum/reagent/toxin/leadacetate = 5,
		/datum/reagent/toxin/mindbreaker = 10,
		/datum/reagent/medicine/omnizine = 10,
		/datum/reagent/medicine/c2/penthrite = 10,
		/datum/reagent/toxin/rotatium = 10,
		/datum/reagent/consumable/vinegar = 5,
	)
	drink_type = NONE
	age_restricted = FALSE

/// Abstract holder object for shared behaviour
/obj/structure/meateor_fluff
	icon = 'icons/mob/simple/meteor_heart.dmi'
	anchored = TRUE
	density = TRUE

/obj/structure/meateor_fluff/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/effects/attackblob.ogg', 50, TRUE)
			else
				playsound(src, 'sound/effects/meatslap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/effects/wounds/sizzle1.ogg', 100, TRUE)

/// A sort of loot box for organs, cut it open and find a prize
/obj/structure/meateor_fluff/flesh_pod
	icon_state = "flesh_pod"
	desc = "A quivering pod of living meat. Something is pulsing inside."
	max_integrity = 60

/// Decorative fluff egg object
/obj/structure/meateor_fluff/abandoned_headcrab_egg
	icon_state = "eggs"
	desc = "A mass of fleshy, egg-shaped nodes."
	max_integrity = 15
