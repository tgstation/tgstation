#define REGENERATION_FILTER "healing_glow"

/**
 * # Ground sinking component (basicly only for garden gnomes ever at this point)
 *
 * A basic mob with this component will sink into the ground, once sinked into the ground it will regenerate and
 * might gain damage resistence. Can be combined with caltrop.
 */
/datum/component/ground_sinking
	/// The icon state of the parent
	var/target_icon_state
	/// You will only sink if you haven't been walking for this many seconds
	var/ground_sinking_delay
	/// The speed at which the mob will sink
	var/sink_speed
	/// If we will heal once we are sinked
	var/heal_when_sinked
	/// Health to regenerate per second
	var/health_per_second
	/// Outline colour of the regeneration
	var/outline_colour
	/// Our damage_coeffs when we are sinked
	var/damage_res_sinked
	/// If we sinked into the ground right now
	var/sinked = FALSE
	/// If we sinking into the ground right now
	var/is_sinking = FALSE
	/// How far we have sinked
	var/sink_count = 0
	/// When this timer completes we start sinking
	var/ground_sinking_start_timer

/datum/component/ground_sinking/Initialize(target_icon_state,
			ground_sinking_delay = 8 SECONDS,
			sink_speed = 1 SECONDS,
			heal_when_sinked = TRUE,
			health_per_second = 1,
			outline_colour = COLOR_PALE_GREEN,
			damage_res_sinked = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1))

	if (!isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE

	src.target_icon_state = target_icon_state
	src.ground_sinking_delay = ground_sinking_delay
	src.sink_speed = sink_speed
	src.heal_when_sinked = heal_when_sinked
	src.health_per_second = health_per_second
	src.outline_colour = outline_colour
	src.damage_res_sinked = damage_res_sinked

/datum/component/ground_sinking/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/component/ground_sinking/UnregisterFromParent()
	if(sinked || is_sinking)
		unsink()
	if(ground_sinking_start_timer)
		deltimer(ground_sinking_start_timer)
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/ground_sinking/Destroy(force, silent)
	if(sinked || is_sinking)
		unsink()
	. = ..()
	if(ground_sinking_start_timer)
		deltimer(ground_sinking_start_timer)

/// When you take damage, reset the cooldown and start processing
/datum/component/ground_sinking/proc/on_moved(mob/living/basic/living_target, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	if(sinked || is_sinking)
		unsink()
	if(ground_sinking_start_timer)
		deltimer(ground_sinking_start_timer)
	ground_sinking_start_timer = addtimer(CALLBACK(src, PROC_REF(start_sinking), living_target), ground_sinking_delay, TIMER_STOPPABLE)

/// Start processing health regeneration, and show animation if provided
/datum/component/ground_sinking/proc/start_sinking(mob/living/basic/living_target)
	if(!sinked || is_sinking)
		is_sinking = TRUE
		INVOKE_ASYNC(src, PROC_REF(sink_once), living_target)

/datum/component/ground_sinking/proc/sink_once(mob/living/basic/living_target)
	living_target.visible_message(span_notice("[living_target] starts sinking into the ground!"))
	for(var/i in 1 to 3)
		if(do_after(living_target, sink_speed, living_target))
			sink_count += 1
			living_target.icon_state = "[target_icon_state]_burried_[sink_count]"
	sink_count = 0
	is_sinked(living_target)

/datum/component/ground_sinking/proc/is_sinked(mob/living/basic/living_target)
	sinked = TRUE
	is_sinking = FALSE
	living_target.density = FALSE
	living_target.damage_coeff = damage_res_sinked
	if(heal_when_sinked)
		start_regenerating()

/datum/component/ground_sinking/proc/unsink()
	var/mob/living/basic/living_target = parent
	if(sinked && heal_when_sinked)
		stop_regenerating()
	living_target.icon_state = target_icon_state
	living_target.damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	living_target.density = TRUE
	sinked = FALSE

/datum/component/ground_sinking/proc/start_regenerating()
	var/mob/living/basic/living_parent = parent
	if (living_parent.stat == DEAD)
		return
	if (living_parent.health == living_parent.maxHealth)
		return
	living_parent.visible_message(span_notice("[living_parent]'s wounds begin to knit closed!"))
	START_PROCESSING(SSobj, src)
	if (!outline_colour)
		return
	living_parent.add_filter(REGENERATION_FILTER, 2, list("type" = "outline", "color" = outline_colour, "alpha" = 0, "size" = 1))
	var/filter = living_parent.get_filter(REGENERATION_FILTER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)

/datum/component/ground_sinking/proc/stop_regenerating()
	STOP_PROCESSING(SSobj, src)
	var/mob/living/basic/living_parent = parent
	var/filter = living_parent.get_filter(REGENERATION_FILTER)
	animate(filter)
	living_parent.remove_filter(REGENERATION_FILTER)

/datum/component/ground_sinking/process(delta_time = SSMOBS_DT)
	var/mob/living/basic/living_parent = parent
	if (living_parent.stat == DEAD)
		stop_regenerating()
		return
	if (living_parent.health == living_parent.maxHealth)
		stop_regenerating()
		return
	living_parent.heal_overall_damage(health_per_second * delta_time)

#undef REGENERATION_FILTER
