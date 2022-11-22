/datum/martial_art/carp_jaws
	name = "Carp Jaws"
	id = MARTIALART_CARP_JAWS

/datum/martial_art/carp_jaws/harm_act(mob/living/attacker, mob/living/defender)
	var/obj/item/bodypart/affecting = defender.get_bodypart(defender.get_random_valid_zone(attacker.zone_selected))
	attacker.do_attack_animation(defender, ATTACK_EFFECT_BITE)
	var/atk_verb = pick("chomp", "bite", "gnash")
	defender.visible_message(span_danger("[attacker] [atk_verb]s [defender]!"), \
					span_userdanger("[attacker] [atk_verb]s you!"), null, null, attacker)
	to_chat(attacker, span_danger("You [atk_verb] [defender]!"))
	defender.apply_damage(15, BRUTE, affecting, wound_bonus=10)
	playsound(get_turf(defender), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	log_combat(attacker, defender, "bitten (Carp Jaws)")
	return TRUE
