/*
	This component is used when you want to create a bunch of shrapnel or projectiles (say, shrapnel from a fragmentation grenade, or buckshot from a shotgun) from a central point,
	without necessarily printing a separate message for every single impact. This component should be instantiated right when you need it (like the moment of firing), then activated
	by signal.

	Pellet cloud currently works on two types of items: ammo casings, and grenades.
		-Ammo casings: This means you're shooting multiple pellets, like buckshot. If an ammo casing is defined as having multiple pellets, it will automatically create a pellet cloud
			and call COMSIG_PELLET_CLOUD_INIT (see [/obj/item/ammo_casing/proc/fire_casing]), then delete its normal BB. Thus, the only projectiles fired will be the ones fired here.
			The magnitude var controls how many pellets are created.
		-Grenades: This results in a big spray of shrapnel flying all around the detonation point when the grenade fires COMSIG_GRENADE_PRIME. The magnitude var controls how big the detonation
			radius is (the bigger the magnitude, the more shrapnel is created).

	Once all of the fired projectiles either hit a target or disappear due to reaching their maximum range,
*/

/datum/component/pellet_cloud
	var/projectile_type
	var/proj_name
	var/num_pellets
	var/list/pellets = list()
	var/list/targets_hit = list()
	var/terminated
	var/hits
	var/radius = 4
	var/not_done_yet
	var/list/bodies

/datum/component/pellet_cloud/Initialize(projectile_type, magnitude=5)
	if(!isammocasing(parent) && !isgrenade(parent))
		return COMPONENT_INCOMPATIBLE

	src.projectile_type = projectile_type

	if(isammocasing(parent))
		num_pellets = magnitude
	else if(isgrenade(parent))
		radius = magnitude
		not_done_yet = TRUE

	var/obj/projectile/p = projectile_type
	proj_name = initial(p.name)

/datum/component/pellet_cloud/Destroy(force, silent)
	if(not_done_yet) // Grenade clouds need to hang around for a bit after the grenade is gone so we know what happened to the pellets.
		return QDEL_HINT_LETMELIVE
	return ..()

/datum/component/pellet_cloud/RegisterWithParent()
	if(isammocasing(parent))
		RegisterSignal(parent, COMSIG_PELLET_CLOUD_INIT, .proc/create_pellets)
	else if(isgrenade(parent))
		RegisterSignal(parent, COMSIG_GRENADE_ARMED, .proc/grenade_armed)
		RegisterSignal(parent, COMSIG_GRENADE_PRIME, .proc/circle_pellets)

/datum/component/pellet_cloud/UnregisterFromParent()
	if(not_done_yet)
		return QDEL_HINT_LETMELIVE
	UnregisterSignal(parent, list(COMSIG_PELLET_CLOUD_INIT, COMSIG_GRENADE_PRIME, COMSIG_GRENADE_ARMED, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_UNCROSSED))

///Creating pellets for an ammo casing we just fired
/datum/component/pellet_cloud/proc/create_pellets(obj/item/ammo_casing/A, target, user, fired_from, randomspread, distro)
	for(var/i in 1 to num_pellets)
		var/obj/projectile/P = new projectile_type(get_turf(parent))
		P.original = target
		if(randomspread)
			P.spread = round((rand() - 0.5) * distro)
		else //Smart spread
			P.spread = round(1 - 0.5) * distro
		P.fired_from = fired_from
		P.firer = user
		P.permutated += user
		P.suppressed = SUPPRESSED_VERY // set the projectiles to make no message so we can do our own aggregate message
		P.preparePixelProjectile(target, fired_from)
		RegisterSignal(P, COMSIG_PROJECTILE_SELF_ON_HIT, .proc/pellet_hit)
		RegisterSignal(P, COMSIG_PROJECTILE_RANGE_OUT, .proc/pellet_range)
		pellets += P
		P.fire()

