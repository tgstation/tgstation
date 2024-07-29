#define AQUARIUM_LAYER_STEP 0.01
/// Aquarium content layer offsets
#define AQUARIUM_MIN_OFFSET 0.02
#define AQUARIUM_MAX_OFFSET 1
/// The layer of the glass overlay
#define AQUARIUM_GLASS_LAYER 0.01
/// The layer of the aquarium pane borders
#define AQUARIUM_BORDERS_LAYER AQUARIUM_MAX_OFFSET + AQUARIUM_LAYER_STEP
/// Layer for stuff rendered below the glass overlay
#define AQUARIUM_BELOW_GLASS_LAYER 0.01

/obj/structure/aquarium
	name = "aquarium"
	desc = "A vivarium in which aquatic fauna and flora are usually kept and displayed."
	density = TRUE
	anchored = FALSE

	icon = 'icons/obj/aquarium/tanks.dmi'
	icon_state = "aquarium_map"

	integrity_failure = 0.3

	/// The icon state is used for mapping so mappers know what they're placing. This prefixes the real icon used in game.
	/// For an example, "aquarium" gives the base sprite of "aquarium_base", the glass is "aquarium_glass_water", and so on.
	var/icon_prefix = "aquarium"

	var/fluid_type = AQUARIUM_FLUID_FRESHWATER
	var/fluid_temp = DEFAULT_AQUARIUM_TEMP
	var/min_fluid_temp = MIN_AQUARIUM_TEMP
	var/max_fluid_temp = MAX_AQUARIUM_TEMP

	///While the feed storage is not empty, this is the interval which the fish are fed.
	var/feeding_interval = 3 MINUTES
	///The last time fishes were fed by the acquarium itsef.
	var/last_feeding

	/// Can fish reproduce in this quarium.
	var/allow_breeding = TRUE

	//This is the area where fish can swim
	var/aquarium_zone_min_px = 2
	var/aquarium_zone_max_px = 31
	var/aquarium_zone_min_py = 10
	var/aquarium_zone_max_py = 28

	var/list/fluid_types = list(AQUARIUM_FLUID_SALTWATER, AQUARIUM_FLUID_FRESHWATER, AQUARIUM_FLUID_SULPHWATEVER, AQUARIUM_FLUID_AIR)

	var/panel_open = FALSE

	///Current layers in use by aquarium contents
	var/list/used_layers = list()

	/// /obj/item/fish in the aquarium, sorted by type - does not include things with aquarium visuals that are not fish
	var/list/tracked_fish_by_type

	/// Var used to keep track of the current beauty of the aquarium, which can be throughfully changed by aquarium content.
	var/current_beauty = 150

/obj/structure/aquarium/Initialize(mapload)
	. = ..()
	update_appearance()
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(track_if_fish))
	AddElement(/datum/element/relay_attackers)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	create_reagents(6, SEALED_CONTAINER)
	RegisterSignal(reagents, COMSIG_REAGENTS_NEW_REAGENT, PROC_REF(start_autofeed))
	AddComponent(/datum/component/plumbing/aquarium, start = anchored)
	if(current_beauty)
		AddElement(/datum/element/beauty, current_beauty)
	ADD_KEEP_TOGETHER(src, INNATE_TRAIT)

/obj/structure/aquarium/proc/track_if_fish(atom/source, atom/initialized)
	SIGNAL_HANDLER
	if(isfish(initialized))
		LAZYADDASSOCLIST(tracked_fish_by_type, initialized.type, initialized)

/obj/structure/aquarium/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isfish(arrived))
		LAZYADDASSOCLIST(tracked_fish_by_type, arrived.type, arrived)

/obj/structure/aquarium/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVEASSOC(tracked_fish_by_type, gone.type, gone)

/obj/structure/aquarium/proc/start_autofeed(datum/source, new_reagent, amount, reagtemp, data, no_react)
	SIGNAL_HANDLER
	START_PROCESSING(SSobj, src)
	UnregisterSignal(reagents, COMSIG_REAGENTS_NEW_REAGENT)

/obj/structure/aquarium/process(seconds_per_tick)
	if(!reagents.total_volume)
		RegisterSignal(reagents, COMSIG_REAGENTS_NEW_REAGENT, PROC_REF(start_autofeed))
		return PROCESS_KILL
	if(world.time < last_feeding + feeding_interval)
		return
	last_feeding = world.time
	var/list/fishes = get_fishes()
	for(var/obj/item/fish/fish as anything in fishes)
		fish.feed(reagents)

