/datum/status_effect/fire_handler
	duration = -1
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH //Custom code
	on_remove_on_mob_delete = TRUE
	tick_interval = 2 SECONDS
	/// Current amount of stacks we have
	var/stacks
	/// Maximum of stacks that we could possibly get
	var/stack_limit = 20
	/// What status effect types do we remove uppon being applied. These are just deleted without any deduction from our or their stacks when forced.
	var/list/enemy_types
	/// What status effect types do we merge into if they exist. Ignored when forced.
	var/list/merge_types
	/// What status effect types do we override if they exist. These are simply deleted when forced.
	var/list/override_types
	/// For how much firestacks does one our stack count
	var/stack_modifier = 1

/datum/status_effect/fire_handler/refresh(mob/living/new_owner, new_stacks, forced = FALSE)
	if(forced)
		set_stacks(new_stacks)
	else
		adjust_stacks(new_stacks)

/datum/status_effect/fire_handler/on_creation(mob/living/new_owner, new_stacks, forced = FALSE)
	. = ..()

	if(isbasicmob(owner))
		qdel(src)
		return

	if(isanimal(owner))
		var/mob/living/simple_animal/animal_owner = owner
		if(!animal_owner.flammable)
			qdel(src)
			return

	owner = new_owner
	set_stacks(new_stacks)

	for(var/enemy_type in enemy_types)
		var/datum/status_effect/fire_handler/enemy_effect = owner.has_status_effect(enemy_type)
		if(enemy_effect)
			if(forced)
				qdel(enemy_effect)
				continue

			var/cur_stacks = stacks
			adjust_stacks(-abs(enemy_effect.stacks * enemy_effect.stack_modifier / stack_modifier))
			enemy_effect.adjust_stacks(-abs(cur_stacks * stack_modifier / enemy_effect.stack_modifier))
			if(enemy_effect.stacks <= 0)
				qdel(enemy_effect)

			if(stacks <= 0)
				qdel(src)
				return

	if(!forced)
		var/list/merge_effects = list()
		for(var/merge_type in merge_types)
			var/datum/status_effect/fire_handler/merge_effect = owner.has_status_effect(merge_type)
			if(merge_effect)
				merge_effects += merge_effects

		if(LAZYLEN(merge_effects))
			for(var/datum/status_effect/fire_handler/merge_effect in merge_effects)
				merge_effect.adjust_stacks(stacks * stack_modifier / merge_effect.stack_modifier / LAZYLEN(merge_effects))
			qdel(src)
			return

	for(var/override_type in override_types)
		var/datum/status_effect/fire_handler/override_effect = owner.has_status_effect(override_type)
		if(override_effect)
			if(forced)
				qdel(override_effect)
				continue

			adjust_stacks(override_effect.stacks)
			qdel(override_effect)

/**
 * Setter and adjuster procs for firestacks
 *
 * Arguments:
 * - new_stacks
 *
 */

/datum/status_effect/fire_handler/proc/set_stacks(new_stacks)
	stacks = max(0, min(stack_limit, new_stacks))
	cache_stacks()

/datum/status_effect/fire_handler/proc/adjust_stacks(new_stacks)
	stacks = max(0, min(stack_limit, stacks + new_stacks))
	cache_stacks()

/**
 * Refresher for mob's fire_stacks
 */

/datum/status_effect/fire_handler/proc/cache_stacks()
	owner.fire_stacks = 0
	var/was_on_fire = owner.on_fire
	owner.on_fire = FALSE
	for(var/datum/status_effect/fire_handler/possible_fire in owner.status_effects)
		owner.fire_stacks += possible_fire.stacks * possible_fire.stack_modifier

		if(!istype(possible_fire, /datum/status_effect/fire_handler/fire_stacks))
			continue

		var/datum/status_effect/fire_handler/fire_stacks/our_fire = possible_fire
		if(our_fire.on_fire)
			owner.on_fire = TRUE

	if(was_on_fire && !owner.on_fire)
		owner.clear_alert(ALERT_FIRE)
	else if(!was_on_fire && owner.on_fire)
		owner.throw_alert(ALERT_FIRE, /atom/movable/screen/alert/fire)

/**
 * Used to update owner's effect overlay
 */

/datum/status_effect/fire_handler/proc/update_overlay()

/datum/status_effect/fire_handler/fire_stacks
	id = "fire_stacks" //fire_stacks and wet_stacks should have different IDs or else has_status_effect won't work
	remove_on_fullheal = TRUE

	enemy_types = list(/datum/status_effect/fire_handler/wet_stacks)
	stack_modifier = 1

	/// If we're on fire
	var/on_fire = FALSE
	/// A weakref to the mob light emitter
	var/datum/weakref/firelight_ref
	/// Type of mob light emitter we use when on fire
	var/firelight_type = /obj/effect/dummy/lighting_obj/moblight/fire
	/// Stores current fire overlay icon state, for optimisation purposes
	var/last_icon_state

