/datum/component/impact_explode
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/dev
	var/heavy
	var/light
	var/flame
	var/flash
	var/log
	var/ignorecap
	var/silent
	var/smoke

/datum/component/impact_explode/Initialize(_dev, _heavy, _light, _flash, _flame, _silent, _smoke, _log, _ignorecap)
	if(istype(parent, /atom/movable))
		RegisterSignal(COMSIG_MOVABLE_IMPACT, .proc/throw_hit)
		if(istype(parent, /obj/item/projectile) || istype(parent, /datum/projectile_generator))
			to_chat(world, "DEBUG: impact_explode registering to a projectile or generator)
			RegisterSignal(COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)
	if(isnum(_dev))
		dev = _dev
	if(isnum(_heavy))
		heavy = _heavy
	if(isnum(_light))
		light = _light
	if(isnum(_flame))
		flame = _flame
	if(isnum(_flash))
		flash = _flash
	if(!isnull(_log))
		log = _log
	if(!isnull(_ignorecap))
		ignorecap = _ignorecap
	if(!isnull(_silent))
		silent = _silent
	if(!isnull(_smoke))
		smoke = _smoke

/datum/component/impact_explode/proc/projectile_hit(obj/item/projectile/P, atom/A, blocked)
	to_chat(world, "DEBUG: projectile_hit called P [P] A [A] blocked [blocked]")
	explosion(A, dev, heavy, light, flash, log, ignorecap, flame, silent, smoke)
	return ..()

/datum/component/impact_explode/proc/throw_hit(atom/A, datum/thrownthing/D)
	explosion(A, dev, heavy, light, flash, log, ignorecap, flame, silent, smoke)
	return ..()
