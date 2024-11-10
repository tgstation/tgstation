///Defines that clamp the beauty of the aquarium, to prevent it from making most areas great or horrid all by itself.
#define MIN_AQUARIUM_BEAUTY -3500
#define MAX_AQUARIUM_BEAUTY 6000

/datum/component/aquarium
	/// list of fishes inside the parent object, sorted by type - does not include things with aquarium visuals that are not fish
	var/list/tracked_fish_by_type

	var/fluid_type
	var/fluid_temp

	var/list/beauty_by_content

	var/default_beauty

	var/list/used_layers = list()

	//This is the area where fish can swim
	var/aquarium_zone_min_px
	var/aquarium_zone_max_px
	var/aquarium_zone_min_py
	var/aquarium_zone_max_py

	var/static/list/fluid_types = list(
		AQUARIUM_FLUID_SALTWATER,
		AQUARIUM_FLUID_FRESHWATER,
		AQUARIUM_FLUID_SULPHWATEVER,
		AQUARIUM_FLUID_AIR,
	)

/datum/component/aquarium/Initialize(min_px, max_px, min_py, max_py, default_beauty = 0, reagents_size = 6)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.default_beauty = default_beauty
	if(default_beauty)
		update_aquarium_beauty(0)

	aquarium_zone_min_px = min_px
	aquarium_zone_max_px = max_px
	aquarium_zone_min_py = min_py
	aquarium_zone_max_py = max_py

	RegisterSignals(parent, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON), PROC_REF(on_entered))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

	RegisterSignal(parent, COMSIG_AQUARIUM_GET_REPRODUCTION_CANDIDATES, PROC_REF(get_candidates))
	RegisterSignal(parent, COMSIG_AQUARIUM_REMOVE_VISUAL, PROC_REF(remove_visual))
	RegisterSignal(parent, COMSIG_AQUARIUM_SET_VISUAL, PROC_REF(set_visual))

	var/atom/movable/movable = parent

	ADD_KEEP_TOGETHER(movable, INNATE_TRAIT)

	if(reagents_size > 0)
		RegisterSignal(movable.reagents, COMSIG_REAGENTS_NEW_REAGENT, PROC_REF(start_autofeed))
		movable.create_reagents(reagents_size, SEALED_CONTAINER)
		RegisterSignal(movable, COMSIG_PLUNGER_ACT, PROC_REF(on_plunger_act))

	RegisterSignal(movable, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_item_interaction))
	RegisterSignal(movable, COMSIG_CLICK_ALT, PROC_REF(on_click_alt))
	RegisterSignal(movable, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	AddElement(/datum/element/relay_attackers)
	RegisterSignal(movable, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

/datum/component/aquarium/proc/Destroy()
	beauty_by_content = null
	return ..()

/datum/component/aquarium/proc/on_click_alt(atom/movable/source, mob/living/user)
	SIGNAL_HANDLER
	var/closing = HAS_TRAIT(parent, TRAIT_AQUARIUM_PANEL_OPEN)
	if(closing)
		REMOVE_TRAIT(parent, TRAIT_AQUARIUM_PANEL_OPEN, INNATE_TRAIT))
	else
		ADD_TRAIT(parent, TRAIT_AQUARIUM_PANEL_OPEN, INNATE_TRAIT))

	source.balloon_alert(user, "panel [closing ? "closed" : "open"]")
	if(closing)
		source.reagents.flags &= ~(TRANSPARENT|REFILLABLE)
	else
		source.reagents.flags |= TRANSPARENT|REFILLABLE

	source.update_appearance()
	return CLICK_ACTION_SUCCESS

/datum/component/aquarium/proc/on_item_interaction(atom/movable/source, mob/living/user, obj/item/item, modifiers)
	SIGNAL_HANDLER
	if(source.get_integrity_percentage() <= source.integrity_failure)
		return
	var/insert_attempt = SEND_SIGNAL(item, COMSIG_TRY_INSERTING_IN_AQUARIUM, source)
	switch(insert_attempt)
		if(COMSIG_CAN_INSERT_IN_AQUARIUM)
			if(!user.transferItemToLoc(item, source))
				user.balloon_alert(user, "stuck to your hand!")
				return TRUE
			source.balloon_alert(user, "added to aquarium")
			source.update_appearance()
			return ITEM_INTERACT_SUCCESS
		if(COMSIG_CANNOT_INSERT_IN_AQUARIUM)
			source.balloon_alert(user, "cannot add to aquarium!")
			return ITEM_INTERACT_BLOCKING

	if(istype(item, /obj/item/reagent_containers/cup/fish_feed) && !HAS_TRAIT(source, TRAIT_AQUARIUM_PANEL_OPEN))
		if(!item.reagents.total_volume)
			source.balloon_alert(user, "[item] is empty!")
			return ITEM_INTERACT_BLOCKING
		var/list/fishes = get_fishes()
		if(!length(fishes))
			balloon_alert(user, "no fish to feed!")
			return ITEM_INTERACT_BLOCKING
		for(var/obj/item/fish/fish as anything in fishes)
			fish.feed(item.reagents)
		source.balloon_alert(user, "fed the fish")
		return ITEM_INTERACT_SUCCESS

