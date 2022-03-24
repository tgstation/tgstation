/datum/action/cooldown/spell/fire_sworn
	name = "Oath of Flame"
	desc = "For a minute, you will passively create a ring of fire around you."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "fire_ring"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 70 SECONDS

	invocation = "FL'MS"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The radius of the fire ring
	var/fire_radius = 1
	/// How long it lasts
	var/duration = 1 MINUTES
	///Determines if you get the fire ring effect
	var/current_timer

/datum/action/cooldown/spell/fire_sworn/Remove(mob/living/remove_from)
	if(current_timer)
		end_cast(remove_from)
	return ..()

/datum/action/cooldown/spell/fire_sworn/cast(atom/cast_on)
	. = ..()
	new /obj/effect/fire_ring(owner, fire_radius)

/datum/action/cooldown/spell/fire_sworn/after_cast(atom/cast_on)
	. = ..()
	if(current_timer)
		deltimer(current_timer)
	current_timer = addtimer(CALLBACK(src, .proc/end_cast, owner), duration, TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/action/cooldown/spell/fire_sworn/proc/end_cast(atom/remove_from)
	var/obj/effect/fire_ring/to_delete = locate() in remove_from
	qdel(to_delete)
	current_timer = null

// An effect that puts a ring of fire around the mob it's located in.
// Moved off of the fire_sworn spell due to cooldown actions processing on their own.
/obj/effect/fire_ring // MELBERT TODO TEST THIS
	/// Radius of the fire ring.
	var/ring_radius = 1

/obj/effect/fire_ring/Initialize(mapload, ring_radus)
	. = ..()
	src.ring_radius = ring_radius
	START_PROCESSING(SSprocessing, src)

/obj/effect/fire_ring/Destroy(force)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/effect/fire_ring/process(delta_time)
	var/mob/living/owner = loc
	if(QDELETED(owner) || owner.stat == DEAD)
		qdel(src)
		return PROCESS_KILL
	if(!isturf(owner.loc))
		return

	for(var/turf/nearby_turf as anything in RANGE_TURFS(1, owner))
		new /obj/effect/hotspot(nearby_turf)
		nearby_turf.hotspot_expose(750, 25 * delta_time, 1)
		for(var/mob/living/fried_living in nearby_turf.contents - owner)
			fried_living.apply_damage(2.5 * delta_time, BURN)

/datum/action/cooldown/spell/fire_cascade
	name = "Fire Cascade"
	desc = "Heats the air around you."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "fire_ring"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "C'SC'DE"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The radius the flames will go around the caster.
	var/flame_radius = 4

/datum/action/cooldown/spell/fire_cascade/cast(atom/cast_on)
	. = ..()
	INVOKE_ASYNC(src, .proc/fire_cascade, cast_on, flame_radius)

/// Spreads a huge wave of fire in a radius around us, staggered between levels
/datum/action/cooldown/spell/fire_cascade/proc/fire_cascade(atom/centre, flame_radius = 1)
	for(var/i in 0 to flame_radius)
		for(var/turf/nearby_turf as anything in spiral_range_turfs(i + 1, centre))
			new /obj/effect/hotspot(nearby_turf)
			nearby_turf.hotspot_expose(750, 50, 1)
			for(var/mob/living/fried_living in nearby_turf.contents - centre)
				fried_living.apply_damage(5, BURN)

		stoplag(0.3 SECONDS)

/datum/action/cooldown/spell/fire_cascade/big
	flame_radius = 6

// Currently unused - releases streams of fire around the caster.
/datum/action/cooldown/spell/pointed/ash_beams
	name = "Nightwatcher's Rite"
	desc = "A powerful spell that releases five streams of eldritch fire towards the target."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "flames"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 300

	invocation = "F'RE"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	/// The length of the flame line spit out.
	var/flame_line_length = 15

/datum/action/cooldown/spell/pointed/ash_beams/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/ash_beams/cast(atom/target)
	. = ..()
	var/static/list/offsets = list(-25, -10, 0, 10, 25)
	for(var/offset in offsets)
		INVOKE_ASYNC(src, .proc/fire_line, user, line_target(offset, range, target, owner))

/datum/action/cooldown/spell/pointed/ash_beams/proc/line_target(offset, range, atom/at, atom/user)
	if(!at)
		return
	var/angle = ATAN2(at.x - user.x, at.y - user.y) + offset
	var/turf/T = get_turf(user)
	for(var/i in 1 to range)
		var/turf/check = locate(user.x + cos(angle) * i, user.y + sin(angle) * i, user.z)
		if(!check)
			break
		T = check
	return (get_line(user, T) - get_turf(user))

/datum/action/cooldown/spell/pointed/ash_beams/proc/fire_line(atom/source, list/turfs)
	var/list/hit_list = list()
	for(var/turf/T in turfs)
		if(istype(T, /turf/closed))
			break

		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message(span_danger("The spell bounces off of [L]!"),span_danger("The spell bounces off of you!"))
				continue
			if(L in hit_list || L == source)
				continue
			hit_list += L
			L.adjustFireLoss(20)
			to_chat(L, span_userdanger("You're hit by [source]'s eldritch flames!"))

		new /obj/effect/hotspot(T)
		T.hotspot_expose(700,50,1)
		// deals damage to mechs
		for(var/obj/vehicle/sealed/mecha/M in T.contents)
			if(M in hit_list)
				continue
			hit_list += M
			M.take_damage(45, BURN, MELEE, 1)
		sleep(1.5)
