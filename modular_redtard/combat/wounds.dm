/// Ratwood's dynamic wounds on medieval maps (datums/wounds/_wound.dm /datum/wound/dynamic, types/bruises.dm, slashes.dm,
/// punctures.dm, bites.dm; surgery/bodyparts/bodypart_wounds.dm manage_dynamic_wound()), on TG's wound machinery. The first
/// blow of a kind that lands on a limb opens a wound of that kind there, and every later blow of the kind grows it: a hematoma
/// from blunt blows, a slash from cuts and chops, a puncture from stabs, a gouge from picks and arrows, a bite, a lashing of
/// the whip, a flogging. Each bleeds (TG's blood_flow, which the module's blood counts, combat/blood.dm), clots towards a floor
/// that rises with every blow, hurts (Ratwood woundpain, combat/pain.dm) and takes mending to close (Ratwood whp: potions,
/// soaked bandages, sleep; combat/medicine.dm, survival/sleep.dm); armor over the limb holds back how far a wound opens. On
/// those bodies they take the place of TG's rolled cuts, stabs and broken bones; burns stay TG's, and the crits still deal
/// TG's wounds (arteries, fractures; combat/crits.dm), which keep the module's pain and wound health tables.

/// Ratwood's clamp of pen_info (get_pen_info()).
#define ROGUE_PEN_INFO_MIN 1
#define ROGUE_PEN_INFO_MAX 8
/// One series of wounds for each kind, so a limb keeps one wound of each kind beside TG's wounds.
#define ROGUE_SERIES_BRUISE "rogue_wound_series_bruise"
#define ROGUE_SERIES_SLASH "rogue_wound_series_slash"
#define ROGUE_SERIES_PUNCTURE "rogue_wound_series_puncture"
#define ROGUE_SERIES_GOUGE "rogue_wound_series_gouge"
#define ROGUE_SERIES_BITE "rogue_wound_series_bite"
#define ROGUE_SERIES_LASHING "rogue_wound_series_lashing"
#define ROGUE_SERIES_FLOGGING "rogue_wound_series_flogging"

/// A wound of the module counted Ratwood's way: what it takes to mend before it closes (Ratwood whp, rogue_health), how much
/// it hurts (woundpain), how fast it clots and down to what, how much it mends by itself. Its bleeding is TG's blood_flow, a
/// second's, which the module's blood and the bandages count (combat/blood.dm); Ratwood's numbers are a Life tick's.
/datum/wound/rogue
	name = "wound"
	sound_effect = null
	severity = WOUND_SEVERITY_MODERATE
	processes = TRUE
	can_scar = FALSE
	wound_flags = CAN_BE_GRASPED
	blood_flow = 0
	/// Ratwood woundpain.
	var/rogue_woundpain = 0
	/// Ratwood clotting_rate: what the bleeding falls by each Life tick while it is above its floor.
	var/rogue_clot_rate = 0
	/// Ratwood clotting_threshold: the bleeding of a Life tick the wound clots down to; null when it does not clot.
	var/rogue_clot_floor
	/// Ratwood passive_healing: what the wound mends by itself each Life tick.
	var/rogue_passive_healing = 0
	/// Ratwood bleed_rate of the fresh wound, a Life tick's: what it bleeds the moment it opens.
	var/rogue_fresh_bleed = 0

/// No determination for these (TG's second_wind()): Ratwood's wounds give none.
/datum/wound/rogue/second_wind()
	return

/datum/wound/rogue/rogue_pain()
	return max(rogue_woundpain, 0)

/datum/wound/rogue/rogue_health_max()
	return rogue_health

/// Ratwood heal_wound(): the wound mends by the amount, its pain eases by half of it, and with nothing left to mend it closes.
/// Returns what it took of the amount.
/datum/wound/rogue/rogue_heal_wound(amount)
	if(amount <= 0 || rogue_health <= 0)
		return 0
	var/healed = min(rogue_health, round(amount, DAMAGE_PRECISION))
	var/eased = min(rogue_woundpain, round(amount / 2, DAMAGE_PRECISION))
	rogue_health -= healed
	if(eased > 0)
		rogue_woundpain -= eased
		if(victim)
			victim.rogue_pain_hud_dirty = TRUE
	if(rogue_health <= 0)
		qdel(src)
	return healed

/// Ratwood on_life(): while the body lives, the wound clots, then mends by itself.
/datum/wound/rogue/handle_process(seconds_per_tick)
	if(!victim || victim.stat == DEAD || HAS_TRAIT(victim, TRAIT_STASIS))
		return
	var/ticks = seconds_per_tick / ROGUE_LIFE_TICK
	rogue_clot(ticks)
	if(rogue_passive_healing > 0)
		rogue_heal_wound(rogue_passive_healing * ticks)

