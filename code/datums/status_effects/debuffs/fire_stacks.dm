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
	var/list/enemy_types = list()
	/// What status effect types do we merge into if they exist. Ignored when forced.
	var/list/merge_types = list()
	/// What status effect types do we override if they exist. These are simply deleted when forced.
	var/list/override_types = list()
	/// For how much firestacks does one our stack count
	var/stack_modifier = 1

/datum/status_effect/fire_handler/refresh(mob/living/new_owner, new_stacks, forced = FALSE)
	if(forced)
		set_stacks(new_stacks)
	else
		adjust_stacks(new_stacks)

/datum/status_effect/fire_handler/on_creation(mob/living/new_owner, new_stacks, forced = FALSE)
	if(isanimal(owner))
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
			adjust_stacks(-enemy_effect.stacks * enemy_effect.stack_modifier / stack_modifier)
			enemy_effect.adjust_stacks(-cur_stacks * stack_modifier / enemy_effect.stack_modifier)
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

	for(var/override_type in override_types)
		var/datum/status_effect/fire_handler/override_effect = owner.has_status_effect(override_type)
		if(override_effect)
			if(forced)
				qdel(override_effect)
				continue

			adjust_stacks(override_effect.stacks)
			qdel(override_effect)

	. = ..()
	cache_stacks()

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
	owner.clear_alert(ALERT_FIRE)
	for(var/fire_type in subtypesof(/datum/status_effect/fire_handler))
		var/datum/status_effect/fire_handler/possible_fire = owner.has_status_effect(fire_type)
		if(possible_fire)
			owner.fire_stacks += possible_fire.stacks * possible_fire.stack_modifier
			if(istype(possible_fire))
				var/datum/status_effect/fire_handler/fire_stacks/our_fire = possible_fire
				if(our_fire.on_fire)
					owner.on_fire = TRUE
					owner.throw_alert(ALERT_FIRE, our_fire.fire_alert_type)

/**
 * Used to update owner's effect overlay
 */

/datum/status_effect/fire_handler/proc/update_overlay()

/datum/status_effect/fire_handler/fire_stacks
	id = "fire_stacks" //fire_stacks and wet_stacks should have different IDs or else has_status_effect won't work

	enemy_types = list(/datum/status_effect/fire_handler/wet_stacks)
	stack_modifier = 1

	/// If we're on fire
	var/on_fire = FALSE
	/// Type for our alert
	var/fire_alert_type = /atom/movable/screen/alert/fire
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

	if(!on_fire || isanimal(owner))
		return TRUE

	adjust_stacks(-0.05 * delta_time)

	if(iscyborg(owner))
		adjust_stacks(-0.5 * delta_time)

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

/datum/status_effect/fire_handler/proc/deal_damage(delta_time, times_fired)
	if(ishuman(owner))
		var/mob/living/carbon/human/victim = owner
		SEND_SIGNAL(victim, COMSIG_HUMAN_BURNING)
		burn_stuff(delta_time, times_fired)
		var/no_protection = FALSE
		if(victim.dna && victim.dna.species)
			no_protection = victim.dna.species.handle_fire(victim, delta_time, times_fired, no_protection)
		harm_human(delta_time, times_fired, no_protection)

	if(isalien(owner))
		owner.adjust_bodytemperature(BODYTEMP_HEATING_MAX * 0.5 * delta_time)

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

/datum/status_effect/fire_handler/proc/harm_human(delta_time, times_fired, no_protection = FALSE)
	var/mob/living/carbon/human/victim = owner
	var/thermal_protection = victim.get_thermal_protection()

	if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT && !no_protection)
		return

	if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT && !no_protection)
		victim.adjust_bodytemperature(5.5 * delta_time)
	else
		victim.adjust_bodytemperature((BODYTEMP_HEATING_MAX + (stacks * 12)) * 0.5 * delta_time)
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)
		victim.mind?.add_memory(MEMORY_FIRE, list(DETAIL_PROTAGONIST = victim), story_value = STORY_VALUE_OKAY)

/**
 * Handles clothing burning
 *
 * Arguments:
 * - delta_time
 * - times_fired
 *
 */

