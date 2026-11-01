/// Ratwood's pain (carbon/life.dm: handle_random_events(), get_complex_pain(), paincrit(), delimb_pain(); the reactions to a
/// hit in species.dm apply_damage()) on medieval maps: a limb hurts by its damage and its wounds, and pain past what the
/// will bears makes one moan, then break and fall. A hit draws a cry, a heavy one holds and slows the struck, the loss of
/// a limb breaks one unless constitution and will hold. The cries sound in the voice of the body's race (rockhill/races.dm).

/mob/living/carbon/human
	/// When the pain is next weighed (Ratwood mob_timers["painstun"]).
	var/rogue_pain_next = 0

/mob/living/carbon
	/// A wound's pain changed without damage that would refresh the HUD (Ratwood mark_pain_hud_dirty()): the heart is redrawn
	/// on the next Life tick.
	var/rogue_pain_hud_dirty = FALSE

/datum/wound
	/// The pain healing has eased (Ratwood heal_wound(): woundpain falls by half of what is healed).
	var/rogue_pain_eased = 0

/datum/element/rogue_pain

/datum/element/rogue_pain/Attach(datum/target)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(target, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(on_damage))
	RegisterSignals(target, list(SIGNAL_ADDTRAIT(TRAIT_ADRENALINE_RUSH), SIGNAL_REMOVETRAIT(TRAIT_ADRENALINE_RUSH), SIGNAL_ADDTRAIT(TRAIT_NOPAIN), SIGNAL_REMOVETRAIT(TRAIT_NOPAIN), COMSIG_ROGUE_ATTRIBUTES_UPDATED), PROC_REF(on_threshold_changed))

/datum/element/rogue_pain/Detach(datum/source, ...)
	UnregisterSignal(source, list(COMSIG_LIVING_LIFE, COMSIG_MOB_AFTER_APPLY_DAMAGE, SIGNAL_ADDTRAIT(TRAIT_ADRENALINE_RUSH), SIGNAL_REMOVETRAIT(TRAIT_ADRENALINE_RUSH), SIGNAL_ADDTRAIT(TRAIT_NOPAIN), SIGNAL_REMOVETRAIT(TRAIT_NOPAIN), COMSIG_ROGUE_ATTRIBUTES_UPDATED))
	return ..()

/// What the will bears has changed (adrenaline, painlessness, willpower): the heart shows the pain against it at once (PR 2546).
/datum/element/rogue_pain/proc/on_threshold_changed(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	source.update_health_hud()

/datum/element/rogue_pain/proc/on_life(mob/living/carbon/human/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(source.rogue_pain_hud_dirty)
		source.rogue_pain_hud_dirty = FALSE
		source.update_health_hud()
	if(world.time >= source.rogue_pain_next && !source.stat && !HAS_TRAIT(source, TRAIT_NOPAIN))
		INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/carbon/human, rogue_pain_check))

/datum/element/rogue_pain/proc/on_damage(mob/living/carbon/human/source, damage, damagetype)
	SIGNAL_HANDLER
	if(damage > 0)
		INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living/carbon/human, rogue_pain_react), damage, damagetype)

/// Ratwood's woundpain for a TG wound: what a wound of the same kind hurts in Ratwood, less what healing has eased of it.
/// Ratwood's own wounds count theirs (combat/wounds.dm).
/datum/wound/proc/rogue_pain()
	return max(rogue_base_pain() - rogue_pain_eased, 0)

/// What a fresh wound of this kind and size hurts in Ratwood.
/datum/wound/proc/rogue_base_pain()
	return 0

/// Ratwood heal_wound(): healing eases the pain of the wound by half of what it heals, never below none.
/datum/wound/proc/rogue_ease_pain(amount)
	var/eased = min(rogue_pain(), round(amount / 2, DAMAGE_PRECISION))
	if(eased <= 0)
		return
	rogue_pain_eased += eased
	if(victim)
		victim.rogue_pain_hud_dirty = TRUE

/datum/wound/slash/flesh/rogue_base_pain()
	return rogue_cut_pain()

/datum/wound/pierce/bleed/rogue_base_pain()
	return rogue_cut_pain()

