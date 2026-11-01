// Ratwood's drugs (code/modules/reagents/reagent_containers/powderspice.dm, their buffs in code/datums/status_effects/rogue/
// roguebuff.dm, their moods in code/datums/stress/positive_events.dm): spice (drukqs), ozium, moondust and the purest moondust,
// starsugar and herozium. They come as powders sniffed whole (below); the porter fills the powders, and the skysugar, with them
// (rockhill/config.json, list_reagents). Their numbers are Ratwood's per Ratwood tick of two seconds, scaled to the TG tick as
// the soups count them (survival/soups.dm); a buff is a /datum/status_effect/rogue_intoxicant (alchemy/alcohol.dm), Ratwood's
// stress a TG mood event. Ratwood's ambient music of the high (SSdroning), its overlays of the world, its combat music of
// starsugar and herozium, its addiction of the junkie and its lift of sleep deprivation are not ported.

/// The white flash of Ratwood's fullscreen_redflash("whiteflash"), and how long it fades.
#define ROGUE_DRUG_FLASH "rogue_drug_flash"
#define ROGUE_DRUG_FLASH_FADE (1 SECONDS)
/// The rush of an overdose (Ratwood heroin_rush.ogg).
#define ROGUE_DRUG_RUSH_SOUND 'modular_redtard/alchemy/sound/heroin_rush.ogg'
/// Forcing a powder up someone else's nose (Ratwood do_mob 5 seconds).
#define ROGUE_POWDER_FORCE_TIME rogue_value("powder_force_time")

/// Ratwood fullscreen_redflash("whiteflash"): the screen flashes white.
/mob/living/proc/rogue_drug_flash()
	overlay_fullscreen(ROGUE_DRUG_FLASH, /atom/movable/screen/fullscreen/flash)
	clear_fullscreen(ROGUE_DRUG_FLASH, ROGUE_DRUG_FLASH_FADE)

/// Ratwood's shaking view of moondust and starsugar: on while the drug works, off when it is spent.
/mob/living/proc/rogue_drug_shake(shaking)
	if(!client)
		return
	if(!shaking)
		animate(client)
		return
	animate(client, pixel_y = 1, time = 1, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -1, time = 1, flags = ANIMATION_RELATIVE)

/// The overdose of a Ratwood drug starts: the rush, and blood from the nose.
/mob/living/proc/rogue_drug_overdose_rush()
	playsound_local(get_turf(src), ROGUE_DRUG_RUSH_SOUND, 100, FALSE)
	visible_message(span_warning("Blood runs from [src]'s nose."))

/// Spice: the mind races (Ratwood's High: intelligence and speed up, fortune down) and the world swims.
/datum/reagent/druqks
	name = "Drukqs"
	description = ""
	color = "#60A584"
	overdose_threshold = 16
	metabolization_rate = ROGUE_REAGENT_RATE(0.2)
	/// The drugginess it keeps up while in the blood (Ratwood 30 Life ticks).
	var/rogue_drugginess = 60 SECONDS
	/// Percent chance a Ratwood tick of a giggle, a chuckle or a twitch.
	var/rogue_emote_chance = 5
	/// Per Ratwood tick of an overdose: brain damage and toxins.
	var/rogue_overdose_brain = 2
	var/rogue_overdose_toxin = 3

/datum/reagent/druqks/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.set_drugginess_if_lower(rogue_drugginess)

/datum/reagent/druqks/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	affected_mob.set_drugginess_if_lower(rogue_drugginess)
	if(prob(rogue_emote_chance * seconds_per_tick / ROGUE_REAGENT_TICK))
		INVOKE_ASYNC(affected_mob, TYPE_PROC_REF(/mob, emote), pick("twitch_s", affected_mob.gender == FEMALE ? "giggle" : "chuckle"))
	affected_mob.apply_status_effect(/datum/status_effect/rogue_intoxicant/druqks)

/datum/reagent/druqks/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/drugginess)
	affected_mob.remove_status_effect(/datum/status_effect/rogue_intoxicant/druqks)

/datum/reagent/druqks/overdose_start(mob/living/affected_mob, metabolization_ratio)
	. = ..()
	affected_mob.visible_message(span_warning("Blood runs from [affected_mob]'s nose."))