/datum/status_effect/fire_handler/fire_stacks/tick(delta_time, times_fired)
	if(stacks <= 0)
		qdel(src)
		return TRUE

	if(!on_fire)
		return TRUE

	if(isanimal(owner))
		var/mob/living/simple_animal/animal_owner = owner
		adjust_stacks(animal_owner.fire_stack_removal_speed * delta_time)
	else if(iscyborg(owner))
		adjust_stacks(-0.55 * delta_time)
	else
		adjust_stacks(-0.05 * delta_time)

	if(stacks <= 0)
		qdel(src)
		return TRUE

	var/datum/gas_mixture/air = owner.loc.return_air()
	if(!air.gases[/datum/gas/oxygen] || air.gases[/datum/gas/oxygen][MOLES] < 1)
		qdel(src)
		return TRUE

	deal_damage(delta_time, times_fired)
	update_overlay()

/**
 * Proc that handles damage dealing and all special effects
 *
 * Arguments:
 * - delta_time
 * - times_fired
 *
 */

/datum/status_effect/fire_handler/fire_stacks/proc/deal_damage(delta_time, times_fired)
	owner.on_fire_stack(delta_time, times_fired, src)

	var/turf/location = get_turf(owner)
	location.hotspot_expose(700, 25 * delta_time, TRUE)

/**
 * Used to deal damage to humans and count their protection.
 *
 * Arguments:
 * - delta_time
 * - times_fired
 * - no_protection: When set to TRUE, fire will ignore any possible fire protection
 *
 */

/datum/status_effect/fire_handler/fire_stacks/proc/harm_human(delta_time, times_fired, no_protection = FALSE)
	var/mob/living/carbon/human/victim = owner
	var/thermal_protection = victim.get_thermal_protection()

	if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT && !no_protection)
		return

	if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT && !no_protection)
		victim.adjust_bodytemperature(5.5 * delta_time)
		return

	victim.adjust_bodytemperature((BODYTEMP_HEATING_MAX + (stacks * 12)) * 0.5 * delta_time)
	victim.add_mood_event("on_fire", /datum/mood_event/on_fire)
	victim.add_mob_memory(/datum/memory/was_burning)

/**
 * Handles mob ignition, should be the only way to set on_fire to TRUE
 *
 * Arguments:
 * - silent: When set to TRUE, no message is displayed
 *
 */

/datum/status_effect/fire_handler/fire_stacks/proc/ignite(silent = FALSE)
	if(HAS_TRAIT(owner, TRAIT_NOFIRE))
		return FALSE

	on_fire = TRUE
	if(!silent)
		owner.visible_message(span_warning("[owner] catches fire!"), span_userdanger("You're set on fire!"))

	if(firelight_type)
		firelight_ref = WEAKREF(new firelight_type(owner))

	SEND_SIGNAL(owner, COMSIG_LIVING_IGNITED, owner)
	cache_stacks()
	update_overlay()
	return TRUE

/**
 * Handles mob extinguishing, should be the only way to set on_fire to FALSE
 */

/datum/status_effect/fire_handler/fire_stacks/proc/extinguish()
	if(firelight_ref)
		qdel(firelight_ref)

	on_fire = FALSE
	owner.clear_mood_event("on_fire")
	SEND_SIGNAL(owner, COMSIG_LIVING_EXTINGUISHED, owner)
	cache_stacks()
	update_overlay()
	if(!iscarbon(owner))
		return

	for(var/obj/item/equipped in owner.get_equipped_items())
		equipped.wash(CLEAN_TYPE_ACID)
		equipped.extinguish()

/datum/status_effect/fire_handler/fire_stacks/on_remove()
	if(on_fire)
		extinguish()
	set_stacks(0)
	update_overlay()

/datum/status_effect/fire_handler/fire_stacks/update_overlay()
	last_icon_state = owner.update_fire_overlay(stacks, on_fire, last_icon_state)

/datum/status_effect/fire_handler/fire_stacks/on_apply()
	. = ..()
	update_overlay()

/datum/status_effect/fire_handler/wet_stacks
	id = "wet_stacks"

	enemy_types = list(/datum/status_effect/fire_handler/fire_stacks)
	stack_modifier = -1

/datum/status_effect/fire_handler/wet_stacks/tick(delta_time)
	adjust_stacks(-0.5 * delta_time)
	if(stacks <= 0)
		qdel(src)
