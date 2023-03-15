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

/// A fun drink enjoyed by the tiger cooperative
/obj/item/reagent_containers/cup/glass/bottle/ritual_wine
	name = "ritual wine"
	desc = "A bottle filled with liquids of a dubious nature."
	icon_state = "winebottle"
	list_reagents = list(
		/datum/reagent/blood = 10,
		/datum/reagent/medicine/changelinghaste = 20,
		/datum/reagent/toxin/mindbreaker = 20,
	)
	drink_type = NONE
	age_restricted = FALSE
