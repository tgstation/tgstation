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
