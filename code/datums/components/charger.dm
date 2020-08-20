/**
  *A component to add to a hostile simplemob to give it a charge attack.
  **/

/datum/component/charger
	var/mob/living/simple_animal/hostile/simple_parent
	///Tracks if the parent is actively charging.
	var/charge_state = FALSE
	///In a charge, how many tiles will the parent travel?
	var/charge_distance = 3
	///How often can the charging parent actually charge? Effects the cooldown between charges.
	var/charge_frequency = 6 SECONDS
	///If the parent is charging, how long will it stun it's target on success, and itself on failure?
	var/knockdown_time = 3 SECONDS
	///Declares a cooldown for potential charges right off the bat.
	COOLDOWN_DECLARE(charge_cooldown)

/datum/component/charger/Initialize(_charge_dist, _charge_freq, _knockdown_time)
	if(!ishostile(parent))
		return COMPONENT_INCOMPATIBLE
	simple_parent = parent
	if(_charge_dist)
		charge_distance = _charge_dist
	if(_charge_freq)
		charge_frequency = _charge_freq
	if(_knockdown_time)
		knockdown_time = _knockdown_time
	RegisterSignal(parent, list(COMSIG_HOSTILE_CHARGING_TARGET), .proc/enter_charge)
	RegisterSignal(parent, list(COMSIG_HOSTILE_POST_CHARGE), .proc/charge_check)
	RegisterSignal(parent, list(COMSIG_HOSTILE_STOP_CHARGE), .proc/charge_end)

/**
  * Proc that handles a charge attack for a mob.
  */
/datum/component/charger/proc/enter_charge(var/atom/target)
	var/target_distance = get_dist(simple_parent,target)
	if((simple_parent.mobility_flags & (MOBILITY_MOVE | MOBILITY_STAND)) != (MOBILITY_MOVE | MOBILITY_STAND) || charge_state)
		return
	if((target_distance > simple_parent.minimum_distance) && (target_distance <= charge_distance))
		return
	if(!(COOLDOWN_FINISHED(src, charge_cooldown)) || !simple_parent.has_gravity() || !target.has_gravity())
		return
	simple_parent.Shake(15, 15, 1 SECONDS)
	//sleep(1.5 SECONDS) //Provides a visable wind up and tell for all charging mobs, with consistant visuals each time.
	charge_state = TRUE
	simple_parent.throw_at(target, charge_distance, 1, simple_parent, FALSE, TRUE, callback = CALLBACK(src, .proc/charge_end))
	COOLDOWN_START(src, charge_cooldown, charge_frequency)

/**
  * Proc that resets a charging mob's target.
  */
/datum/component/charger/proc/charge_end()
	charge_state = FALSE

/**
  * Proc that tells the hostile mob to use the proper thrown behavior, like a charge, instead of the usual being tossed around.
  */
/datum/component/charger/proc/charge_check()
	return COMPONENT_HOSTILE_POSTCHARGE_IMPACT

