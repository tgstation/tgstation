/obj/effect/decal/cleanable/fuel_pool
	name = "pool of fuel"
	desc = "A pool of flammable fuel. Its probably wise to clean this off before something ignites it..."
	icon_state = "fuel_pool"
	beauty = -50
	clean_type = CLEAN_TYPE_BLOOD
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	resistance_flags = UNACIDABLE | ACID_PROOF | FIRE_PROOF | FLAMMABLE //gross way of doing this but would need to disassemble fire_act call stack otherwise
	/// Maximum amount of hotspots this pool can create before deleting itself
	var/burn_amount = 3
	/// Is this fuel pool currently burning?
	var/burning = FALSE
	/// Type of hotspot fuel pool spawns upon being ignited
	var/hotspot_type = /obj/effect/hotspot

/obj/effect/decal/cleanable/fuel_pool/Initialize(mapload, burn_stacks)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_TURF_MOVABLE_THROW_LANDED = PROC_REF(ignition_trigger),
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	for(var/obj/effect/decal/cleanable/fuel_pool/pool in get_turf(src)) //Can't use locate because we also belong to that turf
		if(pool == src)
			continue
		pool.burn_amount =  max(min(pool.burn_amount + burn_stacks, 10), 1)
		return INITIALIZE_HINT_QDEL

	if(burn_stacks)
		burn_amount = max(min(burn_stacks, 10), 1)

	return INITIALIZE_HINT_LATELOAD

// Just in case of fires, do this after mapload.
/obj/effect/decal/cleanable/fuel_pool/LateInitialize()
// We don't want to burn down the create_and_destroy test area
#ifndef UNIT_TESTS
	RegisterSignal(src, COMSIG_ATOM_TOUCHED_SPARKS, PROC_REF(ignition_trigger))
#endif

/obj/effect/decal/cleanable/fuel_pool/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	ignite()

/**
 * Ignites the fuel pool. This should be the only way to ignite fuel pools.
 */
/obj/effect/decal/cleanable/fuel_pool/proc/ignite()
	if(burning)
		return
	burning = TRUE
	burn_process()

/**
 * Spends 1 burn_amount and spawns a hotspot. If burn_amount is equal to 0, deletes the fuel pool.
 * Else, queues another call of this proc upon hotspot getting deleted and ignites other fuel pools around itself after 0.5 seconds.
 * THIS SHOULD NOT BE CALLED DIRECTLY.
 */
/obj/effect/decal/cleanable/fuel_pool/proc/burn_process()
	SIGNAL_HANDLER

	burn_amount -= 1
	var/obj/effect/hotspot/hotspot = new hotspot_type(get_turf(src))
	addtimer(CALLBACK(src, PROC_REF(ignite_others)), 0.5 SECONDS)

	if(!burn_amount)
		qdel(src)
		return

	RegisterSignal(hotspot, COMSIG_QDELETING, PROC_REF(burn_process))

/**
 * Ignites other oil pools around itself.
 */
/obj/effect/decal/cleanable/fuel_pool/proc/ignite_others()
	for(var/obj/effect/decal/cleanable/fuel_pool/oil in range(1, get_turf(src)))
		oil.ignite()

/obj/effect/decal/cleanable/fuel_pool/bullet_act(obj/projectile/hit_proj)
	. = ..()
	ignite()
	log_combat(hit_proj.firer, src, "used [hit_proj] to ignite")

/obj/effect/decal/cleanable/fuel_pool/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	if(item.ignition_effect(src, user))
		ignite()
		log_combat(user, src, "used [item] to ignite")
	return ..()

/obj/effect/decal/cleanable/fuel_pool/proc/on_entered(datum/source, atom/movable/entered_atom)
	SIGNAL_HANDLER

	if(!entered_atom.throwing) // don't light from things being thrown over us, we handle that somewhere else
		ignition_trigger(source = src, enflammable_atom = entered_atom)

/obj/effect/decal/cleanable/fuel_pool/proc/ignition_trigger(datum/source, atom/movable/enflammable_atom)
	SIGNAL_HANDLER

	if(isitem(enflammable_atom))
		var/obj/item/enflamed_item = enflammable_atom
		if(enflamed_item.get_temperature() > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			ignite()
		return
	else if(isliving(enflammable_atom))
		var/mob/living/enflamed_liver = enflammable_atom
		if(enflamed_liver.on_fire)
			ignite()
	else if(istype(enflammable_atom, /obj/effect/particle_effect/sparks))
		ignite()


/obj/effect/decal/cleanable/fuel_pool/hivis
	icon_state = "fuel_pool_hivis"
