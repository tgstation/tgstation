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
			living_victim.apply_damage(40, damagetype = BRUTE, sharpness = SHARP_POINTY)
		else if(potential_target.uses_integrity && !(potential_target.resistance_flags & INDESTRUCTIBLE) && !isitem(potential_target) && !HAS_TRAIT(potential_target, TRAIT_UNDERFLOOR))
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
	if(!istype(pass_info.caller_ref?.resolve(), /mob/living/basic/boss/thing))
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

// ruin stuff

/obj/structure/thing_boss_phase_depleter
	name = "Molecular Accelerator"
	desc = "Weird-ass lab equipment."
	icon_state = "thingdepleter"
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// is this not broken yet
	var/functional = TRUE
	/// boss weakref
	var/datum/weakref/boss_weakref

/obj/structure/thing_boss_phase_depleter/Initialize(mapload)
	. = ..()
	go_in_floor()
	SSqueuelinks.add_to_queue(src, RUIN_QUEUE, 0)

/obj/structure/thing_boss_phase_depleter/MatchedLinks(id, list/partners)
	if(id != RUIN_QUEUE)
		return
	var/mob/living/basic/boss/thing/thing = locate() in partners
	if(isnull(thing))
		qdel(src)
		return
	boss_weakref = WEAKREF(thing)
	RegisterSignal(thing, COMSIG_MEGAFAUNA_THETHING_PHASEUPDATED, PROC_REF(thing_phaseupdated))

/obj/structure/thing_boss_phase_depleter/proc/thing_phaseupdated(mob/living/basic/boss/thing/source)
	SIGNAL_HANDLER
	if(!functional)
		return
	if(source.phase_invulnerability_timer)
		go_out_floor()
	else
		go_in_floor()

/obj/structure/thing_boss_phase_depleter/examine(mob/user)
	. = ..()
	. += density ? span_boldnotice("It may be possible to overload this and destroy that things defenses...") : span_bolddanger("The machine is currently being restrained by tendrils.")

/obj/structure/thing_boss_phase_depleter/proc/set_circuit_floor(state)
	for(var/turf/open/floor/circuit/circuit in RANGE_TURFS(1, loc))
		circuit.on = state
		circuit.update_appearance()

/obj/structure/thing_boss_phase_depleter/proc/go_in_floor()
	if(!density)
		return
	density = FALSE
	obj_flags &= ~CAN_BE_HIT
	set_circuit_floor(FALSE)
	name = "hatch"
	icon_state = "thingdepleter_infloor"

/obj/structure/thing_boss_phase_depleter/proc/go_out_floor()
	if(density)
		return
	density = TRUE
	obj_flags |= CAN_BE_HIT
	set_circuit_floor(TRUE)
	name = initial(name)
	icon_state = "thingdepleter"
	new /obj/effect/temp_visual/mook_dust(loc)

/obj/structure/thing_boss_phase_depleter/interact(mob/user, list/modifiers)
	var/mob/living/basic/boss/thing/the_thing = boss_weakref?.resolve()
	if(!the_thing || !functional || !density)
		return
	if(!user.can_perform_action(src) || !user.can_interact_with(src))
		return
	balloon_alert_to_viewers("overloading...")
	icon_state = "thingdepleter_overriding"
	if(!do_after(user, 1 SECONDS, target = src))
		if(density)
			icon_state = "thingdepleter"
		return
	new /obj/effect/temp_visual/circle_wave/orange(loc)
	playsound(src, 'sound/effects/explosion/explosion3.ogg', 100)
	animate(src, transform = matrix()*1.5, time = 0.2 SECONDS)
	animate(transform = matrix(), time = 0)
	the_thing.phase_successfully_depleted()
	functional = FALSE
	go_in_floor()
	icon_state = "thingdepleter_overriding"
	addtimer(VARSET_CALLBACK(src, icon_state, "thingdepleter_broken"), 0.2 SECONDS)

/obj/effect/temp_visual/circle_wave/orange
	color = COLOR_ORANGE

/obj/structure/aggro_gate
	name = "biohazard gate"
	desc = "A wall of solid light, only activating when a human is endangered by a biohazard, unfortunately that does little for safety as it locks you in with said biohazard. Virtually indestructible, you must evade (or kill) the threat."
	icon = 'icons/effects/effects.dmi'
	icon_state = "wave2"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	move_resist = MOVE_FORCE_OVERPOWERING
	opacity = FALSE
	density = FALSE
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE
	/// queue id
	var/queue_id = RUIN_QUEUE
	/// blackboard key for target
	var/target_bb_key = BB_BASIC_MOB_CURRENT_TARGET

/obj/structure/aggro_gate/Initialize(mapload)
	. = ..()
	SSqueuelinks.add_to_queue(src, queue_id)

/obj/structure/aggro_gate/MatchedLinks(id, list/partners)
	if(id != queue_id)
		return
	for(var/mob/living/partner in partners)
		RegisterSignal(partner, COMSIG_AI_BLACKBOARD_KEY_SET(target_bb_key), PROC_REF(bar_the_gates))
		RegisterSignals(partner, list(COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_bb_key), COMSIG_LIVING_DEATH, COMSIG_MOB_LOGIN), PROC_REF(open_gates))

/obj/structure/aggro_gate/proc/bar_the_gates(mob/living/source)
	SIGNAL_HANDLER
	var/atom/target = source.ai_controller?.blackboard[target_bb_key]
	if (QDELETED(target))
		return
	invisibility = INVISIBILITY_NONE
	density = TRUE
	playsound(src, SFX_SPARKS, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)

/obj/structure/aggro_gate/proc/open_gates(mob/living/source)
	playsound(src, SFX_SPARKS, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	density = FALSE
	invisibility = INVISIBILITY_MAXIMUM
