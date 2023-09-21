/datum/attack_style/melee_weapon/overhead

/datum/attack_style/melee_weapon/overhead/get_swing_description(has_alt_style)
	return "Comes down over the tile in the direction you are attacking. Always targets the head."

/datum/attack_style/melee_weapon/overhead/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	// Future todo : When we decouple more of attack chain this can be passed via proc args
	var/old_zone = attacker.zone_selected
	attacker.zone_selected = BODY_ZONE_HEAD
	. = ..()
	attacker.zone_selected = old_zone
