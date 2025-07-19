/obj/effect/decal/cleanable
	gender = PLURAL
	layer = CLEANABLE_FLOOR_OBJECT_LAYER
	flags_1 = UNPAINTABLE_1
	var/list/random_icon_states = null
	/// When two of these are on a same tile or do we need to merge them into just one?
	var/mergeable_decal = TRUE
	var/beauty = 0
	/// The type of cleaning required to clean the decal. See __DEFINES/cleaning.dm for the options
	var/clean_type = CLEAN_TYPE_LIGHT_DECAL
	///The reagent this decal holds. Leave blank for none.
	var/datum/reagent/decal_reagent
	///The amount of reagent this decal holds, if decal_reagent is defined
	var/reagent_amount = 0
	/// If TRUE, gains TRAIT_MOPABLE on init - thus this cleanable will cleaned if its turf is cleaned
	/// Set to FALSE for things that hang high on the walls or things which generally shouldn't be mopped up
	var/is_mopped = TRUE

/obj/effect/decal/cleanable/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if (LAZYLEN(random_icon_states))
		icon_state = pick(random_icon_states)
		base_icon_state = icon_state

	if (isturf(loc))
		for (var/obj/effect/decal/cleanable/other in loc)
			if (other != src && other.type == type && !QDELETED(other) && replace_decal(other))
				handle_merge_decal(other)
				return INITIALIZE_HINT_QDEL

	if (is_mopped)
		ADD_TRAIT(src, TRAIT_MOPABLE, INNATE_TRAIT)

	if (LAZYLEN(diseases))
		add_diseases(diseases)

	AddElement(/datum/element/beauty, beauty)

	var/turf/our_turf = get_turf(src)
	if (our_turf && is_station_level(our_turf.z))
		SSblackbox.record_feedback("tally", "station_mess_created", 1, name)

/obj/effect/decal/cleanable/Destroy()
	var/turf/our_turf = get_turf(src)
	if (our_turf && is_station_level(our_turf.z))
		SSblackbox.record_feedback("tally", "station_mess_destroyed", 1, name)
	return ..()

/obj/effect/decal/cleanable/proc/add_diseases(list/datum/disease/diseases)
	var/list/datum/disease/diseases_to_add = list()
	for (var/datum/disease/disease as anything in diseases)
		if (disease.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
			diseases_to_add += disease
	if (LAZYLEN(diseases_to_add))
		AddComponent(/datum/component/infective, diseases_to_add)

/// Check if we should give up in favor of the pre-existing decal
/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/other)
	if (mergeable_decal)
		return TRUE

/obj/effect/decal/cleanable/wash(clean_types)
	. = ..()
	if (. || clean_types & clean_type)
		qdel(src)
		. |= COMPONENT_CLEANED|COMPONENT_CLEANED_GAIN_XP

/obj/effect/decal/cleanable/proc/handle_merge_decal(obj/effect/decal/cleanable/merger)
	if (!reagents && !decal_reagent)
		return

	if (!reagents && !merger.reagents && (!merger.decal_reagent || merger.decal_reagent == decal_reagent))
		merger.decal_reagent = decal_reagent
		merger.reagent_amount += reagent_amount
	else if (lazy_init_reagents() && merger.lazy_init_reagents())
		merger.reagents.maximum_volume += reagents.total_volume
		reagents.trans_to(merger, reagents.total_volume)

/// Returns reagents datum if it exists, or lazyloads one if it doesn't
/obj/effect/decal/cleanable/proc/lazy_init_reagents()
	RETURN_TYPE(/datum/reagents)
	if (reagents)
		return reagents

	if (!decal_reagent)
		return

	create_reagents(reagent_amount)
	reagents.add_reagent(decal_reagent, reagent_amount)
	return reagents

/obj/effect/decal/cleanable/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	// Why are rags cups???
	if (!istype(tool, /obj/item/reagent_containers/cup) || istype(tool, /obj/item/rag))
		return NONE

	if (!lazy_init_reagents()?.total_volume)
		to_chat(user, span_notice("[src] isn't thick enough to scoop up!"))
		return ITEM_INTERACT_BLOCKING

	if (!reagents.trans_to(tool, reagents.total_volume, transferred_by = user))
		to_chat(user, span_warning("[tool] is full!"))
		return ITEM_INTERACT_BLOCKING

	to_chat(user, span_notice("You scoop up [reagents.total_volume > 0 ? "some of " : ""]\the [src] into \the [tool]!"))
	if (!reagents.total_volume) //scooped up all of it
		qdel(src)
	return ITEM_INTERACT_SUCCESS

/// Checks if this decal can be bloodcrawled in
/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	if (decal_reagent == /datum/reagent/blood || reagents?.has_reagent(/datum/reagent/blood))
		return TRUE

	var/list/blood_DNA = GET_ATOM_BLOOD_DECALS(src)
	for (var/blood_key in blood_DNA)
		var/datum/blood_type/blood_type = blood_DNA[blood_key]
		if (blood_type.reagent_type == /datum/reagent/blood)
			return TRUE

/// Creates a cleanable decal on a turf
/// Use this if your decal is one of one, and thus we should not spawn it if it's there already
/// Returns either the existing cleanable, the one we created, or null if we can't spawn on that turf
/turf/proc/spawn_unique_cleanable(obj/effect/decal/cleanable/cleanable_type)
	var/turf/checkturf = src
	while (isgroundlessturf(checkturf) && checkturf.zPassOut(DOWN))
		var/turf/below = GET_TURF_BELOW(checkturf)
		if (!below || !below.zPassIn(DOWN))
			break
		checkturf = below

	// There is no need to spam unique cleanables, they don't stack and it just chews cpu
	var/obj/effect/decal/cleanable/existing = locate(cleanable_type) in checkturf
	if (existing)
		return existing
	return new cleanable_type(checkturf)