/// Ratwood's bleed_rate: the blood a Life tick (TG's blood_flow is a second's).
/datum/wound/rogue/proc/rogue_bleed()
	return blood_flow * ROGUE_LIFE_TICK

/// Ratwood set_bleed_rate(), from a Life tick's bleeding.
/datum/wound/rogue/proc/rogue_set_bleed(rate)
	var/flow = max(rate, 0) / ROGUE_LIFE_TICK
	if(!limb)
		blood_flow = flow
		return
	set_blood_flow(flow)

/datum/wound/rogue/proc/rogue_add_bleed(amount)
	rogue_set_bleed(rogue_bleed() + amount)

/// Ratwood's clotting: the bleeding falls by the clotting rate each Life tick, down to the floor.
/datum/wound/rogue/proc/rogue_clot(ticks)
	if(isnull(rogue_clot_floor) || rogue_clot_rate <= 0)
		return
	var/bleed = rogue_bleed()
	if(bleed > rogue_clot_floor)
		rogue_set_bleed(max(rogue_clot_floor, bleed - rogue_clot_rate * ticks))

/// Ratwood is_clotted(): it bleeds no more than its floor (shown only on wounds that still bleed).
/datum/wound/rogue/proc/rogue_clotted()
	var/bleed = rogue_bleed()
	return !isnull(rogue_clot_floor) && bleed > 0 && bleed <= rogue_clot_floor

/datum/wound/rogue/get_bleed_rate_of_change()
	if(blood_flow && HAS_TRAIT(victim, TRAIT_BLOOD_FOUNTAIN))
		return BLOOD_FLOW_INCREASING
	if(rogue_clot_rate > 0 && !isnull(rogue_clot_floor) && rogue_bleed() > rogue_clot_floor)
		return BLOOD_FLOW_DECREASING
	return BLOOD_FLOW_STEADY

/// Ratwood get_visible_name(): the wound by its name, clotted or not.
/datum/wound/rogue/get_wound_description(mob/user)
	return get_desc_intensity("[victim.p_Their()] [limb.plaintext_zone] has \a [name][rogue_clotted() ? " (clotted)" : ""]")

/// Ratwood's dynamic wound (/datum/wound/dynamic): grows with every blow of its kind (rogue_upgrade()), and a needle sewing it
/// shut closes it at once (Ratwood sew_wound(): heal_wound(whp)).
/datum/wound/rogue/dynamic
	/// Ratwood sew_threshold: how far the stitches must get; it rises with every blow. 0: a needle cannot sew it.
	var/rogue_sew_needed = 0
	/// Ratwood is_maxed: the bleeding reached an artery's, which is told once until a stitch closes it again.
	var/rogue_maxed = FALSE
	/// Ratwood is_armor_maxed: the armor held the bleeding back, told once until a stitch.
	var/rogue_armor_maxed = FALSE

/// Every blow of its kind on the limb grows the wound (Ratwood manage_dynamic_wound() -> upgrade()), by the damage that got
/// through, the armor of the limb against that kind of blow, whether the body was exposed, and how far a weapon's blow got
/// through that armor. A blow TG means not to wound (CANT_WOUND) does not.
/datum/wound/rogue/dynamic/receive_damage(wounding_type, wounding_dmg, wound_bonus, attack_direction, damage_source)
	if(!victim || wound_bonus == CANT_WOUND || wounding_dmg <= 0)
		return
	var/bclass = rogue_wound_blow_class(wounding_type, attack_direction, damage_source)
	if(rogue_dynamic_wound_type(bclass) != type)
		return
	var/armor = rogue_limb_armor(bclass)
	rogue_upgrade(wounding_dmg, armor, !!victim.has_status_effect(/datum/status_effect/rogue/exposed), rogue_pen_info(damage_source))

/// Ratwood /datum/wound/dynamic/upgrade(), after what the kind adds (each kind calls this last): a wound that bleeds like an
/// artery is held there, nicks it and no longer clots below an artery's floor; otherwise every blow makes it clot faster and
/// to a higher floor.
/datum/wound/rogue/dynamic/proc/rogue_upgrade(damage, armor, exposed, pen_info)
	var/artery = ROGUE_ARTERY_BLEED * ROGUE_LIFE_TICK
	if(rogue_bleed() >= artery)
		rogue_set_bleed(artery)
		if(!rogue_maxed)
			playsound(victim, 'modular_redtard/combat/sound/misc/wound_tear.ogg', 100, TRUE)
			victim.rogue_strike_note(span_crit("The wound gushes open from [victim]'s <b>[limb.plaintext_zone]</b>, nicking an artery!"))
			rogue_maxed = TRUE
		rogue_clot_rate = 0
		rogue_clot_floor = rogue_value("dynamic_artery_clot_floor")
	if(!rogue_maxed)
		rogue_clot_rate = max(rogue_value("dynamic_clot_min"), rogue_clot_rate + rogue_value("dynamic_clot_per_hit"))
		rogue_clot_floor = (rogue_clot_floor || 0) + rogue_value("dynamic_clot_floor_per_hit")
	victim.rogue_pain_hud_dirty = TRUE