/// Returns tracked_fish_by_type but flattened and without the items in the blacklist, also shuffled if shuffle is TRUE.
/obj/structure/aquarium/proc/get_fishes(shuffle = FALSE, blacklist)
	. = list()
	for(var/fish_type in tracked_fish_by_type)
		. += tracked_fish_by_type[fish_type]
	. -= blacklist
	if(shuffle)
		. = shuffle(.)
	return .

/obj/structure/aquarium/proc/request_layer(layer_type)
	/**
	 * base aq layer
	 * min_offset = this value is returned on bottom layer mode
	 * min_offset + 0.1 fish1
	 * min_offset + 0.2 fish2
	 * ... these layers are returned for auto layer mode and tracked by used_layers
	 * min_offset + max_offset = this value is returned for top layer mode
	 * min_offset + max_offset + 1 = this is used for glass overlay
	 */
	//optional todo: hook up sending surface changed on aquarium changing layers
	switch(layer_type)
		if(AQUARIUM_LAYER_MODE_BEHIND_GLASS)
			return layer + AQUARIUM_BELOW_GLASS_LAYER
		if(AQUARIUM_LAYER_MODE_BOTTOM)
			return layer + AQUARIUM_MIN_OFFSET
		if(AQUARIUM_LAYER_MODE_TOP)
			return layer + AQUARIUM_MAX_OFFSET
		if(AQUARIUM_LAYER_MODE_AUTO)
			var/chosen_layer = AQUARIUM_MIN_OFFSET + AQUARIUM_LAYER_STEP
			while((chosen_layer in used_layers) && (chosen_layer <= AQUARIUM_MAX_OFFSET))
				chosen_layer += AQUARIUM_LAYER_STEP
			used_layers += chosen_layer
			return layer + chosen_layer

/obj/structure/aquarium/proc/free_layer(value)
	used_layers -= value

/obj/structure/aquarium/proc/get_surface_properties()
	. = list()
	.[AQUARIUM_PROPERTIES_PX_MIN] = aquarium_zone_min_px
	.[AQUARIUM_PROPERTIES_PX_MAX] = aquarium_zone_max_px
	.[AQUARIUM_PROPERTIES_PY_MIN] = aquarium_zone_min_py
	.[AQUARIUM_PROPERTIES_PY_MAX] = aquarium_zone_max_py

/obj/structure/aquarium/update_icon()
	. = ..()
	///"aquarium_map" is used for mapping, so mappers can tell what it's.
	icon_state = icon_prefix + "_base"

/obj/structure/aquarium/update_overlays()
	. = ..()
	if(panel_open)
		. += icon_prefix + "_panel"

	///The glass overlay
	var/suffix = fluid_type == AQUARIUM_FLUID_AIR ? "air" : "water"
	if(broken)
		suffix += "_broken"
		. += mutable_appearance(icon, icon_prefix + "_glass_cracks", layer = layer + AQUARIUM_BORDERS_LAYER)
	. += mutable_appearance(icon, icon_prefix + "_glass_[suffix]", layer = layer + AQUARIUM_GLASS_LAYER)
	. += mutable_appearance(icon, icon_prefix + "_borders", layer = layer + AQUARIUM_BORDERS_LAYER)

/obj/structure/aquarium/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt-click</b> to [panel_open ? "close" : "open"] the control and feed panel.")
	if(panel_open && reagents.total_volume)
		. += span_notice("You can use a plunger to empty the feed storage.")

/obj/structure/aquarium/click_alt(mob/living/user)
	panel_open = !panel_open
	balloon_alert(user, "panel [panel_open ? "open" : "closed"]")
	if(panel_open)
		reagents.flags |= TRANSPARENT|REFILLABLE
	else
		reagents.flags &= ~(TRANSPARENT|REFILLABLE)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/structure/aquarium/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/structure/aquarium/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	if(!panel_open)
		return
	user.balloon_alert_to_viewers("plunging...")
	if(do_after(user, 3 SECONDS, target = src))
		user.balloon_alert_to_viewers("finished plunging")
		reagents.expose(get_turf(src), TOUCH) //splash on the floor
		reagents.clear_reagents()

