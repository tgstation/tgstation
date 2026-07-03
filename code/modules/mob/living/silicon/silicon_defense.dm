
/mob/living/silicon/grippedby(mob/living/carbon/user, instant = FALSE)
	return //can't upgrade a simple pull into a more aggressive grab.

/mob/living/silicon/get_ear_protection(ignore_deafness = FALSE)
	return ..() + EAR_PROTECTION_HEAVY //no ears

/mob/living/silicon/attack_alien(mob/living/carbon/alien/adult/user, list/modifiers)
	. = ..()
	if(!.) //if harm or disarm intent
		return
	var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
	if (prob(90))
		playsound(loc, 'sound/items/weapons/slash.ogg', 25, TRUE, -1)
		visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] режет [declent_ru(ACCUSATIVE)]!"), \
						span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] режет вас!"), null, null, user)
		to_chat(user, span_danger("Вы режете [declent_ru(ACCUSATIVE)]!"))
		if(prob(8))
			flash_act(affect_silicon = 1)
		adjust_brute_loss(damage)
		log_combat(user, src, "attacked")
	else
		playsound(loc, 'sound/items/weapons/slashmiss.ogg', 25, TRUE, -1)
		visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] промахивается режущим ударом по [declent_ru(DATIVE)]!"),
						span_danger("Вы избегаете режущий удар от [declent_ru(GENITIVE)]"), null, null, user)
		to_chat(user, span_warning("Вы промахиваетесь режущим ударом по [declent_ru(DATIVE)]!"))
		log_combat(user, src, "attacked and missed")

/mob/living/silicon/attack_animal(mob/living/simple_animal/user, list/modifiers)
	. = ..()
	var/damage_received = .
	if(prob(damage_received))
		for(var/mob/living/buckled in buckled_mobs)
			buckled.Paralyze(2 SECONDS)
			unbuckle_mob(buckled)
			buckled.visible_message(
				span_danger("[capitalize(buckled.declent_ru(NOMINATIVE))] сбит с [declent_ru(GENITIVE)] ударом от [user.declent_ru(GENITIVE)]!"),
				span_userdanger("Вы сбиты с [declent_ru(GENITIVE)] ударом от [user.declent_ru(GENITIVE)]!"),
				ignored_mobs = user,
			)
			to_chat(user, span_danger("Вы сбиваете [buckled.declent_ru(ACCUSATIVE)] с [declent_ru(GENITIVE)]!"))

/mob/living/silicon/attack_paw(mob/living/user, list/modifiers)
	return attack_hand(user, modifiers)

/mob/living/silicon/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(!L.combat_mode)
		visible_message(span_notice("[capitalize(L.declent_ru(NOMINATIVE))] трется головой об [declent_ru(ACCUSATIVE)]."))

/mob/living/silicon/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	adjust_brute_loss(rand(10, 15))
	playsound(loc, SFX_PUNCH, 25, TRUE, -1)
	visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] бьет [declent_ru(ACCUSATIVE)]!"), \
					span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] бьет вас!"), null, COMBAT_MESSAGE_RANGE, user)
	to_chat(user, span_danger("Вы бьете [declent_ru(ACCUSATIVE)]!"))

/mob/living/silicon/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if(.)
		return TRUE

	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		user.disarm(src)
		return TRUE

	if(has_buckled_mobs() && !user.combat_mode)
		user_unbuckle_mob(buckled_mobs[1], user)
		return TRUE
	if(user.combat_mode)
		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		playsound(src.loc, 'sound/effects/bang.ogg', 10, TRUE)
		visible_message(span_danger("[capitalize(user.declent_ru(NOMINATIVE))] бьет [declent_ru(ACCUSATIVE)], но не оставляет и вмятины!"), \
						span_warning("[capitalize(user.declent_ru(NOMINATIVE))] бьет вас, но не оставляет и вмятины!"), null, COMBAT_MESSAGE_RANGE, user)
		to_chat(user, span_danger("Вы бьете [declent_ru(ACCUSATIVE)], но не оставляете и вмятины!"))
		return TRUE
	else
		visible_message(span_notice("[capitalize(user.declent_ru(NOMINATIVE))] гладит [declent_ru(ACCUSATIVE)]."), span_notice("[capitalize(user.declent_ru(NOMINATIVE))] гладит вас."), null, null, user)
		to_chat(user, span_notice("Вы гладите [declent_ru(ACCUSATIVE)]."))
		SEND_SIGNAL(user, COMSIG_MOB_PAT_BORG)
		return TRUE