/// Ratwood armor_check(): over armor the wound bleeds no more than the cap of its kind; told once.
/datum/wound/rogue/dynamic/proc/rogue_armor_check(armor, cap)
	if(!armor || rogue_bleed() < cap)
		return
	rogue_set_bleed(cap)
	if(rogue_armor_maxed)
		return
	playsound(victim, 'modular_redtard/combat/sound/misc/armored_wound.ogg', 100, TRUE)
	victim.rogue_strike_note(span_crit("The wound tears open from [victim]'s <b>[limb.plaintext_zone]</b>, the armor won't let it go any further!"))
	rogue_armor_maxed = TRUE

/// The bleeding an armored weapon blow adds by how far it got through (Ratwood: pen_info 1-2, 3-4, 5-6, 7-8); none without it.
/datum/wound/rogue/dynamic/proc/rogue_pen_bleed(pen_info, low, fair, good, full)
	switch(pen_info)
		if(1 to 2)
			return low
		if(3 to 4)
			return fair
		if(5 to 6)
			return good
		if(7 to 8)
			return full
	return 0

/// The bleeding a blow of a clamped kind adds: its damage times the rate, at least the least, at most the cap over armor or
/// over bare skin (an exposed body counts as bare).
/datum/wound/rogue/dynamic/proc/rogue_clamped_bleed(damage, per_damage, least, cap_armored, cap_bare, armor, exposed)
	rogue_add_bleed(clamp(damage * per_damage, least, (armor && !exposed) ? cap_armored : cap_bare))

/// The best tier of the limb's armor against this kind of blow (Ratwood's run_armor_check() in bodypart_attacked_by()); 0 for none.
/datum/wound/rogue/dynamic/proc/rogue_limb_armor(bclass)
	var/mob/living/carbon/human/person = victim
	if(!istype(person))
		return 0
	var/armor_type
	switch(bclass)
		if(BCLASS_BLUNT, BCLASS_SMASH, BCLASS_TWIST, BCLASS_PUNCH)
			armor_type = ROGUE_ARMOR_BLUNT
		if(BCLASS_CHOP, BCLASS_CUT, BCLASS_LASHING, BCLASS_PUNISH)
			armor_type = ROGUE_ARMOR_SLASH
		if(BCLASS_PICK, BCLASS_STAB, BCLASS_BITE)
			armor_type = ROGUE_ARMOR_STAB
	return armor_type ? person.rogue_armor_tier(limb.body_zone, armor_type) : 0

/// Ratwood get_pen_info(): how far a held weapon's blow got through the armor of the limb, 1 to 8: twice the tiers its intent
/// pierces over the armor's (1 when they match), a keen edge and the wielder's balance on top. Null for any other blow, as
/// Ratwood passes it only with a weapon's.
/datum/wound/rogue/dynamic/proc/rogue_pen_info(obj/item/weapon)
	if(!isitem(weapon))
		return null
	var/mob/living/carbon/human/wielder = weapon.loc
	if(!istype(wielder))
		return null
	var/datum/intent/intent = wielder.rogue_strike_intent(weapon)
	var/penetration = intent?.penfactor
	if(!penetration)
		return ROGUE_PEN_INFO_MIN
	var/mob/living/carbon/human/person = victim
	var/protection = istype(person) ? person.rogue_armor_tier(limb.body_zone, intent.item_d_type) : 0
	. = penetration == protection ? ROGUE_PEN_INFO_MIN : (penetration - protection) * 2
	var/balanced = TRUE
	if(weapon.get_sharpness() && weapon.max_blade_int)
		var/edge = weapon.rogue_edge_ratio()
		if(edge > ROGUE_BLADE_DULL_START)
			. += rogue_value("dynamic_pen_edge_bonus")
		if(edge <= ROGUE_BLADE_DULL_FLOOR)
			balanced = FALSE
	if(balanced)
		var/strength = wielder.rogue_stat(ROGUE_STAT_STRENGTH) - ROGUE_ATTRIBUTE_MIDDLING
		var/balance = strength
		switch(weapon.wbalance)
			if(WBALANCE_HEAVY)
				balance = strength + rogue_value("dynamic_pen_heavy_bonus")
			if(WBALANCE_SWIFT)
				balance = max(wielder.rogue_stat(ROGUE_STAT_SPEED) - ROGUE_ATTRIBUTE_MIDDLING, strength)
		if(weapon.wbalance != WBALANCE_HEAVY)
			balance = min(balance, rogue_value("dynamic_pen_balance_cap"))
		. += balance
	return clamp(., ROGUE_PEN_INFO_MIN, ROGUE_PEN_INFO_MAX)

