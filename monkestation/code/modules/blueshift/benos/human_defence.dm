/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	. = ..()
	if(!.)
		return

	if(LAZYACCESS(modifiers, RIGHT_CLICK)) //Always drop item in hand, if no item, get stun instead.
		var/obj/item/mob_held_item = get_active_held_item()
		var/disarm_damage = rand(user.melee_damage_lower * 1.5, user.melee_damage_upper * 1.5)

		if(mob_held_item)

			/*
			if(check_block(user, damage = 0, attack_text = "[user.name]"))
				playsound(loc, 'sound/weapons/parry.ogg', 25, TRUE, -1) //Audio feedback to the fact you just got blocked
				apply_damage(disarm_damage / 2, STAMINA)
				visible_message(span_danger("[user] attempts to touch [src]!"), \
					span_danger("[user] attempts to touch you!"), span_hear("You hear a swoosh!"), null, user)
				to_chat(user, span_warning("You attempt to touch [src]!"))
				return FALSE
			*/

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, -1) //The sounds of these are changed so the xenos can actually hear they are being non-lethal
			Knockdown(3 SECONDS)
			apply_damage(disarm_damage, STAMINA)
			visible_message(span_danger("[user] knocks [src] down!"), \
				span_userdanger("[user] knocks you down!"), span_hear("You hear aggressive shuffling follow by a loud thud!"), null, user)
			to_chat(user, span_danger("You knock [src] down!"))
			return TRUE

		else
			playsound(loc, 'sound/effects/hit_kick.ogg', 25, TRUE, -1)
			apply_damage(disarm_damage, STAMINA)
			log_combat(user, src, "tackled")
			visible_message(span_danger("[user] tackles [src] down!"), \
							span_userdanger("[user] tackles you down!"), span_hear("You hear aggressive shuffling!"), null, user)
			to_chat(user, span_danger("You tackle [src] down!"))

		return TRUE

	if(user.istate & ISTATE_HARM)
		if(w_uniform)
			w_uniform.add_fingerprint(user)

		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))

		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)

		var/armor_block = run_armor_check(affecting, MELEE,"","",10)

		playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
		visible_message(span_danger("[user] slashes at [src]!"), \
						span_userdanger("[user] slashes at you!"), span_hear("You hear a sickening sound of a slice!"), null, user)
		to_chat(user, span_danger("You slash at [src]!"))
		log_combat(user, src, "attacked")

		if(!dismembering_strike(user, user.zone_selected)) //Dismemberment successful
			return TRUE

		apply_damage(damage, BRUTE, affecting, armor_block)
