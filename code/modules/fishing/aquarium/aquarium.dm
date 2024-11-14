/obj/structure/aquarium
	name = "aquarium"
	desc = "A vivarium in which aquatic fauna and flora are usually kept and displayed."
	density = TRUE
	anchored = FALSE

	icon = 'icons/obj/aquarium/tanks.dmi'
	icon_state = "aquarium_map"
	base_icon_state = "aquarium"

	integrity_failure = 0.3

	//This is the area where fish can swim
	var/aquarium_zone_min_px = 2
	var/aquarium_zone_max_px = 31
	var/aquarium_zone_min_py = 10
	var/aquarium_zone_max_py = 28

	/// Default beauty of the aquarium, without anything inside it
	var/default_beauty = 150

	///Tracks the fluid type of our aquarium component. Used for the icon suffix of some overlays and splashing water when broken.
	var/fluid_type = AQUARIUM_FLUID_FRESHWATER

/obj/structure/aquarium/Initialize(mapload)
	. = ..()
	update_appearance()
	AddComponent(/datum/component/aquarium, aquarium_zone_min_px, aquarium_zone_max_px, aquarium_zone_min_py, aquarium_zone_max_py, default_beauty)
	AddComponent(/datum/component/plumbing/aquarium, start = anchored)
	RegisterSignal(src, COMSIG_AQUARIUM_FLUID_CHANGED, PROC_REF(on_aquarium_liquid_changed))

/obj/structure/aquarium/update_icon()
	. = ..()
	///"aquarium_map" is used for mapping, so mappers can tell what it's.
	icon_state = base_icon_state + "_base"

/obj/structure/aquarium/proc/on_aquarium_liquid_changed(datum/source, fluid_type)
	SIGNAL_HANDLER
	src.fluid_type = fluid_type
	update_appearance()

/obj/structure/aquarium/update_overlays()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_AQUARIUM_PANEL_OPEN))
		. += base_icon_state + "_panel"

	var/icon_suffix = fluid_type == AQUARIUM_FLUID_AIR ? "air" : "water"
	///The glass overlay
	if(broken)
		icon_suffix += "_broken"
		. += mutable_appearance(icon, base_icon_state + "_glass_cracks", layer = layer + AQUARIUM_BORDERS_LAYER)
	. += mutable_appearance(icon, base_icon_state + "_glass_[icon_suffix]", layer = layer + AQUARIUM_GLASS_LAYER)
	. += mutable_appearance(icon, base_icon_state + "_borders", layer = layer + AQUARIUM_BORDERS_LAYER)

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
	for(var/atom/movable/content as anything in contents)
		content.forceMove(pick(possible_destinations_for_fish))
	if(fluid_type != AQUARIUM_FLUID_AIR)
		var/datum/reagents/reagent_splash = new()
		reagent_splash.add_reagent(/datum/reagent/water, 30)
		chem_splash(droploc, null, 3, list(reagent_splash))
	update_appearance()

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

/obj/item/fish_tank
	name = "fish tank"
	desc = "A more portable sort of aquarium to store various fishes in, unless they're too big or there're too many of them."

	icon = 'icons/obj/aquarium/tanks.dmi'
	icon_state = "fish_tank_map"
	base_icon_state = "fish_tank"

	force = 5

	item_flags = SLOWS_WHILE_IN_HAND

	custom_price = PAYCHECK_CREW * 9

	///Tracks the fluid type of our aquarium component. Used for overlays
	var/fluid_type = AQUARIUM_FLUID_FRESHWATER

	///Fish which size exceed this value cannot be inserted
	var/maximum_relative_size = 100
	///Fish cannot be inserted if the sum of the size of all fish in this tank exceeds this value.
	var/max_total_size = 220
	///Tracks the sum of the size of all fish in this tank
	var/current_summed_size = 0
	///Tracks the sum of the weight of all fish in this tank
	var/current_summed_weight = 0

/obj/item/fish_tank/Initialize()
	. = ..()
	update_appearance()
	AddComponent(\
		/datum/component/aquarium,\
		min_px = 6,\
		max_px = 26,\
		min_py = 6,\
		min_py = 24,\
		default_beauty = 100,\
		reagents_size = 4,\
		min_fluid_temp = MIN_AQUARIUM_TEMP + 12,\
		max_fluid_temp = MAX_AQUARIUM_TEMP - 32,\
	)
	AddComponent(/datum/component/plumbing/aquarium, start = anchored)
	RegisterSignal(src, COMSIG_AQUARIUM_FLUID_CHANGED, PROC_REF(on_aquarium_liquid_changed))
	RegisterSignal(src, COMSIG_AQUARIUM_CAN_INSERT, PROC_REF(can_insert))
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_new_fish))

