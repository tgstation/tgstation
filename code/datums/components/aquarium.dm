///Defines that clamp the beauty of the aquarium, to prevent it from making most areas great or horrid all by itself.
#define MIN_AQUARIUM_BEAUTY -3500
#define MAX_AQUARIUM_BEAUTY 6000

/**
 * The component that manages the aquariums UI, fluid, temperature, the current fish inside the parent object, as well as beauty,
 * and a few other common aquarium features.
 */
/datum/component/aquarium
	dupe_mode = COMPONENT_DUPE_UNIQUE
	can_transfer = TRUE
	/// list of fishes inside the parent object, sorted by type - does not include things with aquarium visuals that are not fish
	var/list/tracked_fish_by_type

	///The current type of fluid of the aquarium
	var/fluid_type = AQUARIUM_FLUID_FRESHWATER
	///The current temperature of the fluid of the aquarium
	var/fluid_temp = DEFAULT_AQUARIUM_TEMP

	///A lazy list of key instances and assoc vals representing how much beauty they contribute to the aquarium
	var/list/beauty_by_content

	///The default beauty of the aquarium when empty.
	var/default_beauty

	///A list of layers that are currently being used for the various overlays of the aquarium (from aquarium_content comp)
	var/list/used_layers = list()

	///The minimum pixel x of the area where vis overlays should be displayed
	var/aquarium_zone_min_pw
	///The maximum pixel x of the area where vis overlays should be displayed
	var/aquarium_zone_max_pw
	///The minimum pixel y of the area where vis overlays should be displayed
	var/aquarium_zone_min_pz
	///The maximum pixel y of the area where vis overlays should be displayed
	var/aquarium_zone_max_pz

	///While the feed (reagent) storage is not empty, this is the interval which the fish are fed.
	var/feeding_interval = 3 MINUTES
	///The last time fishes were fed by the acquarium itsef.
	var/last_feeding

	///The minimum fluid temperature that can be reached by this aquarium
	var/min_fluid_temp = MIN_AQUARIUM_TEMP
	///The maximum fluid temperature that can be reached by this aquarium
	var/max_fluid_temp = MAX_AQUARIUM_TEMP

	///static list of available fluid types.
	var/static/list/fluid_types = list(
		AQUARIUM_FLUID_SALTWATER,
		AQUARIUM_FLUID_FRESHWATER,
		AQUARIUM_FLUID_SULPHWATEVER,
		AQUARIUM_FLUID_AIR,
	)
	///static list of available aquarium modes
	var/static/list/aquarium_modes = list(
		AQUARIUM_MODE_MANUAL = "Take full control of fluid and temperature settings. There's no stasis option here.",
		AQUARIUM_MODE_AUTO = "Let an internal processor regulate aquarium settings based on its fish population. Can temporarily fall back to stasis.",
		AQUARIUM_MODE_SAFE = "Prevent fish from dying from wrong fluid/temperature settings and hunger, but also stops growth and reproduction",
	)

	///The size of the reagents holder which will store fish feed.
	var/reagents_size

	///The current aquarium mode, one of either AQUARIUM_MODE_MANUAL, AQUARIUM_MODE_AUTO or AQUARIUM_MODE_SAFE.
	var/current_mode

/datum/component/aquarium/Initialize(
	min_px,
	max_px,
	min_py,
	max_py,
	default_beauty = 0,
	reagents_size = 6,
	min_fluid_temp = MIN_AQUARIUM_TEMP,
	max_fluid_temp = MAX_AQUARIUM_TEMP,
	init_mode = AQUARIUM_MODE_AUTO,
)

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.default_beauty = default_beauty
	src.reagents_size = reagents_size

	aquarium_zone_min_pw = min_px
	aquarium_zone_max_pw = max_px
	aquarium_zone_min_pz = min_py
	aquarium_zone_max_pz = max_py

	src.min_fluid_temp = min_fluid_temp
	src.max_fluid_temp = max_fluid_temp
	fluid_temp = clamp(fluid_temp, min_fluid_temp, max_fluid_temp)

	set_aquarium_mode(init_mode)

