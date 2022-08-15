/// An object which should replace itself on initialisation with something which fell into a chasm.
/obj/item/chasm_detritus
	name = "chasm detritus"
	desc = "Abstract concept of an object which once fell into a deep hole."
	icon_state = "skub"
	/// Stuff which you can always fish up even if nothing fell into a hole.
	var/static/list/default_contents = list(\
		/obj/item/stack/ore/slag = 2, \
		/obj/item/stack/sheet/bone = 3, \
		/obj/effect/mob_spawn/corpse/human/skeleton = 1, \
		/mob/living/simple_animal/hostile/asteroid/lobstrosity/lava = 1, \
		)

/obj/item/chasm_detritus/Initialize(mapload)
	. = ..()
	if (prob(25))
		to_chat(world, "random chance")
		create_default_object()
		return

	var/list/chasm_stuff = find_chasm_contents()
	if (!chasm_stuff.len)
		to_chat(world, "chasms empty")
		create_default_object()
		return

	var/atom/movable/detritus = pick(chasm_stuff)
	var/moved = detritus.forceMove(get_turf(src))
	to_chat(world, "retrieved [detritus] [moved] [get_turf(src)]")
	qdel(src)

/obj/item/chasm_detritus/proc/create_default_object()
	var/contents_type = pick(default_contents)
	new contents_type(get_turf(src))
	qdel(src)

/obj/item/chasm_detritus/proc/find_chasm_contents()
	var/list/chasm_contents = list()
	if (!GLOB.chasm_storage.len)
		return chasm_contents

	clean_storage_refs()
	var/list/chasm_storage_resolved = recursive_list_resolve(GLOB.chasm_storage)
	for (var/obj/storage as anything in chasm_storage_resolved)
		for (var/thing as anything in storage.contents)
			chasm_contents += thing

	return chasm_contents

/obj/item/chasm_detritus/proc/clean_storage_refs()
	var/list/chasm_storage = list()
	for (var/datum/weakref/ref as anything in GLOB.chasm_storage)
		if (!ref.resolve())
			continue
		chasm_storage += ref
	GLOB.chasm_storage = chasm_storage
