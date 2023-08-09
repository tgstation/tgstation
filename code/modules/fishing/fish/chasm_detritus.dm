/// Regular default contents.
#define NORMAL_CONTENTS "normal"
/// Bodies-only default contents.
#define BODIES_ONLY "bodies_only"
/// No corpses (so there's still lobstrosities because they're the main threat with this).
#define NO_CORPSES "no_corpses"

/// An object which should replace itself on initialisation with something which fell into a chasm.
/obj/item/chasm_detritus
	name = "chasm detritus"
	desc = "Abstract concept of an object which once fell into a deep hole."
	icon = 'icons/obj/maintenance_loot.dmi'
	icon_state = "skub"
	/// The chance (out of 100) to fish out something from `default_contents`
	/// even if there's something in GLOB.chasm_storage.
	var/default_contents_chance = 25
	/// Key to the list we want to use from `default_contents`.
	var/default_contents_key = NORMAL_CONTENTS
	/// Stuff which you can always fish up even if nothing fell into a hole. Associative by type.
	var/static/list/default_contents = list(
		NORMAL_CONTENTS = list(
			/obj/item/stack/sheet/bone = 3,
			/obj/item/stack/ore/slag = 2,
			/mob/living/basic/mining/lobstrosity/lava = 1,
			/obj/effect/mob_spawn/corpse/human/skeleton = 1,
		),
		BODIES_ONLY = list(
			/obj/effect/mob_spawn/corpse/human/skeleton = 3,
			/mob/living/basic/mining/lobstrosity/lava = 1,
		),
		NO_CORPSES = list(
			/obj/item/stack/sheet/bone = 14,
			/obj/item/stack/ore/slag = 10,
			/mob/living/basic/mining/lobstrosity/lava = 1,
		),
	)

/obj/item/chasm_detritus/Initialize(mapload)
	. = ..()
	if (prob(default_contents_chance))
		create_default_object()
		return
	RegisterSignal(src, COMSIG_ATOM_FISHING_REWARD, PROC_REF(find_chasm_contents))

/// Returns the chosen detritus from the given list of things to choose from
/obj/item/chasm_detritus/proc/determine_detritus(list/chasm_stuff)
	return pick(chasm_stuff)

/// Instantiates something in its place from the default_contents list.
/obj/item/chasm_detritus/proc/create_default_object()
	var/contents_type = pick(default_contents[default_contents_key])
	new contents_type(get_turf(src))
	qdel(src)

/// Returns an objected which is currently inside of a nearby chasm.
/obj/item/chasm_detritus/proc/find_chasm_contents(datum/source, turf/fishing_spot)
	SIGNAL_HANDLER
	var/list/chasm_contents = get_chasm_contents(fishing_spot)

	if (!length(chasm_contents))
		create_default_object()
		return

	var/atom/movable/detritus = determine_detritus(chasm_contents)
	detritus.forceMove(get_turf(src))
	qdel(src)

/obj/item/chasm_detritus/proc/get_chasm_contents(turf/fishing_spot)
	. = list()
	for (var/obj/effect/abstract/chasm_storage/storage in range(5, fishing_spot))
		for (var/thing as anything in storage.contents)
			. += thing

/// Variant of the chasm detritus that allows for an easier time at fishing out
/// bodies, and sometimes less desireable monsters too.
/obj/item/chasm_detritus/restricted
	/// What type do we check for in the contents of the `/obj/effect/abstract/chasm_storage`
	/// contained in the `GLOB.chasm_storage` global list in `find_chasm_contents()`.
	var/chasm_storage_restricted_type = /obj

/obj/item/chasm_detritus/restricted/get_chasm_contents(turf/fishing_spot)
	. = list()
	for (var/obj/effect/abstract/chasm_storage/storage in range(5, fishing_spot))
		for (var/thing as anything in storage.contents)
			if(!istype(thing, chasm_storage_restricted_type))
				continue
			. += thing

/obj/item/chasm_detritus/restricted/objects
	default_contents_chance = 12.5
	default_contents_key = NO_CORPSES

/obj/item/chasm_detritus/restricted/bodies
	default_contents_chance = 12.5
	default_contents_key = BODIES_ONLY
	chasm_storage_restricted_type = /mob

/// This also includes all mobs fallen into chasms, regardless of distance
/obj/item/chasm_detritus/restricted/bodies/get_chasm_contents(turf/fishing_spot)
	. = ..()
	. |= GLOB.chasm_fallen_mobs

/// Body detritus is selected in favor of bodies belonging to sentient mobs
/// The first sentient body found in the list of contents is returned, otherwise
/// if none are sentient choose randomly.
/obj/item/chasm_detritus/restricted/bodies/determine_detritus(list/chasm_stuff)
	for(var/mob/fallen_mob as anything in chasm_stuff)
		if(fallen_mob.mind)
			return fallen_mob
	return ..()

#undef NORMAL_CONTENTS
#undef BODIES_ONLY
#undef NO_CORPSES
