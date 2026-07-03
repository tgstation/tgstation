#define COOLDOWN_DODGE_SHIFT "dodge_shift_cooldown"

/*
 * Element for dodge with visual effects
 * On successful dodge, shifts the puppet pixel-wise with blur/mirage effect
 */

/datum/element/dodge_shift
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// Dodge chance (0-100)
	var/dodge_chance = 30
	/// Shift distance in pixels
	var/shift_distance = 24
	/// Time in deciseconds before return
	var/return_delay = 0.4 SECONDS
	/// Shift animation time
	var/shift_time = 0.15 SECONDS
	/// Return animation time
	var/return_time = 0.25 SECONDS
	/// Cooldown between dodges
	var/cooldown_time = 2 SECONDS
	/// Stamina cost per dodge
	var/stamina_cost = 0
	/// Attack types that can be dodged (bitflags)
	var/dodge_attack_types = MELEE_ATTACK | UNARMED_ATTACK | THROWN_PROJECTILE_ATTACK
	/// Sound on dodge
	var/dodge_sound = 'sound/items/weapons/punchmiss.ogg'
	/// Whether to create afterimage
	var/create_afterimage = TRUE
	/// Afterimage transparency
	var/afterimage_alpha = 128
	/// Afterimage lifetime
	var/afterimage_duration = 0.5 SECONDS

	/// Stores original positions for mobs currently dodging: list(mob = list(x, y))
	var/list/original_positions = list()
	/// Stores active return timers for cancellation: list(mob = timer_id)
	var/list/return_timers = list()

/datum/element/dodge_shift/Attach(
	datum/target,
	dodge_chance,
	shift_distance,
	return_delay,
	cooldown_time,
	dodge_attack_types,
)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	if(!isnull(dodge_chance))
		src.dodge_chance = dodge_chance
	if(!isnull(shift_distance))
		src.shift_distance = shift_distance
	if(!isnull(return_delay))
		src.return_delay = return_delay
	if(!isnull(cooldown_time))
		src.cooldown_time = cooldown_time
	if(!isnull(dodge_attack_types))
		src.dodge_attack_types = dodge_attack_types

	RegisterSignal(target, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_check_block))
	// Projectiles require a separate signal since COMSIG_LIVING_CHECK_BLOCK doesn't catch them
	if(dodge_attack_types & (PROJECTILE_ATTACK | THROWN_PROJECTILE_ATTACK))
		RegisterSignal(target, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(on_pre_bullet_act))

/datum/element/dodge_shift/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_CHECK_BLOCK, COMSIG_ATOM_PRE_BULLET_ACT))
	// Clean up any stored position data
	original_positions -= target
	if(return_timers[target])
		deltimer(return_timers[target])
		return_timers -= target
	return ..()

/datum/element/dodge_shift/proc/on_check_block(mob/living/source, atom/hit_by, damage, attack_text, attack_type, armour_penetration, damage_type)
	SIGNAL_HANDLER

	if(!(attack_type & dodge_attack_types))
		return FAILED_BLOCK

	if(cooldown_time > 0 && !TIMER_COOLDOWN_FINISHED(source, COOLDOWN_DODGE_SHIFT))
		return FAILED_BLOCK

	if(!prob(dodge_chance))
		return FAILED_BLOCK

	if(!(source.mobility_flags & MOBILITY_MOVE))
		return FAILED_BLOCK

	// Check if we have enough stamina to dodge
	if(stamina_cost > 0 && (source.maxHealth - (source.get_stamina_loss() + stamina_cost)) <= source.crit_threshold)
		return FAILED_BLOCK

	perform_dodge(source, hit_by, attack_text)

	if(cooldown_time > 0)
		TIMER_COOLDOWN_START(source, COOLDOWN_DODGE_SHIFT, cooldown_time)

	return SUCCESSFUL_BLOCK

/// Projectile handler (COMSIG_ATOM_PRE_BULLET_ACT) - fires BEFORE bullet_act allowing complete avoidance
/datum/element/dodge_shift/proc/on_pre_bullet_act(mob/living/source, obj/projectile/hitting_projectile, def_zone, piercing_hit)
	SIGNAL_HANDLER

	if(!(dodge_attack_types & PROJECTILE_ATTACK))
		return NONE

	if(cooldown_time > 0 && !TIMER_COOLDOWN_FINISHED(source, COOLDOWN_DODGE_SHIFT))
		return NONE

	if(!prob(dodge_chance))
		return NONE

	if(!(source.mobility_flags & MOBILITY_MOVE))
		return NONE

	// Check if we have enough stamina to dodge
	if(stamina_cost > 0 && (source.maxHealth - (source.get_stamina_loss() + stamina_cost)) <= source.crit_threshold)
		return NONE

	perform_dodge(source, hitting_projectile, hitting_projectile.name)

	if(cooldown_time > 0)
		TIMER_COOLDOWN_START(source, COOLDOWN_DODGE_SHIFT, cooldown_time)

	// COMPONENT_BULLET_PIERCED means the bullet "passed through" - essentially a dodge
	return COMPONENT_BULLET_PIERCED