/obj/structure/aquarium/proc/on_attacked(datum/source, mob/attacker, attack_flags)
	var/list/fishes = get_fishes()
	for(var/obj/item/fish/fish as anything in fishes)
		SEND_SIGNAL(fish, COMSIG_FISH_STIRRED)

/datum/component/aquarium/proc/start_autofeed(datum/source, new_reagent, amount, reagtemp, data, no_react)
	SIGNAL_HANDLER
	START_PROCESSING(SSobj, src)
	UnregisterSignal(reagents, COMSIG_REAGENTS_NEW_REAGENT)

/datum/component/aquarium/process(seconds_per_tick)
	if(!reagents.total_volume)
		var/atom/movable/movable = parent
		RegisterSignal(movable.reagents, COMSIG_REAGENTS_NEW_REAGENT, PROC_REF(start_autofeed))
		return PROCESS_KILL
	if(world.time < last_feeding + feeding_interval)
		return
	last_feeding = world.time
		var/list/fishes = get_fishes()
	for(var/obj/item/fish/fish as anything in fishes)
		fish.feed(reagents)

datum/component/aquarium/plunger_act(atom/movable/source, obj/item/plunger/plunger, mob/living/user, reinforced)
	if(!HAS_TRAIT(source, TRAIT_AQUARIUM_PANEL_OPEN))
		return
	user.balloon_alert_to_viewers("plunging...")
	if(do_after(user, 3 SECONDS, target = source))
		user.balloon_alert_to_viewers("finished plunging")
		source.reagents.expose(get_turf(movable), TOUCH) //splash on the floor
		source.reagents.clear_reagents()
	return COMPONENT_NO_AFTERATTACK

