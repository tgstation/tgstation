//WATER EFFECTS

/obj/effect/particle_effect/water
	name = "water"
	icon_state = "extinguish"
	pass_flags = PASSTABLE | PASSMACHINE | PASSSTRUCTURE | PASSGRILLE | PASSBLOB | PASSVEHICLE
	var/life = 15
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/particle_effect/water/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 70)

/obj/effect/particle_effect/water/Move(turf/newloc)
	if (--src.life < 1)
		qdel(src)
		return FALSE
	return ..()

/obj/effect/particle_effect/water/Bump(atom/A)
	if(reagents)
		reagents.expose(A)
	if(A.reagents)
		A.reagents.expose_temperature(-25)
	return ..()

///Extinguisher snowflake
/obj/effect/particle_effect/water/extinguisher

/obj/effect/particle_effect/water/extinguisher/Move()
	. = ..()
	if(!reagents)
		return
	reagents.expose(get_turf(src))
	for(var/atom/thing as anything in get_turf(src))
		reagents.expose(thing)

/// Starts the effect moving at a target with a delay in deciseconds, and a lifetime in moves
/// Returns the created loop
/obj/effect/particle_effect/water/extinguisher/proc/move_at(atom/target, delay, lifetime)
	var/datum/move_loop/loop = SSmove_manager.move_towards_legacy(src, target, delay, timeout = delay * lifetime, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_forcemove))
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, PROC_REF(movement_stopped))
	return loop

/obj/effect/particle_effect/water/extinguisher/proc/post_forcemove(datum/move_loop/source, success)
	SIGNAL_HANDLER
	if(!success)
		end_life(source)

/obj/effect/particle_effect/water/extinguisher/proc/movement_stopped(datum/move_loop/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		end_life(source)

/obj/effect/particle_effect/water/extinguisher/proc/end_life(datum/move_loop/engine)
	QDEL_IN(src, engine.delay) //Gotta let it stop drifting
	animate(src, alpha = 0, time = engine.delay)

/obj/effect/particle_effect/water/extinguisher/stomach_acid
	name = "acid"
	icon_state = "xenobarf"

// Stomach acid doesn't use legacy because it's not "targeted", and we instead want the circular sorta look
/obj/effect/particle_effect/water/extinguisher/stomach_acid/move_at(atom/target, delay, lifetime)
	var/datum/move_loop/loop = SSmove_manager.move_towards(src, target, delay, timeout = delay * lifetime, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(post_forcemove))
	RegisterSignal(loop, COMSIG_PARENT_QDELETING, PROC_REF(movement_stopped))
	return loop

/////////////////////////////////////////////
// GENERIC STEAM SPREAD SYSTEM

//Usage: set_up(number of bits of steam, use North/South/East/West only, spawn location)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like a smoking beaker, so then you can just call start() and the steam
// will always spawn at the items location, even if it's moved.

/* Example:
 *var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread() -- creates new system
 *steam.set_up(5, 0, mob.loc) -- sets up variables
 *OPTIONAL: steam.attach(mob)
 *steam.start() -- spawns the effect
*/
/////////////////////////////////////////////
/obj/effect/particle_effect/steam
	name = "steam"
	icon_state = "extinguish"
	density = FALSE

/obj/effect/particle_effect/steam/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 20)

/datum/effect_system/steam_spread
	effect_type = /obj/effect/particle_effect/steam

/obj/effect/particle_effect/water/Bump(atom/A)
	if(A.reagents && reagents)
		A.reagents.expose_temperature(reagents.chem_temp)
