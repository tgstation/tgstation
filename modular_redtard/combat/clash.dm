/// Ratwood's duelist's rings (rogueclothes/rings.dm, clashpurgepeelstuffs.dm, rmb_intents.dm): a bait between two duelists
/// takes the balance for longer (values/combat.txt, "Weapons and gear").
#define ROGUE_DUELIST_BAIT_OFFBALANCE rogue_value("duelist_bait_offbalance")
#define ROGUE_DUELIST_BAIT_HOLD rogue_value("duelist_bait_hold")

/mob/living/var/rogue_bait_stacks = 0

/// Ratwood has_duelist_ring(): a duelist's ring on a finger (the porter lets it be worn on the gloves too).
/mob/living/carbon/human/proc/rogue_has_duelist_ring()
	if(istype(gloves, /obj/item/clothing/ring/duelist))
		return TRUE
	for(var/obj/item/ring as anything in wear_rings)
		if(istype(ring, /obj/item/clothing/ring/duelist))
			return TRUE
	return FALSE

/// Both wear a duelist's ring: an honourable duel.
/mob/living/carbon/human/proc/rogue_dueling(mob/living/carbon/human/opponent)
	return istype(opponent) && rogue_has_duelist_ring() && opponent.rogue_has_duelist_ring()

/mob/living/carbon/human/proc/rogue_try_guard()
	if(has_status_effect(/datum/status_effect/rogue/guard) || has_status_effect(/datum/status_effect/rogue/guard_cooldown))
		return FALSE
	if(!get_active_held_item() && rogue_skill_rank(/datum/attribute/skill/combat/unarmed) < ROGUE_GUARD_UNARMED_RANK)
		to_chat(src, span_warning("I'm not skilled enough in the art of unarmed combat to guard without a weapon!"))
		return FALSE
	if(pulling || pulledby || incapacitated || HAS_TRAIT(src, TRAIT_IMMOBILIZED) || rogue_offbalanced(FALSE) || rogue_is_open())
		return FALSE
	if(move_intent == MOVE_INTENT_RUN)
		to_chat(src, span_warning("I can't focus on this while running."))
		return FALSE
	rogue_mark_in_combat()
	apply_status_effect(/datum/status_effect/rogue/guard)
	return TRUE

/mob/living/carbon/human/proc/rogue_bad_guard(message, cheesy = FALSE)
	if(!has_status_effect(/datum/status_effect/rogue/guard))
		return
	adjust_stamina_loss(max_stamina * ROGUE_BAD_GUARD_DRAIN / 100)
	if(cheesy)
		rogue_energy_add(-rogue_max_energy * ROGUE_BAD_GUARD_DRAIN / 100)
		Immobilize(ROGUE_BAD_GUARD_HOLD)
	if(message)
		to_chat(src, span_warning(message))
	remove_status_effect(/datum/status_effect/rogue/guard)

/mob/living/carbon/human/proc/rogue_riposte(mob/living/attacker)
	attacker.apply_status_effect(/datum/status_effect/rogue/exposed, ROGUE_RIPOSTE_EXPOSED)
	attacker.rogue_delay_action(ROGUE_RIPOSTE_CLICK)
	if(attacker.mind)
		attacker.rogue_change_dodge_cooldown(ROGUE_RIPOSTE_DODGE_PENALTY)
	attacker.rogue_slowdown(ROGUE_RIPOSTE_SLOW)
	to_chat(src, span_notice("[attacker] [attacker.p_are()] exposed!"))
	playsound(src, 'modular_redtard/rockhill/sound/combat/clash_struck.ogg', 100)
	remove_status_effect(/datum/status_effect/rogue/guard)
	log_combat(src, attacker, "riposted")

/obj/item/proc/rogue_riposte_wear(obj/item/riposting_weapon, mob/living/holder)
	if(max_blade_int)
		var/share = ROGUE_RIPOSTE_SHARPNESS + (riposting_weapon?.wbalance == WBALANCE_HEAVY ? ROGUE_RIPOSTE_HEAVY_SHARPNESS : 0)
		rogue_dull(blade_int * share, holder)
		return
	take_damage(max(max_integrity / ROGUE_RIPOSTE_INTEGRITY_DIVISOR, ROGUE_UNARMED_PARRY_WEAR * ROGUE_RIPOSTE_INTEGRITY_FLOOR), BRUTE, "", FALSE)

