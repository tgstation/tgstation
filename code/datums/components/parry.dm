/// Add to a projectile to allow it to be parried by mobs with a certain trait (TRAIT_MINING_PARRYING by default)
/datum/component/parriable_projectile
	/// List of all turfs the projectile passed on its last loop and we assigned comsigs to
	var/list/turf/parry_turfs = list()
	/// List of all mobs who have clicked on a parry turf in last moveloop
	var/list/mob/parriers = list()
	/// When the projectile was created
	var/fire_time = 0
	/// If this projectile has been parried
	var/parried = FALSE
	/// How much this projectile is sped up when parried
	var/parry_speed_mult
	/// How much this projectile's damage is increased when parried
	var/parry_damage_mult
	/// How much this projectile is sped up when boosted (parried by owner)
	var/boost_speed_mult
	/// How much this projectile's damage is increased when boosted (parried by owner)
	var/boost_damage_mult
	/// Trait required to be able to parry this projectile
	var/parry_trait
	/// For how long do valid tiles persist? Acts as clientside lag compensation
	var/grace_period
	/// Callback for special effects upon parrying
	var/datum/callback/parry_callback

/datum/component/parriable_projectile/Initialize(parry_speed_mult = 1.25, parry_damage_mult = 1.15, boost_speed_mult = 1.6, boost_damage_mult = 1.5, parry_trait = TRAIT_MINING_PARRYING, grace_period = 0.25 SECONDS, datum/callback/parry_callback = null)
	if(!isprojectile(parent))
		return COMPONENT_INCOMPATIBLE
	src.parry_speed_mult = parry_speed_mult
	src.parry_damage_mult = parry_damage_mult
	src.boost_speed_mult = boost_speed_mult
	src.boost_damage_mult = boost_damage_mult
	src.parry_trait = parry_trait
	src.grace_period = grace_period
	src.parry_callback = parry_callback
	fire_time = world.time

/datum/component/parriable_projectile/Destroy(force)
	for (var/turf/parry_turf as anything in parry_turfs)
		UnregisterSignal(parry_turf, COMSIG_CLICK)
	. = ..()

/datum/component/parriable_projectile/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PROJECTILE_MOVE_PROCESS_STEP, PROC_REF(on_moved))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(before_move))
	RegisterSignal(parent, COMSIG_PROJECTILE_BEFORE_MOVE, PROC_REF(before_move))
	RegisterSignal(parent, COMSIG_PROJECTILE_SELF_PREHIT, PROC_REF(before_hit))

/datum/component/parriable_projectile/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PROJECTILE_MOVE_PROCESS_STEP, COMSIG_MOVABLE_MOVED, COMSIG_PROJECTILE_BEFORE_MOVE, COMSIG_PROJECTILE_SELF_PREHIT))

/datum/component/parriable_projectile/proc/before_move(obj/projectile/source)
	SIGNAL_HANDLER

	var/list/turfs_to_remove = list()
	for (var/turf/parry_turf as anything in parry_turfs)
		if (parry_turfs[parry_turf] < world.time)
			turfs_to_remove += parry_turf

	for (var/turf/parry_turf as anything in turfs_to_remove)
		parry_turfs -= parry_turf
		UnregisterSignal(parry_turf, COMSIG_CLICK)

	var/list/parriers_to_remove = list()
	for (var/mob/parrier as anything in parriers)
		if (parriers[parrier] < world.time)
			parriers_to_remove += parrier

	for (var/mob/parrier as anything in parriers_to_remove)
		parriers_to_remove -= parrier

/datum/component/parriable_projectile/proc/on_moved(obj/projectile/source)
	SIGNAL_HANDLER
	if (!isturf(source.loc) || parry_turfs[source.loc])
		return
	parry_turfs[source.loc] = world.time + grace_period
	RegisterSignal(source.loc, COMSIG_CLICK, PROC_REF(on_turf_click))

/datum/component/parriable_projectile/proc/on_turf_click(turf/source, atom/location, control, list/params, mob/user)
	SIGNAL_HANDLER
	if (!HAS_TRAIT(user, parry_trait))
		return
	var/obj/projectile/proj_parent = parent
	if (proj_parent.firer == user && (fire_time + grace_period > world.time) && !parried)
		attempt_parry(proj_parent, user)
		return
	parriers[user] = world.time + grace_period

/datum/component/parriable_projectile/proc/before_hit(obj/projectile/source, mob/living/user)
	SIGNAL_HANDLER

	if (!istype(user) || !parriers[user] || parried)
		return

	parriers -= user
	return attempt_parry(source, user)

/datum/component/parriable_projectile/proc/attempt_parry(obj/projectile/source, mob/user)
	if (QDELETED(source) || source.deletion_queued)
		return NONE

	if (SEND_SIGNAL(user, COMSIG_LIVING_PROJECTILE_PARRIED, source) & INTERCEPT_PARRY_EFFECTS)
		return NONE

	parried = TRUE
	if (source.firer != user)
		if (abs(source.angle - dir2angle(user)) < 15)
			source.set_angle((source.angle + 180) % 360 + rand(-3, 3))
		else
			source.set_angle(dir2angle(user) + rand(-3, 3))
		user.visible_message(span_warning("[user] expertly parries [source] with [user.p_their()] bare hand!"), span_warning("You parry [source] with your hand!"))
	else
		user.visible_message(span_warning("[user] boosts [source] with [user.p_their()] bare hand!"), span_warning("You boost [source] with your hand!"))
	source.firer = user
	source.speed *= (source.firer == user) ? boost_speed_mult : parry_speed_mult
	source.damage *= (source.firer == user) ? boost_damage_mult : parry_damage_mult
	source.add_atom_colour(COLOR_RED_LIGHT, TEMPORARY_COLOUR_PRIORITY)
	if (!isnull(parry_callback))
		parry_callback.Invoke(user)

	user.playsound_local(source.loc, 'sound/effects/parry.ogg', 50, TRUE)
	user.overlay_fullscreen("projectile_parry", /atom/movable/screen/fullscreen/crit/projectile_parry, 2)
	addtimer(CALLBACK(user, TYPE_PROC_REF(/mob, clear_fullscreen), "projectile_parry"), 0.25 SECONDS)
	return PROJECTILE_INTERRUPT_HIT_PHASE
