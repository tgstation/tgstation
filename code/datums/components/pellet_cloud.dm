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
	var/holdup = FALSE

/datum/component/pellet_cloud/Initialize(projectile_type, num_pellets=5)
	//if(!isgun(parent) && !ismachinery(parent) && !isstructure(parent) && !isgrenade(parent))
		//return COMPONENT_INCOMPATIBLE
	if(isgrenade(parent))
		holdup = TRUE

	src.projectile_type = projectile_type
	src.num_pellets = num_pellets
	var/obj/projectile/p = projectile_type
	proj_name = initial(p.name)

/datum/component/pellet_cloud/Destroy(force, silent)
	if(holdup)
		testing("Tried dying")
		return QDEL_HINT_LETMELIVE
	. = ..()


/datum/component/pellet_cloud/RegisterWithParent()
	if(istype(parent, /obj/item/ammo_casing))
		RegisterSignal(parent, COMSIG_PELLET_CLOUD_INIT, .proc/create_pellets)
	else if(isgrenade(parent))
		RegisterSignal(parent, COMSIG_GRENADE_PRIME, .proc/circle_pellets)

/datum/component/pellet_cloud/UnregisterFromParent()
	if(holdup)
		testing("Not today, binch")
		return QDEL_HINT_LETMELIVE
	testing("Deleted")
	UnregisterSignal(parent, list(COMSIG_PELLET_CLOUD_INIT, COMSIG_GRENADE_PRIME))

//datum/component/pellet_cloud/proc/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)
	//do_shrapnel(firer, target)

/datum/component/pellet_cloud/proc/create_pellets(obj/item/ammo_casing/A, target, user, fired_from)
	testing("Creating pellets in pellet cloud")
	aim_target = target
	for(var/pelleties = 0, pelleties < num_pellets, pelleties++)
		var/obj/projectile/P = new projectile_type(get_turf(parent))
		P.original = target
		P.spread = rand(-40,40)
		P.fired_from = fired_from
		P.firer = user
		P.permutated += user
		P.suppressed = TRUE
		P.preparePixelProjectile(target, fired_from)

		P.fire()

		pellets += P
		RegisterSignal(P, COMSIG_PROJECTILE_SELF_ON_HIT, .proc/pellet_hit)
		RegisterSignal(P, COMSIG_PROJECTILE_SWEET_FA, .proc/pellet_range)


/datum/component/pellet_cloud/proc/circle_pellets()
	if(radius < 1)
		return

	//var/firer = parent
	var/atom/target = parent
	var/list/all_the_turfs_were_gonna_lacerate = RANGE_TURFS(radius, target) - RANGE_TURFS(radius-1, target)
	num_pellets = all_the_turfs_were_gonna_lacerate.len
	testing("Creating pellets in pellet circle")
	var/turf/target_turf = get_turf(target)
	for(var/turf/shootat_turf in all_the_turfs_were_gonna_lacerate)
		var/obj/projectile/P = new projectile_type(get_turf(target))
		//Shooting Code:
		P.range = radius+1
		P.original = shootat_turf
		P.fired_from = target

		P.firer = target // don't hit ourself that would be really annoying
		P.permutated += target // don't hit the target we hit already with the flak
		P.suppressed = TRUE

		P.preparePixelProjectile(shootat_turf, target)
		RegisterSignal(P, COMSIG_PROJECTILE_SELF_ON_HIT, .proc/pellet_hit)
		RegisterSignal(P, COMSIG_PROJECTILE_SWEET_FA, .proc/pellet_range)
		P.fire()
		pellets += P


	//testing("Created [num_pellets] pellets")

/datum/component/pellet_cloud/proc/pellet_hit(obj/projectile/P, atom/movable/firer, atom/target, Angle)
	terminated++
	hits++
	//testing("Pellet [terminated]/[num_pellets] hit [target]")
	if(!targets_hit[target])
		targets_hit[target] = 1
	else
		targets_hit[target] += 1

	if(terminated == num_pellets)
		finalize()

/datum/component/pellet_cloud/proc/pellet_range(obj/projectile/P)
	//testing("Pellet [terminated]/[num_pellets] missed")
	terminated++

	if(terminated == num_pellets)
		finalize()

/datum/component/pellet_cloud/proc/finalize()
	//testing("FINISHED ---- handled [terminated]/[num_pellets]")
	var/i = 0
	for(var/atom/targeties in targets_hit)
		i++
		//testing("Target [i]/[targets_hit.len]: [targeties.name]")
		var/num_hits = targets_hit[targeties]
		if(num_hits > 1)
			targeties.visible_message("<span class='danger'>[targeties] is hit by [num_hits] [proj_name]s!</span>", targeties)
			to_chat(targeties, "<span class='userdanger'>You're hit by [num_hits] [proj_name]s!</span>", targeties)
		else
			targeties.visible_message("<span class='danger'>[targeties] is hit by a [proj_name]!</span>")
			to_chat(targeties, "<span class='userdanger'>You're hit by a [proj_name]!</span>", targeties)

	holdup = FALSE
	qdel(src)
/*
/datum/component/pellet_cloud/proc/do_shrapnel(mob/firer, atom/target)
	if(radius < 1)
		return
	var/turf/target_turf = get_turf(target)
	for(var/turf/shootat_turf in RANGE_TURFS(radius, target) - RANGE_TURFS(radius-1, target))

		var/obj/projectile/P = new projectile_type(target_turf)
		//Shooting Code:
		P.range = radius+1
		if(override_projectile_range)
			P.range = override_projectile_range
		P.preparePixelProjectile(shootat_turf, target)
		P.firer = firer // don't hit ourself that would be really annoying
		P.permutated += target // don't hit the target we hit already with the flak
		P.fire()
*/
