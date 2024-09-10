#define SWOOP_HEIGHT 270 //how high up swoops go, in pixels
#define SWOOP_DIRECTION_CHANGE_RANGE 5 //the range our x has to be within to not change the direction we slam from

/datum/action/cooldown/mob_cooldown/lava_swoop
	name = "Lava Swoop"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "lavastaff_warn"
	desc = "Allows you to chase a target while raining lava down."
	cooldown_time = 4 SECONDS
	/// Check to see if we are enraged
	var/enraged = FALSE
	/// Check if we are currently swooping
	var/swooping = FALSE

/datum/action/cooldown/mob_cooldown/lava_swoop/Grant(mob/M)
	. = ..()
	M.add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_NOFIRE), ACTION_TRAIT)

/datum/action/cooldown/mob_cooldown/lava_swoop/Remove(mob/M)
	. = ..()
	M.remove_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_NOFIRE), ACTION_TRAIT)

/datum/action/cooldown/mob_cooldown/lava_swoop/Activate(atom/target_atom)
	disable_cooldown_actions()
	attack_sequence(target_atom)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/lava_swoop/proc/attack_sequence(atom/target)
	if(enraged)
		swoop_attack(target, TRUE)
		return
	INVOKE_ASYNC(src, PROC_REF(lava_pools), target)
	swoop_attack(target)

/datum/action/cooldown/mob_cooldown/lava_swoop/proc/swoop_attack(atom/target, lava_arena = FALSE)
	if(swooping || !target)
		return
	// stop swooped target movement
	swooping = TRUE
	ADD_TRAIT(owner, TRAIT_UNDENSE, SWOOPING_TRAIT)
	owner.visible_message(span_boldwarning("[owner] swoops up high!"))

	var/negative
	var/initial_x = owner.x
	if(target.x < initial_x) //if the target's x is lower than ours, swoop to the left
		negative = TRUE
	else if(target.x > initial_x)
		negative = FALSE
	else if(target.x == initial_x) //if their x is the same, pick a direction
		negative = prob(50)
	var/obj/effect/temp_visual/dragon_flight/flight_vis = new /obj/effect/temp_visual/dragon_flight(owner.loc, negative)

	negative = !negative //invert it for the swoop down later

	var/oldtransform = owner.transform
	owner.alpha = 255
	animate(owner, alpha = 204, transform = matrix()*0.9, time = 3, easing = BOUNCE_EASING)
	for(var/i in 1 to 3)
		sleep(0.1 SECONDS)
		if(QDELETED(owner) || owner.stat == DEAD) //we got hit and died, rip us
			qdel(flight_vis)
			if(owner.stat == DEAD)
				swooping = FALSE
				animate(owner, alpha = 255, transform = oldtransform, time = 0, flags = ANIMATION_END_NOW) //reset immediately
			return
	animate(owner, alpha = 100, transform = matrix()*0.7, time = 7)
	owner.status_flags |= GODMODE
	SEND_SIGNAL(owner, COMSIG_SWOOP_INVULNERABILITY_STARTED)

	owner.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	SLEEP_CHECK_DEATH(7, owner)

	var/turf/target_turf = get_turf(target)
	while(!QDELETED(target) && owner.loc != target_turf && owner.z == target_turf.z)
		owner.forceMove(get_step(owner, get_dir(owner, target_turf)))
		SLEEP_CHECK_DEATH(0.5, owner)
		target_turf = get_turf(target)

	// Ash drake flies onto its target and rains fire down upon them
	var/descentTime = 10
	var/lava_success = TRUE
	if(lava_arena)
		lava_success = lava_arena(target)

	//ensure swoop direction continuity.
	if(negative)
		if(ISINRANGE(owner.x, initial_x + 1, initial_x + SWOOP_DIRECTION_CHANGE_RANGE))
			negative = FALSE
	else
		if(ISINRANGE(owner.x, initial_x - SWOOP_DIRECTION_CHANGE_RANGE, initial_x - 1))
			negative = TRUE
	new /obj/effect/temp_visual/dragon_flight/end(owner.loc, negative)
	new /obj/effect/temp_visual/dragon_swoop(owner.loc)
	animate(owner, alpha = 255, transform = oldtransform, descentTime)
	SLEEP_CHECK_DEATH(descentTime, owner)
	owner.mouse_opacity = initial(owner.mouse_opacity)
	playsound(owner.loc, 'sound/effects/meteorimpact.ogg', 200, TRUE)
	for(var/mob/living/victim in orange(1, owner) - owner)
		victim.adjustBruteLoss(75)
		if(!QDELETED(victim)) // Some mobs are deleted on death
			var/throw_dir = get_dir(owner, victim)
			if(victim.loc == owner.loc)
				throw_dir = pick(GLOB.alldirs)
			var/throwtarget = get_edge_target_turf(owner, throw_dir)
			victim.throw_at(throwtarget, 3)
			owner.visible_message(span_warning("[victim] is thrown clear of [owner]!"))
	for(var/obj/vehicle/sealed/mecha/mech in orange(1, owner))
		mech.take_damage(75, BRUTE, MELEE, 1)

	for(var/mob/observer in range(7, owner))
		shake_camera(observer, 15, 1)

	REMOVE_TRAIT(owner, TRAIT_UNDENSE, SWOOPING_TRAIT)
	SLEEP_CHECK_DEATH(1, owner)
	swooping = FALSE
	if(!lava_success)
		SEND_SIGNAL(owner, COMSIG_LAVA_ARENA_FAILED)
	owner.status_flags &= ~GODMODE

