/mob/living/simple_animal
	// List of targets excluded (for now) from being eaten by this mob.
	var/list/prey_exclusions = list()
	devourable = FALSE //insurance because who knows.
	var/vore_active = FALSE				// If vore behavior is enabled for this mob

	var/vore_default_mode = DM_DIGEST	// Default bellymode (DM_DIGEST, DM_HOLD, DM_ABSORB)
	var/vore_digest_chance = 25			// Chance to switch to digest mode if resisted
	var/vore_escape_chance = 25			// Chance of resisting out of mob
	var/vore_absorb_chance = 0			// chance of absorbtion by mob

	var/vore_stomach_name				// The name for the first belly if not "stomach"
	var/vore_stomach_flavor				// The flavortext for the first belly if not the default

	var/vore_fullness = 0				// How "full" the belly is (controls icons)
	var/list/living_mobs = list()


// Release belly contents beforey being gc'd!
/mob/living/simple_animal/Destroy()
	release_vore_contents()
	prey_excludes.Cut()
	. = ..()


// Update fullness based on size & quantity of belly contents
/mob/living/simple_animal/proc/update_fullness(var/atom/movable/M)
	var/new_fullness = 0
	for(var/I in vore_organs)
		var/datum/belly/B = vore_organs[I]
		if (!(M in B.internal_contents))
			return FALSE // Nothing's inside
		new_fullness += M

	vore_fullness = new_fullness

/*
/mob/living/simple_animal/proc/swallow_check()
	for(var/I in vore_organs)
		var/obj/belly/B = vore_organs[I]
		if(vore_active)
			update_fullness()
			if(!vore_fullness)
				// Nothing
				return
			else
				addtimer(CALLBACK(src, .proc/swallow_mob), B.swallow_time)

/mob/living/simple_animal/proc/swallow_mob()
	for(var/I in vore_organs)
		var/obj/belly/B = vore_organs[I]
		for(var/mob/living/M in B.contents)
			B.transfer_contents(M, transferlocation)
*/

/mob/living/simple_animal/death()
	release_vore_contents()
	. = ..()

// Simple animals have only one belly.  This creates it (if it isn't already set up)
/mob/living/simple_animal/proc/init_belly()
	if(vore_organs.len)
		return
	if(no_vore) //If it can't vore, let's not give it a stomach.
		return

	var/obj/belly/B = new /obj/belly(src)
	vore_selected = B
	B.immutable = 1
	B.name = vore_stomach_name ? vore_stomach_name : "stomach"
	B.desc = vore_stomach_flavor ? vore_stomach_flavor : "Your surroundings are warm, soft, and slimy. Makes sense, considering you're inside \the [name]."
	B.digest_mode = vore_default_mode
	B.escapable = vore_escape_chance > 0
	B.escapechance = vore_escape_chance
	B.digestchance = vore_digest_chance
	B.absorbchance = vore_absorb_chance
	B.human_prey_swallow_time = swallowTime
	B.nonhuman_prey_swallow_time = swallowTime
	B.vore_verb = "swallow"
	B.emote_lists[DM_HOLD] = list( // We need more that aren't repetitive. I suck at endo. -Ace
		"The insides knead at you gently for a moment.",
		"The guts glorp wetly around you as some air shifts.",
		"The predator takes a deep breath and sighs, shifting you somewhat.",
		"The stomach squeezes you tight for a moment, then relaxes harmlessly.",
		"The predator's calm breathing and thumping heartbeat pulses around you.",
		"The warm walls kneads harmlessly against you.",
		"The liquids churn around you, though there doesn't seem to be much effect.",
		"The sound of bodily movements drown out everything for a moment.",
		"The predator's movements gently force you into a different position.")
	B.emote_lists[DM_DIGEST] = list(
		"The burning acids eat away at your form.",
		"The muscular stomach flesh grinds harshly against you.",
		"The caustic air stings your chest when you try to breathe.",
		"The slimy guts squeeze inward to help the digestive juices soften you up.",
		"The onslaught against your body doesn't seem to be letting up; you're food now.",
		"The predator's body ripples and crushes against you as digestive enzymes pull you apart.",
		"The juices pooling beneath you sizzle against your sore skin.",
		"The churning walls slowly pulverize you into meaty nutrients.",
		"The stomach glorps and gurgles as it tries to work you into slop.")
/*	B.emote_lists[DM_ITEMWEAK] = list(
		"The burning acids eat away at your form.",
		"The muscular stomach flesh grinds harshly against you.",
		"The caustic air stings your chest when you try to breathe.",
		"The slimy guts squeeze inward to help the digestive juices soften you up.",
		"The onslaught against your body doesn't seem to be letting up; you're food now.",
		"The predator's body ripples and crushes against you as digestive enzymes pull you apart.",
		"The juices pooling beneath you sizzle against your sore skin.",
		"The churning walls slowly pulverize you into meaty nutrients.",
		"The stomach glorps and gurgles as it tries to work you into slop.")*/

//Grab = Nomf
/*
/mob/living/simple_animal/UnarmedAttack(var/atom/A, var/proximity)
	. = ..()

	if(a_intent == I_GRAB && isliving(A) && !has_hands)
		animal_nom(A)*/