#define RADIATION_IMMEDIATE_TOX_DAMAGE 10

#define RADIATION_TOX_DAMAGE_PER_INTERVAL 2
#define RADIATION_TOX_INTERVAL 25

#define RADIATION_BURN_SPLOTCH_DAMAGE 11
#define RADIATION_BURN_INTERVAL_MIN (30 SECONDS)
#define RADIATION_BURN_INTERVAL_MAX (60 SECONDS)

// Showers process on SSmachines
#define RADIATION_CLEAN_IMMUNITY_TIME (SSMACHINES_DT + (1 SECONDS))

/// This atom is irradiated, and will glow green.
/// Humans will take toxin damage until all their toxin damage is cleared.
/// Items will attempt to irradiate whoever is holding them, as well as whatever they are inside.
/datum/component/irradiated
	dupe_mode = COMPONENT_DUPE_UNIQUE

	var/burn_splotch_timer_id

	COOLDOWN_DECLARE(clean_cooldown)
	COOLDOWN_DECLARE(last_tox_damage)

/datum/component/irradiated/Initialize()
	if (!CAN_IRRADIATE(parent))
		return COMPONENT_INCOMPATIBLE

	ADD_TRAIT(parent, TRAIT_RADIATION_PROTECTED, "[type]")

	create_glow()

	if (ishuman(parent))
		var/mob/living/carbon/human/human_parent = parent
		human_parent.apply_damage(RADIATION_IMMEDIATE_TOX_DAMAGE, TOX)
		START_PROCESSING(SSobj, src)

		start_burn_splotch_timer()

/datum/component/irradiated/RegisterWithParent()
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, .proc/on_clean)

/datum/component/irradiated/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT)

/datum/component/irradiated/Destroy(force, silent)
	var/atom/movable/parent_movable = parent
	if (istype(parent_movable))
		parent_movable.remove_filter("rad_glow")

	REMOVE_TRAIT(parent, TRAIT_RADIATION_PROTECTED, "[type]")

	deltimer(burn_splotch_timer_id)
	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/component/irradiated/process(delta_time)
	if (!ishuman(parent))
		return PROCESS_KILL

	var/mob/living/carbon/human/human_parent = parent
	if (human_parent.getToxLoss() == 0)
		qdel(src)
		return PROCESS_KILL

	if (should_halt_effects(parent))
		return

	process_tox_damage(human_parent, delta_time)

/datum/component/irradiated/proc/should_halt_effects(mob/living/carbon/human/target)
	if (IS_IN_STASIS(target))
		return TRUE

	if (COOLDOWN_FINISHED(src, clean_cooldown))
		return TRUE

	return FALSE

/datum/component/irradiated/proc/process_tox_damage(mob/living/carbon/human/target, delta_time)
	if (!COOLDOWN_FINISHED(src, last_tox_damage))
		return

	target.apply_damage(RADIATION_TOX_DAMAGE_PER_INTERVAL, TOX)
	COOLDOWN_START(src, last_tox_damage, RADIATION_TOX_INTERVAL)

/datum/component/irradiated/proc/start_burn_splotch_timer()
	addtimer(CALLBACK(src, .proc/give_burn_splotches), rand(RADIATION_BURN_INTERVAL_MIN, RADIATION_BURN_INTERVAL_MAX), TIMER_STOPPABLE)

/datum/component/irradiated/proc/give_burn_splotches()
	// This shouldn't be possible, but just in case.
	if (QDELETED(src))
		return

	start_burn_splotch_timer()

	var/mob/living/carbon/human/human_parent = parent

	if (should_halt_effects(parent))
		return

	var/obj/affected_limb = human_parent.get_bodypart(ran_zone())
	human_parent.visible_message(
		span_boldwarning("[human_parent]'s [affected_limb.name] bubbles unnaturally, then bursts into blisters!"),
		span_boldwarning("Your [affected_limb.name] bubbles unnaturally, then bursts into blisters!"),
	)

	if (human_parent.is_blind())
		to_chat(human_parent, span_boldwarning("Your [affected_limb.name] feels like it's bubbling, then burns like hell!"))

	human_parent.apply_damage(RADIATION_BURN_SPLOTCH_DAMAGE, BURN, affected_limb)
	playsound(
		human_parent,
		pick('sound/effects/wounds/sizzle1.ogg', 'sound/effects/wounds/sizzle2.ogg'),
		50,
		vary = TRUE,
	)

/datum/component/irradiated/proc/create_glow()
	var/atom/movable/parent_movable = parent
	if (!istype(parent_movable))
		return

	parent_movable.add_filter("rad_glow", 2, list("type" = "outline", "color" = "#39ff1430", "size" = 2))
	addtimer(CALLBACK(src, .proc/start_glow_loop, parent_movable), rand(0.1 SECONDS, 1.9 SECONDS)) // Things should look uneven

/datum/component/irradiated/proc/start_glow_loop(atom/movable/parent_movable)
	var/filter = parent_movable.get_filter("rad_glow")
	if (!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)

/datum/component/irradiated/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if (!(clean_types & CLEAN_TYPE_RADIATION))
		return

	if (isitem(parent))
		qdel(src)
		return COMPONENT_CLEANED

	COOLDOWN_START(src, clean_cooldown, RADIATION_CLEAN_IMMUNITY_TIME)

#undef RADIATION_BURN_SPLOTCH_DAMAGE
#undef RADIATION_BURN_INTERVAL_MIN
#undef RADIATION_BURN_INTERVAL_MAX
#undef RADIATION_CLEAN_IMMUNITY_TIME
#undef RADIATION_IMMEDIATE_TOX_DAMAGE
#undef RADIATION_TOX_INTERVAL
#undef RADIATION_TOX_DAMAGE_PER_INTERVAL
