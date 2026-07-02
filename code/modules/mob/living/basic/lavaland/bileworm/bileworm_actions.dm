/datum/action/cooldown/mob_cooldown/resurface
	name = "Resurface"
	desc = "Burrow underground, and then move to a new location near your target. Must spew bile to refresh."
	shared_cooldown = MOB_SHARED_COOLDOWN_1 | MOB_SHARED_COOLDOWN_2
	/// Damage tracker var for bileworms
	var/jump_damaged = FALSE
	/// How long does the jump take to perform?
	var/jump_length = 1 SECONDS
	/// How long do we get stunned for if we fail a jump?
	var/jump_stun = 2.4 SECONDS

/datum/action/cooldown/mob_cooldown/resurface/Grant(mob/granted_to)
	. = ..()
	owner?.AddElement(/datum/element/relay_attackers)

/datum/action/cooldown/mob_cooldown/resurface/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	StartCooldownOthers(INFINITY)
	burrow(owner, target_atom)
	//spew now off cooldown shortly
	StartCooldownOthers(1.5 SECONDS)

/// Amount of frames in the jump animation
#define BILEWORM_JUMP_FRAMES 14

/datum/action/cooldown/mob_cooldown/resurface/proc/burrow(mob/living/burrower, atom/target, force = FALSE)
	var/turf/unburrow_turf = get_unburrow_turf(burrower, target)
	if (!unburrow_turf) // means all the turfs nearby are station turfs or something, not lavaland
		to_chat(burrower, span_warning("Couldn't burrow anywhere near the target!"))
		if(burrower.ai_controller?.ai_status == AI_STATUS_ON)
			//this is a valid reason to give up on a target
			burrower.ai_controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		return

	if (istype(burrower, /mob/living/basic/mining/bileworm) && !force)
		var/mob/living/basic/mining/bileworm/worm = burrower
		new /obj/effect/temp_visual/mook_dust(get_turf(worm))
		var/old_icon_state = worm.icon_state
		worm.icon_state = null
		// Get rid of the base emissive
		worm.jumping = TRUE
		worm.update_appearance(UPDATE_OVERLAYS)
		var/atom/movable/visual = worm.flick_overlay_view(mutable_appearance(worm.icon_jump, "[worm.icon_living]_jump_1"), jump_length)
		visual.vis_flags |= VIS_INHERIT_ID // So you can attack it
		var/atom/movable/emissive_visual = worm.flick_overlay_view(emissive_appearance(worm.icon_jump, "[worm.emissive_state]_jump_1", worm), jump_length)
		// We have to manually animate these to get around BYOND icon_state animations happening in world time and not per-object
		for (var/i in 2 to BILEWORM_JUMP_FRAMES)
			animate(visual, time = jump_length / BILEWORM_JUMP_FRAMES, icon_state = "[worm.icon_living]_jump_[i]", flags = ANIMATION_CONTINUE)
			animate(emissive_visual, time = jump_length / BILEWORM_JUMP_FRAMES, icon_state = "[worm.emissive_state]_jump_[i]", flags = ANIMATION_CONTINUE)
		jump_damaged = FALSE
		RegisterSignal(worm, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
		// Not in an if check direclty to reduce duplicate code
		var/jump_result = do_after(worm, jump_length, worm, hidden = TRUE, extra_checks = CALLBACK(src, PROC_REF(damage_check)))
		UnregisterSignal(worm, COMSIG_ATOM_WAS_ATTACKED)
		if (worm.icon_state == null)
			worm.icon_state = old_icon_state
		worm.jumping = FALSE
		worm.update_appearance(UPDATE_OVERLAYS)
		if (!jump_result && jump_stun)
			if (!QDELETED(visual))
				QDEL_NULL(visual)
				QDEL_NULL(emissive_visual)
			worm.flick_overlay_view(mutable_appearance('icons/effects/effects.dmi', "dazed"), jump_stun)
			worm.Stun(jump_stun)
			addtimer(CALLBACK(src, PROC_REF(burrow_again), burrower, target), jump_stun)
			return

	burrower.ai_controller?.set_blackboard_key(BB_BILEWORM_SCARED, FALSE)
	playsound(burrower, 'sound/effects/break_stone.ogg', 50, TRUE)
	new /obj/effect/temp_visual/mook_dust(get_turf(burrower))
	ADD_TRAIT(burrower, TRAIT_GODMODE, REF(src))
	burrower.SetInvisibility(INVISIBILITY_MAXIMUM, id=type)
	burrower.forceMove(unburrow_turf)
	//not that it's gonna die with godmode but still
	SLEEP_CHECK_DEATH(rand(0.7 SECONDS, 1.2 SECONDS), burrower)
	playsound(burrower, 'sound/effects/break_stone.ogg', 50, TRUE)
	new /obj/effect/temp_visual/mook_dust(unburrow_turf)
	REMOVE_TRAIT(burrower, TRAIT_GODMODE, REF(src))
	burrower.RemoveInvisibility(type)

#undef BILEWORM_JUMP_FRAMES

/datum/action/cooldown/mob_cooldown/resurface/proc/burrow_again(mob/living/burrower, atom/target)
	if (!QDELETED(burrower) && !burrower.stat)
		// Burrow immediatelly after being stunned out of the first jump to avoid chainstuns
		burrow(burrower, target, force = TRUE)

/datum/action/cooldown/mob_cooldown/resurface/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	if (!(attack_flags & (ATTACKER_STAMINA_ATTACK | ATTACKER_SHOVING)) && jump_stun)
		jump_damaged = TRUE

/datum/action/cooldown/mob_cooldown/resurface/proc/damage_check()
	return !jump_damaged

/datum/action/cooldown/mob_cooldown/resurface/proc/get_unburrow_turf(mob/living/burrower, atom/target)
	var/list/potential_turfs = shuffle(oview(5, target)) // get in view, shuffle
	for(var/turf/open/misc/chosen_one in potential_turfs) // first turf that counts as ground
		return chosen_one

/datum/action/cooldown/mob_cooldown/bileworm_spew
	name = "Spew Bile"
	desc = "Spew a barrage of bile globs."
	shared_cooldown = MOB_SHARED_COOLDOWN_1 | MOB_SHARED_COOLDOWN_2
	cooldown_time = 3 SECONDS
	/// Sound played when firing a projectile
	var/projectile_sound = 'sound/mobs/non-humanoids/bileworm/bileworm_spit.ogg'
	/// How many additional projectiles to shoot around the target?
	var/additional_shots = 4
	/// Delay between each shot
	var/shot_delay = 0.15 SECONDS
	/// Effect to spawn
	var/obj/effect/bileworm_acid/acid_type = /obj/effect/bileworm_acid

/datum/action/cooldown/mob_cooldown/bileworm_spew/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	attack_sequence(owner, target_atom)
	StartCooldownSelf()
	// Resurface now off cooldown shortly
	StartCooldownOthers(2 SECONDS) // Enough time for a mark + detonation combo, or 3 shots with a PKA

/datum/action/cooldown/mob_cooldown/bileworm_spew/proc/attack_sequence(mob/living/firer, atom/target)
	new acid_type(firer, target)
	playsound(firer, projectile_sound, 70)
	var/list/all_dirs = GLOB.alldirs.Copy()
	var/turf/hit_turf = get_turf(target)
	// One guaranteed to hit target's turf, the rest hit randomly around them
	for (var/i in 1 to additional_shots)
		if (!length(all_dirs))
			return

		SLEEP_CHECK_DEATH(shot_delay, firer)
		if (hit_turf != target.loc)
			all_dirs = list(NONE) + GLOB.alldirs // Refresh potential target turfs if they've moved

		var/turf/target_turf = null
		// NODE drones get a much more focused barrage sent at them
		if (istype(target, /mob/living/basic/node_drone) && prob(30))
			target_turf = get_turf(target)
		else
			var/target_dir = pick_n_take(all_dirs)
			target_turf = target_dir ? get_step(target, target_dir) : get_turf(target)

		if (target_turf == firer.loc) // Don't hit ourselves
			var/target_dir = pick_n_take(all_dirs)
			target_turf = target_dir ? get_step(target, target_dir) : get_turf(target)

		new acid_type(firer, target_turf)
		if (i % 2 == 0)
			playsound(firer, projectile_sound, 70)

/obj/effect/bileworm_acid
	name = "acidic bile"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "bile_glob"
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Damage dealt to all mobs in the impact turf
	var/damage = 20
	/// Tiles travelled per second at maximum range
	var/speed = 5
	/// Maximum range for our speed calculations
	var/max_range = 10
	/// Warning sign on the turf we're about to hit
	var/obj/effect/bileworm_target/target_sign = null

/obj/effect/bileworm_acid/Initialize(mapload, atom/new_target)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)
	if (new_target)
		fire_at(get_turf(new_target))

