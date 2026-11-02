// Ratwood's own rules of single crafting recipes (roguecrafting/structure.dm, engineering.dm, turfs.dm,
// roguejobs/gravedigger/gravemarker.dm TurfCheck(), and the diagonal of structure.dm), on the recipes the porter writes into
// crafting/ported/craft_recipes.dm under Ratwood's paths; Azure Peak's where the recipe is Azure's. A rule on a parent path
// covers every recipe below it, as in Ratwood. Ratwood's open space is TG's /turf/open/openspace here.

/// Ratwood structure TurfCheck(): nothing is built over open space or water.
/datum/crafting_recipe/roguetown/structure/rogue_turf_check(mob/living/user, turf/target)
	if(istype(target, /turf/open/openspace) || istype(target, /turf/open/water))
		return FALSE
	return ..()

/// Ratwood: a noose needs open air above it that is not open space; with no level above (the camps), anywhere.
/datum/crafting_recipe/roguetown/structure/noose/rogue_turf_check(mob/living/user, turf/target)
	var/turf/above = get_step_multiz(target, UP)
	if(!above)
		return TRUE
	return isopenturf(above) && !istype(above, /turf/open/openspace)

/// Ratwood stairs going down: open space ahead, and solid open ground below it without stairs or anything dense.
/datum/crafting_recipe/roguetown/structure/stairsd/rogue_turf_check(mob/living/user, turf/target)
	return rogue_stairs_down_clear(user, target)

/datum/crafting_recipe/roguetown/structure/stonestairsd/rogue_turf_check(mob/living/user, turf/target)
	return rogue_stairs_down_clear(user, target)

/proc/rogue_stairs_down_clear(mob/living/user, turf/target)
	var/turf/ahead = get_step(target, user.dir)
	if(!istype(ahead, /turf/open/openspace))
		return FALSE
	var/turf/below = get_step_multiz(ahead, DOWN)
	if(!isopenturf(below) || istype(below, /turf/open/openspace))
		return FALSE
	for(var/obj/structure/thing in below)
		if(istype(thing, /obj/structure/rockhill/stairs) || istype(thing, /obj/structure/stairs) || thing.density)
			return FALSE
	return TRUE

/// Ratwood floor grilles go over open space too, never over lava.
/datum/crafting_recipe/roguetown/structure/floorgrille/rogue_turf_check(mob/living/user, turf/target)
	if(istype(target, /turf/open/openspace))
		return TRUE
	if(istype(target, /turf/open/lava))
		return FALSE
	return ..()

/// Azure Peak's floor grille (an engineering recipe there).
/datum/crafting_recipe/roguetown/engineering/floorgrille/rogue_turf_check(mob/living/user, turf/target)
	if(istype(target, /turf/open/openspace))
		return TRUE
	if(istype(target, /turf/open/lava))
		return FALSE
	return ..()

/// Ratwood: a spike pit is dug in a dirt floor, one to a tile.
/datum/crafting_recipe/roguetown/structure/spike_pit/rogue_turf_check(mob/living/user, turf/target)
	if(!istype(get_step(user.loc, user.dir), /turf/open/floor/rogue/dirt))
		to_chat(user, span_info("I need a dirt floor to do this."))
		return FALSE
	if(locate(/obj/structure/spike_pit) in target)
		to_chat(user, span_info("There's already a pit of spikes here."))
		return FALSE
	return TRUE

/// Ratwood passages and shutters: not over open space, lava or water.
/datum/crafting_recipe/roguetown/engineering/passage/rogue_turf_check(mob/living/user, turf/target)
	return rogue_solid_ground(target) && ..()

/datum/crafting_recipe/roguetown/engineering/shutters/rogue_turf_check(mob/living/user, turf/target)
	return rogue_solid_ground(target) && ..()

/proc/rogue_solid_ground(turf/target)
	return !istype(target, /turf/open/openspace) && !istype(target, /turf/open/lava) && !istype(target, /turf/open/water)

