/area/ruin/space/meateor
	name = "\improper Organic Asteroid"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED

/obj/item/paper/fluff/ruins/meateor/letter
	name = "letter"
	default_raw_text = {"We offer our sincerest congratulations, to be chosen to take this journey is an honour and privilege afforded to few.
	<br> While you are walking in the footsteps of the divine, don't forget about the rest of us back at the farm!
	<br> <This letter has been signed by 15 people.>"}

/// Tiger cultist corpse but with an exit wound
/obj/effect/mob_spawn/corpse/human/tigercultist/perforated

/obj/effect/mob_spawn/corpse/human/tigercultist/perforated/special(mob/living/carbon/human/spawned_human)
	. = ..()

	var/obj/item/bodypart/chest/their_chest = spawned_human.get_bodypart(BODY_ZONE_CHEST)
	if (!their_chest)
		return

	spawned_human.cause_wound_of_type_and_severity(WOUND_PIERCE, their_chest, WOUND_SEVERITY_CRITICAL)

/// A fun drink enjoyed by the tiger cooperative, might corrode your brain if you drink the whole bottle
/obj/item/reagent_containers/cup/glass/bottle/ritual_wine
	name = "ritual wine"
	desc = "A bottle filled with liquids of a dubious nature, often enjoyed by members of the Tiger Cooperative."
	icon_state = "winebottle"
	list_reagents = list(
		/datum/reagent/drug/mushroomhallucinogen = 25,
		/datum/reagent/consumable/ethanol/ritual_wine = 25,
		/datum/reagent/medicine/changelinghaste = 20, // This metabolises very fast
		/datum/reagent/drug/bath_salts = 5,
		/datum/reagent/blood = 5,
		/datum/reagent/toxin/leadacetate = 5,
		/datum/reagent/medicine/omnizine = 5,
		/datum/reagent/medicine/c2/penthrite = 5,
		/datum/reagent/consumable/vinegar = 5,
	)
	age_restricted = FALSE

/// Abstract holder object for shared behaviour
/obj/structure/meateor_fluff
	icon = 'icons/mob/simple/meteor_heart.dmi'
	anchored = TRUE

/obj/structure/meateor_fluff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/bloody_spreader,\
		blood_left = INFINITY,\
		blood_dna = list("meaty DNA" = "MT-"),\
		diseases = null,\
	)

/obj/structure/meateor_fluff/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/blob/attackblob.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
			else
				playsound(loc, 'sound/effects/meatslap.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
		if(BURN)
			playsound(loc, 'sound/effects/wounds/sizzle1.ogg', vol = 100, vary = TRUE, pressure_affected = FALSE)

/// A sort of loot box for organs, cut it open and find a prize
/obj/structure/meateor_fluff/flesh_pod
	name = "flesh pod"
	desc = "A quivering pod of living meat. Something is pulsing inside."
	icon_state = "flesh_pod"
	max_integrity = 120
	density = TRUE
	/// Typepath of the organ to spawn when this is destroyed
	var/stored_organ
	/// Types of organ we can spawn
	var/static/list/allowed_organs = list(
		/obj/item/organ/heart/gland/egg = 7,
		/obj/item/organ/heart/gland/plasma = 7,
		/obj/item/organ/alien/plasmavessel = 5,
		/obj/item/organ/heart/gland/chem = 5,
		/obj/item/organ/heart/gland/mindshock = 5,
		/obj/item/organ/heart/gland/spiderman = 5,
		/obj/item/organ/heart/gland/transform = 5,
		/obj/item/organ/heart/gland/slime = 4,
		/obj/item/organ/heart/gland/trauma = 4,
		/obj/item/organ/heart/carp = 3,
		/obj/item/organ/heart/rat = 3,
		/obj/item/organ/heart/gland/electric = 3,
		/obj/item/organ/monster_core/brimdust_sac = 3,
		/obj/item/organ/monster_core/regenerative_core = 3,
		/obj/item/organ/monster_core/rush_gland = 3,
		/obj/item/organ/tongue/carp = 3,
		/obj/item/organ/alien/acid = 2,
		/obj/item/organ/alien/resinspinner = 2,
		/obj/item/organ/eyes/night_vision/goliath = 2,
		/obj/item/organ/eyes/night_vision/rat = 2,
		/obj/item/organ/heart/gland/ventcrawling = 1,
	)

/obj/structure/meateor_fluff/flesh_pod/Initialize(mapload)
	. = ..()
	stored_organ = pick_weight(allowed_organs)

/obj/structure/meateor_fluff/flesh_pod/attackby(obj/item/attacking_item, mob/user, params)
	if (attacking_item.get_sharpness() & SHARP_EDGED)
		cut_open(user)
		return
	return ..()

/// Cut the pod open and destroy it
/obj/structure/meateor_fluff/flesh_pod/proc/cut_open(mob/user)
	balloon_alert(user, "slicing...")
	if (!do_after(user, 3 SECONDS, target = src))
		return
	take_damage(max_integrity)

/obj/structure/meateor_fluff/flesh_pod/atom_destruction(damage_flag)
	new stored_organ(loc)
	new /obj/effect/decal/cleanable/blood(loc)
	new /obj/structure/meateor_fluff/flesh_pod_open(loc)
	playsound(loc, 'sound/effects/wounds/blood3.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
	return ..()

/obj/structure/meateor_fluff/flesh_pod_open
	name = "flesh pod"
	desc = "A pod of living meat, this one has been hollowed out."
	icon_state = "flesh_pod_open"
	max_integrity = 60

/obj/structure/meateor_fluff/flesh_pod_open/atom_destruction(damage_flag)
	new /obj/effect/gibspawner/human(loc)
	return ..()

/// Decorative fluff egg object
/obj/structure/meateor_fluff/abandoned_headcrab_egg
	name = "meaty eggs"
	desc = "A mass of fleshy, egg-shaped nodes."
	icon_state = "eggs"
	max_integrity = 15

/obj/structure/meateor_fluff/abandoned_headcrab_egg/atom_destruction(damage_flag)
	new /obj/effect/decal/cleanable/xenoblood(loc)
	playsound(loc, 'sound/effects/footstep/gib_step.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
	return ..()
