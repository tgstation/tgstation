

/mob/living/carbon/alien/adult/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjustBruteLoss(15)
	var/hitverb = "hit"
	if(mob_size < MOB_SIZE_LARGE)
		safe_throw_at(get_edge_target_turf(src, get_dir(user, src)), 2, 1, user)
		hitverb = "slam"
	playsound(loc, SFX_PUNCH, 25, TRUE, -1)
	visible_message(span_danger("[user] [hitverb]s [src]!"), \
					span_userdanger("[user] [hitverb]s you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("You [hitverb] [src]!"))

/mob/living/carbon/alien/adult/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(!..() || !user.combat_mode)
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		if (body_position == STANDING_UP)
			if (prob(5))
				Unconscious(40)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
				log_combat(user, src, "pushed")
				visible_message(span_danger("[user] pushes [src] down!"), \
								span_userdanger("[user] pushes you down!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), null, user)
				to_chat(user, span_danger("You push [src] down!"))
		return TRUE
	var/damage = rand(1, 9)
	if (prob(90))
		playsound(loc, SFX_PUNCH, 25, TRUE, -1)
		visible_message(span_danger("[user] punches [src]!"), \
						span_userdanger("[user] punches you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You punch [src]!"))
		if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of knocking an alien down.
			Unconscious(40)
			visible_message(span_danger("[user] knocks [src] down!"), \
							span_userdanger("[user] knocks you down!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, user)
			to_chat(user, span_danger("You knock [src] down!"))
		var/obj/item/bodypart/affecting = get_bodypart(get_random_valid_zone(user.zone_selected))
		apply_damage(damage, BRUTE, affecting)
		log_combat(user, src, "attacked")
	else
		playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
		visible_message(span_danger("[user]'s punch misses [src]!"), \
						span_danger("You avoid [user]'s punch!"), span_hear("You hear a swoosh!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Your punch misses [src]!"))


/mob/living/carbon/alien/adult/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
