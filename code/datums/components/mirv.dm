/datum/component/mirv
	var/projectile_type
	var/radius // shoots a projectile for every turf on this radius from the hit target
	var/override_projectile_range

/datum/component/mirv/Initialize(projectile_type, radius=1, override_projectile_range)
	if(!isgun(parent) && !ismachinery(parent) && !isstructure(parent) && !isgrenade(parent) && !isprojectilespell(parent))
		return COMPONENT_INCOMPATIBLE

	src.projectile_type = projectile_type
	src.radius = radius
	src.override_projectile_range = override_projectile_range

	if(isgrenade(parent))
		parent.AddComponent(/datum/component/pellet_cloud, projectile_type=projectile_type)

/datum/component/mirv/RegisterWithParent()
	if(ismachinery(parent) || isstructure(parent) || isgun(parent) || isprojectilespell(parent)) // turrets, etc
		RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, PROC_REF(projectile_hit))

/datum/component/mirv/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PROJECTILE_ON_HIT))

/datum/component/mirv/proc/projectile_hit(datum/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(do_shrapnel), firer, target)

/datum/component/mirv/proc/do_shrapnel(mob/firer, atom/target)
	if(radius < 1)
		return
	var/turf/target_turf = get_turf(target)
	for(var/turf/shootat_turf in RANGE_TURFS(radius, target) - RANGE_TURFS(radius-1, target))

		var/obj/projectile/proj = new projectile_type(target_turf)
		//Shooting Code:
		proj.range = radius+1
		if(override_projectile_range)
			proj.range = override_projectile_range
		proj.aim_projectile(shootat_turf, target)
		proj.firer = firer // don't hit ourself that would be really annoying
		proj.impacted = list(WEAKREF(target) = TRUE) // don't hit the target we hit already with the flak
		proj.fire()
