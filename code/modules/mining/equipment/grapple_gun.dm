#define DAMAGE_ON_IMPACT 20

/obj/item/grapple_gun
	name = "grapple gun"
	desc = "A handy tool for traversing the land-scape of lava-land!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "grapple_gun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_icon_state = "gun"
	item_flags = NOBLUDGEON
	///overlay when the hook is retracted
	var/static/mutable_appearance/hook_overlay = new(icon = 'icons/obj/mining.dmi', icon_state = "grapple_gun_hooked")
	///is the hook retracted
	var/hooked = TRUE
	///addtimer id for launching the user
	var/grapple_timer_id
	///traits we apply to the user when being launched
	var/static/list/traits_on_zipline = list(
		TRAIT_IMMOBILIZED,
		TRAIT_MOVE_FLOATING,
		TRAIT_FORCED_STANDING,
	)
	///the beam we draw
	var/datum/beam/zipline
	///our user currently ziplining
	var/datum/weakref/zipliner
	///ziplining sound
	var/datum/looping_sound/zipline/zipline_sound
	///our initial matrix
	var/matrix/initial_matrix

/obj/item/grapple_gun/Initialize(mapload)
	. = ..()
	zipline_sound = new(src)
	update_appearance()

/obj/item/grapple_gun/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(isgroundlessturf(target))
		return NONE
	if(target == user || !hooked)
		return NONE

	if(!lavaland_equipment_pressure_check(get_turf(user)))
		user.balloon_alert(user, "gun mechanism wont work here!")
		return ITEM_INTERACT_BLOCKING
	if(get_dist(user, target) > 9)
		user.balloon_alert(user, "too far away!")
		return ITEM_INTERACT_BLOCKING

	var/turf/attacked_atom = get_turf(target)
	if(isnull(attacked_atom))
		return ITEM_INTERACT_BLOCKING

	var/list/turf_list = (get_line(user, attacked_atom) - get_turf(src))
	for(var/turf/singular_turf as anything in turf_list)
		if(ischasm(singular_turf))
			continue
		if(!singular_turf.is_blocked_turf())
			continue
		attacked_atom = singular_turf
		break

	if(user.CanReach(attacked_atom))
		return ITEM_INTERACT_BLOCKING

	var/atom/bullet = fire_projectile(/obj/projectile/grapple_hook, attacked_atom, 'sound/weapons/zipline_fire.ogg')
	zipline = user.Beam(bullet, icon_state = "zipline_hook", maxdistance = 9, layer = BELOW_MOB_LAYER)
	hooked = FALSE
	RegisterSignal(bullet, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_grapple_hit))
	RegisterSignal(bullet, COMSIG_PREQDELETED, PROC_REF(on_grapple_fail))
	zipliner = WEAKREF(user)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/item/grapple_gun/proc/on_grapple_hit(datum/source, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_PROJECTILE_ON_HIT, COMSIG_PREQDELETED))
	QDEL_NULL(zipline)
	var/mob/living/user = zipliner?.resolve()
	if(isnull(user) || isnull(target))
		cancel_hook()
		return

	zipline = user.Beam(target, icon_state = "zipline_hook", maxdistance = 9, layer = BELOW_MOB_LAYER)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(determine_distance))
	RegisterSignal(user, COMSIG_MOVABLE_PRE_THROW, PROC_REF(apply_throw_traits))
	grapple_timer_id = addtimer(CALLBACK(src, PROC_REF(launch_user), target), 1.5 SECONDS, TIMER_STOPPABLE)

/obj/item/grapple_gun/proc/on_grapple_fail(datum/source)
	SIGNAL_HANDLER
	cancel_hook()

/obj/item/grapple_gun/proc/determine_distance(atom/movable/source)
	SIGNAL_HANDLER

	if(isnull(zipline))
		return
	var/atom/target = zipline.target
	if(isnull(target))
		return
	if(get_dist(source, target) > zipline.max_distance)
		cancel_hook()

/obj/item/grapple_gun/proc/apply_throw_traits(mob/living/source, list/arguements)
	SIGNAL_HANDLER
	var/atom/target_atom = arguements[1]
	if(isnull(target_atom))
		return
	var/dir_to_turn = get_angle(source, target_atom)
	if(dir_to_turn > 175 && dir_to_turn < 190)
		dir_to_turn = 0
	source.add_traits(traits_on_zipline, LEAPING_TRAIT)
	initial_matrix = source.transform
	animate(source, transform = matrix().Turn(dir_to_turn), time = 0.1 SECONDS)

/obj/item/grapple_gun/proc/launch_user(atom/target_atom)
	var/mob/living/my_user = zipliner?.resolve()
	if(isnull(my_user) || isnull(target_atom) || my_user.buckled)
		cancel_hook()
		return
	zipline_sound.start()
	new /obj/effect/temp_visual/mook_dust(drop_location())
	RegisterSignal(my_user, COMSIG_MOVABLE_IMPACT, PROC_REF(strike_target))
	my_user.throw_at(target = target_atom, range = 9, speed = 1, spin = FALSE, gentle = TRUE, callback = CALLBACK(src, PROC_REF(post_land)))

/obj/item/grapple_gun/proc/strike_target(mob/living/source, mob/living/victim, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(!istype(victim))
		return

	victim.apply_damage(DAMAGE_ON_IMPACT)
	playsound(victim, 'sound/effects/hit_kick.ogg', 50)
	var/turf/target_turf = get_ranged_target_turf(victim, source.dir, 3)
	if(isnull(target_turf))
		return
	victim.throw_at(target = target_turf, speed = 1, spin = TRUE, range = 3)


/obj/item/grapple_gun/proc/post_land()
	var/mob/living/my_user = zipliner?.resolve()
	if(!isnull(my_user))
		my_user.transform = initial_matrix
		my_user.remove_traits(traits_on_zipline, LEAPING_TRAIT)
	new /obj/effect/temp_visual/mook_dust(drop_location())
	cancel_hook()

/obj/item/grapple_gun/proc/cancel_hook()
	var/atom/my_zipliner = zipliner?.resolve()
	if(!isnull(my_zipliner))
		UnregisterSignal(my_zipliner, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_PRE_THROW))
	QDEL_NULL(zipline)
	zipliner = null
	if(grapple_timer_id)
		deltimer(grapple_timer_id)
	grapple_timer_id = null
	hooked = TRUE
	zipline_sound.stop()
	initial_matrix = null
	update_appearance()

/obj/item/grapple_gun/update_overlays()
	. = ..()
	if(hooked)
		. += hook_overlay

/obj/projectile/grapple_hook
	name = "grapple hook"
	icon_state = "grapple_hook"
	damage = 0
	range = 9
	speed = 0.1
	can_hit_turfs = TRUE
	hitsound = 'sound/weapons/zipline_hit.ogg'

#undef DAMAGE_ON_IMPACT
