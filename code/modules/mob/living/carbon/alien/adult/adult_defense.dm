

/mob/living/carbon/alien/adult/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjust_brute_loss(15)
	var/hitverb = "hit"
	if(mob_size < MOB_SIZE_LARGE)
		safe_throw_at(get_edge_target_turf(src, get_dir(user, src)), 2, 1, user)
		hitverb = "slam"
	playsound(loc, /datum/sound_effect/punch, 25, TRUE, -1)
	combat_message(
		attacker = user,
		defender = src,
		to_attacker = "You [hitverb] [src]!",
		to_defender = "[user] [PRESENT_TENSE(hitverb)] you!",
		to_blind_attacker = "You [hitverb] someone!",
		to_blind_defender = "Someone [PRESENT_TENSE(hitverb)] you!",
		to_viewers = "[user] [PRESENT_TENSE(hitverb)] [src]!",
		to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
	)

/mob/living/carbon/alien/adult/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE
	var/damage = rand(1, 9)
	if (prob(90))
		playsound(loc, /datum/sound_effect/punch, 25, TRUE, -1)
		combat_message(
			attacker = user,
			defender = src,
			to_attacker = "You punch [src]!",
			to_defender = "[user] punches you!",
			to_blind_attacker = "You punch something!",
			to_blind_defender = "Something punches you!",
			to_viewers = "[user] punches [src]!",
			to_blind_viewers = "You hear a sickening sound of flesh hitting flesh!",
		)
		if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of knocking an alien down.
			Unconscious(40)
			visible_message(
				span_attack_other("[src] is knocked down!"),
				span_attack_self_major("You're knocked down!"),
				span_hear("You hear a heavy thud!"),
				COMBAT_MESSAGE_RANGE,
				ALWAYS_SHOW_SELF_MESSAGE,
			)
		var/obj/item/bodypart/affecting = get_bodypart(get_random_valid_zone(user.zone_selected))
		apply_damage(damage, BRUTE, affecting)
		log_combat(user, src, "attacked")
	else
		playsound(loc, 'sound/items/weapons/punchmiss.ogg', 25, TRUE, -1)
		visible_message(span_danger("[user]'s punch misses [src]!"), \
						span_danger("You avoid [user]'s punch!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your punch misses [src]!"))
		combat_message(
			attacker = user,
			defender = src,
			to_attacker = "You miss [src]!",
			to_defender = "[user] misses you!",
			to_blind_attacker = "You throw out a punch and miss!",
			to_blind_defender = "You hear a swoosh!",
			to_viewers = "[user] misses [src]!",
			to_blind_viewers = "You hear a swoosh!",
		)

/mob/living/carbon/alien/adult/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
