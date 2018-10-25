/mob/living/carbon/human/movement_delay()
	return species:_movement_delay() + ..()			//YES I KNOW THIS IS BANNED THIS IS A WIP PR!
//THIS ENTIRE FILE IS WIP
////////////////
// MOVE SPEED //
////////////////

/datum/species/proc/_movement_delay(mob/living/carbon/human/H)

	if(gravity && !flight)	//Check for chemicals and innate speedups and slowdowns if we're on the ground
		if(H.has_trait(TRAIT_GOTTAGOFAST))
			. -= 1
		if(H.has_trait(TRAIT_GOTTAGOREALLYFAST))
			. -= 2
		. += H.physiology.speed_mod

	if(!gravity)
		var/obj/item/tank/jetpack/J = H.back
		var/obj/item/clothing/suit/space/hardsuit/C = H.wear_suit
		var/obj/item/organ/cyberimp/chest/thrusters/T = H.getorganslot(ORGAN_SLOT_THRUSTERS)
		if(!istype(J) && istype(C))
			J = C.jetpack
		if(istype(J) && J.full_speed && J.allow_thrust(0.01, H))	//Prevents stacking
			. -= 2
		else if(istype(T) && T.allow_thrust(0.01, H))
			. -= 2

	if(!ignoreslow && gravity)
		if(H.wear_suit)
			. += H.wear_suit.slowdown
		if(H.shoes)
			. += H.shoes.slowdown
		if(H.back)
			. += H.back.slowdown
		for(var/obj/item/I in H.held_items)
			if(I.item_flags & SLOWS_WHILE_IN_HAND)
				. += I.slowdown
		var/health_deficiency = (100 - H.health + H.staminaloss)
		if(health_deficiency >= 40)
			if(flight)
				. += (health_deficiency / 75)
			else
				. += (health_deficiency / 25)
		if(CONFIG_GET(flag/disable_human_mood))
			var/hungry = (500 - H.nutrition) / 5 //So overeat would be 100 and default level would be 80
			if((hungry >= 70) && !flight) //Being hungry will still allow you to use a flightsuit/wings.
				. += hungry / 50

		//Moving in high gravity is very slow (Flying too)
		if(gravity > STANDARD_GRAVITY)
			var/grav_force = min(gravity - STANDARD_GRAVITY,3)
			. += 1 + grav_force

		if(H.has_trait(TRAIT_FAT))
			. += (1.5 - flight)
		if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !H.has_trait(TRAIT_RESISTCOLD))
			. += (BODYTEMP_COLD_DAMAGE_LIMIT - H.bodytemperature) / COLD_SLOWDOWN_FACTOR
	return .
