/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "flux"
	density = TRUE
	anomaly_core = /obj/item/assembly/signaler/anomaly/flux
	var/canshock = FALSE
	var/shockdamage = 20
	var/emp_zap = FLUX_EMP

/obj/effect/anomaly/flux/Initialize(mapload, new_lifespan, emp_zap = FLUX_EMP)
	. = ..()
	src.emp_zap = emp_zap
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	apply_wibbly_filters(src)

/obj/effect/anomaly/flux/anomalyEffect()
	..()
	canshock = TRUE
	for(var/mob/living/M in range(0, src))
		mobShock(M)

/obj/effect/anomaly/flux/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha=src.alpha)

/obj/effect/anomaly/flux/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	mobShock(AM)

/obj/effect/anomaly/flux/Bump(atom/A)
	mobShock(A)

/obj/effect/anomaly/flux/Bumped(atom/movable/AM)
	mobShock(AM)

/obj/effect/anomaly/flux/proc/mobShock(mob/living/M)
	if(canshock && istype(M))
		canshock = FALSE
		M.electrocute_act(shockdamage, name, flags = SHOCK_NOGLOVES)

/obj/effect/anomaly/flux/detonate()
	switch(emp_zap)
		if(FLUX_EMP)
			empulse(src, 4, 16)
			explosion(src, heavy_impact_range = 1, light_impact_range = 4, flash_range = 6) //Trashes the room a bit, might blow a small hole in the hull.
		if(FLUX_LIGHT_EMP)
			empulse(src, 4, 6)
			explosion(src, light_impact_range = 3, flash_range = 6)
		if(FLUX_NO_EMP)
			new /obj/effect/particle_effect/sparks(loc)

/// A flux anomaly which doesn't emp or produce a core
/obj/effect/anomaly/flux/minor
	anomaly_core = null

// We need to override the default arguments here to achieve the desired effect
/obj/effect/anomaly/flux/minor/Initialize(mapload, new_lifespan, emp_zap = FLUX_NO_EMP)
	return ..()

///Bigger, meaner, immortal flux anomaly
/obj/effect/anomaly/flux/big
	immortal = TRUE
	anomaly_core = null
	shockdamage = 30

	///range in whuich we zap
	var/zap_range = 1
	///strength of the zappy
	var/zap_power = 2500
	///the zappy flags
	var/zap_flags = ZAP_GENERATES_POWER | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE

/obj/effect/anomaly/flux/big/Initialize(mapload, new_lifespan)
	. = ..()

	transform *= 3

/obj/effect/anomaly/flux/big/anomalyEffect()
	. = ..()

	tesla_zap(source = src, zap_range = zap_range, power = zap_power, cutoff = 1e3, zap_flags = zap_flags)

/obj/effect/anomaly/flux/big/Bumped(atom/movable/bumpee)
	. = ..()

	if(isliving(bumpee))
		var/mob/living/living = bumpee
		living.dust()