/// Ratwood's severity_names of the kind: the adjective a wound takes once its bleeding (its health, while it does not bleed)
/// reaches the number, in order.
/datum/wound/rogue/dynamic/proc/rogue_severity_names()
	return list()

/// Ratwood update_name(): the wound is named by the last step its bleeding (or, not bleeding, its health) has reached, and a
/// worse name is told. Its TG severity follows the steps: the last one is critical, the one before severe.
/datum/wound/rogue/dynamic/proc/rogue_update_name()
	var/list/names = rogue_severity_names()
	var/bleed = rogue_bleed()
	var/adjective
	var/stage = 0
	for(var/index in 1 to length(names))
		var/word = names[index]
		var/threshold = names[word]
		if((!bleed && threshold <= rogue_health) || threshold <= bleed)
			adjective = word
			stage = index
	var/old_name = name
	name = adjective ? "[adjective] [initial(name)]" : initial(name)
	if(stage && stage == length(names))
		severity = WOUND_SEVERITY_CRITICAL
	else if(stage && stage == length(names) - 1)
		severity = WOUND_SEVERITY_SEVERE
	else
		severity = WOUND_SEVERITY_MODERATE
	if(name != old_name)
		victim.rogue_strike_note(span_red("The [old_name] on [victim]'s [limb.plaintext_zone] gets worse!"))

/datum/wound/rogue/dynamic/rogue_sew_threshold()
	return rogue_sew_needed

/// Ratwood /datum/wound/dynamic/sew_wound(): heal_wound(whp), the sewn wound is gone.
/datum/wound/rogue/dynamic/rogue_sew_done()
	qdel(src)

/// Ratwood's stitch: the bleeding itself falls, and the wound may tell of an artery or of the armor again.
/datum/wound/rogue/dynamic/rogue_stitch(hold)
	if(blood_flow > 0)
		adjust_blood_flow(-hold)
	rogue_maxed = FALSE
	rogue_armor_maxed = FALSE

/// Ratwood on_bodypart_gain(): a new wound that bleeds soaks through the bandage on the limb.
/datum/wound/rogue/dynamic/rogue_soaks_bandage()
	return rogue_fresh_bleed > 0

/// Ratwood dynamic/bruise: hurts a great deal, does not bleed, armor does not change it; every blow makes it mend faster.
/datum/wound/rogue/dynamic/bruise
	name = "hematoma"
	desc = "Bruised flesh, swollen with blood under the skin. It mends by itself."
	treat_text = "Rest; it mends by itself."
	treat_text_short = "Let it mend"
	examine_desc = "is bruised"
	wound_flags = NONE

/datum/wound/rogue/dynamic/bruise/New()
	. = ..()
	rogue_health = rogue_value("dynamic_bruise_health")
	rogue_woundpain = rogue_value("dynamic_bruise_pain")
	rogue_passive_healing = rogue_value("dynamic_bruise_passive")

/datum/wound/rogue/dynamic/bruise/rogue_upgrade(damage, armor, exposed, pen_info)
	rogue_health += damage * rogue_value("dynamic_bruise_health_per_damage")
	rogue_woundpain += damage * rogue_value("dynamic_bruise_pain_per_damage")
	rogue_passive_healing += rogue_value("dynamic_bruise_selfheal")
	rogue_update_name()
	return ..()

/datum/wound/rogue/dynamic/bruise/rogue_severity_names()
	var/static/list/names = list("minor" = 20, "moderate" = 60, "big" = 120, "massive" = 180)
	return names

/// Ratwood dynamic/slash: painful, hard to sew and to heal, held back by armor.
/datum/wound/rogue/dynamic/slash
	name = "slash"
	desc = "A cut through the flesh that bleeds and deepens with every blow."
	treat_text = "Sew it shut with a needle, or bind it with cloth."
	treat_text_short = "Sew or bandage it"
	examine_desc = "is slashed open"

