/obj/effect/mob_spawn/corpse/goliath/pierced
	corpse_description = "Seems to have been pierced through the heart by a Watcher spike."
	naive_corpse_description = "It's got a pretty big boo-boo, might need one of the large plasters."

/obj/effect/mob_spawn/corpse/watcher/goliath_chewed
	corpse_description = "Prior to its death, it was badly mangled by the jaws of a Goliath."
	naive_corpse_description = "It's all tuckered out after playing rough with a Goliath."

/obj/effect/mob_spawn/corpse/watcher/crushed
	corpse_description = "Crushed by a rockslide, it seemed to have been scraping frantically at the rocks even as it perished."
	naive_corpse_description = "All of those rocks probably don't make a comfortable blanket."


#define WATCHER_EGG_LIVELY_MOD 0.75
#define WATCHER_EGG_ACTIVE_MOD 0.5

/// Egg which hatches into a helpful pet. Or you can eat it if you want.
/obj/item/food/egg/watcher
	name = "watcher egg"
	desc = "A lonely egg still pulsing with life, somehow untouched by the corruption of the Necropolis."
	icon_state = "egg_watcher"
	chick_throw_prob = 100
	tastes = list("ocular fluid" = 6, "loneliness" = 1)
	preserved_food = TRUE
	/// How far have we moved?
	var/steps_travelled = 0
	/// How far should we travel to hatch?
	var/steps_to_hatch = 600
	/// Datum used to measure our steps
	var/datum/movement_detector/pedometer

/obj/item/food/egg/watcher/Initialize(mapload)
	. = ..()
	pedometer = new(src, CALLBACK(src, PROC_REF(on_stepped)))

/obj/item/food/egg/watcher/Destroy(force)
	. = ..()
	QDEL_NULL(pedometer)

/obj/item/food/egg/watcher/spawn_impact_chick(turf/spawn_turf)
	new /obj/effect/spawner/random/lavaland_mob/watcher(spawn_turf)

/obj/item/food/egg/watcher/examine(mob/user)
	return ..() + span_notice("<i>Watch it more closely to see how it is doing...</i>")

/obj/item/food/egg/watcher/examine_more(mob/user)
	. = ..()
	if (steps_travelled < (steps_to_hatch * WATCHER_EGG_ACTIVE_MOD))
		return . + span_notice("Something stirs listlessly inside.")
	if (steps_travelled < steps_to_hatch * WATCHER_EGG_LIVELY_MOD)
		return . + span_notice("Something is moving actively inside.")
	return . + span_boldnotice("It's jiggling wildly, it's about to hatch!")

/// Called when we are moved, whether inside an inventory or by ourself somehow
/obj/item/food/egg/watcher/proc/on_stepped(atom/movable/egg, atom/mover, atom/old_loc, direction)
	var/new_loc = get_turf(egg)
	if (isnull(new_loc) || new_loc == get_turf(old_loc))
		return // Didn't actually go anywhere
	steps_travelled++
	if (steps_travelled == steps_to_hatch * WATCHER_EGG_ACTIVE_MOD)
		jiggle()
		return
	if (steps_travelled < steps_to_hatch)
		return
	visible_message(span_boldnotice("[src] splits and unfurls into a baby Watcher!"))
	playsound(new_loc, 'sound/effects/splat.ogg', 50, TRUE)
	new /obj/effect/decal/cleanable/greenglow(new_loc)
	new /obj/item/watcher_hatchling(new_loc)
	qdel(src)

/// Animate the egg
/obj/item/food/egg/watcher/proc/jiggle()
	var/animation = isturf(loc) ? rand(1, 3) : 1 // Pixel_x/y animations don't work in an inventory
	switch(animation)
		if (1)
			animate(src, transform = transform.Scale(1.3), time = 1 SECONDS, easing = BOUNCE_EASING)
			animate(transform = matrix(), time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)
		if (2)
			animate(src, pixel_y = 8, time = 0.5 SECONDS, easing = SINE_EASING | EASE_OUT)
			animate(pixel_y = 0, time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)
			animate(pixel_y = 4, time = 0.5 SECONDS, easing = SINE_EASING | EASE_OUT)
			animate(pixel_y = 0, time = 0.5 SECONDS, easing = BOUNCE_EASING | EASE_IN)
		if (3)
			Shake(pixelshiftx = 2, pixelshifty = 0, shake_interval = 0.3 SECONDS)
	var/next_jiggle = rand(5 SECONDS, 10 SECONDS) / (steps_travelled >= steps_to_hatch * WATCHER_EGG_LIVELY_MOD ? 2 : 1)
	addtimer(CALLBACK(src, PROC_REF(jiggle)), next_jiggle, TIMER_DELETE_ME)

#undef WATCHER_EGG_LIVELY_MOD
#undef WATCHER_EGG_ACTIVE_MOD


/// A cute pet who will occasionally attack lavaland mobs for you
/obj/item/watcher_hatchling
	name = "watcher hatchling"
	desc = "A newly born watcher, apparently free of the Necropolis' corruption. Perhaps one of the last."
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "watcher_baby"
	w_class = WEIGHT_CLASS_SMALL
	/// The effect we create when out and about
	var/obj/effect/watcher_orbiter/orbiter
	/// Who are we orbiting?
	var/mob/living/owner

/obj/item/watcher_hatchling/attack_self(mob/user, modifiers)
	. = ..()
	if (!isnull(orbiter))
		watcher_return()
		return
	orbiter = new (get_turf(src))
	orbiter.follow(user)
	owner = user
	RegisterSignal(owner, COMSIG_QDELETING, PROC_REF(remove_owner))
	RegisterSignal(orbiter, COMSIG_QDELETING, PROC_REF(remove_orbiter))

