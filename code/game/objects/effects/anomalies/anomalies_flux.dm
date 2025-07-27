/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "flux"
	density = TRUE
	anomaly_core = /obj/item/assembly/signaler/anomaly/flux
	var/explosive = FLUX_EXPLOSIVE
	///range in whuich we zap
	var/zap_range = 1
	///strength of the zappy
	var/zap_power = 2500
	///the zappy flags
	var/zap_flags = ZAP_GENERATES_POWER | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/shock_damage = 1

/obj/effect/anomaly/flux/Initialize(mapload, new_lifespan, explosive = FLUX_EXPLOSIVE)
	. = ..()
	src.explosive = explosive
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	apply_wibbly_filters(src)


/obj/effect/anomaly/flux/anomalyEffect()
	..()
	for(var/mob/living/M in range(max(zap_range/3, 1), src))
		mobShock(M)
	var/area/area = get_area(src)
	if(area.apc)
		zap_power = area.apc.terminal?.surplus() > zap_power ? area.apc.terminal?.surplus() : zap_power
	else
		var/obj/structure/cable/found_node = locate(/obj/structure/cable) in range(zap_range, src)
		if(found_node?.powernet?.netexcess > zap_power)
			zap_power = found_node.powernet.netexcess
	zap_range = max(zap_power / (50 KILO WATTS), 1)
	var/machine_explode_chance = zap_range// 1 MW excess power = 20% chance to explode machines in range
	if(prob(machine_explode_chance))
		zap_flags |= ZAP_MACHINE_EXPLOSIVE | ZAP_MOB_STUN
	tesla_zap(source = src, zap_range = zap_range, power = zap_power, cutoff = 1e3, zap_flags = zap_flags)
	//If we popped our machine_explode_chance, reset everything to the initial value
	//Highly likely to destroy the area's APC in short order if there's a ton of excess power
	//so subsequent checks to area.apc will just keep everything as it was
	if(zap_flags & ZAP_MACHINE_EXPLOSIVE && !(initial(zap_flags) & ZAP_MACHINE_EXPLOSIVE))
		zap_power = initial(zap_power)
		zap_range = initial(zap_range)
		zap_flags = initial(zap_flags)

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
	if(istype(M))
		// 10% as powerful as the damage from its tesla zap
		M.electrocute_act(min(zap_power / 6000, 50), name, flags = SHOCK_NOGLOVES)

/obj/effect/anomaly/flux/detonate()
	switch(explosive)
		if(FLUX_EXPLOSIVE)
			explosion(src, devastation_range = 1, heavy_impact_range = 4, light_impact_range = 16, flash_range = 18) //Low devastation, but hits a lot of stuff.
		if(FLUX_LOW_EXPLOSIVE)
			explosion(src, heavy_impact_range = 1, light_impact_range = 4, flash_range = 6)
		if(FLUX_NO_EXPLOSION)
			new /obj/effect/particle_effect/sparks(loc)

/// A flux anomaly which doesn't explode or produce a core
/obj/effect/anomaly/flux/minor
	anomaly_core = null

// We need to override the default arguments here to achieve the desired effect
/obj/effect/anomaly/flux/minor/Initialize(mapload, new_lifespan, explosive = FLUX_NO_EXPLOSION)
	return ..()

///Bigger, meaner, immortal flux anomaly
/obj/effect/anomaly/flux/big
	immortal = TRUE
	anomaly_core = null

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