/obj/effect/bileworm_acid/Destroy(force)
	QDEL_NULL(target_sign)
	return ..()

/obj/effect/bileworm_acid/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha = 20, effect_type = EMISSIVE_BLOOM)

/obj/effect/bileworm_acid/proc/fire_at(turf/target)
	if (!istype(target))
		target = get_turf(target)
	var/turf/start = get_turf(src)
	forceMove(target) // Immediately move to the target turf so we can guarantee they can see us
	pixel_x = (start.x - target.x) * ICON_SIZE_X
	pixel_y = (start.y - target.y) * ICON_SIZE_Y
	// Because BYOND's get_dist is taxicab distance
	var/travel_dist = sqrt((start.x - target.x) ** 2 + (start.y - target.y) ** 2)
	// Slightly scale the speed with distance for fairer gameplay
	if (travel_dist < max_range)
		speed *= 0.5 + travel_dist / max_range * 0.5
	var/travel_time = travel_dist / speed * 1 SECONDS
	animate(src, pixel_x = 0, time = travel_time, flags = ANIMATION_PARALLEL, easing = SINE_EASING | EASE_OUT) // Not a perfect arc but looks better
	animate(src, pixel_y = 160, time = travel_time / 2, flags = ANIMATION_PARALLEL, easing = QUAD_EASING | EASE_OUT)
	animate(pixel_y = 0, time = travel_time / 2, easing = QUAD_EASING | EASE_IN)
	animate(src, transform = matrix().Turn(start.x > target.x ? -91 : 91), time = travel_time / 2, flags = ANIMATION_PARALLEL, easing = SINE_EASING | EASE_IN)
	animate(transform = matrix().Turn(start.x > target.x ? -180 : 180), time = travel_time / 2, easing = SINE_EASING | EASE_OUT)
	target_sign = new(target)
	addtimer(CALLBACK(src, PROC_REF(impact), target), travel_time)

