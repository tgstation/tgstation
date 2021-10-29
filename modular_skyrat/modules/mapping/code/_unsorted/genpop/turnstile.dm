/obj/machinery/turnstile
	name = "\improper turnstile"
	desc = "A mechanical door that permits one-way access and prevents tailgating."
	icon = 'modular_skyrat/modules/mapping/icons/unique/turnstile.dmi'
	icon_state = "turnstile_map"
	density = TRUE
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, rad = 100, fire = 90, acid = 70)
	anchored = TRUE
	use_power = FALSE
	idle_power_usage = 2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = OPEN_DOOR_LAYER
	var/last_bumped = 0


/obj/machinery/turnstile/Initialize()
	. = ..()
	icon_state = "turnstile"

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
		COMSIG_ATOM_EXIT = .proc/on_exit,
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/turnstile/can_atmos_pass(turf/T)
	return TRUE

/obj/machinery/turnstile/bullet_act(obj/projectile/P, def_zone)
	return //Pass through!

/obj/machinery/turnstile/proc/allowed_access(mob/bumper)
	if(bumper.pulledby && ismob(bumper.pulledby))
		return allowed(bumper.pulledby) | allowed(bumper)
	else
		return allowed(bumper)


/obj/machinery/turnstile/CanPass(atom/movable/mover, border_dir)
	if(isliving(mover))
		var/mob/living/living_mover = mover

		if(world.time - living_mover.last_bumped <= 5)
			return FALSE
		living_mover.last_bumped = world.time

		var/allowed_access = FALSE
		var/turf/behind = get_step(src, dir)

		if(living_mover in behind.contents)
			allowed_access = allowed_access(living_mover)
		else
			return FALSE

		if(allowed_access)
			return TRUE
		else
			return FALSE
	return ..()


/obj/machinery/turnstile/Bumped(atom/movable/AM)
	if(ismob(AM) && world.time - last_bumped > 5)
		to_chat(usr, span_notice("[src] resists your efforts."))
		flick("deny", src)
		playsound(src,'sound/machines/deniedbeep.ogg',50,0,3)
		last_bumped = world.time


/obj/machinery/turnstile/proc/on_entered(datum/source, atom/movable/entering)
	SIGNAL_HANDLER

	flick("operate", src)
	playsound(src, 'sound/items/ratchet.ogg', 50, 0, 3)


/obj/machinery/turnstile/proc/on_exit(datum/source, atom/movable/leaving)
	SIGNAL_HANDLER

	if(isliving(leaving))
		var/mob/living/skedaddling = leaving
		var/outdir = dir
		if(allowed_access(skedaddling))
			outdir = REVERSE_DIR(dir)
		var/turf/outturf = get_step(src, outdir)
		var/canexit = !outturf.is_blocked_turf()

		if(!canexit && world.time - skedaddling.last_bumped <= 5)
			to_chat(usr, span_notice("[src] resists your efforts."))
		skedaddling.last_bumped = world.time

		if(!canexit)
			return COMPONENT_ATOM_BLOCK_EXIT