/datum/wound/rogue/dynamic/slash/New()
	. = ..()
	rogue_health = rogue_value("dynamic_slash_health")
	rogue_fresh_bleed = rogue_value("dynamic_slash_bleed")
	rogue_sew_needed = rogue_value("dynamic_slash_sew")
	rogue_woundpain = rogue_value("dynamic_slash_pain")
	rogue_clot_rate = rogue_value("dynamic_slash_clot")
	rogue_clot_floor = rogue_value("dynamic_slash_clot_floor")

/datum/wound/rogue/dynamic/slash/rogue_upgrade(damage, armor, exposed, pen_info)
	rogue_health += damage * rogue_value("dynamic_slash_health_per_damage")
	if(!armor || exposed)
		rogue_add_bleed(rogue_value("dynamic_slash_bleed_bare"))
	else
		rogue_add_bleed(rogue_pen_bleed(pen_info, rogue_value("dynamic_slash_bleed_pen_low"), rogue_value("dynamic_slash_bleed_pen_fair"), rogue_value("dynamic_slash_bleed_pen_good"), rogue_value("dynamic_slash_bleed_pen_full")))
	rogue_sew_needed += damage * rogue_value("dynamic_slash_sew_per_damage")
	rogue_woundpain += damage * rogue_value("dynamic_slash_pain_per_damage")
	rogue_armor_check(armor, rogue_value("dynamic_slash_armor_cap"))
	rogue_update_name()
	return ..()

/datum/wound/rogue/dynamic/slash/rogue_severity_names()
	var/static/list/names = list("light" = 5, "deep" = 10, "gnarly" = 15, "lethal" = 20)
	return names

/// Ratwood dynamic/puncture, of stabs: not as painful, bleeds more through armor, easier to sew and to heal.
/datum/wound/rogue/dynamic/puncture
	name = "puncture"
	desc = "A stab wound that bleeds and goes deeper with every thrust."
	treat_text = "Sew it shut with a needle, or bind it with cloth."
	treat_text_short = "Sew or bandage it"
	examine_desc = "is punctured"

/datum/wound/rogue/dynamic/puncture/New()
	. = ..()
	rogue_health = rogue_value("dynamic_puncture_health")
	rogue_fresh_bleed = rogue_value("dynamic_puncture_bleed")
	rogue_sew_needed = rogue_value("dynamic_puncture_sew")
	rogue_woundpain = rogue_value("dynamic_puncture_pain")
	rogue_clot_rate = rogue_value("dynamic_puncture_clot")
	rogue_clot_floor = rogue_value("dynamic_puncture_clot_floor")

/datum/wound/rogue/dynamic/puncture/rogue_upgrade(damage, armor, exposed, pen_info)
	rogue_health += damage * rogue_value("dynamic_puncture_health_per_damage")
	if(!armor || exposed)
		rogue_add_bleed(rogue_value("dynamic_puncture_bleed_bare"))
	else
		rogue_add_bleed(rogue_pen_bleed(pen_info, rogue_value("dynamic_puncture_bleed_pen_low"), rogue_value("dynamic_puncture_bleed_pen_fair"), rogue_value("dynamic_puncture_bleed_pen_good"), rogue_value("dynamic_puncture_bleed_pen_full")))
	rogue_sew_needed += damage * rogue_value("dynamic_puncture_sew_per_damage")
	rogue_woundpain += damage * rogue_value("dynamic_puncture_pain_per_damage")
	rogue_armor_check(armor, rogue_value("dynamic_puncture_armor_cap"))
	rogue_update_name()
	return ..()

/datum/wound/rogue/dynamic/puncture/rogue_severity_names()
	var/static/list/names = list("shallow" = 3, "deep" = 6, "gnarly" = 9, "vicious" = 12, "lethal" = 20)
	return names

/// Ratwood dynamic/gouge, of picks and piercing shots: hardly hurts or bleeds, but cannot be seared shut.
/datum/wound/rogue/dynamic/gouge
	name = "gouge"
	desc = "A hole driven deep into the flesh."
	treat_text = "Sew it shut with a needle, or bind it with cloth."
	treat_text_short = "Sew or bandage it"
	examine_desc = "is gouged"

/datum/wound/rogue/dynamic/gouge/New()
	. = ..()
	rogue_health = rogue_value("dynamic_gouge_health")
	rogue_fresh_bleed = rogue_value("dynamic_gouge_bleed")
	rogue_sew_needed = rogue_value("dynamic_gouge_sew")
	rogue_woundpain = rogue_value("dynamic_gouge_pain")
	rogue_clot_rate = rogue_value("dynamic_gouge_clot")
	rogue_clot_floor = rogue_value("dynamic_gouge_clot_floor")