/datum/action/cooldown/mob_cooldown/lava_swoop/proc/lava_pools(atom/target, amount = 30, delay = 0.8)
	if(!target)
		return
	target.visible_message(span_boldwarning("Lava starts to pool up around you!"))

	while(amount > 0)
		if(QDELETED(target))
			break
		var/turf/target_turf = get_turf(target)
		var/turf/lava_turf = pick(RANGE_TURFS(1, target_turf))
		var/obj/effect/temp_visual/lava_warning/warn_effect = new /obj/effect/temp_visual/lava_warning(lava_turf, 60) // longer reset time for the lava
		warn_effect.owner = owner
		amount--
		SLEEP_CHECK_DEATH(delay, owner)

/datum/action/cooldown/mob_cooldown/lava_swoop/proc/lava_arena(atom/target)
	var/turf/target_turf = get_turf(target)
	if(QDELETED(target) || !isliving(target) || target_turf.z != owner.z)
		return
	target.visible_message(span_boldwarning("[owner] encases you in an arena of fire!"))
	var/amount = 3
	var/turf/center = get_turf(owner)
	var/list/walled = RANGE_TURFS(3, center) - RANGE_TURFS(2, center)
	var/list/drakewalls = list()
	for(var/turf/T in walled)
		drakewalls += new /obj/effect/temp_visual/drakewall(T) // no people with lava immunity can just run away from the attack for free
	var/list/indestructible_turfs = list()
	for(var/turf/T in RANGE_TURFS(2, center))
		if(isindestructiblefloor(T))
			continue
		if(isindestructiblewall(T))
			indestructible_turfs += T
	SLEEP_CHECK_DEATH(1 SECONDS, owner) // give them a bit of time to realize what attack is actually happening

	var/list/turfs = RANGE_TURFS(2, center)
	var/list/mobs_with_clients = list()
	while(amount > 0)
		var/list/empty = indestructible_turfs.Copy() // can't place safe turfs on turfs that weren't changed to be open
		var/any_attack = FALSE
		for(var/turf/T in turfs)
			for(var/mob/living/L in T.contents)
				if(L.client)
					empty += pick(((RANGE_TURFS(2, L) - RANGE_TURFS(1, L)) & turfs) - empty) // picks a turf within 2 of the creature not outside or in the shield
					any_attack = TRUE
					mobs_with_clients |= L
			for(var/obj/vehicle/sealed/mecha/M in T.contents)
				empty += pick(((RANGE_TURFS(2, M) - RANGE_TURFS(1, M)) & turfs) - empty)
				any_attack = TRUE
		if(!any_attack) // nothing to attack in the arena, time for enraged attack if we still have a cliented target.
			for(var/obj/effect/temp_visual/drakewall/D in drakewalls)
				qdel(D)
			for(var/a in mobs_with_clients)
				var/mob/living/L = a
				if(!QDELETED(L) && L.client)
					return FALSE
			return TRUE
		for(var/turf/T in turfs)
			if(!(T in empty))
				new /obj/effect/temp_visual/lava_warning(T)
			else if(!isindestructiblewall(T))
				new /obj/effect/temp_visual/lava_safe(T)
		amount--
		SLEEP_CHECK_DEATH(2.4 SECONDS, owner)
	return TRUE // attack finished completely

/obj/effect/temp_visual/dragon_swoop
	name = "certain death"
	desc = "Don't just stand there, move!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "landing"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	pixel_x = -32
	pixel_y = -32
	color = COLOR_RED
	duration = 10

/obj/effect/temp_visual/dragon_flight
	icon = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	icon_state = "dragon"
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -32
	duration = 10
	randomdir = FALSE

/obj/effect/temp_visual/dragon_flight/Initialize(mapload, negative)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(flight), negative)

/obj/effect/temp_visual/dragon_flight/proc/flight(negative)
	if(negative)
		animate(src, pixel_x = -SWOOP_HEIGHT*0.1, pixel_z = SWOOP_HEIGHT*0.15, time = 3, easing = BOUNCE_EASING)
	else
		animate(src, pixel_x = SWOOP_HEIGHT*0.1, pixel_z = SWOOP_HEIGHT*0.15, time = 3, easing = BOUNCE_EASING)
	sleep(0.3 SECONDS)
	icon_state = "dragon_swoop"
	if(negative)
		animate(src, pixel_x = -SWOOP_HEIGHT, pixel_z = SWOOP_HEIGHT, time = 7)
	else
		animate(src, pixel_x = SWOOP_HEIGHT, pixel_z = SWOOP_HEIGHT, time = 7)

/obj/effect/temp_visual/dragon_flight/end
	pixel_x = SWOOP_HEIGHT
	pixel_z = SWOOP_HEIGHT
	duration = 10

/obj/effect/temp_visual/dragon_flight/end/flight(negative)
	if(negative)
		pixel_x = -SWOOP_HEIGHT
		animate(src, pixel_x = -16, pixel_z = 0, time = 5)
	else
		animate(src, pixel_x = -16, pixel_z = 0, time = 5)

#undef SWOOP_HEIGHT
#undef SWOOP_DIRECTION_CHANGE_RANGE