/mob/living/carbon/human/proc/rogue_process_clash(datum/rogue_strike/strike)
	var/mob/living/attacker = strike.attacker
	var/obj/item/our_weapon = get_active_held_item()
	var/obj/item/their_weapon = strike.weapon
	if(attacker == src)
		rogue_bad_guard("I hit myself.")
		return
	if(ishuman(attacker) && attacker.has_status_effect(/datum/status_effect/rogue/guard))
		rogue_clash(attacker, our_weapon, their_weapon)
		return
	if(!their_weapon)
		visible_message(span_suicide((our_weapon ? "[src] ripostes [attacker] with \the [our_weapon]!" : "[src] ripostes [attacker]'s strike with [p_their()] bare hands!")))
	else if(!our_weapon)
		visible_message(span_suicide("[src] ripostes [attacker]'s strike with [p_their()] bare hands!"))
		their_weapon.rogue_riposte_wear(null, attacker)
	else
		their_weapon.rogue_riposte_wear(our_weapon, attacker)
		visible_message(span_suicide("[src] ripostes [attacker] with \the [our_weapon]!"))
		rogue_change_dodge_cooldown(-ROGUE_RIPOSTE_DODGE_PENALTY)
	rogue_riposte(attacker)

/mob/living/carbon/human/proc/rogue_catch_bite(mob/living/biter)
	var/obj/item/our_weapon = get_active_held_item()
	var/force = our_weapon ? our_weapon.force * rogue_strength_factor(our_weapon, src) : rogue_unarmed_damage()
	visible_message(span_suicide((our_weapon ? "[src] catches [biter]'s bite and bashes \the [our_weapon] into [biter.p_their()] mouth!" : "[src] catches [biter]'s bite and smashes [p_their()] fist into [biter.p_their()] mouth!")))
	var/blocked = biter.run_armor_check(BODY_ZONE_HEAD, MELEE, silent = TRUE)
	if(ishuman(biter))
		var/mob/living/carbon/human/human_biter = biter
		force *= human_biter.rogue_armor_hit(BODY_ZONE_PRECISE_MOUTH, ROGUE_ARMOR_BLUNT, force, ROGUE_PEN_NONE, rogue_wear_factor(our_weapon, null), our_weapon, BCLASS_BLUNT)
	biter.rogue_apply_armored_damage(force, BRUTE, BODY_ZONE_HEAD, blocked, attacking_item = our_weapon)
	rogue_riposte(biter)