/obj/item/watcher_hatchling/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if (isnull(orbiter))
		return
	var/mob/holder = recursive_loc_check(src, /mob)
	if (holder != owner)
		watcher_return()

/// If the guy we are orbiting is deleted but somehow we aren't
/obj/item/watcher_hatchling/proc/remove_owner()
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_QDELETING)
	owner = null

/// In the more likely event that our orbiter is deleted, stop holding a reference to it
/obj/item/watcher_hatchling/proc/remove_orbiter()
	SIGNAL_HANDLER
	orbiter = null // No need to unregister signal because we only call this when it deletes

/// Get back in your ball pikachu
/obj/item/watcher_hatchling/proc/watcher_return()
	qdel(orbiter)
	remove_owner()


/// Orbiting visual which shoots at mining mobs
/obj/effect/watcher_orbiter
	name = "watcher hatchling"
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "watcher_baby"
	layer = EDGED_TURF_LAYER // Don't render under lightbulbs
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_y = 22
	alpha = 0
	/// Who are we following?
	var/atom/parent
	/// Datum which keeps us hanging out with our parent
	var/datum/movement_detector/tracker
	/// Type of projectile we fire
	var/projectile_type = /obj/projectile/baby_watcher_blast
	/// Sound to make when we shoot
	var/projectile_sound = 'sound/items/weapons/pierce.ogg'
	/// Time between taking potshots at goliaths
	var/fire_delay = 5 SECONDS
	/// How much faster do we shoot when avenging our parent?
	var/on_death_multiplier = 5
	/// Time taken between shots
	COOLDOWN_DECLARE(shot_cooldown)
	/// Types of mobs to attack
	var/list/target_faction = list(FACTION_MINING)

/obj/effect/watcher_orbiter/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

// Shuttle rotation fucks with our position, we just want to stick with our guy
/obj/effect/watcher_orbiter/shuttleRotate(rotation, params)
	return

/obj/effect/watcher_orbiter/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(tracker)
	return ..()

/obj/effect/watcher_orbiter/process(seconds_per_tick)
	if (!COOLDOWN_FINISHED(src, shot_cooldown))
		return
	for (var/mob/living/potential_target in oview(5, src))
		if (!ismining(potential_target) || potential_target.stat == DEAD)
			continue
		if (!faction_check(target_faction, potential_target.faction))
			continue
		shoot_at(potential_target)
		return

/// Take a shot
/obj/effect/watcher_orbiter/proc/shoot_at(atom/target)
	COOLDOWN_START(src, shot_cooldown, fire_delay)
	fire_projectile(projectile_type, target, projectile_sound, ignore_targets = list(parent))

/// Set ourselves up to track and orbit around a guy
/obj/effect/watcher_orbiter/proc/follow(atom/movable/target)
	parent = target
	glide_size = target.glide_size
	animate(src, pixel_y = 26, alpha = 255, time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(orbit_animation)), 0.5 SECONDS, TIMER_DELETE_ME)
	tracker = new(target, CALLBACK(src, PROC_REF(on_parent_moved)))
	RegisterSignal(target, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(on_glide_size_changed))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_parent_deleted))
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_parent_died))
	RegisterSignal(target, COMSIG_LIVING_REVIVE, PROC_REF(on_parent_revived))

/// Do our orbiting animation
/obj/effect/watcher_orbiter/proc/orbit_animation()
	animate(src, pixel_y = 26, time = 1 SECONDS, loop = -1, easing = SINE_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_y = 18, time = 1 SECONDS, easing = SINE_EASING)
	animate(src, pixel_x = 20, time = 0.5 SECONDS, loop = -1, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(pixel_x = 0, time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)
	animate(pixel_x = -20, time = 0.5 SECONDS, easing = SINE_EASING | EASE_OUT)
	animate(pixel_x = 0, time = 0.5 SECONDS, easing = SINE_EASING | EASE_IN)

/// Follow our parent
/obj/effect/watcher_orbiter/proc/on_parent_moved(atom/movable/parent, atom/mover, atom/old_loc, direction)
	if(parent.loc == old_loc)
		return
	var/turf/new_turf = get_turf(parent)
	if(isnull(new_turf))
		qdel(src)
		return
	if (loc != new_turf)
		abstract_move(new_turf)

/// Make sure we glide at the same speed as our parent
/obj/effect/watcher_orbiter/proc/on_glide_size_changed(atom/source, new_glide_size)
	SIGNAL_HANDLER
	glide_size = new_glide_size

/// Called if the guy we're tracking is deleted somehow
/obj/effect/watcher_orbiter/proc/on_parent_deleted()
	SIGNAL_HANDLER
	parent = null
	qdel(src)

/// We must guard this corpse
/obj/effect/watcher_orbiter/proc/on_parent_died(mob/living/parent)
	SIGNAL_HANDLER
	visible_message(span_notice("[src] emits a piteous keening in mourning of [parent]!"))
	fire_delay /= on_death_multiplier

/// Exit hyperactive mode
/obj/effect/watcher_orbiter/proc/on_parent_revived(mob/living/parent)
	SIGNAL_HANDLER
	visible_message(span_notice("[src] chirps happily as [parent] suddenly gasps for breath!"))
	fire_delay *= on_death_multiplier


/// Beam fired by a baby watcher, doesn't actually do less damage than its parent
/obj/projectile/baby_watcher_blast
	name = "hatchling beam"
	icon_state = "ice_2"
	damage = 10
	damage_type = BRUTE // Mining mobs don't take a lot of burn damage so we'll pretend
	speed = 1
	pixel_speed_multiplier = 0.5

/obj/projectile/baby_watcher_blast/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.5)