/mob/living/silicon/check_block(atom/hitby, damage, attack_text, attack_type, armour_penetration, damage_type, attack_flag)
	. = ..()
	if(. == SUCCESSFUL_BLOCK)
		return SUCCESSFUL_BLOCK
	if(damage_type == BRUTE && attack_type == UNARMED_ATTACK && attack_flag == MELEE && damage <= 10)
		playsound(src, 'sound/effects/bang.ogg', 10, TRUE)
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] не получает и вмятины - корпус останавливает [attack_text]!"), vision_distance = COMBAT_MESSAGE_RANGE)
		return SUCCESSFUL_BLOCK
	return FAILED_BLOCK

/mob/living/silicon/attack_drone(mob/living/basic/drone/user)
	if(user.combat_mode)
		return
	return ..()

/mob/living/silicon/attack_drone_secondary(mob/living/basic/drone/user)
	if(user.combat_mode)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/mob/living/silicon/emp_act(severity)
	. = ..()
	to_chat(src, span_danger("Предупреждение: обнаружен электромагнитный импульс."))
	if(. & EMP_PROTECT_SELF || QDELETED(src))
		return
	switch(severity)
		if(1)
			src.take_bodypart_damage(burn = 20)
		if(2)
			src.take_bodypart_damage(burn = 10)
	to_chat(src, span_userdanger("*БЗЗЗТ*"))
	for(var/mob/living/M in buckled_mobs)
		if(prob(severity*50))
			unbuckle_mob(M)
			M.Paralyze(40)
			M.visible_message(span_boldwarning("[capitalize(M.declent_ru(NOMINATIVE))] падает с [declent_ru(GENITIVE)]!"))
	flash_act(affect_silicon = 1)

/mob/living/silicon/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if(hitting_projectile.damage_type == BURN)
		hitting_projectile.damage_type = BRUTE //Burn is for wire damage. Brute is the outer chassis.
	. = ..()
	if(. != BULLET_ACT_HIT)
		return .

	var/prob_of_knocking_dudes_off = 0
	if(hitting_projectile.damage_type == BRUTE)
		prob_of_knocking_dudes_off = hitting_projectile.damage * 1.5
	if(hitting_projectile.stun || hitting_projectile.knockdown || hitting_projectile.paralyze)
		prob_of_knocking_dudes_off = 100

	if(prob(prob_of_knocking_dudes_off))
		for(var/mob/living/buckled in buckled_mobs)
			buckled.visible_message(span_boldwarning("[capitalize(buckled.declent_ru(NOMINATIVE))] падает с [declent_ru(GENITIVE)] от попадания [hitting_projectile.declent_ru(GENITIVE)]!"))
			unbuckle_mob(buckled)
			buckled.Paralyze(4 SECONDS)

/mob/living/silicon/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash/static, length = 25)
	if(affect_silicon)
		return ..()

/// If an item does this or more throwing damage it will slow a borg down on hit
#define CYBORG_SLOWDOWN_THRESHOLD 10

/mob/living/silicon/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	. = ..()
	if(. || AM.throwforce < CYBORG_SLOWDOWN_THRESHOLD) // can cyborgs even catch things?
		return
	apply_status_effect(/datum/status_effect/borg_slow, AM.throwforce / 20)

/mob/living/silicon/attack_effects(damage_done, hit_zone, armor_block, obj/item/attacking_item, mob/living/attacker)
	. = ..()
	if(damage_done < CYBORG_SLOWDOWN_THRESHOLD)
		return
	apply_status_effect(/datum/status_effect/borg_slow, damage_done / 60)

#undef CYBORG_SLOWDOWN_THRESHOLD

/mob/living/silicon/hypnosis_vulnerable()
	return FALSE //It obeys its laws