/mob/living/carbon/human/proc/rogue_clash(mob/living/carbon/human/opponent, obj/item/our_weapon, obj/item/their_weapon)
	var/our_chance = 0
	var/their_chance = 0
	for(var/stat_type in list(ROGUE_STAT_STRENGTH, ROGUE_STAT_PERCEPTION, ROGUE_STAT_SPEED, ROGUE_STAT_FORTUNE, ROGUE_STAT_INTELLIGENCE))
		var/gap = rogue_stat(stat_type) - opponent.rogue_stat(stat_type)
		if(gap >= ROGUE_CLASH_STAT_GAP)
			our_chance += ROGUE_CLASH_STEP
		else if(gap <= -ROGUE_CLASH_STAT_GAP)
			their_chance += ROGUE_CLASH_STEP
	var/skill_gap = rogue_weapon_rank(our_weapon) - opponent.rogue_weapon_rank(their_weapon)
	var/list/edges = list(
		skill_gap,
		(our_weapon ? our_weapon.wlength : 0) - (their_weapon ? their_weapon.wlength : 0),
		(our_weapon?.rogue_wielded ? 1 : 0) - (their_weapon?.rogue_wielded ? 1 : 0),
		((our_weapon ? our_weapon.wbalance : WBALANCE_NORMAL) < (their_weapon ? their_weapon.wbalance : WBALANCE_NORMAL)) ? 1 : 0,
		pick(-1, 0, 1),
	)
	for(var/edge in edges)
		if(edge > 0)
			our_chance += ROGUE_CLASH_STEP
		else if(edge < 0)
			their_chance += ROGUE_CLASH_STEP
	our_chance += rand(ROGUE_CLASH_INITIATOR_MIN, ROGUE_CLASH_INITIATOR_MAX)
	// Ratwood's duelist's rings: two duelists clash on even odds, each with the better of the two chances.
	if(rogue_dueling(opponent))
		our_chance = max(our_chance, their_chance)
		their_chance = our_chance
	visible_message(span_boldwarning("[src] and [opponent] clash!"))
	do_sparks(1, TRUE, get_step(src, dir))
	var/decided = FALSE
	if(prob(our_chance))
		playsound(src, 'modular_redtard/rockhill/sound/combat/clash_disarm_opp.ogg', 100, TRUE)
		opponent.rogue_lose_clash(their_weapon)
		decided = TRUE
	if(prob(their_chance))
		playsound(src, 'modular_redtard/rockhill/sound/combat/clash_disarm_us.ogg', 100, TRUE)
		rogue_lose_clash(our_weapon)
		decided = TRUE
	if(!decided)
		to_chat(src, span_warning("Draw! The opponent's chances were... [their_chance]%"))
		to_chat(opponent, span_warning("Draw! The opponent's chances were... [our_chance]%"))
		playsound(src, 'modular_redtard/rockhill/sound/combat/clash_draw.ogg', 100, TRUE)
	log_combat(src, opponent, "clashed with")
	remove_status_effect(/datum/status_effect/rogue/guard)
	opponent.remove_status_effect(/datum/status_effect/rogue/guard)

/mob/living/carbon/human/proc/rogue_lose_clash(obj/item/weapon)
	if(weapon)
		rogue_disarmed(weapon)
	else
		apply_status_effect(/datum/status_effect/rogue_vulnerable, ROGUE_CLASH_VULNERABLE)
		rogue_delay_action(ROGUE_DISARM_CLICK)
	rogue_slowdown(ROGUE_CLASH_SLOW)

/mob/living/carbon/human/proc/rogue_disarmed(obj/item/weapon)
	if(QDELETED(weapon) || !is_holding(weapon))
		return
	visible_message(span_suicide("[src] is disarmed!"), span_boldwarning("I'm disarmed!"))
	var/distance = rand(1, ROGUE_DISARM_RANGE)
	var/turf/landing = get_ranged_target_turf(src, turn(dir, pick(90, 270)), distance)
	if(dropItemToGround(weapon))
		weapon.throw_at(landing, distance, 1, src)
	rogue_delay_action(ROGUE_DISARM_CLICK)

