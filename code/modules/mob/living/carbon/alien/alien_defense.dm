
/mob/living/carbon/human/species/alien/get_eye_protection()
	return ..() + 2 //potential cyber implants + natural eye protection

/mob/living/carbon/human/species/alien/get_ear_protection()
	return 2 //no ears

/mob/living/carbon/human/species/alien/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..(AM, skipcatch = TRUE, hitpush = FALSE)


/*Code for aliens attacking aliens. Because aliens act on a hivemind, I don't see them as very aggressive with each other.
As such, they can either help or harm other aliens. Help works like the human help command while harm is a simple nibble.
In all, this is a lot like the monkey code. /N
*/
/mob/living/carbon/human/species/alien/attack_alien(mob/living/carbon/human/species/alien/user, list/modifiers)
	if(isturf(loc) && istype(loc.loc, /area/start))
		to_chat(user, "No attacking people at spawn, you jackass.")
		return

	if(user.combat_mode)
		if(user == src && check_self_for_injuries())
			return
		set_resting(FALSE)
		AdjustStun(-60)
		AdjustKnockdown(-60)
		AdjustImmobilized(-60)
		AdjustParalyzed(-60)
		AdjustUnconscious(-60)
		AdjustSleeping(-100)
		visible_message(span_notice("[user.name] nuzzles [src] trying to wake [p_them()] up!"))
	else if(health > 0)
		user.do_attack_animation(src, ATTACK_EFFECT_BITE)
		playsound(loc, 'sound/weapons/bite.ogg', 50, TRUE, -1)
		visible_message(span_danger("[user.name] bites [src]!"), \
						span_userdanger("[user.name] bites you!"), span_hear("You hear a chomp!"), COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("You bite [src]!"))
		adjustBruteLoss(1)
		log_combat(user, src, "attacked")
		updatehealth()
	else
		to_chat(user, span_warning("[name] is too injured for that."))



/mob/living/carbon/human/species/alien/attack_larva(mob/living/carbon/human/species/alien/larva/L)
	return attack_alien(L)


/mob/living/carbon/human/species/alien/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.) //to allow surgery to return properly.
		return FALSE

	var/martial_result = user.apply_martial_art(src, modifiers)
	if (martial_result != MARTIAL_ATTACK_INVALID)
		return martial_result

	if(user.combat_mode)
		if(LAZYACCESS(modifiers, RIGHT_CLICK))
			user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return TRUE
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		return TRUE
	else
		help_shake_act(user)


/mob/living/carbon/human/species/alien/attack_paw(mob/living/carbon/human/user, list/modifiers)
	if(..())
		if (stat != DEAD)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(user.zone_selected))
			apply_damage(rand(1, 3), BRUTE, affecting)

/mob/living/carbon/human/species/alien/soundbang_act(intensity = 1, stun_pwr = 20, damage_pwr = 5, deafen_pwr = 15)
	return 0

/mob/living/carbon/human/species/alien/acid_act(acidpwr, acid_volume)
	return FALSE//aliens are immune to acid.