/// Ratwood floors and walls of wood, stone and brick, tents, windows and druidic grass go on a rogue floor.
/datum/crafting_recipe/roguetown/turfs/wood/rogue_turf_check(mob/living/user, turf/target)
	return rogue_on_floor(target)

/datum/crafting_recipe/roguetown/turfs/stone/rogue_turf_check(mob/living/user, turf/target)
	return rogue_on_floor(target)

/datum/crafting_recipe/roguetown/turfs/brick/rogue_turf_check(mob/living/user, turf/target)
	return rogue_on_floor(target)

/datum/crafting_recipe/roguetown/turfs/tentwall/rogue_turf_check(mob/living/user, turf/target)
	return rogue_on_floor(target)

/datum/crafting_recipe/roguetown/turfs/tentdoor/rogue_turf_check(mob/living/user, turf/target)
	return rogue_on_floor(target) && ..()

/datum/crafting_recipe/roguetown/turfs/roguewindow/rogue_turf_check(mob/living/user, turf/target)
	return rogue_on_floor(target)

/datum/crafting_recipe/roguetown/turfs/druidic_grass/rogue_turf_check(mob/living/user, turf/target)
	return rogue_on_floor(target)

/proc/rogue_on_floor(turf/target)
	return !isclosedturf(target) && istype(target, /turf/open/floor/rogue)

/// Ratwood platforms of wood, stone and twigs span open space or water.
/datum/crafting_recipe/roguetown/turfs/wood/platform/rogue_turf_check(mob/living/user, turf/target)
	return rogue_over_gap(target)

/datum/crafting_recipe/roguetown/turfs/stone/platform/rogue_turf_check(mob/living/user, turf/target)
	return rogue_over_gap(target)

/datum/crafting_recipe/roguetown/turfs/twigplatform/rogue_turf_check(mob/living/user, turf/target)
	return rogue_over_gap(target)

/proc/rogue_over_gap(turf/target)
	return !isclosedturf(target) && (istype(target, /turf/open/openspace) || istype(target, /turf/open/water))

/// Ratwood cobblerock roads are laid on dirt.
/datum/crafting_recipe/roguetown/turfs/stone/cobblerock/rogue_turf_check(mob/living/user, turf/target)
	return !isclosedturf(target) && istype(target, /turf/open/floor/rogue/dirt)

/// Ratwood twig floors go on dirt or grass.
/datum/crafting_recipe/roguetown/turfs/twig/rogue_turf_check(mob/living/user, turf/target)
	if(isclosedturf(target))
		return FALSE
	var/static/list/grounds = typecacheof(list(
		/turf/open/floor/rogue/dirt,
		/turf/open/floor/rogue/grass,
		/turf/open/floor/rogue/grassred,
		/turf/open/floor/rogue/grassyel,
		/turf/open/floor/rogue/grasscold,
	))
	return is_type_in_typecache(target, grounds)

/// Ratwood grave marker: on a covered grave (a closed grave of the map or one dug and filled in) that has none yet.
/datum/crafting_recipe/roguetown/gravemarker/rogue_turf_check(mob/living/user, turf/target)
	var/found = FALSE
	for(var/obj/structure/closet/crate/wooden/rockhill/dirthole/hole in target)
		found = TRUE
		if(!hole.rogue_grave_covered())
			to_chat(user, span_warning("The grave isn't covered."))
			return FALSE
	if(!found)
		to_chat(user, span_warning("There is no grave here."))
		return FALSE
	if(locate(/obj/structure/gravemarker) in target)
		to_chat(user, span_warning("This grave is already hallowed."))
		return FALSE
	return TRUE

/// Ratwood diagonal: a railing corner faces the diagonal the crafter picks.
/datum/crafting_recipe/roguetown/structure/bordercorner
	rogue_diagonal = TRUE
