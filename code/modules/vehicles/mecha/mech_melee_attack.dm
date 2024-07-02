/**
 * ## Mech melee attack
 * Called when a mech melees a target with fists
 * Handles damaging the target & associated effects
 * return value is number of damage dealt. returning a value puts our mech onto attack cooldown.
 * Arguments:
 * * mecha_attacker: Mech attacking this target
 * * user: mob that initiated the attack from inside the mech as a controller
 */
/atom/proc/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_MECH, mecha_attacker, user)
	log_combat(user, src, "attacked", mecha_attacker, "(COMBAT MODE: [uppertext(user.combat_mode)] (DAMTYPE: [uppertext(mecha_attacker.damtype)])")
	return 0

/turf/closed/wall/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	if(!user.combat_mode)
		return 0

	mecha_attacker.do_attack_animation(src)
	switch(mecha_attacker.damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 50, TRUE)
		else
			return 0
	mecha_attacker.visible_message(span_danger("[mecha_attacker] hits [src]!"), span_danger("You hit [src]!"), null, COMBAT_MESSAGE_RANGE)
	if(prob(hardness + mecha_attacker.force) && mecha_attacker.force > 20)
		dismantle_wall(1)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	else
		add_dent(WALL_DENT_HIT)
	..()
	return 100 //this is an arbitrary "damage" number since the actual damage is rng dismantle

/obj/structure/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	if(!user.combat_mode)
		return 0

	mecha_attacker.do_attack_animation(src)
	switch(mecha_attacker.damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 50, TRUE)
		else
			return 0
	mecha_attacker.visible_message(span_danger("[mecha_attacker] hits [src]!"), span_danger("You hit [src]!"), null, COMBAT_MESSAGE_RANGE)
	..()
	return take_damage(mecha_attacker.force * 3, mecha_attacker.damtype, "melee", FALSE, get_dir(src, mecha_attacker)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

/obj/machinery/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	if(!user.combat_mode)
		return 0

	mecha_attacker.do_attack_animation(src)
	switch(mecha_attacker.damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 50, TRUE)
		else
			return 0
	mecha_attacker.visible_message(span_danger("[mecha_attacker] hits [src]!"), span_danger("You hit [src]!"), null, COMBAT_MESSAGE_RANGE)
	..()
	return take_damage(mecha_attacker.force * 3, mecha_attacker.damtype, "melee", FALSE, get_dir(src, mecha_attacker)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

/obj/structure/window/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	if(!can_be_reached())
		return 0
	return ..()

/mob/living/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	if(!user.combat_mode)
		step_away(src, mecha_attacker)
		log_combat(user, src, "pushed", mecha_attacker)
		visible_message(span_warning("[mecha_attacker] pushes [src] out of the way."), \
						span_warning("[mecha_attacker] pushes you out of the way."), span_hear("You hear aggressive shuffling!"), 5, list(mecha_attacker))
		to_chat(mecha_attacker, span_danger("You push [src] out of the way."))
		return 0

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to harm other living beings!"))
		return 0
	mecha_attacker.do_attack_animation(src)
	if(mecha_attacker.damtype == BRUTE)
		step_away(src, mecha_attacker, 15)
	var/obj/item/bodypart/selected_zone = get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_HEAD))
	if(selected_zone)
		var/dmg = rand(mecha_attacker.force * 0.5, mecha_attacker.force)
		switch(mecha_attacker.damtype)
			if(BRUTE)
				if(mecha_attacker.force > 35) // durand and other heavy mechas
					Unconscious(20)
				else if(mecha_attacker.force > 20 && !IsKnockdown()) // lightweight mechas like gygax
					Knockdown(40)
				selected_zone.receive_damage(dmg, 0, updating_health = TRUE)
				playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			if(FIRE)
				selected_zone.receive_damage(0, dmg, updating_health = TRUE)
				playsound(src, 'sound/items/welder.ogg', 50, TRUE)
			if(TOX)
				playsound(src, 'sound/effects/spray2.ogg', 50, TRUE)
				if((reagents.get_reagent_amount(/datum/reagent/cryptobiolin) + mecha_attacker.force) < mecha_attacker.force*2)
					reagents.add_reagent(/datum/reagent/cryptobiolin, mecha_attacker.force/2)
				if((reagents.get_reagent_amount(/datum/reagent/toxin) + mecha_attacker.force) < mecha_attacker.force*2)
					reagents.add_reagent(/datum/reagent/toxin, mecha_attacker.force/2.5)
			else
				return 0
		. = dmg
	visible_message(span_danger("[mecha_attacker.name] hits [src]!"), \
		span_userdanger("[mecha_attacker.name] hits you!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), COMBAT_MESSAGE_RANGE, list(mecha_attacker))
	to_chat(mecha_attacker, span_danger("You hit [src]!"))
	..()
