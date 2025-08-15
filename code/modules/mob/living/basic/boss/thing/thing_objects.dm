/obj/structure/thing_boss_spike
	name = "blades"
	desc = "A sharp flurry of blades that have erupted from the ground."
	icon_state = "thingspike"
	density = FALSE //so ai considers it
	anchored = TRUE
	max_integrity = 1 // 1 hit
	/// time before we fall apart
	var/expiry_time = 10 SECONDS

/obj/structure/thing_boss_spike/Initialize(mapload)
	. = ..()
	var/turf/our_turf = get_turf(src)
#ifndef UNIT_TESTS //just in case
	new /obj/effect/temp_visual/mook_dust(loc)
#endif
	var/hit_someone = FALSE
	for(var/atom/movable/potential_target as anything in our_turf)
		if (ismegafauna(potential_target) || potential_target == src)
			continue
		var/mob/living/living_victim = potential_target
		if(isliving(living_victim))
			hit_someone = TRUE
			living_victim.apply_damage(40, damagetype = BRUTE, sharpness = SHARP_POINTY, wound_bonus = -10)
		else if(potential_target.uses_integrity && !(potential_target.resistance_flags & INDESTRUCTIBLE) && initial(potential_target.density) && !HAS_TRAIT(potential_target, TRAIT_UNDERFLOOR))
			potential_target.take_damage(100, BRUTE)
	if (hit_someone)
		expiry_time /= 2
		playsound(src, 'sound/items/weapons/slice.ogg', vol = 50, vary = TRUE, pressure_affected = FALSE)
	else
		playsound(src, 'sound/misc/splort.ogg', vol = 25, vary = TRUE, pressure_affected = FALSE)

	QDEL_IN(src, expiry_time)

/obj/structure/thing_boss_spike/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(damage_amount)
		playsound(src, 'sound/effects/blob/blobattack.ogg', 50, TRUE)
	else
		playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)

/obj/structure/thing_boss_spike/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!istype(mover, /mob/living/basic/boss/thing))
		return FALSE

/obj/structure/thing_boss_spike/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!istype(pass_info.requester_ref?.resolve(), /mob/living/basic/boss/thing))
		return FALSE
	return ..()

/obj/effect/temp_visual/telegraphing/exclamation
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "exclamation"
	duration = 1 SECONDS

/obj/effect/temp_visual/telegraphing/exclamation/Initialize(mapload, duration)
	if(!isnull(duration))
		src.duration = duration
	return ..()

/obj/effect/temp_visual/telegraphing/exclamation/following/Initialize(mapload, duration, obj/following)
	. = ..()
	if(isnull(following))
		return INITIALIZE_HINT_QDEL
	glide_size = following.glide_size
	RegisterSignal(following, COMSIG_MOVABLE_MOVED, PROC_REF(follow))

///called when the thing we're following moves
/obj/effect/temp_visual/telegraphing/exclamation/following/proc/follow(datum/source)
	SIGNAL_HANDLER
	forceMove(get_turf(source))

/obj/effect/temp_visual/telegraphing/exclamation/animated
	alpha = 0

/obj/effect/temp_visual/telegraphing/exclamation/animated/Initialize(mapload)
	. = ..()
	transform = matrix()*2
	animate(src, alpha = 255, transform = matrix(), time = duration/3)

/obj/effect/temp_visual/telegraphing/big
	icon = 'icons/mob/telegraphing/telegraph_96x96.dmi'
	icon_state = "target_largebox"
	pixel_x = -32
	pixel_y = -32
	color = COLOR_RED
	duration = 2 SECONDS

/obj/effect/temp_visual/incoming_thing_acid
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "toxin"
	name = "acid"
	desc = "Get out of the way!"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	randomdir = FALSE
	duration = 0.9 SECONDS
	pixel_z = 270

/obj/effect/temp_visual/incoming_thing_acid/Initialize(mapload)
	. = ..()
	animate(src, pixel_z = 0, time = duration)
	addtimer(CALLBACK(src, PROC_REF(make_acid)), 0.85 SECONDS)

/obj/effect/temp_visual/incoming_thing_acid/proc/make_acid()
	for(var/turf/open/open in RANGE_TURFS(1, loc))
		new /obj/effect/thing_acid(open)

/obj/effect/thing_acid
	name = "stomach acid"
	icon = 'icons/effects/acid.dmi'
	icon_state = "default"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	anchored = TRUE
	/// how long does the acid exist for
	var/duration_time = 5 SECONDS

/obj/effect/thing_acid/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	QDEL_IN(src, duration_time)

/obj/effect/thing_acid/proc/on_entered(datum/source, mob/living/victim)
	SIGNAL_HANDLER
	if(!istype(victim) || ismegafauna(victim))
		return
	for(var/zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/blocked = victim.run_armor_check(zone, ACID)
		victim.apply_damage(25, BURN, def_zone = zone, blocked = blocked)
	to_chat(victim, span_userdanger("You are burnt by the acid!"))
	playsound(victim, 'sound/effects/wounds/sizzle1.ogg', vol = 50, vary = TRUE)
	qdel(src)

/obj/item/keycard/thing_boss
	name = "Storage Room 2 Keycard"
	desc = "A fancy keycard for storage room 2."
	color = COLOR_PALE_GREEN
	puzzle_id = "thingbosslootroom"
