//magician's fried chicken

/datum/sutando_abilities/fire
	id = "fire"
	name = "Controlled Combustion"
	value = 7


/datum/sutando_abilities/fire/handle_stats()
	stand.melee_damage_lower += 4.5
	stand.melee_damage_upper += 4.5
	stand.attack_sound = 'sound/items/Welder.ogg'
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.3
	stand.range += 4.5
	stand.a_intent = INTENT_HELP

/datum/sutando_abilities/fire/bump_reaction(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/M = AM
		if(!stand.hasmatchingsummoner(M) && M != user && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()

/datum/sutando_abilities/fire/life_act()
	if(user)
		user.ExtinguishMob()
		user.adjust_fire_stacks(-20)