/obj/effect/bileworm_acid/proc/impact(turf/target)
	var/obj/effect/abstract/particle_holder/impact_particles = new(target, /particles/bile)
	QDEL_IN(impact_particles, /particles/bile::lifespan)

	var/hit_something = FALSE
	for (var/mob/living/victim in target)
		if(HAS_TRAIT(target, TRAIT_UNHITTABLE_BY_PROJECTILES))
			if(!HAS_TRAIT(target, TRAIT_BLOCKING_PROJECTILES) && isliving(target))
				var/mob/living/living_target = target
				living_target.block_projectile_effects()
			continue

		// Doesn't make much sense to use melee for mobs, but its a mining mob so eeeeeh
		// Can't use acid either as its mostly for atom armor only
		var/blocked = victim.run_armor_check(null, MELEE, armour_penetration = 40, silent = TRUE)
		if (blocked >= 100)
			continue

		hit_something = TRUE
		victim.apply_damage(damage, BURN, null, blocked, wound_bonus = CANT_WOUND)
		to_chat(victim, span_userdanger("You're hit by [src]!"))

	for (var/obj/thing in target)
		if (!thing.uses_integrity || !thing.density)
			continue
		hit_something = TRUE
		thing.take_damage(damage, BURN, ACID, sound_effect = FALSE)

	if (hit_something)
		playsound(target, 'sound/items/weapons/sear.ogg', 50, -1)

	qdel(src)