/obj/item/fish_tank/update_icon()
	. = ..()
	///"aquarium_map" is used for mapping, so mappers can tell what it's.
	icon_state = base_icon_state

/obj/item/fish_tank/proc/on_aquarium_liquid_changed(datum/source, fluid_type)
	SIGNAL_HANDLER
	src.fluid_type = fluid_type
	update_appearance()

/obj/item/fish_tank/update_overlays()
	. = ..()
	. += "[base_icon_state]_panel[HAS_TRAIT(src, TRAIT_AQUARIUM_PANEL_OPEN) ? "_open" : ""]"
	. += mutable_appearance(icon, "[base_icon_state]_[fluid_type == AQUARIUM_FLUID_AIR ? "air" : "water"]", layer = layer + AQUARIUM_GLASS_LAYER)
	. += mutable_appearance(icon, "[base_icon_state]_borders", layer = layer + AQUARIUM_BORDERS_LAYER)

/obj/item/fish_tank/proc/can_insert(atom/movable/source, obj/item/item, mob/living/user)
	SIGNAL_HANDLER
	if(!isfish(item))
		return
	var/obj/item/fish/fish = item
	if(fish.size > maximum_relative_size)
		balloon_alert(user, "fish is too big!")
		return COMSIG_CANNOT_INSERT_IN_AQUARIUM
	if(current_summed_size > max_total_size)
		balloon_alert(user, "fish tank is full!")
		return COMSIG_CANNOT_INSERT_IN_AQUARIUM
	return COMSIG_CAN_INSERT_IN_AQUARIUM

/obj/item/fish_tank/Entered(atom/movable/entered)
	. = ..()
	on_new_fish(src, entered)

/obj/item/fish_tank/proc/on_new_fish(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	if(!isfish(movable))
		return
	var/obj/item/fish/fish = movable
	change_size_weight(fish.size, fish.weight)
	RegisterSignal(fish, COMSIG_FISH_UPDATE_SIZE_AND_WEIGHT, PROC_REF(on_fish_size_weight_updated))

/obj/item/fish_tank/proc/on_fish_size_weight_updated(obj/item/fish/source, new_size, new_weight)
	SIGNAL_HANDLER
	change_size_weight(new_size - source.size, new_weight - source.weight)

/obj/item/fish_tank/Exited(atom/movable/gone)
	if(isfish(gone))
		var/obj/item/fish/fish = gone
		change_size_weight(-fish.size, -fish.weight)
		UnregisterSignal(fish, COMSIG_FISH_UPDATE_SIZE_AND_WEIGHT)
	return ..()

/obj/item/fish_tank/proc/change_size_weight(size_change, weight_change)
	current_summed_size += size_change
	current_summed_weight += weight_change
	if(current_summed_size > max_total_size)
		ADD_TRAIT(src, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, INNATE_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_STOP_FISH_REPRODUCTION_AND_GROWTH, INNATE_TRAIT)
	if(HAS_TRAIT(src, TRAIT_SPEED_POTIONED) || current_summed_weight < FISH_WEIGHT_SLOWDOWN)
		slowdown = 0
		drag_slowdown = 0
	else
		slowdown = GET_FISH_SLOWDOWN(current_summed_weight)
		drag_slowdown = slowdown * 0.5
	if(ismob(loc))
		var/mob/mob = loc
		mob.update_equipment_speed_mods()

	force = 2 + (GET_FISH_WEIGHT_RANK(current_summed_weight) * 3)

///The lawyer's own pet goldfish's fish tank. It used to be an aquarium, but now it can be held and carried around.
/obj/item/fish_tank/lawyer

/obj/item/fish_tank/lawyer/Initialize(mapload)
	. = ..()

	new /obj/item/aquarium_prop/sand(src)
	new /obj/item/aquarium_prop/seaweed(src)

	if(prob(85))
		new /obj/item/fish/goldfish/gill(src)
		reagents.add_reagent(/datum/reagent/consumable/nutriment, 3)
	else
		new /obj/item/fish/goldfish/three_eyes/gill(src)
		reagents.add_reagent(/datum/reagent/toxin/mutagen, 3) //three eyes goldfish feed on mutagen.