/datum/component/aquarium/proc/on_examine(atom/movable/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/panel_open = HAS_TRAIT(source, TRAIT_AQUARIUM_PANEL_OPEN)
	examine_list += span_notice("<b>Alt-click</b> to [panel_open ? "close" : "open"] the control and feed panel.")
	if(panel_open && source.reagents.total_volume)
		examine_list += span_notice("You can use a plunger to empty the feed storage.")

/datum/component/aquarium/proc/on_entered(atom/movable/source, atom/movable/entered)
	SIGNAL_HANDLER
	get_content_beauty(entered)
	if(!isfish(entered))
		return
	LAZYADDASSOCLIST(tracked_fish_by_type, entered.type, entered)
	if(fish.stable_population < length(tracked_fish_by_type[entered.type]))
		return
	for(var/obj/item/fish/fish as anything in tracked_fish_by_type[entered.type])
		fish.fish_flags |= FISH_FLAG_OVERPOPULATED
	check_fluid_and_temperature(entered)
	RegisterSignal(entered, COMSIG_FISH_STATUS_CHANGED, PROC_REF(on_fish_status_changed))

/datum/component/aquarium/proc/get_content_beauty(atom/movable/content)
	var/list/beauty_holder = list()
	SEND_SIGNAL(content, COMSIG_MOVABLE_GET_AQUARIUM_BEAUTY, beauty)
	var/beauty = beauty_holder[1]
	if(beauty)
		var/old_beauty = default_beauty
		for(var/key in beauty_by_content)
			old_beauty += beauty_by_content[key]
		LAZYSET(beauty_by_content, content, beauty)
		update_aquarium_beauty(old_beauty)

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
	if(gone.stable_population == length(tracked_fish_by_type[gone.type]))
		return
	for(var/obj/item/fish/fish as anything in tracked_fish_by_type[gone.type])
		fish.fish_flags &= ~FISH_FLAG_OVERPOPULATED
	LAZYREMOVEASSOC(tracked_fish_by_type, gone.type, gone)
	var/obj/item/fish/fish = gone
	fish.fish_flags &= ~(FISH_FLAG_SAFE_TEMPERATURE|FISH_FLAG_SAFE_FLUID)
	UnregisterSignal(entered, COMSIG_FISH_STATUS_CHANGED, PROC_REF(on_fish_status_changed))

/datum/component/aquarium/proc/get_candidates(atom/movable/source, obj/item/fish/fish, list/candidates)
	var/list/types_to_mate_with = tracked_fish_by_type
	if(!HAS_TRAIT(fish, TRAIT_FISH_CROSSBREEDER))
		var/list/types_to_check = list(fish.type)
		if(compatible_types)
			types_to_check |= compatible_types
		types_to_mate_with = types_to_mate_with & types_to_check

	for(var/obj/item/fish/fish_type as anything in types_to_mate_with)
		var/list/type_fishes = types_to_mate_with[fish_type]
		if(length(type_fishes) >= initial(fish_type.stable_population))
			continue
		candidates += type_fishes

	if(length(aquarium.tracked_fish_by_type[type]) >= stable_population)
		return COMPONENT_STOP_SELF_REPRODUCTION
	return NONE

/datum/component/aquarium/proc/check_evolution(atom/movable/source, obj/item/fish/one, obj/item/fish/two, datum/fish_evolution/evolution)
	SIGNAL_HANDLER
	//chances are halved if only one parent has this evolution.
	var/real_probability = (two && (evolution.type in two.evolution_types)) ? evolution.probability : evolution.probability * 0.5
	if(HAS_TRAIT(one, TRAIT_FISH_MUTAGENIC) || (two && HAS_TRAIT(two, TRAIT_FISH_MUTAGENIC)))
		real_probability *= 3
	if(!prob(real_probability))
		return COMPONENT_STOP_EVOLUTION
	if(!ISINRANGE(fluid_temp, evolution.required_temperature_min, evolution.required_temperature_max))
		return COMPONENT_STOP_EVOLUTION
	return COMPONENT_ALLOW_EVOLUTION

/datum/component/aquarium/proc/check_fluid_and_temperature(obj/item/fish/fish)
	if(compatible_fluid_type(fish.required_fluid_type, fluid_type) || (fluid_type == AQUARIUM_FLUID_AIR && HAS_TRAIT(fish, TRAIT_FISH_AMPHIBIOUS)))
		fish.fish_flags |= FISH_FLAG_SAFE_FLUID
	else
		fish.flags &= ~FISH_FLAG_SAFE_FLUID
	if(ISINRANGE(fluid_temp, fish.required_temperature_min, fish.required_temperature_max))
		fish.fish_flags |= FISH_FLAG_SAFE_TEMPERATURE
	else
		fish.flags &= ~FISH_FLAG_SAFE_TEMPERATURE

///Fish beauty changes when they're dead, so we need to update the beauty of the aquarium too.
/datum/component/aquarium/proc/on_fish_status_changed(obj/item/fish/fish)
	get_content_beauty(fish)

/datum/component/aquarium_content/proc/update_aquarium_beauty(old_beauty)
	if(QDELETED(aquarium) || !change)
		return
	old_beauty = clamp(old_beauty, MIN_AQUARIUM_BEAUTY, MAX_AQUARIUM_BEAUTY)
	var/new_beauty = 0
	for(var/key in beauty_by_content)
		new_beauty += beauty_by_content
	new_beauty = clamp(new_beauty, MIN_AQUARIUM_BEAUTY, MAX_AQUARIUM_BEAUTY)
	if(new_clamped_beauty == old_clamped_beauty)
		return
	if(old_clamped_beauty)
		parent.RemoveElement(/datum/element/beauty, old_clamped_beauty)
	if(new_clamped_beauty)
		parent.AddElement(/datum/element/beauty, new_clamped_beauty)

/datum/component/aquarium/proc/remove_visual(atom/movable/source, /obj/effect/aquarium/visual)
	SIGNAL_HANDLER
	source.vis_contents -= visual
	used_layers -= visual.layer

/datum/component/aquarium/proc/set_visual(atom/movable/source, /obj/effect/aquarium/visual)
	SIGNAL_HANDLER
	used_layers -= visual.layer
	visual.layer = current_aquarium.request_layer(visual.layer_mode)
	visual.aquarium_zone_min_px = aquarium_zone_min_px
	visual.aquarium_zone_max_px = aquarium_zone_max_px
	visual.aquarium_zone_min_py = aquarium_zone_min_py
	visual.aquarium_zone_max_py = aquarium_zone_max_py
	visual.fluid_type = fluid_type

/datum/component/aquarium/proc/request_layer(layer_type)
	/**
	 * base aquarium layer
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

/datum/component/aquarium/proc/get_fishes()
	var/list/fishes = list()
	for(var/key in tracked_fish_by_type)
		fishes += tracked_fish_by_type[key]
	return fishes

#undef MIN_AQUARIUM_BEAUTY
#undef MAX_AQUARIUM_BEAUTY