/datum/status_effect/fire_handler/proc/burn_stuff(delta_time, times_fired)
	var/mob/living/carbon/human/victim = owner
	//the fire tries to damage the exposed clothes and items
	var/list/burning_items = list()
	var/obscured = victim.check_obscured_slots(TRUE)
	//HEAD//

	if(victim.glasses && !(obscured & ITEM_SLOT_EYES))
		burning_items += victim.glasses
	if(victim.wear_mask && !(obscured & ITEM_SLOT_MASK))
		burning_items += victim.wear_mask
	if(victim.wear_neck && !(obscured & ITEM_SLOT_NECK))
		burning_items += victim.wear_neck
	if(victim.ears && !(obscured & ITEM_SLOT_EARS))
		burning_items += victim.ears
	if(victim.head)
		burning_items += victim.head

	//CHEST//
	if(victim.w_uniform && !(obscured & ITEM_SLOT_ICLOTHING))
		burning_items += victim.w_uniform
	if(victim.wear_suit)
		burning_items += victim.wear_suit

	//ARMS & HANDS//
	var/obj/item/clothing/arm_clothes = null
	if(victim.gloves && !(obscured & ITEM_SLOT_GLOVES))
		arm_clothes = victim.gloves
	else if(victim.wear_suit && ((victim.wear_suit.body_parts_covered & HANDS) || (victim.wear_suit.body_parts_covered & ARMS)))
		arm_clothes = victim.wear_suit
	else if(victim.w_uniform && ((victim.w_uniform.body_parts_covered & HANDS) || (victim.w_uniform.body_parts_covered & ARMS)))
		arm_clothes = victim.w_uniform
	if(arm_clothes)
		burning_items |= arm_clothes

	//LEGS & FEET//
	var/obj/item/clothing/leg_clothes = null
	if(victim.shoes && !(obscured & ITEM_SLOT_FEET))
		leg_clothes = victim.shoes
	else if(victim.wear_suit && ((victim.wear_suit.body_parts_covered & FEET) || (victim.wear_suit.body_parts_covered & LEGS)))
		leg_clothes = victim.wear_suit
	else if(victim.w_uniform && ((victim.w_uniform.body_parts_covered & FEET) || (victim.w_uniform.body_parts_covered & LEGS)))
		leg_clothes = victim.w_uniform
	if(leg_clothes)
		burning_items |= leg_clothes

	for(var/obj/item/burning in burning_items)
		burning.fire_act((stacks * 25 * delta_time)) //damage taken is reduced to 2% of this value by fire_act()

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

/**
 * Handles mob extinguishing, should be the only way to set on_fire to FALSE
 */

/datum/status_effect/fire_handler/fire_stacks/proc/extinguish()
	if(firelight_ref)
		var/atom/firelight = firelight_ref.resolve()
		if(firelight && !QDELETED(firelight))
			qdel(firelight)

	on_fire = FALSE
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "on_fire")
	SEND_SIGNAL(owner, COMSIG_LIVING_EXTINGUISHED, owner)
	cache_stacks()
	update_overlay()

/datum/status_effect/fire_handler/fire_stacks/on_remove()
	if(on_fire)
		extinguish()
	set_stacks(0)
	update_overlay()

/datum/status_effect/fire_handler/fire_stacks/update_overlay()
	if(iscyborg(owner))
		var/fire_icon = "generic_burning[get_special_icon()]"
		var/mutable_appearance/fire_overlay = mutable_appearance('icons/mob/onfire.dmi', fire_icon)
		if(stacks && on_fire)
			if(last_icon_state != fire_icon)
				owner.add_overlay(fire_overlay)
				last_icon_state = fire_icon
		else
			if(last_icon_state)
				owner.cut_overlay(fire_overlay)
				last_icon_state = null
		return TRUE

	if(iscarbon(owner))
		var/mob/living/carbon/victim = owner
		var/fire_icon = "generic_burning[get_special_icon()]"
		if(ishuman(victim) && stacks > HUMAN_FIRE_STACK_ICON_NUM)
			var/mob/living/carbon/human/human_victim = victim
			if(human_victim.dna && human_victim.dna.species)
				fire_icon = "[human_victim.dna.species.fire_overlay][get_special_icon()]"
			else
				fire_icon = "human_burning[get_special_icon()]"

		if((stacks > 0 && on_fire) || HAS_TRAIT(victim, TRAIT_PERMANENTLY_ONFIRE))
			if(fire_icon == last_icon_state)
				return TRUE

			victim.remove_overlay(FIRE_LAYER)
			var/mutable_appearance/new_fire_overlay = mutable_appearance('icons/mob/onfire.dmi', fire_icon, -FIRE_LAYER)
			new_fire_overlay.appearance_flags = RESET_COLOR
			victim.overlays_standing[FIRE_LAYER] = new_fire_overlay
			victim.apply_overlay(FIRE_LAYER)
			last_icon_state = fire_icon

		else if(last_icon_state)
			victim.remove_overlay(FIRE_LAYER)
			victim.apply_overlay(FIRE_LAYER)
			last_icon_state = null

		return TRUE
	return FALSE

/**
 * Should return a suffix for custom fire icons, made for inheritance reasons
 */

/datum/status_effect/fire_handler/fire_stacks/proc/get_special_icon()
	return

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
