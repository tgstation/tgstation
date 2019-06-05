/datum/component/homing
	var/turning_speed
	var/override_projectile_range // if you want the projectile to have an altered distance it can go

/datum/component/homing/Initialize(turning_speed=10, override_projectile_range)
	if(!isgun(parent) && !ismachinery(parent) && !isstructure(parent))
		return COMPONENT_INCOMPATIBLE

	src.turning_speed = turning_speed
	src.override_projectile_range = override_projectile_range

/datum/component/homing/RegisterWithParent()
	if(ismachinery(parent) || isstructure(parent) || isgun(parent)) // turrets, etc
		RegisterSignal(parent, COMSIG_PROJECTILE_BEFORE_FIRE, .proc/projectile_firing)

/datum/component/homing/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PROJECTILE_BEFORE_FIRE))

/datum/component/homing/proc/projectile_firing(atom/fired_from, obj/item/projectile/fired, atom/target)
	do_homing(fired, target)

/datum/component/homing/proc/do_homing(obj/item/projectile/fired, atom/target)
	fired.set_homing_target(target)
	fired.homing_turn_speed = turning_speed
	if(override_projectile_range != null)
		fired.range = override_projectile_range