/// A cut or a stab: a critical one is an opened artery (combat/blood.dm).
/datum/wound/proc/rogue_cut_pain()
	if(severity >= WOUND_SEVERITY_CRITICAL)
		switch(rogue_artery)
			if(ROGUE_ARTERY_THROAT)
				return ROGUE_PAIN_ARTERY_NECK
			if(ROGUE_ARTERY_HEART)
				return ROGUE_PAIN_ARTERY_CHEST
		return ROGUE_PAIN_ARTERY
	return severity >= WOUND_SEVERITY_SEVERE ? ROGUE_PAIN_CUT_SEVERE : ROGUE_PAIN_CUT_MODERATE

/// A dislocation, or a fracture from severe up.
/datum/wound/blunt/bone/rogue_base_pain()
	return severity >= WOUND_SEVERITY_SEVERE ? ROGUE_PAIN_FRACTURE : ROGUE_PAIN_DISLOCATION

/datum/wound/cranial_fissure/rogue_base_pain()
	return ROGUE_PAIN_FRACTURE

/datum/wound/burn/flesh/rogue_base_pain()
	switch(severity)
		if(WOUND_SEVERITY_CRITICAL)
			return ROGUE_PAIN_BURN_CRITICAL
		if(WOUND_SEVERITY_SEVERE)
			return ROGUE_PAIN_BURN_SEVERE
	return ROGUE_PAIN_BURN_MODERATE

/datum/wound/rogue_stump/rogue_base_pain()
	return ROGUE_STUMP_PAIN * (stumps - sewn) + ROGUE_STUMP_SEWN_PAIN * sewn

/// A stump eases by half of what searing and medicine have closed of it (its integrity, combat/dismember.dm), as Ratwood's
/// cauterize_wound() and heal_wound() ease its woundpain.
/datum/wound/rogue_stump/rogue_pain()
	return max(rogue_base_pain() - max(ROGUE_STUMP_INTEGRITY * stumps - integrity, 0) / 2, 0)

/// The most a limb can hurt, wounds included (Ratwood max_pain_damage).
/obj/item/bodypart/proc/rogue_max_pain()
	switch(body_zone)
		if(BODY_ZONE_CHEST)
			return ROGUE_PAIN_MAX_CHEST
		if(BODY_ZONE_HEAD)
			return ROGUE_PAIN_MAX_HEAD
	return ROGUE_PAIN_MAX_LIMB

/// Ratwood's get_complex_pain(): each living limb hurts by its share of damage and its wounds, up to what it can hurt;
/// adrenaline halves it.
/mob/living/carbon/human/proc/rogue_complex_pain()
	. = 0
	var/adrenaline = HAS_TRAIT(src, TRAIT_ADRENALINE_RUSH)
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!(limb.biological_state & BIO_FLESH))
			continue
		var/most = limb.rogue_max_pain()
		var/pain = (limb.brute_dam + limb.burn_dam) / limb.max_damage * most
		for(var/datum/wound/wound as anything in limb.wounds)
			pain += wound.rogue_pain()
		pain = min(pain, most)
		if(adrenaline)
			pain *= ROGUE_PAIN_ADRENALINE_SHARE
		. += pain

/// What pain the will bears, counted anew each time (Ratwood get_pain_threshold(), PR 2546): willpower times ten, five more
/// willpower under adrenaline, the painless 250. The pain checks and the heart both read it.
/mob/living/carbon/human/proc/rogue_pain_threshold()
	if(HAS_TRAIT(src, TRAIT_NOPAIN))
		return ROGUE_PAIN_NOPAIN_THRESHOLD
	var/willpower = max(rogue_stat(ROGUE_STAT_WILLPOWER), 1)
	if(HAS_TRAIT(src, TRAIT_ADRENALINE_RUSH))
		willpower += ROGUE_PAIN_ADRENALINE_WILLPOWER
	return willpower * ROGUE_PAIN_PER_WILLPOWER

/// The pain in percent of what the will bears (Ratwood painpercent).
/mob/living/carbon/human/proc/rogue_pain_share()
	return rogue_complex_pain() / rogue_pain_threshold() * 100

/// The pain the heart shows, in percent of what the will bears; 0 off medieval maps and for bodies Ratwood's pain skips.
/mob/living/proc/rogue_heart_pain()
	return 0

/mob/living/carbon/human/rogue_heart_pain()
	return rogue_combat_enabled() ? rogue_pain_share() : 0

