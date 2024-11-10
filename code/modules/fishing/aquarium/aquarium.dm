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
	var/reproduction_and_growth = TRUE

	//This is the area where fish can swim
	var/aquarium_zone_min_px = 2
	var/aquarium_zone_max_px = 31
	var/aquarium_zone_min_py = 10
	var/aquarium_zone_max_py = 28

	///Current layers in use by aquarium contents
	var/list/used_layers = list()

	/// Var used to keep track of the current beauty of the aquarium, which can be throughfully changed by aquarium content.
	var/current_beauty = 150

/obj/structure/aquarium/Initialize(mapload)
	. = ..()
	update_appearance()
	AddComponent(src, /datum/component/aquarium, aquarium_zone_min_px, aquarium_zone_max_px, aquarium_zone_min_py, aquarium_zone_max_py, default_beauty)
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(track_if_fish))
	AddElement(/datum/element/relay_attackers)
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	AddComponent(/datum/component/plumbing/aquarium, start = anchored)

/obj/structure/aquarium/update_icon()
	. = ..()
	///"aquarium_map" is used for mapping, so mappers can tell what it's.
	icon_state = icon_prefix + "_base"

/obj/structure/aquarium/update_overlays()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_AQUARIUM_PANEL_OPEN))
		. += icon_prefix + "_panel"

	///The glass overlay
	var/suffix = fluid_type == AQUARIUM_FLUID_AIR ? "air" : "water"
	if(broken)
		suffix += "_broken"
		. += mutable_appearance(icon, icon_prefix + "_glass_cracks", layer = layer + AQUARIUM_BORDERS_LAYER)
	. += mutable_appearance(icon, icon_prefix + "_glass_[suffix]", layer = layer + AQUARIUM_GLASS_LAYER)
	. += mutable_appearance(icon, icon_prefix + "_borders", layer = layer + AQUARIUM_BORDERS_LAYER)

/obj/structure/aquarium/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

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

/obj/structure/aquarium/interact(mob/user)
	if(panel_open)
		return ..() //call base ui_interact
	else
		admire(user)

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

	var/morb = HAS_MIND_TRAIT(user, TRAIT_MORBID)
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
	.["fluidType"] = fluid_type
	.["temperature"] = fluid_temp
	.["allowBreeding"] = reproduction_and_growth
	.["fishData"] = list()
	.["feedingInterval"] = feeding_interval / (1 MINUTES)
	.["propData"] = list()
	for(var/atom/movable/item in contents)
		if(isfish(item))
			var/obj/item/fish/fish = item
			.["fishData"] += list(list(
				"fish_ref" = REF(fish),
				"fish_name" = fish.name,
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

/obj/structure/aquarium/ui_static_data(mob/user)
	. = ..()
	//I guess these should depend on the fluid so lava critters can get high or stuff below water freezing point but let's keep it simple for now.
	.["minTemperature"] = min_fluid_temp
	.["maxTemperature"] = max_fluid_temp
	.["fluidTypes"] = fluid_types
	.["heartIcon"] = 'icons/effects/effects.dmi'

/obj/structure/aquarium/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
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
			reproduction_and_growth = !reproduction_and_growth
			. = TRUE
		if("feeding_interval")
			feeding_interval = params["feeding_interval"] MINUTES
			. = TRUE
		if("pet_fish")
			var/obj/item/fish/fish = locate(params["fish_reference"]) in contents
			fish?.pet_fish(user)
		if("remove_item")
			var/atom/movable/item = locate(params["item_reference"]) in contents
			item?.forceMove(drop_location())
			to_chat(user, span_notice("You take out [item] from [src]."))
		if("rename_fish")
			var/new_name = sanitize_name(params["chosen_name"])
			var/atom/movable/fish = locate(params["fish_reference"]) in contents
			if(!fish || !new_name || new_name == fish.name)
				return
			fish.AddComponent(/datum/component/rename, new_name, fish.desc)

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
	playsound(src, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)
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

	if(prob(85))
		new /obj/item/fish/goldfish/gill(src)
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 2)
	else
		new /obj/item/fish/goldfish/three_eyes/gill(src)
		reagents.add_reagent(/datum/reagent/toxin/mutagen, 2) //three eyes goldfish feed on mutagen.


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
