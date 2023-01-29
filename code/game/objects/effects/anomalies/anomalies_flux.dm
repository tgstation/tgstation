
/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "flux"
	density = TRUE
	aSignal = /obj/item/assembly/signaler/anomaly/flux
	var/canshock = FALSE
	var/shockdamage = 20
	var/explosive = FLUX_EXPLOSIVE

/obj/effect/anomaly/flux/Initialize(mapload, new_lifespan, drops_core = TRUE, explosive = FLUX_EXPLOSIVE)
	. = ..()
	src.explosive = explosive
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

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
	switch(explosive)
		if(FLUX_EXPLOSIVE)
			explosion(src, devastation_range = 1, heavy_impact_range = 4, light_impact_range = 16, flash_range = 18) //Low devastation, but hits a lot of stuff.
		if(FLUX_LOW_EXPLOSIVE)
			explosion(src, heavy_impact_range = 1, light_impact_range = 4, flash_range = 6)
		if(FLUX_NO_EXPLOSION)
			new /obj/effect/particle_effect/sparks(loc)