/// Ratwood's handle_random_events(): every ten seconds the pain is weighed. Lying, one only moans now and then; standing,
/// one moans from high pain, and pain past the will may break one, unless a strong will or Psydonian grit endures it.
/mob/living/carbon/human/proc/rogue_pain_check()
	if(stat || HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || HAS_TRAIT(src, TRAIT_NOPAIN))
		return
	rogue_pain_next = world.time + ROGUE_PAIN_CHECK_INTERVAL
	var/share = rogue_pain_share()
	if(body_position == LYING_DOWN || IsKnockdown())
		if(share >= ROGUE_PAIN_MOAN_SHARE && prob(ROGUE_PAIN_LYING_MOAN_CHANCE))
			emote("painmoan")
		return
	if(share < ROGUE_PAIN_BREAK_SHARE)
		if(share >= ROGUE_PAIN_MOAN_SHARE)
			emote("painmoan")
		return
	var/willpower = rogue_stat(ROGUE_STAT_WILLPOWER)
	var/grit = HAS_TRAIT(src, TRAIT_PSYDONIAN_GRIT)
	if((grit || willpower >= ROGUE_PAIN_ENDURE_WILLPOWER) && prob(ROGUE_PAIN_ENDURE_CHANCE))
		Immobilize(ROGUE_PAIN_ENDURE_HOLD)
		if(grit)
			visible_message(span_info("[src] audibly grits [p_their()] teeth, ENDURING through [p_their()] pain."), span_info("Through my faith in HIM, I ENDURE."))
		else
			visible_message(span_info("[src] trembles for a moment, but [p_they()] remain[p_s()] standing."), span_info("My strong constitution keeps me upright."))
		adjust_stutter(ROGUE_PAIN_STUTTER)
		emote("painmoan")
		return
	if(!HAS_TRAIT(src, TRAIT_NOPAINSTUN) && prob(max(ROGUE_PAIN_BREAK_BASE - willpower * ROGUE_PAIN_BREAK_PER_WILLPOWER, ROGUE_PAIN_BREAK_FLOOR)))
		rogue_paincrit()
		rogue_pain_next = world.time + ROGUE_PAIN_CRIT_INTERVAL
		return
	emote("painmoan")
	adjust_stutter(ROGUE_PAIN_STUTTER)

/// Ratwood's paincrit(): the pain breaks one. A scream and a moment held, then the stun and the fall.
/mob/living/carbon/human/proc/rogue_paincrit()
	Immobilize(ROGUE_PAINCRIT_HOLD)
	emote("paincrit", forced = TRUE)
	adjust_stutter(ROGUE_PAIN_STUTTER)
	addtimer(CALLBACK(src, PROC_REF(Stun), ROGUE_PAINCRIT_STUN), ROGUE_PAINCRIT_DELAY)
	addtimer(CALLBACK(src, PROC_REF(Knockdown), ROGUE_PAINCRIT_STUN), ROGUE_PAINCRIT_DELAY)

/// Ratwood's delimb_pain(): losing a limb breaks one, unless constitution and will hold (get_delimb_survival_chance());
/// who holds screams and fights on, the willful in an adrenaline rush, the faithful of Psydon with a roar.
/mob/living/carbon/human/proc/rogue_delimb_pain()
	if(!client || stat || HAS_TRAIT(src, TRAIT_KNOCKEDOUT) || HAS_TRAIT(src, TRAIT_NOPAIN) || HAS_TRAIT(src, TRAIT_NUMBED_LIMBS))
		return
	var/grit = HAS_TRAIT(src, TRAIT_PSYDONIAN_GRIT)
	var/chance = (rogue_stat(ROGUE_STAT_CONSTITUTION) + rogue_stat(ROGUE_STAT_WILLPOWER) - ROGUE_DELIMB_SURVIVE_BASE) * ROGUE_DELIMB_SURVIVE_SHARE
	if(grit)
		chance += ROGUE_DELIMB_GRIT_BONUS
	if(!HAS_TRAIT(src, TRAIT_NOPAINSTUN) && !prob(max(chance, 0)))
		rogue_paincrit()
		return
	if(grit)
		var/static/list/his_will = list(
			"THROUGH HIM, I ENDURE!!",
			"THE BELLS TOLL MY NAME, BUT I CAN STILL FIGHT!!",
			"ENDURE!!",
			"IF I AM TO FALL, THEN THEY SHALL FALL WITH ME!!",
		)
		emote("rage", forced = TRUE)
		visible_message(span_danger("[src] ROARS through the pain, teeth bared in defiant fury!"), span_userdanger(pick(his_will)))
		apply_status_effect(/datum/status_effect/rogue_adrenaline, ROGUE_ADRENALINE_DURATION + ROGUE_ADRENALINE_GRIT_BONUS)
		return
	emote("painscream", forced = TRUE)
	visible_message(span_danger("[src] staggers back from the shock, but holds fast with fire in [p_their()] eyes!"), span_danger("I can still fight!"))
	if(rogue_stat(ROGUE_STAT_WILLPOWER) >= ROGUE_DELIMB_ADRENALINE_WILLPOWER)
		apply_status_effect(/datum/status_effect/rogue_adrenaline)