/datum/element/dodge_shift/proc/perform_dodge(mob/living/dodger, atom/hit_by, attack_text)
	// Spend stamina for the dodge
	if(stamina_cost > 0)
		dodger.adjust_stamina_loss(stamina_cost)

	var/dodge_dir = get_dodge_direction(dodger, hit_by)

	var/shift_x = 0
	var/shift_y = 0

	if(dodge_dir & NORTH)
		shift_y = shift_distance
	else if(dodge_dir & SOUTH)
		shift_y = -shift_distance

	if(dodge_dir & EAST)
		shift_x = shift_distance
	else if(dodge_dir & WEST)
		shift_x = -shift_distance

	// If direction undefined, dodge in random direction
	if(!shift_x && !shift_y)
		shift_x = pick(-shift_distance, shift_distance)
		if(prob(50))
			shift_y = pick(-shift_distance, shift_distance)
			shift_x = 0

	if(create_afterimage)
		create_afterimage_effect(dodger)

	var/blur_x = shift_x > 0 ? 2 : (shift_x < 0 ? -2 : 0)
	var/blur_y = shift_y > 0 ? 2 : (shift_y < 0 ? -2 : 0)
	dodger.add_filter("dodge_blur", 1, motion_blur_filter(x = blur_x, y = blur_y))

	// Store original position only if not already dodging
	// This ensures we always return to the TRUE original position
	var/original_pixel_x
	var/original_pixel_y

	if(original_positions[dodger])
		// Already dodging - use stored original position
		var/list/stored_pos = original_positions[dodger]
		original_pixel_x = stored_pos[1]
		original_pixel_y = stored_pos[2]
	else
		// First dodge - store current position as original
		original_pixel_x = dodger.pixel_x
		original_pixel_y = dodger.pixel_y
		original_positions[dodger] = list(original_pixel_x, original_pixel_y)

	// Cancel any existing return timer to prevent conflicts
	if(return_timers[dodger])
		deltimer(return_timers[dodger])
		return_timers[dodger] = null

	animate(dodger, pixel_x = original_pixel_x + shift_x, pixel_y = original_pixel_y + shift_y, time = shift_time, easing = CIRCULAR_EASING | EASE_OUT)

	dodger.visible_message(
		span_danger("[dodger] dodges [attack_text]!"),
		span_userdanger("You dodge [attack_text]!"),
	)

	if(dodge_sound)
		playsound(dodger, dodge_sound, 25, TRUE, -1)

	// Store the timer ID for potential cancellation
	return_timers[dodger] = addtimer(CALLBACK(src, PROC_REF(return_to_position), dodger, original_pixel_x, original_pixel_y), return_delay, TIMER_STOPPABLE)

/datum/element/dodge_shift/proc/get_dodge_direction(mob/living/dodger, atom/attacker)
	if(!attacker)
		return pick(GLOB.cardinals)

	// Dodge perpendicular to attack direction
	var/attack_dir = get_dir(attacker, dodger)

	if(attack_dir & (NORTH|SOUTH))
		return pick(EAST, WEST)
	else if(attack_dir & (EAST|WEST))
		return pick(NORTH, SOUTH)
	else
		// For diagonal attacks
		return pick(GLOB.cardinals)

/datum/element/dodge_shift/proc/return_to_position(mob/living/dodger, original_x, original_y)
	if(QDELETED(dodger))
		return

	// Clear the stored position - dodge sequence complete
	original_positions -= dodger
	return_timers -= dodger

	// Force snap to exact original position to ensure accuracy
	dodger.pixel_x = original_x
	dodger.pixel_y = original_y

	// Small visual animation for smooth return feel
	animate(dodger, pixel_x = original_x, pixel_y = original_y, time = return_time, easing = CIRCULAR_EASING | EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(remove_blur_filter), dodger), return_time)

/datum/element/dodge_shift/proc/remove_blur_filter(mob/living/dodger)
	if(QDELETED(dodger))
		return
	dodger.remove_filter("dodge_blur")

/datum/element/dodge_shift/proc/create_afterimage_effect(mob/living/dodger)
	var/obj/effect/temp_visual/dodge_afterimage/afterimage = new(get_turf(dodger))
	afterimage.copy_appearance_from(dodger)
	afterimage.pixel_x = dodger.pixel_x
	afterimage.pixel_y = dodger.pixel_y
	afterimage.alpha = afterimage_alpha
	afterimage.duration = afterimage_duration

	QDEL_IN(afterimage, afterimage_duration)

/*
 * Temporary visual effect - afterimage (mirage)
 */
/obj/effect/temp_visual/dodge_afterimage
	name = "afterimage"
	desc = "A ghostly trail from rapid movement."
	duration = 0.5 SECONDS
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/dodge_afterimage/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = CIRCULAR_EASING | EASE_IN)

/obj/effect/temp_visual/dodge_afterimage/proc/copy_appearance_from(mob/living/source)
	if(!source)
		return

	appearance = source.appearance
	// Remove effects unnecessary for mirage
	overlays.Cut()
	underlays.Cut()

	color = list(
		1, 0, 0,
		0, 0.8, 0,
		0, 0, 1,
		0, 0, 0
	)

/*
 * Predefined dodge element variants
 */

/// You have 7 minutes
/datum/element/dodge_shift/ultimate
	dodge_chance = 100
	shift_distance = 24
	return_delay = 0.3 SECONDS
	cooldown_time = 0
	stamina_cost = 5
	dodge_attack_types = MELEE_ATTACK | UNARMED_ATTACK | PROJECTILE_ATTACK | THROWN_PROJECTILE_ATTACK | LEAP_ATTACK | OVERWHELMING_ATTACK
	create_afterimage = TRUE
	afterimage_alpha = 100

/// Projectile dodge (requires separate handling via COMSIG_ATOM_PRE_BULLET_ACT)
/datum/element/dodge_shift/projectile
	dodge_chance = 25
	dodge_attack_types = PROJECTILE_ATTACK | THROWN_PROJECTILE_ATTACK
	cooldown_time = 3 SECONDS
