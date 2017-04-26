//magician's fried chicken

/datum/guardian_abilities/fire
	id = "fire"
	name = "Controlled Combustion"
	value = 7


/datum/guardian_abilities/fire/handle_stats()
	guardian.melee_damage_lower += 4.5
	guardian.melee_damage_upper += 4.5
	guardian.attack_sound = 'sound/items/Welder.ogg'
	for(var/i in guardian.damage_coeff)
		guardian.damage_coeff[i] -= 0.3
	guardian.range += 4.5
	guardian.a_intent = INTENT_HELP

/datum/guardian_abilities/fire/bump_reaction(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/M = AM
		if(!guardian.hasmatchingsummoner(M) && M != user && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()

/datum/guardian_abilities/fire/life_act()
	if(user)
		user.ExtinguishMob()
		user.adjust_fire_stacks(-20)

