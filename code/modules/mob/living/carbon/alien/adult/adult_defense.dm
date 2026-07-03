

/mob/living/carbon/alien/adult/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjust_brute_loss(15)
	var/hitverb = "ударяет"
	if(mob_size < MOB_SIZE_LARGE)
		safe_throw_at(get_edge_target_turf(src, get_dir(user, src)), 2, 1, user)
		hitverb = "швыряет"
	playsound(loc, SFX_PUNCH, 25, TRUE, -1)
	visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] [hitverb] [declent_ru(ACCUSATIVE)]!"), \
					span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] [hitverb] вас!"), span_hear("Вы слышите противный звук удара плоти о плоть!"), COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("Вы [hitverb]е [declent_ru(ACCUSATIVE)]!"))

/mob/living/carbon/alien/adult/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE
	var/damage = rand(1, 9)
	if (prob(90))
		playsound(loc, SFX_PUNCH, 25, TRUE, -1)
		visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] бьет [declent_ru(ACCUSATIVE)]!"), \
						span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] бьет вас!"), span_hear("Вы слышите противный звук удара плоти о плоть!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("Вы бьете [declent_ru(ACCUSATIVE)]!"))
		if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of knocking an alien down.
			Unconscious(40)
			visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] сбивает [declent_ru(ACCUSATIVE)] с ног!"), \
							span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] сбивает вас с ног!"), span_hear("Вы слышите противный звук удара плоти о плоть!"), null, user)
			to_chat(user, span_danger("Вы сбиваете [declent_ru(ACCUSATIVE)] с ног!"))
		var/obj/item/bodypart/affecting = get_bodypart(get_random_valid_zone(user.zone_selected))
		apply_damage(damage, BRUTE, affecting)
		log_combat(user, src, "attacked")
	else
		playsound(loc, 'sound/items/weapons/punchmiss.ogg', 25, TRUE, -1)
		visible_message(span_danger("Удар [user.declent_ru(GENITIVE)] промахивается по [declent_ru(DATIVE)]!"), \
						span_danger("Вы уворачиваетесь от удара [user.declent_ru(GENITIVE)]!"), span_hear("Вы слышите свист!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_warning("Вы промахиваетесь по [declent_ru(DATIVE)]!"))

/mob/living/carbon/alien/adult/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && !visual_effect_icon)
		visual_effect_icon = ATTACK_EFFECT_CLAW
	..()
