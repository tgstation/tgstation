
/datum/component/artifact/repulsor
	associated_object = /obj/structure/artifact/repulsor
	weight = ARTIFACT_COMMON
	type_name = "Repulsor/Impulsor"
	activation_message = "opens up, a weird aura starts emitting from it!"
	deactivation_message = "closes up."
	xray_result = "SEGMENTED"
	var/attract = FALSE //if FALSE, repulse, otherwise, attract
	var/strength
	var/range
	var/cooldown_time
	COOLDOWN_DECLARE(cooldown)

/datum/component/artifact/repulsor/setup()
	attract = prob(40)
	range = rand(1,3)
	cooldown_time = rand(3,5) SECONDS
	strength = rand(MOVE_FORCE_DEFAULT,MOVE_FORCE_OVERPOWERING)
	potency += cooldown_time / 4 + strength / 3000
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/component/artifact, artifact_deactivate)), round(20 * (potency * 10) SECONDS))

/datum/component/artifact/repulsor/effect_touched(mob/user)
	if(!COOLDOWN_FINISHED(src,cooldown))
		return
	pulse()
	COOLDOWN_START(src,cooldown,cooldown_time)

/datum/component/artifact/repulsor/effect_process()
	. = ..()
	if(prob(100 - potency))
		return
	pulse()

/datum/component/artifact/repulsor/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_HITBY, PROC_REF(pulse))

/datum/component/artifact/repulsor/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_HITBY)

/datum/component/artifact/repulsor/proc/pulse(datum/source,atom/movable/thrown, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!active)
		return
	holder.visible_message(span_warning("[holder] emits a pulse of energy, throwing things [attract ? "towards it!" : "away from it!"]"))
	var/owner_turf = get_turf(holder)
	if(isnull(thrown))
		for(var/atom/movable/throwee in oview(range,holder))
			if(throwee.anchored)
				continue
			if(attract)
				throwee.safe_throw_at(holder, strength / 3000, 1, force = strength)
			else
				var/throwtarget = get_edge_target_turf(get_turf(throwee), get_dir(owner_turf, get_step_away(throwee, owner_turf)))
				throwee.safe_throw_at(throwtarget, strength / 3000, 1, force = strength)
	else if(throwingdatum?.thrower)
		thrown.safe_throw_at(throwingdatum.thrower, get_dist(holder, throwingdatum.thrower), 1, force = strength)
