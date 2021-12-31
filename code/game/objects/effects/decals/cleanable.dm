/obj/effect/decal/cleanable
	gender = PLURAL
	layer = ABOVE_NORMAL_TURF_LAYER
	var/list/random_icon_states = null
	var/blood_state = "" //I'm sorry but cleanable/blood code is ass, and so is blood_DNA
	var/bloodiness = 0 //0-100, amount of blood in this decal, used for making footprints and affecting the alpha of bloody footprints
	var/mergeable_decal = TRUE //when two of these are on a same tile or do we need to merge them into just one?
	var/beauty = 0
	///The type of cleaning required to clean the decal. See __DEFINES/cleaning.dm for the options
	var/clean_type = CLEAN_TYPE_LIGHT_DECAL

/obj/effect/decal/cleanable/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	if (random_icon_states && (icon_state == initial(icon_state)) && length(random_icon_states) > 0)
		icon_state = pick(random_icon_states)
	create_reagents(300)
	if(loc && isturf(loc))
		for(var/obj/effect/decal/cleanable/C in loc)
			if(C != src && C.type == type && !QDELETED(C))
				if (replace_decal(C))
					return INITIALIZE_HINT_QDEL

	if(LAZYLEN(diseases))
		var/list/datum/disease/diseases_to_add = list()
		for(var/datum/disease/D in diseases)
			if(D.spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
				diseases_to_add += D
		if(LAZYLEN(diseases_to_add))
			AddComponent(/datum/component/infective, diseases_to_add)

	AddElement(/datum/element/beauty, beauty)

	var/turf/T = get_turf(src)
	if(T && is_station_level(T.z))
		SSblackbox.record_feedback("tally", "station_mess_created", 1, name)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/cleanable/Destroy()
	var/turf/T = get_turf(src)
	if(T && is_station_level(T.z))
		SSblackbox.record_feedback("tally", "station_mess_destroyed", 1, name)
	return ..()

/obj/effect/decal/cleanable/proc/replace_decal(obj/effect/decal/cleanable/C) // Returns true if we should give up in favor of the pre-existing decal
	if(mergeable_decal)
		return TRUE

/obj/effect/decal/cleanable/attackby(obj/item/W, mob/user, params)
	if((istype(W, /obj/item/reagent_containers/glass) && !istype(W, /obj/item/reagent_containers/glass/rag)) || istype(W, /obj/item/reagent_containers/food/drinks))
		if(src.reagents && W.reagents)
			. = 1 //so the containers don't splash their content on the src while scooping.
			if(!src.reagents.total_volume)
				to_chat(user, span_notice("[src] isn't thick enough to scoop up!"))
				return
			if(W.reagents.total_volume >= W.reagents.maximum_volume)
				to_chat(user, span_notice("[W] is full!"))
				return
			to_chat(user, span_notice("You scoop up [src] into [W]!"))
			reagents.trans_to(W, reagents.total_volume, transfered_by = user)
			if(!reagents.total_volume) //scooped up all of it
				qdel(src)
				return
	if(W.get_temperature()) //todo: make heating a reagent holder proc
		if(istype(W, /obj/item/clothing/mask/cigarette))
			return
		else
			var/hotness = W.get_temperature()
			reagents.expose_temperature(hotness)
			to_chat(user, span_notice("You heat [name] with [W]!"))
	else
		return ..()

/obj/effect/decal/cleanable/ex_act(severity)
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act(severity)
	return ..()

/obj/effect/decal/cleanable/fire_act(exposed_temperature, exposed_volume)
	if(reagents)
		reagents.expose_temperature(exposed_temperature)
	..()


//Add "bloodiness" of this blood's type, to the human's shoes
//This is on /cleanable because fuck this ancient mess
/obj/effect/decal/cleanable/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(iscarbon(AM) && blood_state && bloodiness >= 40)
		SEND_SIGNAL(AM, COMSIG_STEP_ON_BLOOD, src)
		update_appearance()

/obj/effect/decal/cleanable/wash(clean_types)
	. = ..()
	if (. || (clean_types & clean_type))
		qdel(src)
		return TRUE
	return .

/obj/effect/decal/cleanable/proc/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return bloodiness
	else
		return 0