/datum/wound/rogue/dynamic/gouge/rogue_upgrade(damage, armor, exposed, pen_info)
	rogue_health += damage * rogue_value("dynamic_gouge_health_per_damage")
	rogue_clamped_bleed(damage, rogue_value("dynamic_gouge_bleed_per_damage"), rogue_value("dynamic_gouge_bleed_least"), rogue_value("dynamic_gouge_bleed_armored"), rogue_value("dynamic_gouge_bleed_bare"), armor, exposed)
	rogue_sew_needed += damage * rogue_value("dynamic_gouge_sew_per_damage")
	rogue_woundpain += damage * rogue_value("dynamic_gouge_pain_per_damage")
	rogue_armor_check(armor, rogue_value("dynamic_gouge_armor_cap"))
	rogue_update_name()
	return ..()

/datum/wound/rogue/dynamic/gouge/rogue_severity_names()
	var/static/list/names = list("shallow" = 2, "deep" = 4, "gnarly" = 8, "vicious" = 12, "lethal" = 20)
	return names

/// Ratwood dynamic/bite: hurts a great deal and bleeds freely, but armor stops most of it; it mends by itself.
/datum/wound/rogue/dynamic/bite
	name = "bite"
	desc = "Torn flesh, the marks of teeth."
	treat_text = "Sew it shut with a needle, or bind it with cloth."
	treat_text_short = "Sew or bandage it"
	examine_desc = "is bitten"

/datum/wound/rogue/dynamic/bite/New()
	. = ..()
	rogue_health = rogue_value("dynamic_bite_health")
	rogue_fresh_bleed = rogue_value("dynamic_bite_bleed")
	rogue_sew_needed = rogue_value("dynamic_bite_sew")
	rogue_woundpain = rogue_value("dynamic_bite_pain")
	rogue_passive_healing = rogue_value("dynamic_bite_passive")
	rogue_clot_rate = rogue_value("dynamic_clot_base")

/datum/wound/rogue/dynamic/bite/rogue_upgrade(damage, armor, exposed, pen_info)
	rogue_health += damage * rogue_value("dynamic_bite_health_per_damage")
	rogue_clamped_bleed(damage, rogue_value("dynamic_bite_bleed_per_damage"), rogue_value("dynamic_bite_bleed_least"), rogue_value("dynamic_bite_bleed_armored"), rogue_value("dynamic_bite_bleed_bare"), armor, exposed)
	rogue_sew_needed += damage * rogue_value("dynamic_bite_sew_per_damage")
	rogue_woundpain += damage * rogue_value("dynamic_bite_pain_per_damage")
	rogue_armor_check(armor, rogue_value("dynamic_bite_armor_cap"))
	rogue_update_name()
	return ..()

/datum/wound/rogue/dynamic/bite/rogue_severity_names()
	var/static/list/names = list("shallow" = 3, "deep" = 8, "gnarly" = 12, "lethal" = 15, "impossible" = 20)
	return names

/// Ratwood dynamic/lashing, of the whip: painful, bleeds hugely on bare skin, next to nothing through armor; cannot be seared.
/datum/wound/rogue/dynamic/lashing
	name = "lashing"
	desc = "Welts and torn skin left by a whip."
	treat_text = "Sew it shut with a needle, or bind it with cloth."
	treat_text_short = "Sew or bandage it"
	examine_desc = "is lashed"

/datum/wound/rogue/dynamic/lashing/New()
	. = ..()
	rogue_health = rogue_value("dynamic_lashing_health")
	rogue_sew_needed = rogue_value("dynamic_lashing_sew")
	rogue_woundpain = rogue_value("dynamic_lashing_pain")
	rogue_clot_rate = rogue_value("dynamic_lashing_clot")
	rogue_clot_floor = rogue_value("dynamic_lashing_clot_floor")

/datum/wound/rogue/dynamic/lashing/rogue_upgrade(damage, armor, exposed, pen_info)
	rogue_health += damage * rogue_value("dynamic_lashing_health_per_damage")
	rogue_clamped_bleed(damage, rogue_value("dynamic_lashing_bleed_per_damage"), rogue_value("dynamic_lashing_bleed_least"), rogue_value("dynamic_lashing_bleed_armored"), rogue_value("dynamic_lashing_bleed_bare"), armor, exposed)
	rogue_sew_needed += damage * rogue_value("dynamic_lashing_sew_per_damage")
	rogue_woundpain += damage * rogue_value("dynamic_lashing_pain_per_damage")
	rogue_armor_check(armor, rogue_value("dynamic_lashing_armor_cap"))
	rogue_update_name()
	return ..()

/datum/wound/rogue/dynamic/lashing/rogue_severity_names()
	var/static/list/names = list("light" = 5, "deep" = 10, "gnarly" = 15, "lethal" = 20)
	return names