///Creating pellets for a grenade
/datum/component/pellet_cloud/proc/circle_pellets()
	if(radius < 1)
		not_done_yet = FALSE
		QDEL_NULL(src)
		return

	var/atom/target = parent

	var/list/martyrs = list()
	for(var/mob/living/L in get_turf(parent))
		if(!(L in bodies))
			testing("Adding [L] to martyrs")
			martyrs += L

	var/magnitude_absorbed

	for(var/M in martyrs)
		var/mob/living/L = M
		testing("[L] is a martyr")
		if(radius > 5)
			L.visible_message("<b><span class='danger'>[L] heroically covers \the [parent] with [L.p_their()] body, absorbing a load of the shrapnel!</span></b>", "<span class='userdanger'>You heroically cover \the [parent] with your body, absorbing a load of the shrapnel!</span>")
			magnitude_absorbed = round(radius * 0.5)
		else if(radius > 3)
			L.visible_message("<b><span class='danger'>[L] heroically covers \the [parent] with [L.p_their()] body, absorbing some of the shrapnel!</span></b>", "<span class='userdanger'>You heroically cover \the [parent] with your body, absorbing some of the shrapnel!</span>")
			magnitude_absorbed = 1
		else
			L.visible_message("<b><span class='danger'>[L] heroically covers \the [parent] with [L.p_their()] body, snuffing out the shrapnel!</span></b>", "<span class='userdanger'>You heroically cover \the [parent] with your body, snuffing out the shrapnel!</span>")
			magnitude_absorbed = radius

	var/pellets_absorbed
	pellets_absorbed = (radius ** 2) - ((radius - magnitude_absorbed - 1) ** 2)
	testing("Absorbed [pellets_absorbed] (Radius [radius] -> [radius - magnitude_absorbed])")
	radius -= magnitude_absorbed

	if(radius < 1)
		not_done_yet = FALSE
		QDEL_NULL(src)
		return

	var/list/all_the_turfs_were_gonna_lacerate = RANGE_TURFS(radius, target) - RANGE_TURFS(radius-1, target)
	num_pellets = all_the_turfs_were_gonna_lacerate.len
	for(var/T in all_the_turfs_were_gonna_lacerate)
		var/turf/shootat_turf = T
		var/obj/projectile/P = new projectile_type(get_turf(target))
		//Shooting Code:
		P.range = radius+1
		P.original = shootat_turf
		P.fired_from = target
		P.firer = target // don't hit ourself that would be really annoying
		P.permutated += target // don't hit the target we hit already with the flak
		P.suppressed = SUPPRESSED_VERY // set the projectiles to make no message so we can do our own aggregate message
		P.preparePixelProjectile(shootat_turf, target)
		RegisterSignal(P, COMSIG_PROJECTILE_SELF_ON_HIT, .proc/pellet_hit)
		RegisterSignal(P, COMSIG_PROJECTILE_RANGE_OUT, .proc/pellet_range)
		pellets += P
		P.fire()

///One of our pellets hit something, record what it was and check if we're done (terminated == num_pellets)
/datum/component/pellet_cloud/proc/pellet_hit(obj/projectile/P, atom/movable/firer, atom/target, Angle)
	pellets -= P
	terminated++
	hits++
	targets_hit[target]++
	if(terminated == num_pellets)
		finalize()

///One of our pellets disappeared due to hitting their max range, remove it from our list and check if we're done (terminated == num_pellets)
/datum/component/pellet_cloud/proc/pellet_range(obj/projectile/P)
	pellets -= P
	terminated++
	if(terminated == num_pellets)
		finalize()

///All of our pellets are accounted for, time to go target by target and tell them how many things they got hit by.
/datum/component/pellet_cloud/proc/finalize()
	for(var/atom/target in targets_hit)
		var/num_hits = targets_hit[target]
		if(num_hits > 1)
			target.visible_message("<span class='danger'>[target] is hit by [num_hits] [proj_name]s!</span>", "<span class='userdanger'>You're hit by [num_hits] [proj_name]s!</span>")
		else
			target.visible_message("<span class='danger'>[target] is hit by a [proj_name]!</span>", "<span class='userdanger'>You're hit by a [proj_name]!</span>")

	not_done_yet = FALSE
	qdel(src)

///All of our pellets are accounted for, time to go target by target and tell them how many things they got hit by.
/datum/component/pellet_cloud/proc/grenade_armed()
	LAZYINITLIST(bodies)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/grenade_moved)
	RegisterSignal(parent, COMSIG_MOVABLE_UNCROSSED, .proc/grenade_uncrossed)

///All of our pellets are accounted for, time to go target by target and tell them how many things they got hit by.
/datum/component/pellet_cloud/proc/grenade_moved()
	LAZYCLEARLIST(bodies)
	for(var/mob/living/L in get_turf(parent))
		testing("[L] is in bodies")
		bodies += L

///All of our pellets are accounted for, time to go target by target and tell them how many things they got hit by.
/datum/component/pellet_cloud/proc/grenade_uncrossed(atom/movable/AM)
	if(AM in bodies)
		testing("[AM] is out of bodies now")
	bodies -= AM

