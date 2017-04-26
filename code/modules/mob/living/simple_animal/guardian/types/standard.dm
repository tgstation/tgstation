//ORA ORA ORA

/datum/guardian_abilities/punch
	id = "punch"
	name = "Close-Range Combat"
	value = 5


/datum/guardian_abilities/punch/handle_stats()
	. = ..()
	guardian.melee_damage_lower += 10
	guardian.melee_damage_upper += 10
	guardian.obj_damage += 80
	guardian.next_move_modifier -= 0.2 //attacks 20% faster
	guardian.environment_smash = 2


/datum/guardian_abilities/punch/ability_act()
	if(isliving(guardian.target))
		guardian.attack_sound = pick('sound/magic/guardianpunch.ogg', 'sound/magic/guardianpunch1.ogg', 'sound/magic/guardianpunch2.ogg')
		guardian.say("[battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry]!!")
		playsound(guardian.loc, guardian.attack_sound, 50, 1, 1)
		playsound(guardian.loc, guardian.attack_sound, 50, 1, 1)
		playsound(guardian.loc, guardian.attack_sound, 50, 1, 1)
		playsound(guardian.loc, guardian.attack_sound, 50, 1, 1)