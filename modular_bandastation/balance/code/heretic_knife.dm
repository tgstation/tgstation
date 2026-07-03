#define MIN_DISTANSE_TO_EXPLODE 10

/datum/heretic_knowledge/limited_amount/starting
	var/explode_blade_limit
	var/exploded_blades

/datum/heretic_knowledge/limited_amount/starting/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()

	explode_blade_limit = 1

/datum/heretic_knowledge/limited_amount/starting/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	for(var/datum/weakref/ref as anything in created_items)
		var/atom/real_thing = ref.resolve()
		if(QDELETED(real_thing))
			LAZYREMOVE(created_items, ref)

	if(LAZYLEN(created_items) >= limit)
		var/atom/farthest_item
		var/farthest_distance

		for(var/datum/weakref/ref as anything in created_items)
			var/atom/item = ref.resolve()
			var/distance = get_dist(user, item)
			if(distance > farthest_distance)
				farthest_distance = distance
				farthest_item = item

		if(farthest_distance < MIN_DISTANSE_TO_EXPLODE)
			loc.balloon_alert(user, "ritual failed, at limit!")
			return FALSE

		if(exploded_blades >= explode_blade_limit)
			loc.balloon_alert(user, "ritual failed, at limit, we can't renounce our blades anymore!")
			return FALSE

		if(farthest_item)
			playsound(src, 'sound/effects/magic/hereticknock.ogg', 100, TRUE, 3)
			addtimer(CALLBACK(loc, TYPE_PROC_REF(/atom, balloon_alert), user, "we renounce the furthest blade!"), 0.5 SECONDS)
			explode_blade(farthest_item, 'sound/effects/magic/hereticknock.ogg')
			exploded_blades++
			return TRUE

	return TRUE

/datum/heretic_knowledge/limited_amount/starting/proc/explode_blade(atom/item_to_explode, sound_path)
	var/sound_length = rustg_sound_length(sound_path)
	playsound(item_to_explode, sound_path, 100, TRUE, 3)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), item_to_explode, 0, 0, 1), sound_length)
	addtimer(CALLBACK(src, PROC_REF(delete_blade), item_to_explode), (sound_length + 1))

/datum/heretic_knowledge/limited_amount/starting/proc/delete_blade(atom/item_to_delete)
	LAZYREMOVE(created_items, WEAKREF(item_to_delete))
	qdel(item_to_delete)

#undef MIN_DISTANSE_TO_EXPLODE