/obj/structure/aquarium/attackby(obj/item/item, mob/living/user, params)
	if(broken)
		var/obj/item/stack/sheet/glass/glass = item
		if(istype(glass))
			if(glass.get_amount() < 2)
				balloon_alert(user, "it needs two sheets!")
				return
			balloon_alert(user, "fixing the aquarium...")
			if(do_after(user, 2 SECONDS, target = src))
				glass.use(2)
				broken = FALSE
				atom_integrity = max_integrity
				update_appearance()
			return TRUE
	else
		var/insert_attempt = SEND_SIGNAL(item, COMSIG_TRY_INSERTING_IN_AQUARIUM, src)
		switch(insert_attempt)
			if(COMSIG_CAN_INSERT_IN_AQUARIUM)
				if(!user.transferItemToLoc(item, src))
					user.balloon_alert(user, "stuck to your hand!")
					return TRUE
				balloon_alert(user, "added to aquarium")
				update_appearance()
				return TRUE
			if(COMSIG_CANNOT_INSERT_IN_AQUARIUM)
				balloon_alert(user, "cannot add to aquarium!")
				return TRUE

	if(istype(item, /obj/item/fish_feed) && !panel_open)
		if(!item.reagents.total_volume)
			balloon_alert(user, "[item] is empty!")
			return TRUE
		var/list/fishes = get_fishes()
		for(var/obj/item/fish/fish as anything in fishes)
			fish.feed(item.reagents)
		balloon_alert(user, "fed the fish")
		return TRUE
	if(istype(item, /obj/item/aquarium_upgrade))
		var/obj/item/aquarium_upgrade/upgrade = item
		if(upgrade.upgrade_from_type != type)
			balloon_alert(user, "wrong kind of aquarium!")
			return
		balloon_alert(user, "upgrading...")
		if(!do_after(user, 5 SECONDS, src))
			return
		var/obj/structure/aquarium/upgraded_aquarium = new upgrade.upgrade_to_type(loc)
		for(var/atom/movable/moving in contents)
			moving.forceMove(upgraded_aquarium)
		balloon_alert(user, "upgraded")
		qdel(upgrade)
		qdel(src)
		return
	return ..()

/obj/structure/aquarium/proc/on_attacked(datum/source, mob/attacker, attack_flags)
	var/list/fishes = get_fishes()
	//I wish this were an aquarium signal, but the aquarium_content component got in the way.
	for(var/obj/item/fish/fish as anything in fishes)
		SEND_SIGNAL(fish, COMSIG_FISH_STIRRED)

/obj/structure/aquarium/interact(mob/user)
	if(!broken && user.pulling && isliving(user.pulling))
		var/mob/living/living_pulled = user.pulling
		var/datum/component/aquarium_content/content_component = living_pulled.GetComponent(/datum/component/aquarium_content)
		if(content_component && content_component.is_ready_to_insert(src))
			try_to_put_mob_in(user)
	else if(panel_open)
		. = ..() //call base ui_interact
	else
		admire(user)

/// Tries to put mob pulled by the user in the aquarium after a delay
/obj/structure/aquarium/proc/try_to_put_mob_in(mob/user)
	if(user.pulling && isliving(user.pulling))
		var/mob/living/living_pulled = user.pulling
		if(living_pulled.buckled || living_pulled.has_buckled_mobs())
			to_chat(user, span_warning("[living_pulled] is attached to something!"))
			return
		user.visible_message(span_danger("[user] starts to put [living_pulled] into [src]!"))
		if(do_after(user, 10 SECONDS, target = src))
			if(QDELETED(living_pulled) || user.pulling != living_pulled || living_pulled.buckled || living_pulled.has_buckled_mobs())
				return
			var/datum/component/aquarium_content/content_component = living_pulled.GetComponent(/datum/component/aquarium_content)
			if(content_component || content_component.is_ready_to_insert(src))
				return
			user.visible_message(span_danger("[user] stuffs [living_pulled] into [src]!"))
			living_pulled.forceMove(src)
			update_appearance()

///Apply mood bonus depending on aquarium status
/obj/structure/aquarium/proc/admire(mob/living/user)
	user.balloon_alert(user, "admiring aquarium...")
	if(!do_after(user, 5 SECONDS, target = src))
		return
	var/alive_fish = 0
	var/dead_fish = 0
	var/list/tracked_fish = get_fishes()
	for(var/obj/item/fish/fish in tracked_fish)
		if(fish.status == FISH_ALIVE)
			alive_fish++
		else
			dead_fish++

	var/morb = HAS_TRAIT(user, TRAIT_MORBID)
	//Check if there are live fish - good mood
	//All fish dead - bad mood.
	//No fish - nothing.
	if(alive_fish > 0)
		user.add_mood_event("aquarium", morb ? /datum/mood_event/morbid_aquarium_bad : /datum/mood_event/aquarium_positive)
	else if(dead_fish > 0)
		user.add_mood_event("aquarium", morb ? /datum/mood_event/morbid_aquarium_good : /datum/mood_event/aquarium_negative)
	// Could maybe scale power of this mood with number/types of fish