/// Ratwood dynamic/punish, the whip's punishing intent: very painful, hardly bleeds, mends by itself the more it is beaten.
/datum/wound/rogue/dynamic/punish
	name = "flogging"
	desc = "Skin beaten raw by a punishing whip."
	treat_text = "Sew it shut with a needle, or let it mend."
	treat_text_short = "Let it mend"
	examine_desc = "is flogged"

/datum/wound/rogue/dynamic/punish/New()
	. = ..()
	rogue_health = rogue_value("dynamic_flogging_health")
	rogue_sew_needed = rogue_value("dynamic_flogging_sew")
	rogue_woundpain = rogue_value("dynamic_flogging_pain")
	rogue_clot_rate = rogue_value("dynamic_flogging_clot")
	rogue_clot_floor = rogue_value("dynamic_flogging_clot_floor")

/// Ratwood punish upgrade(dam, armor): its bleeding reads only the armor, not an exposed body.
/datum/wound/rogue/dynamic/punish/rogue_upgrade(damage, armor, exposed, pen_info)
	rogue_health += damage * rogue_value("dynamic_flogging_health_per_damage")
	rogue_clamped_bleed(damage, rogue_value("dynamic_flogging_bleed_per_damage"), rogue_value("dynamic_flogging_bleed_least"), rogue_value("dynamic_flogging_bleed_armored"), rogue_value("dynamic_flogging_bleed_bare"), armor, FALSE)
	rogue_sew_needed += damage * rogue_value("dynamic_flogging_sew_per_damage")
	rogue_woundpain += damage * rogue_value("dynamic_flogging_pain_per_damage")
	rogue_passive_healing += rogue_value("dynamic_flogging_selfheal")
	rogue_armor_check(armor, rogue_value("dynamic_flogging_armor_cap"))
	rogue_update_name()
	return ..()

/datum/wound/rogue/dynamic/punish/rogue_severity_names()
	var/static/list/names = list("light" = 5, "deep" = 10, "gnarly" = 15, "lethal" = 20)
	return names

/// The pregen data of the dynamic wounds: only ever opened by a blow of their kind (never rolled by TG), on a limb of flesh
/// that bleeds (Ratwood can_bloody_wound()), one of each kind on a limb.
/datum/wound_pregen_data/rogue_dynamic
	abstract = TRUE
	can_be_randomly_generated = FALSE
	compete_for_wounding = FALSE
	required_limb_biostate = (BIO_FLESH|BIO_BLOODED)
	ignore_cannot_bleed = FALSE
	required_wounding_type = WOUND_ALL

/datum/wound_pregen_data/rogue_dynamic/bruise
	abstract = FALSE
	wound_path_to_generate = /datum/wound/rogue/dynamic/bruise
	wound_series = ROGUE_SERIES_BRUISE

/datum/wound_pregen_data/rogue_dynamic/slash
	abstract = FALSE
	wound_path_to_generate = /datum/wound/rogue/dynamic/slash
	wound_series = ROGUE_SERIES_SLASH

/datum/wound_pregen_data/rogue_dynamic/puncture
	abstract = FALSE
	wound_path_to_generate = /datum/wound/rogue/dynamic/puncture
	wound_series = ROGUE_SERIES_PUNCTURE

/datum/wound_pregen_data/rogue_dynamic/gouge
	abstract = FALSE
	wound_path_to_generate = /datum/wound/rogue/dynamic/gouge
	wound_series = ROGUE_SERIES_GOUGE

/datum/wound_pregen_data/rogue_dynamic/bite
	abstract = FALSE
	wound_path_to_generate = /datum/wound/rogue/dynamic/bite
	wound_series = ROGUE_SERIES_BITE

/datum/wound_pregen_data/rogue_dynamic/lashing
	abstract = FALSE
	wound_path_to_generate = /datum/wound/rogue/dynamic/lashing
	wound_series = ROGUE_SERIES_LASHING

/datum/wound_pregen_data/rogue_dynamic/punish
	abstract = FALSE
	wound_path_to_generate = /datum/wound/rogue/dynamic/punish
	wound_series = ROGUE_SERIES_FLOGGING