/obj/effect/bileworm_target
	icon = 'icons/mob/telegraphing/telegraph.dmi'
	icon_state = "projectile_circle"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE

/obj/effect/bileworm_target/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/bileworm_target/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha = 90, effect_type = EMISSIVE_BLOOM)

/particles/bile
	icon = 'icons/effects/particles/goop.dmi'
	icon_state = list("goop_1" = 6, "goop_2" = 2, "goop_3" = 1)
	width = 100
	height = 100
	count = 10
	spawning = 10
	color = "#00ea2b80" //to get 96 alpha
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	grow = -0.025
	gravity = list(0, 0.15)
	position = generator(GEN_SPHERE, 0, 8, NORMAL_RAND)
	spin = generator(GEN_NUM, -15, 15, NORMAL_RAND)
	velocity = generator(GEN_BOX, list(-2, 2), list(2, 4), NORMAL_RAND)

/datum/action/cooldown/mob_cooldown/devour
	name = "Devour"
	desc = "Burrow underground, and then move to your target to consume them. Short cooldown, but your target must be unconscious."
	shared_cooldown = MOB_SHARED_COOLDOWN_2

/datum/action/cooldown/mob_cooldown/devour/Activate(atom/target_atom)
	if(target_atom == owner)
		to_chat(owner, span_warning("You can't eat yourself!"))
		return
	if(!isliving(target_atom))
		to_chat(owner, span_warning("That's not food!"))
		return
	var/mob/living/living_target = target_atom
	if(living_target.stat < UNCONSCIOUS)
		to_chat(owner, span_warning("No way you're eating that while it's still kicking! It should at least be unconscious first."))
		return
	burrow_and_devour(owner, living_target)

/datum/action/cooldown/mob_cooldown/devour/proc/burrow_and_devour(mob/living/devourer, mob/living/target)
	var/turf/devour_turf = get_turf(target)
	if(!istype(devour_turf, /turf/open/misc)) // means all the turfs nearby are station turfs or something, not lavaland
		to_chat(devourer, span_warning("Your target is on something you can't burrow through!"))
		return //this will give up on devouring the target which is fine by me
	playsound(devourer, 'sound/effects/break_stone.ogg', 50, TRUE)
	new /obj/effect/temp_visual/mook_dust(get_turf(devourer))
	ADD_TRAIT(devourer, TRAIT_GODMODE, REF(src))
	devourer.SetInvisibility(INVISIBILITY_MAXIMUM, id=type)
	devourer.forceMove(devour_turf)
	//not that it's gonna die with godmode but still
	SLEEP_CHECK_DEATH(rand(0.7 SECONDS, 1.2 SECONDS), devourer)
	playsound(devourer, 'sound/effects/break_stone.ogg', 50, TRUE)
	new /obj/effect/temp_visual/mook_dust(devour_turf)
	REMOVE_TRAIT(devourer, TRAIT_GODMODE, REF(src))
	devourer.RemoveInvisibility(type)
	if(!(target in devour_turf))
		to_chat(devourer, span_warning("Someone stole your dinner!"))
		return
	to_chat(target, span_userdanger("You are consumed by [devourer]!"))
	devourer.visible_message(span_warning("[devourer] consumes [target]!"))
	devourer.fully_heal()
	playsound(devourer, 'sound/effects/splat.ogg', 50, TRUE)
	//to be received on death
	target.forceMove(devourer)
