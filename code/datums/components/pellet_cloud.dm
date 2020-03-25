/datum/component/pellet_cloud
	var/projectile_type
	var/num_pellets
	var/list/pellets = list()
	var/terminated = 0
	var/hits = 0
	var/list/targets_hit = list()
	var/atom/aim_target
	var/proj_name
	var/radius = 4
	var/not_done_yet = FALSE

/datum/component/pellet_cloud/Initialize(projectile_type, magnitude=5)
	if(!istype(parent, /obj/item/ammo_casing) && !isgrenade(parent))
		return COMPONENT_INCOMPATIBLE
	if(isgrenade(parent))
		not_done_yet = TRUE

	src.projectile_type = projectile_type
	if(istype(parent, /obj/item/ammo_casing))
		num_pellets = magnitude
	else if(isgrenade(parent))
		radius = magnitude

	var/obj/projectile/p = projectile_type
	proj_name = initial(p.name)

/datum/component/pellet_cloud/Destroy(force, silent)
	if(not_done_yet)
		return QDEL_HINT_LETMELIVE
	return ..()

/datum/component/pellet_cloud/RegisterWithParent()
	if(istype(parent, /obj/item/ammo_casing))
		RegisterSignal(parent, COMSIG_PELLET_CLOUD_INIT, .proc/create_pellets)
	else if(isgrenade(parent))
		RegisterSignal(parent, COMSIG_GRENADE_PRIME, .proc/circle_pellets)

/datum/component/pellet_cloud/UnregisterFromParent()
	if(not_done_yet)
		return QDEL_HINT_LETMELIVE
	UnregisterSignal(parent, list(COMSIG_PELLET_CLOUD_INIT, COMSIG_GRENADE_PRIME))

/datum/component/pellet_cloud/proc/create_pellets(obj/item/ammo_casing/A, target, user, fired_from, randomspread, distro)
	aim_target = target
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

/datum/component/pellet_cloud/proc/circle_pellets()
	if(radius < 1)
		return

	var/atom/target = parent
	var/list/all_the_turfs_were_gonna_lacerate = RANGE_TURFS(radius, target) - RANGE_TURFS(radius-1, target)
	num_pellets = all_the_turfs_were_gonna_lacerate.len
	for(var/turf/shootat_turf in all_the_turfs_were_gonna_lacerate)
		var/obj/projectile/P = new projectile_type(get_turf(target))
		//Shooting Code:
		P.range = radius+1
		P.original = shootat_turf
		P.fired_from = target

		P.firer = target // don't hit ourself that would be really annoying
		P.permutated += target // don't hit the target we hit already with the flak
		P.suppressed = SUPPRESSED_VERY

		P.preparePixelProjectile(shootat_turf, target)
		RegisterSignal(P, COMSIG_PROJECTILE_SELF_ON_HIT, .proc/pellet_hit)
		RegisterSignal(P, COMSIG_PROJECTILE_RANGE_OUT, .proc/pellet_range)
		pellets += P
		P.fire()

/datum/component/pellet_cloud/proc/pellet_hit(obj/projectile/P, atom/movable/firer, atom/target, Angle)
	pellets -= P
	terminated++
	hits++
	targets_hit[target]++

	if(terminated == num_pellets)
		finalize()

/datum/component/pellet_cloud/proc/pellet_range(obj/projectile/P)
	pellets -= P
	terminated++

	if(terminated == num_pellets)
		finalize()

/datum/component/pellet_cloud/proc/finalize()
	for(var/atom/target in targets_hit)
		var/num_hits = targets_hit[target]
		if(num_hits > 1)
			target.visible_message("<span class='danger'>[target] is hit by [num_hits] [proj_name]s!</span>", "<span class='userdanger'>You're hit by [num_hits] [proj_name]s!</span>")
		else
			target.visible_message("<span class='danger'>[target] is hit by a [proj_name]!</span>", "<span class='userdanger'>You're hit by a [proj_name]!</span>")

	not_done_yet = FALSE
	qdel(src)