/mob/living/carbon/human/proc/rogue_bait(mob/living/carbon/human/target)
	if(incapacitated || !istype(target) || target == src)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		to_chat(src, span_warning(pick("I will not lure another into violence.", "I refuse to tempt them into striking.")))
		return FALSE
	if(target.has_status_effect(/datum/status_effect/rogue/baited) || has_status_effect(/datum/status_effect/rogue/bait_cooldown))
		return FALSE
	face_atom(target)
	rogue_mark_in_combat()
	target.rogue_mark_in_combat()
	if(target.mind && !target.rogue_sees(src) && target.rogue_tempo_reaches("aware"))
		to_chat(src, span_notice("[target.p_They()] didn't see me! Nothing happened!"))
		apply_status_effect(/datum/status_effect/rogue/bait_cooldown, ROGUE_TEMPO_UNSEEN_COOLDOWN)
		return FALSE
	visible_message(span_danger("[src] baits an attack from [target]!"))
	apply_status_effect(/datum/status_effect/rogue/bait_cooldown, max(ROGUE_BAIT_COOLDOWN - rogue_tempo_bonus("rmb_cooldown"), 1))
	var/our_zone = rogue_precise_zone()
	var/their_zone = target.rogue_precise_zone()
	var/face_pair = (our_zone in GLOB.rogue_face_zones) && (their_zone in GLOB.rogue_face_zones)
	if((our_zone != their_zone && !face_pair) || our_zone == BODY_ZONE_CHEST || their_zone == BODY_ZONE_CHEST)
		to_chat(src, span_danger("It didn't work! [target.p_Their()] footing returned!"))
		to_chat(target, span_notice("I fooled [p_them()]! I've regained my footing!"))
		adjust_stamina_loss(max_stamina * ROGUE_BAIT_FAIL_DRAIN)
		target.rogue_bait_stacks = 0
		return FALSE
	var/drain_divisor = ROGUE_BAIT_DRAIN_BARE
	switch(target.rogue_highest_armor_class())
		if(ARMOR_CLASS_LIGHT, ARMOR_CLASS_MEDIUM)
			drain_divisor = ROGUE_BAIT_DRAIN_LIGHT
		if(ARMOR_CLASS_HEAVY)
			drain_divisor = ROGUE_BAIT_DRAIN_HEAVY
	target.apply_status_effect(/datum/status_effect/rogue/baited)
	target.apply_status_effect(/datum/status_effect/rogue/exposed, ROGUE_BAIT_EXPOSED)
	target.rogue_delay_action(ROGUE_BAIT_CLICK)
	if(target.rogue_def_intent == ROGUE_INTENT_DODGE)
		target.rogue_change_dodge_cooldown(ROGUE_BAIT_DODGE_PENALTY)
		target.rogue_change_dodge_fatigue(-ROGUE_BAIT_DODGE_PENALTY)
	if(rogue_def_intent == ROGUE_INTENT_DODGE)
		rogue_change_dodge_cooldown(-ROGUE_BAIT_DODGE_PENALTY)
		rogue_change_dodge_fatigue(ROGUE_BAIT_DODGE_PENALTY)
	target.rogue_bait_stacks++
	if(target.has_status_effect(/datum/status_effect/rogue/guard))
		target.rogue_bad_guard()
	if(target.rogue_bait_stacks <= 1)
		target.Immobilize(ROGUE_BAIT_IMMOBILIZE)
		target.adjust_stamina_loss(target.max_stamina / drain_divisor)
		target.rogue_slowdown(ROGUE_BAIT_SLOW)
		changeNext_move(1)
		to_chat(src, span_notice("[target.p_They()] fell for my bait <b>perfectly</b>! One more!"))
		to_chat(target, span_danger("I fall for [src]'s bait <b>perfectly</b>! I'm losing my footing! <b>I can't let this happen again!</b>"))
	// Ratwood: between two duelists with rings the first bait already takes the balance, and for longer.
	var/duel = rogue_dueling(target)
	if(duel || target.rogue_bait_stacks >= 2)
		target.rogue_off_balance(duel ? ROGUE_DUELIST_BAIT_OFFBALANCE : ROGUE_BAIT_OFFBALANCE)
		target.Immobilize(duel ? ROGUE_DUELIST_BAIT_HOLD : ROGUE_BAIT_HOLD)
		to_chat(src, span_notice("[target.p_They()] fell for it again and is off-balanced! NOW!"))
		to_chat(target, span_danger("I fall for [src]'s bait <b>perfectly</b>! My balance is GONE!"))
		target.rogue_bait_stacks = 0
	log_combat(src, target, "baited")
	if(target.pulling)
		target.stop_pulling()
		to_chat(src, span_notice("[target.p_They()] fell for my dirty trick! I am loose!"))
		to_chat(target, span_danger("I fall for [src]'s dirty trick! My hold is broken!"))
		rogue_off_balance(ROGUE_BAIT_OFFBALANCE)
		target.rogue_off_balance(ROGUE_BAIT_OFFBALANCE)
		playsound(src, 'modular_redtard/rockhill/sound/combat/riposte.ogg', 100, TRUE)
	return TRUE

#undef ROGUE_DUELIST_BAIT_OFFBALANCE
#undef ROGUE_DUELIST_BAIT_HOLD
