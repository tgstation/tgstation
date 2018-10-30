/mob/living/carbon/human/updatehealth()
	. = ..()
	var/health_deficiency = (100 - health - staminaloss)
	if(health_deficiency >= 40)
		add_movespeed_modifier(MOVESPEED_ID_HUMAN_HEALTH, override = TRUE, flags = MOVESPEED_MODIFIER_NO_FLIGHT, multiplicative_slowdown = health_deficiency / 25)
		add_movespeed_modifier(MOVESPEED_ID_HUMAN_HEALTH_FLIGHT, override = TRUE, flags = MOVESPEED_MODIFIER_REQUIRES_FLIGHT, multiplicative_slowdown = health_deficiency / 75)
	else
		remove_movespeed_modifier(MOVESPEED_ID_HUMAN_HEALTH)
		remove_movespeed_modifier(MOVESPEED_ID_HUMAN_HEALTH_FLIGHT)

/mob/living/carbon/human/proc/update_item_slowdown()
	. = 0
	if(istype(wear_suit))
		. += wear_suit.slowdown
	if(istype(shoes))
		. += shoes.slowdown
	if(istype(back))
		. += back.slowdown
	for(var/obj/item/I in held_items)
		if(I.item_flags & SLOWS_WHILE_IN_HAND)
			. += I.slowdown
	add_movespeed_modifier(MOVESPEED_ID_HUMAN_ITEM, override = TRUE, flags = MOVESPEED_MODIFIER_REQUIRES_GRAVITY, multiplicative_slowdown = .)

/mob/living/carbon/human/proc/update_hunger()			//NOT CODE HOOKED YET

/mob/living/carbon/human/proc/update_trait_slowdowns()		//NOT CODE HOOKED YET
	. = 0
	if(has_trait(TRAIT_GOTTAGOFAST))
		. -= 1
	else if(has_trait(TRAIT_GOTTAGOREALLYFAST))
		. -= 2
	add_movespeed_modifier(MOVESPEED_ID_HUMAN_TRAIT, override = TRUE, flags = (MOVESPEED_MODIFIER_REQUIRES_GRAIVTY|MOVESPEED_MODIFIER_NO_FLIGHT), multiplicative_slowdown = .)

/mob/living/carbon/human/movement_delay()
	return species:_movement_delay() + ..()			//YES I KNOW THIS IS BANNED THIS IS A WIP PR!
//THIS ENTIRE FILE IS WIP
////////////////
// MOVE SPEED //
////////////////

/datum/species/proc/_movement_delay(mob/living/carbon/human/H)

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
