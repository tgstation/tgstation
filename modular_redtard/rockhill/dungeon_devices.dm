/// Devices of Ratwood's dungeon rooms: the arcyne wall of the forcewall spell (spells/wizard/conjure/forcewall.dm), which fades
/// arcyne_wall_time after it appears, and the bone pile (hostile/roguetown/haunt.dm) that raises a haunt and raises it again
/// whenever it is laid to rest, until the pile itself is broken. The pressure plates are in rockhill/redstone.dm.

/// Ratwood's weak forcefield: stops everything but a creature that wards off magic, and fades by itself.
/obj/structure/forcefield_weak
	/// Who conjured it, if anyone.
	var/mob/caster

/obj/structure/forcefield_weak/Initialize(mapload, mob/summoner)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	caster = summoner
	var/lifetime = rogue_value("arcyne_wall_time")
	if(lifetime > 0)
		QDEL_IN(src, lifetime)

/obj/structure/forcefield_weak/Destroy()
	caster = null
	return ..()

/obj/structure/forcefield_weak/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(ismob(mover))
		var/mob/walker = mover
		if(walker.can_block_magic(MAGIC_RESISTANCE, charge_cost = 0))
			return TRUE
	return FALSE

/// Ratwood boneloop: the pile's eerie rattle.
/datum/looping_sound/rockhill_bonepile
	mid_sounds = 'modular_redtard/rockhill/sound/vo/mobs/ghost/skullpile_loop.ogg'
	mid_length = 6.5 SECONDS
	volume = 100
	extra_range = -1

/// Ratwood's bone pile: a haunt rises from it a moment after it is made and again a moment after each haunt is gone; hit, it
/// sets its haunts on whoever struck it; broken, it takes its haunts with it and leaves a pinch of spice.
/obj/structure/bonepile
	/// The haunts it raised that are still about.
	var/list/mob/living/simple_animal/hostile/rogue/haunt/haunts
	/// A haunt is about to rise.
	var/spawning = FALSE
	var/datum/looping_sound/rockhill_bonepile/soundloop

/obj/structure/bonepile/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	soundloop = new(src, TRUE)
	spawn_haunt()

/obj/structure/bonepile/Destroy()
	QDEL_NULL(soundloop)
	spawning = FALSE
	for(var/mob/living/simple_animal/hostile/rogue/haunt/ghost as anything in haunts)
		ghost.rockhill_pile = null
		if(ghost.stat != DEAD)
			INVOKE_ASYNC(ghost, TYPE_PROC_REF(/mob/living, death))
	haunts = null
	var/turf/here = get_turf(src)
	if(here)
		new /obj/item/reagent_containers/powder/spice(here)
	return ..()

/obj/structure/bonepile/update_icon_state()
	. = ..()
	icon_state = spawning ? "hauntpile-r" : "hauntpile"

/obj/structure/bonepile/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!isliving(user))
		return
	for(var/mob/living/simple_animal/hostile/rogue/haunt/ghost as anything in haunts)
		ghost.rogue_set_upon(user)

/// Ratwood spawn_haunt(): the pile stirs, and a haunt rises after bonepile_haunt_delay.
/obj/structure/bonepile/proc/spawn_haunt()
	if(QDELETED(src) || spawning)
		return
	spawning = TRUE
	update_appearance(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(create_haunt)), rogue_value("bonepile_haunt_delay"))

/obj/structure/bonepile/proc/create_haunt()
	if(QDELETED(src) || !spawning)
		return
	spawning = FALSE
	var/mob/living/simple_animal/hostile/rogue/haunt/ghost = new(get_turf(src))
	ghost.rockhill_pile = src
	LAZYADD(haunts, ghost)
	update_appearance(UPDATE_ICON_STATE)

/// One of its haunts is gone: another rises.
/obj/structure/bonepile/proc/haunt_gone(mob/living/simple_animal/hostile/rogue/haunt/ghost)
	LAZYREMOVE(haunts, ghost)
	spawn_haunt()

/// A haunt of Ratwood: gone with its body when it dies, and bound to its bone pile.
/mob/living/simple_animal/hostile/rogue/haunt
	basic_mob_flags = DEL_ON_DEATH
	/// The bone pile that raised it (Ratwood slavepile).
	var/obj/structure/bonepile/rockhill_pile

/mob/living/simple_animal/hostile/rogue/haunt/Destroy()
	if(rockhill_pile)
		var/obj/structure/bonepile/pile = rockhill_pile
		rockhill_pile = null
		pile.haunt_gone(src)
	return ..()

/// Ratwood haunt Life(): strayed past haunt_leash_range of its pile, or off its level, it is pulled back to the pile, or
/// fades if the pile is nowhere to stand on.
/mob/living/simple_animal/hostile/rogue/haunt/Life(seconds_per_tick = SSMOBS_DT)
	. = ..()
	if(!rockhill_pile || stat == DEAD)
		return
	if(z == rockhill_pile.z && get_dist(src, rockhill_pile) <= rogue_value("haunt_leash_range"))
		return
	if(isturf(rockhill_pile.loc))
		forceMove(rockhill_pile.loc)
	else
		death()