/// Ratwood manage_dynamic_wound(): the wound each kind of blow leaves; null for a blow that leaves none (a burn, a sunder).
/proc/rogue_dynamic_wound_type(bclass)
	switch(bclass)
		if(BCLASS_BLUNT, BCLASS_SMASH, BCLASS_PUNCH, BCLASS_TWIST)
			return /datum/wound/rogue/dynamic/bruise
		if(BCLASS_BITE)
			return /datum/wound/rogue/dynamic/bite
		if(BCLASS_CHOP, BCLASS_CUT)
			return /datum/wound/rogue/dynamic/slash
		if(BCLASS_STAB)
			return /datum/wound/rogue/dynamic/puncture
		if(BCLASS_PICK, BCLASS_PIERCE)
			return /datum/wound/rogue/dynamic/gouge
		if(BCLASS_LASHING)
			return /datum/wound/rogue/dynamic/lashing
		if(BCLASS_PUNISH)
			return /datum/wound/rogue/dynamic/punish
	return null

/// The kind of blow (Ratwood's bclass) a hit was, as TG's damage tells it to the limb:
/// - a weapon or a round of the module says it: the intent its wielder struck with (rogue_current_bclass), a round's own
///   (rogue_bclass); unless TG saw the blow sharp another way (a special of another kind than the hand's intent), then as TG;
/// - a sharp hit with no weapon but a direction is a creature's bite or claw (TG's attack_animal(); Ratwood's beasts bite
///   and claw with intents of the slash kind);
/// - a pointed hit with neither a weapon nor a direction is a bite of the teeth (combat/mmb.dm deals bites so);
/// - else as TG saw it: a cut, a stab, a blunt blow. Burns are not blows; they leave TG's wounds.
/proc/rogue_wound_blow_class(wounding_type, attack_direction, damage_source)
	if(wounding_type == WOUND_BURN)
		return null
	var/bclass
	if(isitem(damage_source))
		var/obj/item/weapon = damage_source
		bclass = weapon.rogue_current_bclass
	else if(istype(damage_source, /obj/projectile/rogue_ammo))
		var/obj/projectile/rogue_ammo/shot = damage_source
		bclass = shot.rogue_bclass
	if(bclass && (wounding_type == WOUND_BLUNT || rogue_bclass_to_wound(bclass) == wounding_type))
		return bclass
	if(!isitem(damage_source) && !isprojectile(damage_source))
		if(attack_direction && (wounding_type == WOUND_SLASH || wounding_type == WOUND_PIERCE))
			return BCLASS_CUT
		if(!attack_direction && wounding_type == WOUND_PIERCE)
			return BCLASS_BITE
	switch(wounding_type)
		if(WOUND_SLASH)
			return BCLASS_CUT
		if(WOUND_PIERCE)
			return BCLASS_STAB
	return BCLASS_BLUNT

/// On a medieval human (TRAIT_ROGUE_WOUNDS, given by the blood element) a cut, a stab or a blow opens Ratwood's dynamic wound
/// of its kind instead of rolling TG's wound; TG's loop of receive_damage() right after this grows it by the hit. Burns roll
/// TG's wounds as before, and the crits deal TG's wounds without a roll (combat/crits.dm).
/obj/item/bodypart/check_wounding(woundtype, damage, wound_bonus, exposed_wound_bonus, attack_direction, damage_source, wound_clothing)
	if(woundtype == WOUND_BURN || !owner || !HAS_TRAIT(owner, TRAIT_ROGUE_WOUNDS))
		return ..()
	if(!is_woundable())
		return null
	return rogue_open_wound(rogue_dynamic_wound_type(rogue_wound_blow_class(woundtype, attack_direction, damage_source)), damage_source)

/// Ratwood manage_dynamic_wound(): the limb's wound of this kind, or a new one, told as Ratwood tells it ("A new slash appears
/// on X's chest!", on the line of the strike that opened it, combat/chat.dm). A new wound that bleeds soaks through the bandage
/// on the limb (the blood element, combat/blood.dm).
/obj/item/bodypart/proc/rogue_open_wound(wound_type, damage_source)
	if(!ispath(wound_type, /datum/wound/rogue/dynamic))
		return null
	for(var/datum/wound/existing as anything in wounds)
		if(existing.type == wound_type)
			return existing
	var/datum/wound/rogue/dynamic/wound = new wound_type
	if(!wound.apply_wound(src, silent = TRUE, wound_source = damage_source) || QDELETED(wound))
		return null
	wound.rogue_set_bleed(wound.rogue_fresh_bleed)
	owner.rogue_strike_note(span_red("A new [wound.name] appears on [owner]'s [plaintext_zone]!"))
	return wound

#undef ROGUE_PEN_INFO_MIN
#undef ROGUE_PEN_INFO_MAX
#undef ROGUE_SERIES_BRUISE
#undef ROGUE_SERIES_SLASH
#undef ROGUE_SERIES_PUNCTURE
#undef ROGUE_SERIES_GOUGE
#undef ROGUE_SERIES_BITE
#undef ROGUE_SERIES_LASHING
#undef ROGUE_SERIES_FLOGGING