/// Ratwood's reaction to a hit (species.dm apply_damage()): a cry, a scream from a blow past the constitution; a heavy
/// blow holds the struck and shakes their sight, and a hit past ten slows them; a burn draws a cry too.
/mob/living/carbon/human/proc/rogue_pain_react(damage, damagetype)
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_NOPAIN))
		return
	switch(damagetype)
		if(BRUTE)
			var/constitution = rogue_stat(ROGUE_STAT_CONSTITUTION)
			if(damage > ROGUE_PAIN_CRY_DAMAGE)
				AdjustSleeping(-ROGUE_PAIN_WAKE)
				if(prob(damage * ROGUE_PAIN_CRY_CHANCE))
					emote(damage > constitution * ROGUE_PAIN_SCREAM_CON_FACTOR ? "painscream" : "pain")
			if(HAS_TRAIT(src, TRAIT_NOPAINSTUN))
				return
			if(damage > constitution * ROGUE_PAIN_HOLD_CON_FACTOR)
				Immobilize(ROGUE_PAIN_HOLD)
				shake_camera(src, 2, 2)
				adjust_stutter(ROGUE_PAIN_STUTTER)
			if(damage > ROGUE_PAIN_SLOW_DAMAGE && !HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
				rogue_slowdown(clamp(damage / ROGUE_PAIN_SLOW_DAMAGE, ROGUE_PAIN_SLOW_MIN, ROGUE_PAIN_SLOW_MAX))
				shake_camera(src, 1, 1)
		if(BURN)
			if(damage > ROGUE_PAIN_BURN_CRY_DAMAGE && prob(damage))
				emote("pain")

/// Ratwood's adrenaline rush (buff/adrenaline_rush): for a while pain is halved and the will bears more, bleeding stops,
/// and some blood comes back.
/datum/status_effect/rogue_adrenaline
	id = "rogue_adrenaline"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/rogue_adrenaline

/datum/status_effect/rogue_adrenaline/on_creation(mob/living/new_owner, set_duration)
	duration = set_duration || ROGUE_ADRENALINE_DURATION
	return ..()

/datum/status_effect/rogue_adrenaline/refresh(effect, set_duration)
	duration = max(duration, set_duration || ROGUE_ADRENALINE_DURATION)

/datum/status_effect/rogue_adrenaline/on_apply()
	ADD_TRAIT(owner, TRAIT_ADRENALINE_RUSH, TRAIT_STATUS_EFFECT(id))
	owner.attributes?.set_variable_attribute_modifier(id, list(ROGUE_STAT_WILLPOWER = ROGUE_ADRENALINE_WILLPOWER))
	owner.playsound_local(get_turf(owner), 'modular_redtard/rockhill/sound/misc/adrenaline_rush.ogg', 100, TRUE)
	owner.adjust_blood_volume(ROGUE_ADRENALINE_BLOOD, maximum = BLOOD_VOLUME_NORMAL)
	return TRUE

/datum/status_effect/rogue_adrenaline/on_remove()
	REMOVE_TRAIT(owner, TRAIT_ADRENALINE_RUSH, TRAIT_STATUS_EFFECT(id))
	owner.attributes?.remove_attribute_modifier(id)
	return ..()

/atom/movable/screen/alert/status_effect/rogue_adrenaline
	name = "Adrenaline Rush"
	desc = "The gambit worked! I can do anything! My heart races, the throb of my wounds wavers."
	icon = ROGUE_COMBAT_ALERTS_ICON
	icon_state = "adrrush"