/datum/reagent/druqks/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	var/ticks = seconds_per_tick / ROGUE_REAGENT_TICK
	affected_mob.adjust_organ_loss(ORGAN_SLOT_BRAIN, rogue_overdose_brain * ticks)
	if(affected_mob.adjust_tox_loss(rogue_overdose_toxin * ticks, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH

/// A painless world (Ratwood's ozium buff: no pain, slower, keener eyes).
/datum/reagent/ozium
	name = "Ozium"
	description = ""
	color = "#a5606f"
	taste_description = "a bitter numbess"
	overdose_threshold = 16
	metabolization_rate = ROGUE_REAGENT_RATE(0.2)
	/// Toxins per Ratwood tick of an overdose.
	var/rogue_overdose_toxin = 3

/datum/reagent/ozium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	affected_mob.apply_status_effect(/datum/status_effect/rogue_intoxicant/ozium)

/datum/reagent/ozium/overdose_start(mob/living/affected_mob, metabolization_ratio)
	. = ..()
	affected_mob.rogue_drug_overdose_rush()

/datum/reagent/ozium/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(affected_mob.adjust_tox_loss(rogue_overdose_toxin * seconds_per_tick / ROGUE_REAGENT_TICK, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH

/// Moondust: faster limbs and hands, a firmer will, a duller mind; the view shakes and flashes white. With the purest moondust
/// it knocks one out, but for Baotha's blessed.
/datum/reagent/moondust
	name = "moondust"
	description = ""
	color = "#f9e5fd"
	taste_description = "numbness and the moon"
	overdose_threshold = 24
	metabolization_rate = ROGUE_REAGENT_RATE(0.2)
	/// Its buff, and the other moondust that knocks one out with it.
	var/rogue_buff = /datum/status_effect/rogue_intoxicant/moondust
	var/rogue_clashing = /datum/reagent/moondust_purest
	/// The sleep of the two together.
	var/rogue_clash_sleep = 4 SECONDS
	/// Percent chance a Ratwood tick of a white flash.
	var/rogue_flash_chance = 10
	/// Toxins per Ratwood tick of an overdose.
	var/rogue_overdose_toxin = 3

/datum/reagent/moondust/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.rogue_drug_flash()
	affected_mob.rogue_drug_shake(TRUE)

/datum/reagent/moondust/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.rogue_drug_shake(FALSE)

/datum/reagent/moondust/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(holder.has_reagent(rogue_clashing) && !HAS_TRAIT(affected_mob, TRAIT_CRACKHEAD))
		affected_mob.Sleeping(rogue_clash_sleep)
	affected_mob.apply_status_effect(rogue_buff)
	if(prob(rogue_flash_chance * seconds_per_tick / ROGUE_REAGENT_TICK))
		affected_mob.rogue_drug_flash()

/datum/reagent/moondust/overdose_start(mob/living/affected_mob, metabolization_ratio)
	. = ..()
	affected_mob.rogue_drug_overdose_rush()

/datum/reagent/moondust/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	if(affected_mob.adjust_tox_loss(rogue_overdose_toxin * seconds_per_tick / ROGUE_REAGENT_TICK, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH

/datum/reagent/moondust_purest
	parent_type = /datum/reagent/moondust
	name = "Purest Moondust"
	color = "#e7ade9"
	taste_description = "sheer, unadulterated energy"
	overdose_threshold = 20
	rogue_buff = /datum/status_effect/rogue_intoxicant/moondust_purest
	rogue_clashing = /datum/reagent/moondust
	rogue_flash_chance = 20

/// Starsugar: a powerful stimulant. It shakes off stuns and fatigue, quickens the feet and the hands, lets one dodge and see in
/// the dark; the view shakes and flashes white. With herozium it knocks one out, but for Baotha's blessed. Ratwood calls its
/// parent twice a tick, so it is spent twice as fast as its rate of 0.5 says.
/datum/reagent/starsugar
	name = "starsugar"
	description = ""
	color = "#e47cdf"
	overdose_threshold = 20
	metabolization_rate = ROGUE_REAGENT_RATE(1)
	/// Per Ratwood tick: stuns of every kind shaken off, fatigue (TG stamina damage) taken off, jitters kept up.
	var/rogue_stun_off = 4 SECONDS
	var/rogue_fatigue_off = 2
	var/rogue_jitter = 4 SECONDS
	/// The sleep with herozium.
	var/rogue_clash_sleep = 4 SECONDS
	/// Percent chances a Ratwood tick: a word of the high, a twitch, a white flash.
	var/rogue_message_chance = 5
	var/rogue_emote_chance = 5
	var/rogue_flash_chance = 20
	/// Per Ratwood tick of an overdose: toxins, the steps one staggers, the chances of a laugh and of dropping everything.
	var/rogue_overdose_toxin = 4
	var/rogue_overdose_steps = 4
	var/rogue_overdose_laugh_chance = 20
	var/rogue_overdose_drop_chance = 15
	var/static/list/rogue_high_messages = list("You feel hyper.", "You feel like you need to go faster.", "You feel like you can run the world.")

/datum/reagent/starsugar/on_mob_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.add_movespeed_modifier(/datum/movespeed_modifier/reagent/rogue_starsugar)
	affected_mob.rogue_drug_flash()
	affected_mob.rogue_drug_shake(TRUE)

/datum/reagent/starsugar/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/rogue_intoxicant/starsugar)
	affected_mob.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/rogue_starsugar)
	affected_mob.rogue_drug_shake(FALSE)

/datum/reagent/starsugar/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	var/ticks = seconds_per_tick / ROGUE_REAGENT_TICK
	if(prob(rogue_message_chance * ticks))
		to_chat(affected_mob, span_notice(pick(rogue_high_messages)))
	var/stun_off = -rogue_stun_off * ticks
	affected_mob.AdjustStun(stun_off)
	affected_mob.AdjustKnockdown(stun_off)
	affected_mob.AdjustUnconscious(stun_off)
	affected_mob.AdjustParalyzed(stun_off)
	affected_mob.AdjustImmobilized(stun_off)
	if(affected_mob.adjust_stamina_loss(-rogue_fatigue_off * ticks, updating_stamina = FALSE))
		. = UPDATE_MOB_HEALTH
	affected_mob.set_jitter_if_lower(rogue_jitter)
	if(holder.has_reagent(/datum/reagent/herozium) && !HAS_TRAIT(affected_mob, TRAIT_CRACKHEAD))
		affected_mob.Sleeping(rogue_clash_sleep)
	if(prob(rogue_emote_chance * ticks))
		INVOKE_ASYNC(affected_mob, TYPE_PROC_REF(/mob, emote), pick("twitch", "shiver", "sniff"))
	affected_mob.apply_status_effect(/datum/status_effect/rogue_intoxicant/starsugar)
	if(prob(rogue_flash_chance * ticks))
		affected_mob.rogue_drug_flash()

/datum/reagent/starsugar/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	var/ticks = seconds_per_tick / ROGUE_REAGENT_TICK
	affected_mob.rogue_drug_overdose_rush()
	if((affected_mob.mobility_flags & MOBILITY_MOVE) && isturf(affected_mob.loc))
		for(var/i in 1 to round(rogue_overdose_steps * ticks))
			step(affected_mob, pick(GLOB.cardinals))
	if(prob(rogue_overdose_laugh_chance * ticks))
		INVOKE_ASYNC(affected_mob, TYPE_PROC_REF(/mob, emote), "laugh")
	if(prob(rogue_overdose_drop_chance * ticks))
		affected_mob.visible_message(span_danger("[affected_mob]'s face turns pale and sweaty!"))
		affected_mob.drop_all_held_items()
	if(affected_mob.adjust_tox_loss(rogue_overdose_toxin * ticks, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH

/datum/movespeed_modifier/reagent/rogue_starsugar
	multiplicative_slowdown = -0.5

/// Herozium: sweet unfeeling. No pain, no fear of a mortal wound, a heavier body and slower hands; jitters, confusion and
/// nausea fall away and the world swims. With ozium or starsugar it knocks one out, but for Baotha's blessed; too much of it
/// is a choking sleep.
/datum/reagent/herozium
	name = "herozium"
	description = ""
	color = "#ff6207"
	overdose_threshold = 20
	metabolization_rate = ROGUE_REAGENT_RATE(0.5)
	/// The drugginess it keeps up while in the blood (Ratwood 30 Life ticks).
	var/rogue_drugginess = 60 SECONDS
	/// The sleep with ozium or starsugar.
	var/rogue_clash_sleep = 8 SECONDS
	/// Percent chance a Ratwood tick of the rush.
	var/rogue_rush_chance = 15
	/// Per Ratwood tick of an overdose: the chance of a gag, a snore or a yawn, the dizziness of a snore, the sleep, the choking.
	var/rogue_overdose_emote_chance = 30
	var/rogue_overdose_dizzy = 50 SECONDS
	var/rogue_overdose_sleep = 4 SECONDS
	var/rogue_overdose_oxy = 4

/datum/reagent/herozium/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	affected_mob.set_jitter(0)
	affected_mob.set_confusion(0)
	affected_mob.set_disgust(0)
	affected_mob.set_drugginess_if_lower(rogue_drugginess)
	affected_mob.apply_status_effect(/datum/status_effect/rogue_intoxicant/herozium)
	if((holder.has_reagent(/datum/reagent/ozium) || holder.has_reagent(/datum/reagent/starsugar)) && !HAS_TRAIT(affected_mob, TRAIT_CRACKHEAD))
		affected_mob.Sleeping(rogue_clash_sleep)
	if(prob(rogue_rush_chance * seconds_per_tick / ROGUE_REAGENT_TICK))
		affected_mob.playsound_local(get_turf(affected_mob), ROGUE_DRUG_RUSH_SOUND, 100, FALSE)

/datum/reagent/herozium/on_mob_end_metabolize(mob/living/affected_mob)
	. = ..()
	affected_mob.remove_status_effect(/datum/status_effect/drugginess)
	affected_mob.remove_status_effect(/datum/status_effect/rogue_intoxicant/herozium)

/datum/reagent/herozium/overdose_process(mob/living/affected_mob, seconds_per_tick, metabolization_ratio)
	. = ..()
	var/ticks = seconds_per_tick / ROGUE_REAGENT_TICK
	if(prob(rogue_overdose_emote_chance * ticks))
		var/reaction = pick("gag", "snore", "yawn")
		INVOKE_ASYNC(affected_mob, TYPE_PROC_REF(/mob, emote), reaction)
		if(reaction == "snore")
			affected_mob.set_dizzy_if_lower(rogue_overdose_dizzy)
	affected_mob.Sleeping(rogue_overdose_sleep)
	if(affected_mob.adjust_oxy_loss(rogue_overdose_oxy * ticks, updating_health = FALSE))
		. = UPDATE_MOB_HEALTH

// The highs (Ratwood's buffs of the drugs; their alert is Ratwood's "High").

/datum/status_effect/rogue_intoxicant/druqks
	id = "rogue_druqks"
	duration = 2 MINUTES
	stats = list(ROGUE_STAT_INTELLIGENCE = 5, ROGUE_STAT_SPEED = 3, ROGUE_STAT_FORTUNE = -5)
	mood = /datum/mood_event/rogue_high
	clear_mood = TRUE

/datum/status_effect/rogue_intoxicant/ozium
	id = "rogue_ozium"
	duration = 30 SECONDS
	stats = list(ROGUE_STAT_SPEED = -5, ROGUE_STAT_PERCEPTION = 2)
	mood = /datum/mood_event/rogue_ozium
	clear_mood = TRUE
	traits = list(TRAIT_NOPAIN)

/datum/status_effect/rogue_intoxicant/moondust
	id = "rogue_moondust"
	duration = 30 SECONDS
	stats = list(ROGUE_STAT_SPEED = 2, ROGUE_STAT_WILLPOWER = 2, ROGUE_STAT_INTELLIGENCE = -2)
	mood = /datum/mood_event/rogue_moondust
	click_delay = 0.8

/datum/status_effect/rogue_intoxicant/moondust_purest
	id = "rogue_moondust_purest"
	duration = 40 SECONDS
	stats = list(ROGUE_STAT_SPEED = 3, ROGUE_STAT_WILLPOWER = 3, ROGUE_STAT_INTELLIGENCE = -2)
	mood = /datum/mood_event/rogue_moondust_purest
	click_delay = 0.8

/datum/status_effect/rogue_intoxicant/herozium
	id = "rogue_herozium"
	duration = 80 SECONDS
	stats = list(ROGUE_STAT_SPEED = -5, ROGUE_STAT_WILLPOWER = 4, ROGUE_STAT_INTELLIGENCE = -3, ROGUE_STAT_CONSTITUTION = 3)
	mood = /datum/mood_event/rogue_ozium
	clear_mood = TRUE
	traits = list(TRAIT_NOPAIN, TRAIT_CRITICAL_RESISTANCE)
	click_delay = 1.2

/datum/status_effect/rogue_intoxicant/starsugar
	id = "rogue_starsugar"
	duration = 80 SECONDS
	stats = list(ROGUE_STAT_SPEED = 4, ROGUE_STAT_WILLPOWER = 4, ROGUE_STAT_INTELLIGENCE = -3, ROGUE_STAT_CONSTITUTION = -3)
	mood = /datum/mood_event/rogue_starsugar
	clear_mood = TRUE
	traits = list(TRAIT_DODGEEXPERT, TRAIT_DARKVISION)
	click_delay = 0.7

/datum/mood_event/rogue_high
	description = "I'm so high, don't take away my sky."
	mood_change = 4 * ROGUE_STRESS_TO_MOOD
	timeout = 5 MINUTES

/datum/mood_event/rogue_ozium
	description = "I've taken a hit and entered a painless world."
	mood_change = 99 * ROGUE_STRESS_TO_MOOD
	timeout = 2 MINUTES

/datum/mood_event/rogue_moondust
	description = "Moondust surges through me."
	mood_change = 6 * ROGUE_STRESS_TO_MOOD
	timeout = 4 MINUTES

/datum/mood_event/rogue_moondust_purest
	description = "PURE moondust surges through me!"
	mood_change = 8 * ROGUE_STRESS_TO_MOOD
	timeout = 4 MINUTES

/datum/mood_event/rogue_starsugar
	description = "My heart rushes, my blood runs, I feel tightly bound together. I could run a marathon."
	mood_change = 1 * ROGUE_STRESS_TO_MOOD
	timeout = 4 MINUTES

// Powders (Ratwood /obj/item/reagent_containers/powder attack()): a powder is sniffed whole, by oneself or forced up someone
// else's nose. Ratwood's snort of a powder thrown at the nose is not ported.

/obj/item/reagent_containers/powder/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!iscarbon(interacting_with))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_sniff_powder), interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/// Sniffs the powder, straight into the blood (Ratwood's "swallow" skips the stomach): one needs a head and a nose, and the
/// mouth and nose bare; someone on guard turns their face away unless their head is held, otherwise it takes powder_force_time.
/obj/item/reagent_containers/powder/proc/rogue_sniff_powder(mob/living/carbon/sniffer, mob/living/user)
	if(!canconsume(sniffer, user))
		return
	if(!sniffer.get_bodypart(BODY_ZONE_HEAD))
		to_chat(user, span_warning("[sniffer.p_theyre(TRUE)] missing something."))
		return
	if(HAS_TRAIT(sniffer, TRAIT_ANOSMIA))
		to_chat(user, span_warning("[sniffer.p_they(TRUE)] [sniffer.p_have()] no nose!"))
		return
	if(sniffer == user)
		user.visible_message(span_notice("[user] sniffs [src]."))
	else
		user.visible_message(span_danger("[user] attempts to force [sniffer] to inhale [src]."), span_danger("I attempt to force [sniffer] to inhale [src]!"))
		if(sniffer.combat_mode && !rogue_holds_head(user, sniffer))
			to_chat(user, span_info("[sniffer.p_they(TRUE)] steals [sniffer.p_their()] face from it."))
			return
		if(!do_after(user, ROGUE_POWDER_FORCE_TIME, target = sniffer) || QDELETED(src) || !reagents.total_volume)
			return
	playsound(sniffer, 'modular_redtard/husbandry/sound/sniff.ogg', 100, FALSE)
	user.log_message("made [sniffer] sniff [src] ([reagents.get_reagent_log_string()])", LOG_ATTACK)
	reagents.trans_to(sniffer, reagents.total_volume, transferred_by = user, methods = INHALE)
	qdel(src)

/// Whether user holds target by the head (a rogue grip on the head or a part of it).
/proc/rogue_holds_head(mob/living/user, mob/living/target)
	for(var/obj/item/hand_item/rogue_grab/grip in user.held_items)
		if(grip.grabbed == target && (grip.zone in GLOB.rogue_head_zones))
			return TRUE
	return FALSE

#undef ROGUE_DRUG_FLASH
#undef ROGUE_DRUG_FLASH_FADE
#undef ROGUE_DRUG_RUSH_SOUND
#undef ROGUE_POWDER_FORCE_TIME
