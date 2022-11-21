/// An object which should replace itself on initialisation with something which fell into a chasm.
/obj/item/chasm_detritus
	name = "chasm detritus"
	desc = "Abstract concept of an object which once fell into a deep hole."
	icon_state = "skub"
	/// The chance (out of 100) to fish out something from `default_contents`
	/// even if there's something in GLOB.chasm_storage.
	var/default_contents_chance = 25
	/// Stuff which you can always fish up even if nothing fell into a hole. Associative by type.
	var/static/list/default_contents = list(
		/obj/item/chasm_detritus = list(
			/obj/item/stack/ore/slag = 2,
			/obj/item/stack/sheet/bone = 3,
			/obj/effect/mob_spawn/corpse/human/skeleton = 1,
			/mob/living/simple_animal/hostile/asteroid/lobstrosity/lava = 1,
		),
		/obj/item/chasm_detritus/bodies = list(
			/obj/effect/mob_spawn/corpse/human/skeleton = 3,
			/mob/living/simple_animal/hostile/asteroid/lobstrosity/lava = 1,
		)
	)

/obj/item/chasm_detritus/Initialize(mapload)
	. = ..()
	if (prob(default_contents_chance))
		create_default_object()
		return

	var/list/chasm_stuff = find_chasm_contents()
	if (!chasm_stuff.len)
		create_default_object()
		return

	var/atom/movable/detritus = pick(chasm_stuff)
	detritus.forceMove(get_turf(src))
	qdel(src)

/// Instantiates something from the default list.
/obj/item/chasm_detritus/proc/create_default_object()
	var/contents_type = pick(default_contents[type])
	new contents_type(get_turf(src))
	qdel(src)

/// Returns a list of every object which is currently inside of a chasm.
/obj/item/chasm_detritus/proc/find_chasm_contents()
	var/list/chasm_contents = list()
	if (!GLOB.chasm_storage.len)
		return chasm_contents

	var/list/chasm_storage_resolved = recursive_list_resolve(GLOB.chasm_storage)
	for (var/obj/storage as anything in chasm_storage_resolved)
		for (var/thing as anything in storage.contents)
			chasm_contents += thing

	return chasm_contents


/// Variant of the chasm detritus that allows for an easier time at fishing out
/// bodies, and sometimes less desireable monsters too.
/obj/item/chasm_detritus/bodies
	default_contents_chance = 50


/obj/item/chasm_detritus/bodies/find_chasm_contents()
	var/list/chasm_contents = list()
	if (!GLOB.chasm_storage.len)
		return chasm_contents

	var/list/chasm_storage_resolved = recursive_list_resolve(GLOB.chasm_storage)
	for (var/obj/storage as anything in chasm_storage_resolved)
		for (var/thing as anything in storage.contents)
			if(!istype(thing, /mob))
				continue

			chasm_contents += thing

	return chasm_contents

