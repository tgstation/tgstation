/*
	Takes projectiles fired from structures or guns, and turns them into homing projectiles
*/

/datum/component/homing
	// turning speed of the projectile
	var/turning_speed
	// forcibly changes the range of the projectile
	var/override_projectile_range

/datum/component/homing/Initialize(_turning_speed=10, _override_projectile_range)
	if(!isgun(parent) && !ismachinery(parent) && !isstructure(parent))
		return COMPONENT_INCOMPATIBLE

	turning_speed = _turning_speed
	override_projectile_range = _override_projectile_range

/datum/component/homing/RegisterWithParent()
	if(ismachinery(parent) || isstructure(parent) || isgun(parent)) // turrets, etc
		RegisterSignal(parent, COMSIG_PROJECTILE_BEFORE_FIRE, .proc/projectile_firing)

/datum/component/homing/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PROJECTILE_BEFORE_FIRE))

/*
	Gets the projectile fired from the structure
*/
/datum/component/homing/proc/projectile_firing(atom/fired_from, obj/item/projectile/fired, atom/target)
	do_homing(fired, target)

/*
	Turns the projectile into a homing projectile
*/
/datum/component/homing/proc/do_homing(obj/item/projectile/fired, atom/target)
	fired.set_homing_target(target)
	fired.homing_turn_speed = turning_speed
	if(override_projectile_range != null)
		fired.range = override_projectile_range