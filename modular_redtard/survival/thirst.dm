// Ratwood's thirst on medieval maps (mob.dm hydration, species.dm handle_digestion(), carbon_movement.dm Move(),
// status_effects/rogue/debuff.dm thirstyt1-3, stress/negative_events.dm drym, thirst and parched, positive_events.dm hydrated,
// human/examine.dm, reagents' hydration and hydration_factor, turfs/open/water.dm and structures/well.dm onbite()). A human's
// hydration runs from a thousand down to nothing: it seeps away with time (faster in the heat), with every step (more running)
// and with vomiting, and what the body takes in of water and drinks brings it back (salt water dries one out, but not the sea
// folk). A little thirsty, thirsty and parched are steps of thirst with Ratwood's stat penalties and moods; quite full, one is
// glad of it. Those who read others' bodies see their thirst on examine. A body without water does not mend in sleep, and with
// neither water nor food a spent body's heart gives out. Biting (the bite of the middle mouse button) open water or a fountain
// drinks from it a mouthful at a time; a wood bin or a well fills a vessel to drink from (survival/vessels.dm). Players who
// begin the round get full hydration (Ratwood's ready-up bonus); others start a little thirsty.

/// Ratwood HYDRATION_LEVEL_*: the most, glad of it from, a little thirsty below, thirsty below, parched below.
#define THIRST_FULL 1000
#define THIRST_QUENCHED 999
#define THIRST_LITTLE 600
#define THIRST_THIRSTY 350
#define THIRST_PARCHED 100
#define THIRST_ICON 'modular_redtard/survival/icons/thirst.dmi'
/// Mood categories: the step of thirst (Ratwood drym, thirst, parched) and being glad of a full belly of water (hydrated).
#define THIRST_MOOD "rogue_thirst"
#define QUENCHED_MOOD "rogue_quenched"
#define DRINK_SOUNDS list('modular_redtard/rockhill/sound/items/drink_gen (1).ogg', 'modular_redtard/rockhill/sound/items/drink_gen (2).ogg', 'modular_redtard/rockhill/sound/items/drink_gen (3).ogg')
#define SIP_SOUNDS list('modular_redtard/survival/sound/waterwash1.ogg', 'modular_redtard/survival/sound/waterwash2.ogg')

/// The status of each step of thirst, first to third.
GLOBAL_LIST_INIT(rogue_thirst_stages, list(
	/datum/status_effect/rogue_thirst,
	/datum/status_effect/rogue_thirst/thirsty,
	/datum/status_effect/rogue_thirst/parched,
))

/mob/living/carbon/human
	/// Ratwood hydration, from nothing to THIRST_FULL; null for one the thirst does not reach (modern maps).
	var/rogue_hydration
	/// The step of thirst shown now (its status and mood): 0 none, 1 a little thirsty, 2 thirsty, 3 parched.
	var/rogue_thirst_stage = 0

/// Medieval maps: humans thirst.
/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	if(rogue_survival_enabled())
		AddElement(/datum/element/rogue_thirst)

/// Ratwood adjust_hydration(): one who needs no food (TRAIT_NOHUNGER) needs no water either.
/mob/living/carbon/human/proc/rogue_adjust_hydration(amount)
	if(isnull(rogue_hydration) || HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	rogue_hydration = clamp(rogue_hydration + amount, 0, THIRST_FULL)
	return TRUE

/// Ratwood set_hydration().
/mob/living/carbon/human/proc/rogue_set_hydration(amount)
	if(isnull(rogue_hydration) || HAS_TRAIT(src, TRAIT_NOHUNGER))
		return FALSE
	rogue_hydration = clamp(amount, 0, THIRST_FULL)
	rogue_thirst_update()
	return TRUE

/// Ratwood handle_digestion() switch(hydration): the step of thirst follows the hydration; a full one is glad of it.
/mob/living/carbon/human/proc/rogue_thirst_update()
	if(isnull(rogue_hydration))
		return
	var/stage = 0
	if(!HAS_TRAIT(src, TRAIT_NOHUNGER))
		if(rogue_hydration < THIRST_PARCHED)
			stage = 3
		else if(rogue_hydration < THIRST_THIRSTY)
			stage = 2
		else if(rogue_hydration < THIRST_LITTLE)
			stage = 1
		else if(rogue_hydration >= THIRST_QUENCHED)
			add_mood_event(QUENCHED_MOOD, /datum/mood_event/rogue_quenched)
	if(stage == rogue_thirst_stage)
		return
	rogue_thirst_stage = stage
	if(stage)
		apply_status_effect(GLOB.rogue_thirst_stages[stage])
	else
		remove_status_effect(/datum/status_effect/rogue_thirst)

/// Ratwood hydration of a human: it seeps away with time and steps, comes back with what the body takes in, and its step of
/// thirst shows; one who reads bodies sees it.
/datum/element/rogue_thirst
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/// Ratwood ready-up bonus (job equip): a player beginning the round starts fully watered.
/datum/element/rogue_thirst/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_spawn))

