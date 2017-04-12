//ORA ORA ORA

/datum/sutando_abilities/punch
	id = "punch"
	name = "Close-Range Combat"
	value = 5


/datum/sutando_abilities/punch/handle_stats()
	. = ..()
	stand.melee_damage_lower += 10
	stand.melee_damage_upper += 10
	stand.obj_damage += 80
	stand.next_move_modifier -= 0.2 //attacks 20% faster
	stand.environment_smash = 2


/datum/sutando_abilities/punch/ability_act()
	if(isliving(stand.target))
		stand.attack_sound = pick('sound/magic/sutandopunch.ogg', 'sound/magic/sutandopunch1.ogg', 'sound/magic/sutandopunch2.ogg')
		stand.say("[battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry]!!")
		playsound(stand.loc, stand.attack_sound, 50, 1, 1)
		playsound(stand.loc, stand.attack_sound, 50, 1, 1)
		playsound(stand.loc, stand.attack_sound, 50, 1, 1)
		playsound(stand.loc, stand.attack_sound, 50, 1, 1)