/datum/component/aquarium/RegisterWithParent()
	if(default_beauty)
		update_aquarium_beauty(0)

	RegisterSignals(parent, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON), PROC_REF(on_entered))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

	RegisterSignal(parent, COMSIG_AQUARIUM_GET_REPRODUCTION_CANDIDATES, PROC_REF(get_candidates))
	RegisterSignal(parent, COMSIG_AQUARIUM_CHECK_EVOLUTION_CONDITIONS, PROC_REF(check_evolution))

	RegisterSignal(parent, COMSIG_AQUARIUM_SET_VISUAL, PROC_REF(set_visual))
	RegisterSignal(parent, COMSIG_AQUARIUM_REMOVE_VISUAL, PROC_REF(remove_visual))

	var/atom/movable/movable = parent

	ADD_KEEP_TOGETHER(movable, AQUARIUM_TRAIT) //render the fish on the same layer of the aquarium.

	if(reagents_size > 0)
		if(!movable.reagents)
			movable.create_reagents(reagents_size, SEALED_CONTAINER)
		if(movable.reagents.total_volume)
			start_autofeed(movable.reagents)
		else
			RegisterSignal(movable.reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(start_autofeed))
		RegisterSignal(movable, COMSIG_PLUNGER_ACT, PROC_REF(on_plunger_act))

	RegisterSignal(movable, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	RegisterSignal(movable, COMSIG_CLICK_ALT, PROC_REF(on_click_alt))
	RegisterSignal(movable, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	if(isitem(movable))
		RegisterSignal(movable, COMSIG_ITEM_ATTACK_SELF, PROC_REF(interact))
		RegisterSignal(movable, COMSIG_ITEM_ATTACK_SELF_SECONDARY, PROC_REF(secondary_interact))
		RegisterSignals(movable, list(COMSIG_ATOM_ATTACK_ROBOT_SECONDARY, COMSIG_ATOM_ATTACK_HAND_SECONDARY), PROC_REF(on_secondary_attack_hand))
	else
		RegisterSignal(movable, COMSIG_ATOM_UI_INTERACT, PROC_REF(interact))

	movable.AddElement(/datum/element/relay_attackers)
	movable.AddComponent(/datum/component/fishing_spot, /datum/fish_source/aquarium)


	movable.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(movable, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

	for(var/atom/movable/content as anything in movable.contents)
		if(content.flags_1 & INITIALIZED_1)
			on_entered(movable, content)

	movable.add_traits(list(TRAIT_IS_AQUARIUM, TRAIT_STOP_FISH_FLOPPING), AQUARIUM_TRAIT)

/datum/component/aquarium/UnregisterFromParent()
	var/atom/movable/movable = parent
	UnregisterSignal(movable, list(
		COMSIG_ATOM_ENTERED,
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON,
		COMSIG_ATOM_EXITED,
		COMSIG_AQUARIUM_GET_REPRODUCTION_CANDIDATES,
		COMSIG_AQUARIUM_CHECK_EVOLUTION_CONDITIONS,
		COMSIG_AQUARIUM_SET_VISUAL,
		COMSIG_AQUARIUM_REMOVE_VISUAL,
		COMSIG_PLUNGER_ACT,
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_CLICK_ALT,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ATOM_ATTACK_ROBOT_SECONDARY,
		COMSIG_ATOM_ATTACK_HAND_SECONDARY,
		COMSIG_ATOM_UI_INTERACT,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
	))
	if(movable.reagents)
		UnregisterSignal(movable, COMSIG_REAGENTS_HOLDER_UPDATED)
		STOP_PROCESSING(SSobj, src)
	beauty_by_content = null
	tracked_fish_by_type = null
	movable.remove_traits(list(TRAIT_IS_AQUARIUM, TRAIT_AQUARIUM_PANEL_OPEN, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, TRAIT_STOP_FISH_FLOPPING), AQUARIUM_TRAIT)
	qdel(movable.GetComponent(/datum/component/fishing_spot))
	REMOVE_KEEP_TOGETHER(movable, AQUARIUM_TRAIT)

/datum/component/aquarium/PreTransfer(atom/movable/new_parent)
	if(!istype(new_parent))
		return
	if(HAS_TRAIT(parent, TRAIT_AQUARIUM_PANEL_OPEN))
		ADD_TRAIT(new_parent, TRAIT_AQUARIUM_PANEL_OPEN, AQUARIUM_TRAIT)
	if(HAS_TRAIT_FROM(parent, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, AQUARIUM_TRAIT))
		ADD_TRAIT(new_parent, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, AQUARIUM_TRAIT)
	var/atom/movable/movable = parent
	var/old_mode = current_mode //Make sure we don't keep updating temp/fluid on AQUARIUM_MODE_AUTO for this.
	current_mode = NONE
	for(var/atom/movable/moving as anything in movable.contents)
		if(HAS_TRAIT(moving, TRAIT_AQUARIUM_CONTENT))
			moving.forceMove(new_parent)
	current_mode = old_mode
	if(reagents_size)
		if(!new_parent.reagents)
			new_parent.create_reagents(reagents_size, SEALED_CONTAINER)
		movable.reagents.trans_to(new_parent, movable.reagents.total_volume)

/datum/component/aquarium/PostTransfer(datum/new_parent)
	if(!ismovable(new_parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/aquarium/InheritComponent(datum/component/aquarium/new_comp, i_am_original)
	fluid_temp = clamp(new_comp.fluid_temp, min_fluid_temp, max_fluid_temp)
	set_fluid_type(new_comp.fluid_type)
	feeding_interval = new_comp.feeding_interval
	last_feeding = new_comp.last_feeding
	var/atom/movable/movable = parent
	movable.update_appearance()

/datum/component/aquarium/proc/on_click_alt(atom/movable/source, mob/living/user)
	SIGNAL_HANDLER
	if(!user.can_perform_action(source))
		return
	var/closing = HAS_TRAIT(parent, TRAIT_AQUARIUM_PANEL_OPEN)
	if(closing)
		REMOVE_TRAIT(parent, TRAIT_AQUARIUM_PANEL_OPEN, AQUARIUM_TRAIT)
		source.reagents.flags &= ~(TRANSPARENT|REFILLABLE)
		SStgui.close_uis(src)
	else
		ADD_TRAIT(parent, TRAIT_AQUARIUM_PANEL_OPEN, AQUARIUM_TRAIT)
		source.reagents.flags |= TRANSPARENT|REFILLABLE

	source.balloon_alert(user, "panel [closing ? "closed" : "open"]")
	source.update_appearance()
	return CLICK_ACTION_SUCCESS

///This proc handles feeding the aquarium and inserting aquarium content.
/datum/component/aquarium/proc/on_item_interaction(atom/movable/source, mob/living/user, obj/item/item, modifiers)
	SIGNAL_HANDLER

	if(istype(item, /obj/item/reagent_containers/cup/fish_feed))
		if(source.reagents && HAS_TRAIT(source, TRAIT_AQUARIUM_PANEL_OPEN))
			return //don't block, we'll be transferring reagents to the feed storage.
		if(!item.reagents.total_volume)
			source.balloon_alert(user, "[item] is empty!")
			return ITEM_INTERACT_BLOCKING
		var/list/fishes = get_fishes()
		if(!length(fishes))
			source.balloon_alert(user, "no fish to feed!")
			return ITEM_INTERACT_BLOCKING
		feed_fishes(item, fishes)
		source.balloon_alert(user, "fed the fish")
		return ITEM_INTERACT_SUCCESS

	if(!HAS_TRAIT(item, TRAIT_AQUARIUM_CONTENT) || (!isitem(parent) && user.combat_mode))
		return //proceed with normal interactions

	var/broken = source.get_integrity_percentage() <= source.integrity_failure
	if(!can_insert(source, item, user))
		return ITEM_INTERACT_BLOCKING
	if(broken)
		source.balloon_alert(user, "aquarium is broken!")
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(item, source))
		user.balloon_alert(user, "stuck to your hand!")
		return ITEM_INTERACT_BLOCKING
	source.balloon_alert(user, "added to aquarium")
	source.update_appearance()
	return ITEM_INTERACT_SUCCESS

///Called when the feed storage is no longer empty.
/datum/component/aquarium/proc/start_autofeed(datum/reagents/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_REAGENTS_HOLDER_UPDATED)
	START_PROCESSING(SSobj, src)

///Feed the fish at defined intervals until the feed storage is empty.
/datum/component/aquarium/process(seconds_per_tick)
	//safe mode, no need to feed the fishes
	if(HAS_TRAIT_FROM(parent, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, AQUARIUM_TRAIT))
		last_feeding += seconds_per_tick SECONDS
		return
	var/atom/movable/movable = parent
	if(!movable.reagents?.total_volume)
		if(movable.reagents)
			RegisterSignal(movable.reagents, COMSIG_REAGENTS_HOLDER_UPDATED, PROC_REF(start_autofeed))
		return PROCESS_KILL
	if(world.time < last_feeding + feeding_interval)
		return
	last_feeding = world.time
	feed_fishes(movable)

/datum/component/aquarium/proc/feed_fishes(atom/movable/movable, list/fishes = get_fishes())
	for(var/obj/item/fish/fish as anything in fishes)
		fish.feed(movable.reagents)
	if(current_mode == AQUARIUM_MODE_AUTO && is_fish_population_safe())
		REMOVE_TRAIT(parent, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, AQUARIUM_TRAIT)

/datum/component/aquarium/proc/on_plunger_act(atom/movable/source, obj/item/plunger/plunger, mob/living/user, reinforced)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(source, TRAIT_AQUARIUM_PANEL_OPEN))
		source.balloon_alert(user, "open panel first!")
		return
	INVOKE_ASYNC(src, PROC_REF(do_plunging), source, user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/aquarium/proc/do_plunging(atom/movable/source, mob/living/user)
	user.balloon_alert_to_viewers("plunging...")
	if(do_after(user, 3 SECONDS, target = source))
		user.balloon_alert_to_viewers("finished plunging")
		source.reagents.expose(get_turf(source), TOUCH) //splash on the floor
		source.reagents.clear_reagents()

/datum/component/aquarium/proc/on_examine(atom/movable/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("Its temperature and fluid are currently set to [EXAMINE_HINT("[fluid_temp] K")] and [EXAMINE_HINT(fluid_type)].")
	var/panel_open = HAS_TRAIT(source, TRAIT_AQUARIUM_PANEL_OPEN)
	examine_list += span_notice("[EXAMINE_HINT("Alt-click")] to [panel_open ? "close" : "open"] the control and feed panel.")
	if(panel_open && source.reagents.total_volume)
		examine_list += span_notice("You can use a plunger to empty the feed storage.")

///Check if an item can be inserted into the aquarium
/datum/component/aquarium/proc/can_insert(atom/movable/source, obj/item/item, mob/living/user)
	var/return_value = SEND_SIGNAL(src, COMSIG_AQUARIUM_CAN_INSERT, item, user)
	if(return_value & COMSIG_CANNOT_INSERT_IN_AQUARIUM)
		return FALSE
	if(return_value & COMSIG_CAN_INSERT_IN_AQUARIUM)
		return TRUE

	if(HAS_TRAIT(item, TRAIT_UNIQUE_AQUARIUM_CONTENT))
		for(var/atom/movable/content as anything in source)
			if(content == item)
				continue
			if(content.type == item.type)
				source.balloon_alert(user, "cannot add to aquarium!")
				return FALSE
	return TRUE

///Handles aquarium content insertion
/datum/component/aquarium/proc/on_entered(atom/movable/source, atom/movable/entered)
	SIGNAL_HANDLER
	get_content_beauty(entered)
	if(!isfish(entered))
		return
	var/obj/item/fish/fish = entered
	LAZYADDASSOCLIST(tracked_fish_by_type, entered.type, entered)
	if(fish.stable_population < length(tracked_fish_by_type[fish.type]))
		for(var/obj/item/fish/anyfin as anything in tracked_fish_by_type[entered.type])
			anyfin.fish_flags |= FISH_FLAG_OVERPOPULATED

	if(current_mode == AQUARIUM_MODE_AUTO && fish.status != FISH_DEAD)
		get_optimal_aquarium_settings()
	else
		check_fluid_and_temperature(fish)
	RegisterSignal(fish, COMSIG_FISH_STATUS_CHANGED, PROC_REF(on_fish_status_changed))

///update the beauty_by_content of a 'beauty_by_content' key and then recalculate the beauty.
/datum/component/aquarium/proc/get_content_beauty(atom/movable/content)
	var/list/beauty_holder = list()
	SEND_SIGNAL(content, COMSIG_MOVABLE_GET_AQUARIUM_BEAUTY, beauty_holder)
	var/beauty = beauty_holder[1]
	if(!beauty)
		return
	var/old_beauty = default_beauty
	for(var/key in beauty_by_content)
		old_beauty += beauty_by_content[key]
	LAZYSET(beauty_by_content, content, beauty)
	update_aquarium_beauty(old_beauty)

///Handles aquarium content removal.
/datum/component/aquarium/proc/on_exited(atom/movable/source, atom/movable/gone)
	SIGNAL_HANDLER
	var/beauty = beauty_by_content?[gone]
	if(beauty)
		var/old_beauty = default_beauty
		for(var/key in beauty_by_content)
			old_beauty += beauty_by_content[key]
		LAZYREMOVE(beauty_by_content, gone)
		update_aquarium_beauty(old_beauty)
	if(!isfish(gone))
		return
	var/obj/item/fish/fish = gone
	if(fish.stable_population == length(tracked_fish_by_type[fish.type]))
		for(var/obj/item/fish/anyfin as anything in tracked_fish_by_type[fish.type])
			anyfin.fish_flags &= ~FISH_FLAG_OVERPOPULATED
	LAZYREMOVEASSOC(tracked_fish_by_type, fish.type, fish)
	fish.fish_flags &= ~(FISH_FLAG_SAFE_TEMPERATURE|FISH_FLAG_SAFE_FLUID)
	UnregisterSignal(gone, COMSIG_FISH_STATUS_CHANGED, PROC_REF(on_fish_status_changed))
	if(current_mode == AQUARIUM_MODE_AUTO && fish.status != FISH_DEAD)
		get_optimal_aquarium_settings()

///Return a list of fish which our fishie can reproduce with (including itself if self-reproducing)
/datum/component/aquarium/proc/get_candidates(atom/movable/source, obj/item/fish/fish, list/candidates)
	SIGNAL_HANDLER
	var/list/types_to_mate_with = tracked_fish_by_type
	if(!HAS_TRAIT(fish, TRAIT_FISH_CROSSBREEDER))
		var/list/types_to_check = list(fish.type)
		if(fish.compatible_types)
			types_to_check |= fish.compatible_types
		types_to_mate_with = types_to_mate_with & types_to_check

	for(var/obj/item/fish/fish_type as anything in types_to_mate_with)
		var/list/type_fishes = tracked_fish_by_type[fish_type]
		if(length(type_fishes) >= initial(fish_type.stable_population))
			continue
		candidates += type_fishes

///Check if an offspring of two fish (or one if self-reproducing) can evolve.
/datum/component/aquarium/proc/check_evolution(atom/movable/source, obj/item/fish/fish, obj/item/fish/mate, datum/fish_evolution/evolution)
	SIGNAL_HANDLER
	//chances are halved if only one parent has this evolution.
	var/real_probability = (mate && (evolution.type in mate.evolution_types)) ? evolution.probability : evolution.probability * 0.5
	if(HAS_TRAIT(fish, TRAIT_FISH_MUTAGENIC) || (mate && HAS_TRAIT(mate, TRAIT_FISH_MUTAGENIC)))
		real_probability *= 3
	if(!prob(real_probability))
		return NONE
	if(!ISINRANGE(fluid_temp, evolution.required_temperature_min, evolution.required_temperature_max))
		return NONE
	return COMPONENT_ALLOW_EVOLUTION

/**
 * Toggles a couple flags that determine if the fish is in safe waters so that we won't have to use signals or
 * access this comp in multiple places just to confirm that.
 */
/datum/component/aquarium/proc/check_fluid_and_temperature(obj/item/fish/fish)
	if((fluid_type in GLOB.fish_compatible_fluid_types[fish.required_fluid_type]) || (fluid_type == AQUARIUM_FLUID_AIR && HAS_TRAIT(fish, TRAIT_FISH_AMPHIBIOUS)))
		fish.fish_flags |= FISH_FLAG_SAFE_FLUID
	else
		fish.fish_flags &= ~FISH_FLAG_SAFE_FLUID
	if(ISINRANGE(fluid_temp, fish.required_temperature_min, fish.required_temperature_max))
		fish.fish_flags |= FISH_FLAG_SAFE_TEMPERATURE
	else
		fish.fish_flags &= ~FISH_FLAG_SAFE_TEMPERATURE

///Fish beauty changes when they're dead, so we need to update the beauty of the aquarium too.
/datum/component/aquarium/proc/on_fish_status_changed(obj/item/fish/fish)
	get_content_beauty(fish)
	if(current_mode == AQUARIUM_MODE_AUTO)
		get_optimal_aquarium_settings()

/datum/component/aquarium/proc/update_aquarium_beauty(old_beauty)
	if(QDELETED(parent))
		return
	old_beauty = clamp(old_beauty, MIN_AQUARIUM_BEAUTY, MAX_AQUARIUM_BEAUTY)
	var/new_beauty = 0
	for(var/key in beauty_by_content)
		new_beauty += beauty_by_content[key]
	new_beauty = clamp(new_beauty, MIN_AQUARIUM_BEAUTY, MAX_AQUARIUM_BEAUTY)
	if(new_beauty == old_beauty)
		return
	if(old_beauty)
		parent.RemoveElement(/datum/element/beauty, old_beauty)
	if(new_beauty)
		parent.AddElement(/datum/element/beauty, new_beauty)

///Remove a visual overlay from an aquarium_content comp
/datum/component/aquarium/proc/remove_visual(atom/movable/source, obj/effect/aquarium/visual)
	SIGNAL_HANDLER
	source.vis_contents -= visual
	used_layers -= visual.layer

///set values for a visual overlay for an aquarium_content comp
/datum/component/aquarium/proc/set_visual(atom/movable/source, obj/effect/aquarium/visual)
	SIGNAL_HANDLER
	used_layers -= visual.layer
	visual.layer = request_layer(visual.layer_mode)
	visual.aquarium_zone_min_pw = aquarium_zone_min_pw
	visual.aquarium_zone_max_pw = aquarium_zone_max_pw
	visual.aquarium_zone_min_pz = aquarium_zone_min_pz
	visual.aquarium_zone_max_pz = aquarium_zone_max_pz
	visual.fluid_type = fluid_type

/datum/component/aquarium/proc/request_layer(layer_type)
	var/atom/movable/movable = parent
	switch(layer_type)
		if(AQUARIUM_LAYER_MODE_BEHIND_GLASS)
			return movable.layer + AQUARIUM_BELOW_GLASS_LAYER
		if(AQUARIUM_LAYER_MODE_BOTTOM)
			return movable.layer + AQUARIUM_MIN_OFFSET
		if(AQUARIUM_LAYER_MODE_TOP)
			return movable.layer + AQUARIUM_MAX_OFFSET
		if(AQUARIUM_LAYER_MODE_AUTO)
			var/chosen_layer = AQUARIUM_MIN_OFFSET + AQUARIUM_LAYER_STEP
			while((chosen_layer in used_layers) && (chosen_layer <= AQUARIUM_MAX_OFFSET))
				chosen_layer += AQUARIUM_LAYER_STEP
			used_layers += chosen_layer
			return movable.layer + chosen_layer

/datum/component/aquarium/proc/get_fishes()
	var/list/fishes = list()
	for(var/key in tracked_fish_by_type)
		fishes += tracked_fish_by_type[key]
	return fishes

/datum/component/aquarium/proc/is_fish_population_safe()
	var/list/fishes = get_fishes()
	var/alive = 0
	var/not_safe = 0
	for(var/obj/item/fish/fishie as anything in fishes)
		if(fishie.status == FISH_DEAD)
			continue
		if(!fishie.proper_environment() || fishie.get_hunger() > FISH_STARVING_THRESHOLD * 0.9)
			not_safe++
		alive++
	return not_safe <= (alive / 2)

/**
 * Called if the mode is AQUARIUM_MODE_AUTO whenever a fish is added, removed, dies or resurrected.
 *
 * This tries to find what the best combination of fluid and temperature. is to ensure
 * the survival of the highest number of fishes. It also can and will activate stasis if over half of
 * the fish population is at risk of dying. It doesn't care if the fish is big or small, useful
 * or not. All fish are equal before the impartial eye of AQUARIUM_MODE_AUTO.
 */
/datum/component/aquarium/proc/get_optimal_aquarium_settings()
	if(!length(tracked_fish_by_type))
		REMOVE_TRAIT(parent, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, AQUARIUM_TRAIT)
		return

	var/list/can_survive_with = list()
	var/list/checked_types = list()
	var/list/sorted_tracked = sortTim(tracked_fish_by_type.Copy(), GLOBAL_PROC_REF(cmp_list_len_dsc), associative = TRUE)
	var/list/fish_alive_by_type = list()
	for(var/obj/item/fish/fish_type as anything in sorted_tracked)
		var/our_min_temp = fish_type::required_temperature_min
		var/our_max_temp = fish_type::required_temperature_max
		var/our_fluid_type = fish_type::required_fluid_type

		checked_types += fish_type
		LAZYINITLIST(can_survive_with[fish_type])

		var/fish_amount = 0
		for(var/obj/item/fish/fish_instance as anything in tracked_fish_by_type[fish_type])
			if(fish_instance.status == FISH_ALIVE)
				fish_amount++

		if(!fish_amount) //all fishes of this type are dead, skip it.
			continue

		fish_alive_by_type[fish_type] = fish_amount

		//Check if there's an overlap with the temp/fluid requirements of the other types.
		for(var/obj/item/fish/enemy_type as anything in (tracked_fish_by_type - checked_types))
			var/enem_min_temp = initial(enemy_type.required_temperature_min)
			var/enem_max_temp = initial(enemy_type.required_temperature_max)
			if(our_min_temp > enem_max_temp || our_max_temp < enem_min_temp)
				continue
			var/enem_fluid_type = initial(enemy_type.required_fluid_type)
			if(!length(GLOB.fish_compatible_fluid_types[our_fluid_type] & GLOB.fish_compatible_fluid_types[enem_fluid_type]))
				continue
			can_survive_with[fish_type] |= enemy_type
			LAZYOR(can_survive_with[enemy_type], fish_type)

	var/list/highest_val_list = list(tracked_fish_by_type[1]) //In case there's only one type of fish in here...
	var/highest_val = -1
	for(var/fish_type as anything in can_survive_with)
		var/list/compatible_types = can_survive_with[fish_type]
		var/fish_amount = fish_alive_by_type[fish_type]
		for(var/obj/item/fish/fish_instance as anything in tracked_fish_by_type[fish_type])
			if(fish_instance.status == FISH_ALIVE)
				fish_amount++
		for(var/ally_type in compatible_types)
			var/val = fish_amount + fish_alive_by_type[ally_type]
			var/list/common_allies = compatible_types & can_survive_with[ally_type]
			for(var/third_type in common_allies)
				val += fish_alive_by_type[third_type]
			if(val <= highest_val)
				continue
			highest_val_list = list(fish_type, ally_type) + common_allies
			highest_val = val

	var/min_temp = MIN_AQUARIUM_TEMP
	var/max_temp = MAX_AQUARIUM_TEMP
	var/list/possible_fluids = fluid_types.Copy()
	for(var/obj/item/fish/chosen_type as anything in highest_val_list)
		possible_fluids &= GLOB.fish_compatible_fluid_types[chosen_type::required_fluid_type]
		min_temp = max(min_temp, chosen_type::required_temperature_min)
		max_temp = min(max_temp, chosen_type::required_temperature_max)

	fluid_temp = clamp(min_temp + round((max_temp - min_temp) / 2), min_fluid_temp, max_fluid_temp)
	set_fluid_type(possible_fluids[1])

	if(!is_fish_population_safe())
		ADD_TRAIT(parent, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, AQUARIUM_TRAIT)
	else
		REMOVE_TRAIT(parent, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, AQUARIUM_TRAIT)

/datum/component/aquarium/proc/interact(atom/movable/source, mob/user)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_AQUARIUM_PANEL_OPEN))
		INVOKE_ASYNC(src, PROC_REF(ui_interact), user)
		return
	INVOKE_ASYNC(src, PROC_REF(admire), source, user)

/datum/component/aquarium/proc/secondary_interact(atom/movable/source, mob/user)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_AQUARIUM_PANEL_OPEN))
		return
	INVOKE_ASYNC(src, PROC_REF(admire), source, user)

/datum/component/aquarium/proc/on_secondary_attack_hand(obj/item/source, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(admire), source, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/aquarium/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/atom/movable/movable = parent
		ui = new(user, src, "Aquarium", movable.name)
		ui.open()

/datum/component/aquarium/ui_data(mob/user)
	. = ..()
	var/atom/movable/aquarium = parent
	.["fluidType"] = fluid_type
	.["temperature"] = fluid_temp
	.["lockedFluidTemp"] = current_mode == AQUARIUM_MODE_AUTO
	.["currentMode"] = current_mode
	.["currentTooltip"] = aquarium_modes[current_mode]
	.["fishData"] = list()
	.["feedingInterval"] = feeding_interval / (1 MINUTES)
	.["propData"] = list()
	for(var/atom/movable/item as anything in aquarium.contents)
		if(isfish(item))
			var/obj/item/fish/fish = item
			.["fishData"] += list(list(
				"fish_ref" = REF(fish),
				"fish_name" = uppertext(fish.name),
				"fish_happiness" = fish.get_happiness_value(),
				"fish_icon" = fish::icon,
				"fish_icon_state" = fish::icon_state,
				"fish_health" = fish.health,
			))
			continue
		.["propData"] += list(list(
			"prop_ref" = REF(item),
			"prop_name" = item.name,
			"prop_icon" = item::icon,
			"prop_icon_state" = item::icon_state,
		))

/datum/component/aquarium/ui_static_data(mob/user)
	. = ..()
	//I guess these should depend on the fluid so lava critters can get high or stuff below water freezing point but let's keep it simple for now.
	.["minTemperature"] = min_fluid_temp
	.["maxTemperature"] = max_fluid_temp
	.["fluidTypes"] = fluid_types
	.["heartIcon"] = 'icons/effects/effects.dmi'
	var/list/modes_no_assoc = list() //the UI dropdown won't work with assoc lists here
	for(var/mode in aquarium_modes)
		modes_no_assoc += mode
	.["aquariumModes"] = modes_no_assoc

/datum/component/aquarium/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	var/atom/movable/movable = parent
	switch(action)
		if("temperature")
			var/temperature = params["temperature"]
			if(isnum(temperature) && temperature != fluid_temp)
				fluid_temp = clamp(temperature, min_fluid_temp, max_fluid_temp)
				for(var/obj/item/fish/fish as anything in get_fishes())
					check_fluid_and_temperature(fish)
			. = TRUE
		if("fluid")
			if(params["fluid"] != fluid_type && (params["fluid"] in fluid_types))
				set_fluid_type(params["fluid"])
			. = TRUE
		if("change_mode")
			var/new_mode = params["new_mode"]
			set_aquarium_mode(new_mode)
			. = TRUE
		if("feeding_interval")
			feeding_interval = params["feeding_interval"] MINUTES
			. = TRUE
		if("pet_fish")
			var/obj/item/fish/fish = locate(params["fish_reference"]) in movable.contents
			fish?.pet_fish(user)
		if("remove_item")
			var/atom/movable/item = locate(params["item_reference"]) in movable.contents
			item?.forceMove(movable.drop_location())
			to_chat(user, span_notice("You take out [item] from [movable]."))
		if("rename_fish")
			var/new_name = sanitize_name(params["chosen_name"])
			var/atom/movable/fish = locate(params["fish_reference"]) in movable.contents
			if(!fish || !new_name || new_name == fish.name)
				return
			fish.AddComponent(/datum/component/rename, new_name, fish.desc)

/datum/component/aquarium/proc/set_aquarium_mode(new_mode)
	if(new_mode == current_mode)
		return
	REMOVE_TRAIT(parent, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, AQUARIUM_TRAIT)
	current_mode = new_mode
	switch(current_mode)
		if(AQUARIUM_MODE_SAFE)
			ADD_TRAIT(parent, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, AQUARIUM_TRAIT)
		if(AQUARIUM_MODE_AUTO)
			get_optimal_aquarium_settings()

/datum/component/aquarium/proc/set_fluid_type(new_fluid_type)
	var/atom/movable/movable = parent
	fluid_type = new_fluid_type
	SEND_SIGNAL(movable, COMSIG_AQUARIUM_FLUID_CHANGED, fluid_type)
	for(var/obj/item/fish/fish as anything in get_fishes())
		check_fluid_and_temperature(fish)

/datum/component/aquarium/proc/admire(atom/movable/source, mob/living/user)
	source.balloon_alert(user, "admiring aquarium...")
	if(!do_after(user, 5 SECONDS, target = source))
		return
	var/alive_fish = 0
	var/dead_fish = 0
	for(var/obj/item/fish/fish as anything in get_fishes())
		if(fish.status == FISH_ALIVE)
			alive_fish++
		else
			dead_fish++

	var/morb = HAS_MIND_TRAIT(user, TRAIT_MORBID)
	//Check if there are live fish - good mood
	//All fish dead - bad mood.
	//No fish - nothing.
	if(alive_fish > 0)
		user.add_mood_event("aquarium", morb ? /datum/mood_event/morbid_aquarium_bad : /datum/mood_event/aquarium_positive)
	else if(dead_fish > 0)
		user.add_mood_event("aquarium", morb ? /datum/mood_event/morbid_aquarium_good : /datum/mood_event/aquarium_negative)

/datum/component/aquarium/proc/on_requesting_context_from_item(atom/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER
	var/open_panel = HAS_TRAIT(source, TRAIT_AQUARIUM_PANEL_OPEN)
	var/is_held_item = (held_item == source)
	if(!held_item || is_held_item)
		var/isitem = isitem(source)
		if(!isitem || is_held_item)
			context[SCREENTIP_CONTEXT_LMB] = open_panel ? "Adjust settings" : "Admire"
		if(isitem)
			context[SCREENTIP_CONTEXT_RMB] = "Admire"
		context[SCREENTIP_CONTEXT_ALT_LMB] = "[!open_panel ? "Open" : "Close"] settings panel"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/plunger))
		context[SCREENTIP_CONTEXT_LMB] = "Empty feed storage"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/reagent_containers/cup/fish_feed) && (!source.reagents || !open_panel))
		context[SCREENTIP_CONTEXT_LMB] = "Feed fishes"
		return CONTEXTUAL_SCREENTIP_SET
	if(HAS_TRAIT(held_item, TRAIT_AQUARIUM_CONTENT))
		context[SCREENTIP_CONTEXT_LMB] = "Insert in aquarium"
		return CONTEXTUAL_SCREENTIP_SET

#undef MIN_AQUARIUM_BEAUTY
#undef MAX_AQUARIUM_BEAUTY