/datum/element/rogue_thirst/Attach(datum/target)
	. = ..()
	if(!ishuman(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/carbon/human/drinker = target
	if(isnull(drinker.rogue_hydration))
		drinker.rogue_hydration = rand(rogue_value("thirst_start_min"), rogue_value("thirst_start_max"))
	RegisterSignal(drinker, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(drinker, COMSIG_MOB_REAGENT_TICK, PROC_REF(on_reagent))
	RegisterSignal(drinker, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	RegisterSignal(drinker, COMSIG_CARBON_VOMITED, PROC_REF(on_vomit))
	RegisterSignal(drinker, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	drinker.rogue_thirst_update()

/datum/element/rogue_thirst/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_LIVING_LIFE, COMSIG_MOB_REAGENT_TICK, COMSIG_MOVABLE_MOVED, COMSIG_CARBON_VOMITED, COMSIG_ATOM_EXAMINE))
	var/mob/living/carbon/human/drinker = source
	drinker.remove_status_effect(/datum/status_effect/rogue_thirst)
	drinker.clear_mood_event(QUENCHED_MOOD)
	drinker.rogue_thirst_stage = 0
	drinker.rogue_hydration = null
	return ..()

/datum/element/rogue_thirst/proc/on_job_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER
	if(!ishuman(spawned) || SSticker.current_state >= GAME_STATE_PLAYING)
		return
	var/mob/living/carbon/human/drinker = spawned
	drinker.rogue_set_hydration(THIRST_FULL)

/// Ratwood handle_digestion(): water seeps away every second of life, half as fast again in the heat, slower for a hemophage.
/// With neither water nor food in it, a body worn out to the last breath has its heart give out (Ratwood stamina_add()).
/datum/element/rogue_thirst/proc/on_life(mob/living/carbon/human/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER
	if(source.stat == DEAD)
		return
	if(!HAS_TRAIT(source, TRAIT_NOHUNGER))
		var/drain = rogue_value("thirst_drain") * seconds_per_tick
		if(source.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT)
			drain *= rogue_value("thirst_hot_factor")
		if(HAS_TRAIT(source, TRAIT_HEMOPHAGE))
			drain *= rogue_value("thirst_hemophage_factor")
		source.rogue_adjust_hydration(-drain)
		if(source.rogue_hydration <= 0 && source.nutrition <= 0 && source.get_stamina_loss() >= source.max_stamina && !source.undergoing_cardiac_arrest())
			source.set_heartattack(TRUE)
	source.rogue_thirst_update()

/// Ratwood reagents' hydration: every unit the body takes in quenches (or dries out) by its drink's hydration.
/datum/element/rogue_thirst/proc/on_reagent(mob/living/carbon/human/source, datum/reagent/chem, seconds_per_tick, metabolization_ratio)
	SIGNAL_HANDLER
	var/hydration = chem.rogue_hydration_for(source)
	if(hydration)
		source.rogue_adjust_hydration(hydration * metabolization_ratio / REM)

/// Ratwood carbon Move(): every step costs a little water, a running one more.
/datum/element/rogue_thirst/proc/on_moved(mob/living/carbon/human/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(forced || source.stat == DEAD || !isturf(source.loc) || (source.movement_type & FLOATING))
		return
	var/cost = rogue_value("thirst_step")
	if(source.move_intent == MOVE_INTENT_RUN && !source.buckled)
		cost += rogue_value("thirst_run_step")
	source.rogue_adjust_hydration(-cost)

/// Ratwood vomit(): throwing up loses water as well as food.
/datum/element/rogue_thirst/proc/on_vomit(mob/living/carbon/human/source, distance, force)
	SIGNAL_HANDLER
	source.rogue_adjust_hydration(-rogue_value("thirst_vomit"))

/// Ratwood examine(): one with Eora's exteroception sees how thirsty someone looks.
/datum/element/rogue_thirst/proc/on_examine(mob/living/carbon/human/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(user, TRAIT_EXTEROCEPTION))
		return
	switch(source.rogue_thirst_stage)
		if(1)
			examine_list += span_notice("[source.p_They()] [source.p_are()] looking like [source.p_their()] mouth is dry.")
		if(2)
			examine_list += span_warning("[source.p_They()] [source.p_are()] looking thirsty for a drink.")
		if(3)
			examine_list += span_danger("[source.p_They()] [source.p_are()] looking parched.")

/// Ratwood handle_sleep(): only a body with water in it mends in sleep (survival/sleep.dm).
/datum/component/rogue_sleeper/sleep_heal(mob/living/carbon/human/source, seconds_per_tick)
	if(!isnull(source.rogue_hydration) && source.rogue_hydration <= 0 && !HAS_TRAIT(source, TRAIT_NOHUNGER))
		return
	return ..()

// --- The steps of thirst (Ratwood thirstyt1-3, ten seconds renewed each Life tick: here they last while the step does)

/datum/status_effect/rogue_thirst
	id = "rogue_thirst"
	status_type = STATUS_EFFECT_REPLACE
	duration = STATUS_EFFECT_PERMANENT
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/rogue_thirst
	/// Ratwood effectedstats of the step.
	var/list/stats = list(ROGUE_STAT_WILLPOWER = -1)
	/// Ratwood's stress of the step.
	var/mood = /datum/mood_event/rogue_thirst

/// A replaced step is not removed (TG be_replaced()): every step sets its own stats and mood over the last one's.
/datum/status_effect/rogue_thirst/on_apply()
	owner.attributes?.set_variable_attribute_modifier(id, stats.Copy())
	owner.add_mood_event(THIRST_MOOD, mood)
	return TRUE

/datum/status_effect/rogue_thirst/on_remove()
	owner.attributes?.remove_attribute_modifier(id)
	owner.clear_mood_event(THIRST_MOOD)
	return ..()

/datum/status_effect/rogue_thirst/thirsty
	alert_type = /atom/movable/screen/alert/status_effect/rogue_thirst/thirsty
	stats = list(ROGUE_STAT_SPEED = -1, ROGUE_STAT_WILLPOWER = -2)
	mood = /datum/mood_event/rogue_thirst/thirsty

/datum/status_effect/rogue_thirst/parched
	alert_type = /atom/movable/screen/alert/status_effect/rogue_thirst/parched
	stats = list(ROGUE_STAT_STRENGTH = -1, ROGUE_STAT_SPEED = -2, ROGUE_STAT_WILLPOWER = -3)
	mood = /datum/mood_event/rogue_thirst/parched

/atom/movable/screen/alert/status_effect/rogue_thirst
	name = "Thirsty"
	desc = "I need water."
	icon = THIRST_ICON
	icon_state = "thirst1"

/atom/movable/screen/alert/status_effect/rogue_thirst/thirsty
	desc = "My mouth feels much drier."
	icon_state = "thirst2"

/atom/movable/screen/alert/status_effect/rogue_thirst/parched
	desc = "I urgently need water!"
	icon_state = "thirst3"

/datum/mood_event/rogue_thirst
	description = "I'm a little thirsty."
	mood_change = -1 * ROGUE_STRESS_TO_MOOD

/datum/mood_event/rogue_thirst/thirsty
	description = "I'm thirsty."
	mood_change = -3 * ROGUE_STRESS_TO_MOOD

/datum/mood_event/rogue_thirst/parched
	description = "I'm going to die of thirst."
	mood_change = -5 * ROGUE_STRESS_TO_MOOD

/datum/mood_event/rogue_quenched
	description = "My thirst is quenched. Invigorating."
	mood_change = 1 * ROGUE_STRESS_TO_MOOD
	timeout = 10 MINUTES

// --- What quenches (Ratwood water hydration, consumables' hydration_factor, soups' and milk's hydration)

/datum/reagent
	/// Ratwood hydration of one unit the body takes in (its hydration a Life tick over the units it used a tick); below zero it
	/// dries one out.
	var/rogue_hydration = 0

/// The hydration of a unit of this for this drinker.
/datum/reagent/proc/rogue_hydration_for(mob/living/carbon/human/drinker)
	return rogue_hydration

/datum/reagent/water
	rogue_hydration = 12

/// Ratwood water on_mob_life(): a hemophage cannot keep water down.
/datum/reagent/water/rogue_hydration_for(mob/living/carbon/human/drinker)
	return HAS_TRAIT(drinker, TRAIT_HEMOPHAGE) ? 0 : rogue_hydration

/// Ratwood salty water: it dries out all but the sea folk, whom it quenches.
/datum/reagent/water/salt
	rogue_hydration = -12

/datum/reagent/water/salt/rogue_hydration_for(mob/living/carbon/human/drinker)
	return HAS_TRAIT(drinker, TRAIT_SEA_DRINKER) ? -rogue_hydration : rogue_hydration

/datum/reagent/consumable/ethanol
	rogue_hydration = 10

/datum/reagent/consumable/caffeine
	rogue_hydration = 5

/datum/reagent/consumable/milk
	rogue_hydration = 10

/datum/reagent/consumable/soup
	/// Ratwood hydration a Life tick of a soup, spread over the units it uses a tick (its Ratwood rate, ROGUE_REAGENT_RATE()).
	var/rogue_hydration_tick = 6

/datum/reagent/consumable/soup/rogue_hydration_for(mob/living/carbon/human/drinker)
	if(metabolization_rate <= 0)
		return 0
	return rogue_hydration_tick / (metabolization_rate * ROGUE_REAGENT_TICK)

/datum/reagent/consumable/soup/porridge
	rogue_hydration_tick = 2

/datum/reagent/consumable/soup/veggie
	rogue_hydration_tick = 8

/datum/reagent/consumable/soup/purebutter
	rogue_hydration_tick = 1

/datum/reagent/consumable/soup/lemon
	rogue_hydration_tick = 8

/datum/reagent/consumable/soup/lime
	rogue_hydration_tick = 8

/datum/reagent/consumable/soup/pear
	rogue_hydration_tick = 8

/datum/reagent/consumable/soup/apple
	rogue_hydration_tick = 8

/datum/reagent/consumable/soup/tangerine_marmalade
	rogue_hydration_tick = 8

/datum/reagent/consumable/soup/bone_broth
	rogue_hydration_tick = 10

// --- Drinking straight from water (Ratwood onbite() of water, fountains)

/// Ratwood onbite(): the bite (middle mouse button) drinks from open water and fountains.
/mob/living/carbon/human/rogue_try_bite(atom/target)
	if(istype(wear_mouth, /obj/item/rogue_bite) || !rogue_survival_enabled() || !target?.rogue_drink_reagent() || !target.Adjacent(src))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_drink_from), target)
	return TRUE

/// What a mouthful from this is, or null when one cannot drink from it.
/atom/proc/rogue_drink_reagent()
	return null

/// How many mouthfuls in one go before one has had enough.
/atom/proc/rogue_drink_sips()
	return 1

/// How much one mouthful is.
/atom/proc/rogue_drink_amount()
	return rogue_value("drink_sip")

/// What one thinks, starting to drink from it.
/atom/proc/rogue_drink_warning(mob/living/drinker)
	return

/turf/open/water/rockhill/rogue_drink_reagent()
	return rogue_water_reagent

/turf/open/water/rockhill/rogue_drink_sips()
	return rogue_value("drink_water_sips")

/turf/open/water/sewer/rogue_drink_warning(mob/living/drinker)
	to_chat(drinker, span_userdanger("Have I gone mad!? Why am I drinking sewage?"))

/obj/structure/well/fountain/rogue_drink_reagent()
	return /datum/reagent/water

/obj/structure/well/fountain/rogue_drink_sips()
	return rogue_value("drink_fountain_sips")

/// Ratwood's mana fountain gives a little mana potion a mouthful.
/obj/structure/well/fountain/mana/rogue_drink_reagent()
	return /datum/reagent/medicine/manapot

/obj/structure/well/fountain/mana/rogue_drink_sips()
	return rogue_value("drink_mana_sips")

/obj/structure/well/fountain/mana/rogue_drink_amount()
	return rogue_value("drink_mana_sip")

/// Ratwood's swamp fountain: one mouthful of bog water.
/obj/structure/well/fountainswamp/rogue_drink_reagent()
	return /datum/reagent/water/gross

/// Ratwood onbite() and drink_act(): mouthful after mouthful while the drinker keeps at it, until they have had enough.
/mob/living/carbon/human/proc/rogue_drink_from(atom/source)
	if(stat != STABLE)
		return
	if(is_mouth_covered())
		to_chat(src, span_warning("My mouth is covered."))
		return
	var/sips = source.rogue_drink_sips()
	visible_message(span_info("[src] starts to drink from [source]."))
	playsound(src, pick(SIP_SOUNDS), 100, FALSE)
	source.rogue_drink_warning(src)
	for(var/sip in 1 to sips)
		if(stat != STABLE || !do_after(src, rogue_value("drink_sip_time"), source) || QDELETED(source))
			return
		var/datum/reagent/drink = source.rogue_drink_reagent()
		if(!drink)
			return
		rogue_take_mouthful(drink, source.rogue_drink_amount())
		playsound(src, pick(DRINK_SOUNDS), 100, TRUE)
	if(sips > 1)
		to_chat(src, span_warning("I've had enough."))

/// A mouthful of a reagent, swallowed (into the stomach, as TG drinks go).
/mob/living/carbon/human/proc/rogue_take_mouthful(datum/reagent/drink, amount)
	var/datum/reagents/mouthful = new(amount, NO_REACT)
	mouthful.add_reagent(drink, amount)
	mouthful.trans_to(src, amount, methods = INGEST)
	qdel(mouthful)

#undef THIRST_FULL
#undef THIRST_QUENCHED
#undef THIRST_LITTLE
#undef THIRST_THIRSTY
#undef THIRST_PARCHED
#undef THIRST_ICON
#undef THIRST_MOOD
#undef QUENCHED_MOOD
#undef DRINK_SOUNDS
#undef SIP_SOUNDS