/obj/structure/aquarium/ui_data(mob/user)
	. = ..()
	.["fluid_type"] = fluid_type
	.["temperature"] = fluid_temp
	.["allow_breeding"] = allow_breeding
	.["feeding_interval"] = feeding_interval / (1 MINUTES)
	var/list/content_data = list()
	for(var/atom/movable/fish in contents)
		content_data += list(list("name"=fish.name,"ref"=ref(fish)))
	.["contents"] = content_data

/obj/structure/aquarium/ui_static_data(mob/user)
	. = ..()
	//I guess these should depend on the fluid so lava critters can get high or stuff below water freezing point but let's keep it simple for now.
	.["minTemperature"] = min_fluid_temp
	.["maxTemperature"] = max_fluid_temp
	.["fluidTypes"] = fluid_types

/obj/structure/aquarium/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	switch(action)
		if("temperature")
			var/temperature = params["temperature"]
			if(isnum(temperature))
				fluid_temp = clamp(temperature, min_fluid_temp, max_fluid_temp)
				. = TRUE
		if("fluid")
			if(params["fluid"] in fluid_types)
				fluid_type = params["fluid"]
				SEND_SIGNAL(src, COMSIG_AQUARIUM_FLUID_CHANGED, fluid_type)
				. = TRUE
		if("allow_breeding")
			allow_breeding = !allow_breeding
			. = TRUE
		if("feeding_interval")
			feeding_interval = params["feeding_interval"] MINUTES
			. = TRUE
		if("remove")
			var/atom/movable/inside = locate(params["ref"]) in contents
			if(inside)
				if(isitem(inside))
					user.put_in_hands(inside)
				else
					inside.forceMove(get_turf(src))
				to_chat(user,span_notice("You take out [inside] from [src]."))

/obj/structure/aquarium/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Aquarium", name)
		ui.open()

/obj/structure/aquarium/atom_break(damage_flag)
	. = ..()
	if(!broken)
		aquarium_smash()

/obj/structure/aquarium/proc/aquarium_smash()
	broken = TRUE
	var/possible_destinations_for_fish = list()
	var/droploc = drop_location()
	if(isturf(droploc))
		possible_destinations_for_fish = get_adjacent_open_turfs(droploc)
	else
		possible_destinations_for_fish = list(droploc)
	playsound(src, 'sound/effects/glassbr3.ogg', 100, TRUE)
	for(var/atom/movable/fish in contents)
		fish.forceMove(pick(possible_destinations_for_fish))
	if(fluid_type != AQUARIUM_FLUID_AIR)
		var/datum/reagents/reagent_splash = new()
		reagent_splash.add_reagent(/datum/reagent/water, 30)
		chem_splash(droploc, null, 3, list(reagent_splash))
	update_appearance()

#undef AQUARIUM_LAYER_STEP
#undef AQUARIUM_MIN_OFFSET
#undef AQUARIUM_MAX_OFFSET
#undef AQUARIUM_GLASS_LAYER
#undef AQUARIUM_BORDERS_LAYER
#undef AQUARIUM_BELOW_GLASS_LAYER

/obj/structure/aquarium/lawyer
	anchored = TRUE

/obj/structure/aquarium/lawyer/Initialize(mapload)
	. = ..()

	new /obj/item/aquarium_prop/sand(src)
	new /obj/item/aquarium_prop/seaweed(src)

	new /obj/item/fish/goldfish/gill(src)

	reagents.add_reagent(/datum/reagent/consumable/nutriment, 2)

/obj/structure/aquarium/prefilled
	anchored = TRUE

/obj/structure/aquarium/prefilled/Initialize(mapload)
	. = ..()

	new /obj/item/aquarium_prop/sand(src)
	new /obj/item/aquarium_prop/seaweed(src)

	new /obj/item/fish/goldfish(src)
	new /obj/item/fish/angelfish(src)
	new /obj/item/fish/guppy(src)

	//They'll be alive for about 30 minutes with this amount.
	reagents.add_reagent(/datum/reagent/consumable/nutriment, 3)
