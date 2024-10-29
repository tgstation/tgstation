/obj/item/bait_can
	name = "can o bait"
	desc = "there's a lot of them in there, getting them out takes a while though."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "bait_can"
	base_icon_state =  "bait_can"
	w_class = WEIGHT_CLASS_SMALL
	/// Tracking until we can take out another bait item
	COOLDOWN_DECLARE(bait_removal_cooldown)
	/// What bait item it produces
	var/obj/item/bait_type = /obj/item/food/bait
	/// Time between bait retrievals
	var/cooldown_time = 5 SECONDS
	/// How many uses does it have left.
	var/uses_left = 20

/obj/item/bait_can/attack_self(mob/user, modifiers)
	. = ..()
	var/fresh_bait = retrieve_bait(user)
	if(fresh_bait)
		user.put_in_hands(fresh_bait)

/obj/item/bait_can/examine(mob/user)
	. = ..()
	. += span_info("It[uses_left ? " has got [uses_left] [bait_type::name] left" : "'s empty"].")

/obj/item/bait_can/update_icon_state()
	. = ..()
	icon_state = base_icon_state
	if(uses_left <= initial(uses_left))
		if(!uses_left)
			icon_state = "[icon_state]_empty"
		else
			icon_state = "[icon_state]_open"

/obj/item/bait_can/proc/retrieve_bait(mob/user)
	if(!uses_left)
		user.balloon_alert(user, "empty")
		return
	if(!COOLDOWN_FINISHED(src, bait_removal_cooldown))
		user.balloon_alert(user, "wait a bit")
		return
	COOLDOWN_START(src, bait_removal_cooldown, cooldown_time)
	update_appearance()
	uses_left--
	return new bait_type(src)

/obj/item/bait_can/worm
	name = "can o' worm"
	desc = "This can got worms."
	bait_type = /obj/item/food/bait/worm

/obj/item/bait_can/worm/premium
	name = "can o' worm deluxe"
	desc = "This can got fancy worms."
	bait_type = /obj/item/food/bait/worm/premium

/obj/item/bait_can/super_baits
	name = "can o' super-baits"
	desc = "This can got the nectar of god."
	bait_type = /obj/item/food/bait/doughball/synthetic/super
	uses_left = 12

/obj/item/fishing_lure
	name = "artificial minnow"
	desc = "A fishing lure meant to attract smaller omnivore fish."
	icon = 'icons/obj/fishing.dmi'
	icon_state = "minnow"
	w_class = WEIGHT_CLASS_SMALL
	/**
	 * A list with two keys delimiting the spinning interval in which a mouse click has to be pressed while fishing.
	 * This is passed down to the fishing rod, and then to the lure during the minigame.
	 */
	var/spin_frequency = list(2 SECONDS, 3 SECONDS)

/obj/item/fishing_lure/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_FISHING_BAIT, TRAIT_BAIT_ALLOW_FISHING_DUD, TRAIT_OMNI_BAIT, TRAIT_BAIT_UNCONSUMABLE), INNATE_TRAIT)
	RegisterSignal(src, COMSIG_FISHING_EQUIPMENT_SLOTTED, PROC_REF(lure_equipped))

/obj/item/fishing_lure/proc/lure_equipped(datum/source, obj/item/fishing_rod/rod)
	SIGNAL_HANDLER
	rod.spin_frequency = spin_frequency
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_removed))

/obj/item/fishing_lure/proc/on_removed(atom/movable/source, obj/item/fishing_rod/rod, dir, forced)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	rod.spin_frequency = null

///Called for every fish subtype by the fishing subsystem when initializing, to populate the list of fish that can be catched with this lure.
/obj/item/fishing_lure/proc/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/avg_size = initial(fish_type.average_size)
	var/intermediate_size = FISH_SIZE_SMALL_MAX + (FISH_SIZE_NORMAL_MAX - FISH_SIZE_SMALL_MAX)
	if(!ISINRANGE(avg_size, FISH_SIZE_TINY_MAX * 0.5, intermediate_size))
		return FALSE
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(length(list(/datum/fish_trait/vegan, /datum/fish_trait/picky_eater, /datum/fish_trait/nocturnal, /datum/fish_trait/heavy) & fish_traits))
		return FALSE
	return TRUE

/obj/item/fishing_lure/examine(mob/user)
	. = ..()
	. += span_info("It has to be spun with a frequency of [spin_frequency[1] * 0.1] to [spin_frequency[2] * 0.1] seconds while fishing.")
	if(HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISHING_SPOT))
		. += span_tinynotice("Thanks to your experience, you can examine it again to get a list of fish you can catch with it.")

/obj/item/fishing_lure/examine_more(mob/user)
	. = ..()
	if(!HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISHING_SPOT))
		return

	var/list/known_fishes = list()
	for(var/obj/item/fish/fish_type as anything in SSfishing.lure_catchables[type])
		if(initial(fish_type.fish_flags) & FISH_FLAG_SHOW_IN_CATALOG)
			known_fishes += initial(fish_type.name)

	if(!length(known_fishes))
		return

	. += span_info("You can catch the following fish with this lure: [english_list(known_fishes)].")

///Check if the fish is in the list of catchable fish for this fishing lure. Return value is a multiplier.
/obj/item/fishing_lure/check_bait(obj/item/fish/fish_type)
	var/multiplier = 0
	if(is_type_in_list(/obj/item/fishing_lure, SSfishing.fish_properties[fish_type][FISH_PROPERTIES_FAV_BAIT]))
		multiplier += 2
	if(fish_type in SSfishing.lure_catchables[type])
		multiplier += 10
	return multiplier

/obj/item/fishing_lure/plug
	name = "big plug lure"
	desc = "A fishing lure used to catch larger omnivore fish."
	icon_state = "plug"

/obj/item/fishing_lure/plug/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/avg_size = initial(fish_type.average_size)
	if(avg_size <= FISH_SIZE_SMALL_MAX)
		return FALSE
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(length(list(/datum/fish_trait/vegan, /datum/fish_trait/picky_eater, /datum/fish_trait/nocturnal, /datum/fish_trait/heavy) & fish_traits))
		return FALSE
	return TRUE

/obj/item/fishing_lure/dropping
	name = "plastic dropping"
	desc = "A fishing lure to catch all sort of slimy, ratty, disgusting and/or junk-loving fish."
	icon_state = "dropping"
	spin_frequency = list(1.5 SECONDS, 2.8 SECONDS)

/obj/item/fishing_lure/dropping/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/list/sources = list(/datum/fish_source/toilet, /datum/fish_source/moisture_trap)
	for(var/datum/fish_source/source as anything in sources)
		var/datum/fish_source/instance = GLOB.preset_fish_sources[/datum/fish_source/toilet]
		if(fish_type in instance.fish_table)
			return TRUE
	var/list/fav_baits = fish_properties[FISH_PROPERTIES_FAV_BAIT]
	for(var/list/identifier in fav_baits)
		if(identifier[FISH_BAIT_TYPE] == FISH_BAIT_FOODTYPE && (identifier[FISH_BAIT_VALUE] & (JUNKFOOD|GROSS|TOXIC)))
			return TRUE
	if(initial(fish_type.beauty) <= FISH_BEAUTY_DISGUSTING)
		return TRUE
	return FALSE

/obj/item/fishing_lure/spoon
	name = "\improper Indy spoon lure"
	desc = "A lustrous piece of metal mimicking the scales of a fish. Good for catching small to medium freshwater omnivore fish."
	icon_state = "spoon"
	spin_frequency = list(1.25 SECONDS, 2.25 SECONDS)

/obj/item/fishing_lure/spoon/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/avg_size = initial(fish_type.average_size)
	if(!ISINRANGE(avg_size, FISH_SIZE_TINY_MAX + 1, FISH_SIZE_NORMAL_MAX))
		return FALSE
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(length(list(/datum/fish_trait/vegan, /datum/fish_trait/picky_eater, /datum/fish_trait/nocturnal, /datum/fish_trait/heavy) & fish_traits))
		return FALSE
	var/fluid_type = initial(fish_type.required_fluid_type)
	if(fluid_type == AQUARIUM_FLUID_FRESHWATER || fluid_type == AQUARIUM_FLUID_ANADROMOUS || fluid_type == AQUARIUM_FLUID_ANY_WATER)
		return TRUE
	if((/datum/fish_trait/amphibious in fish_traits) && fluid_type == AQUARIUM_FLUID_AIR)
		return TRUE
	return FALSE

/obj/item/fishing_lure/artificial_fly
	name = "\improper Silkbuzz artificial fly"
	desc = "A fishing lure resembling a large wooly fly. Good for catching all sort of picky fish."
	icon_state = "artificial_fly"
	spin_frequency = list(1.1 SECONDS, 2 SECONDS)

/obj/item/fishing_lure/artificial_fly/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(/datum/fish_trait/picky_eater in fish_traits)
		return TRUE
	return FALSE

/obj/item/fishing_lure/led
	name = "\improper LED fishing lure"
	desc = "A heavy, waterproof and fish-looking LED stick, used to catch abyssal and demersal fish alike."
	icon_state = "led"
	spin_frequency = list(3 SECONDS, 3.8 SECONDS)

/obj/item/fishing_lure/led/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_BAIT_IGNORE_ENVIRONMENT, INNATE_TRAIT)
	update_appearance(UPDATE_OVERLAYS)

/obj/item/fishing_lure/led/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "led_emissive", src)

/obj/item/fishing_lure/led/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(length(list(/datum/fish_trait/nocturnal, /datum/fish_trait/heavy) & fish_traits))
		return TRUE
	return FALSE

/obj/item/fishing_lure/lucky_coin
	name = "\improper Maneki-Coin lure"
	desc = "A faux-gold lure used to attract shiny-loving fish."
	icon_state = "lucky_coin"
	spin_frequency = list(1.5 SECONDS, 2.7 SECONDS)

/obj/item/fishing_lure/lucky_coin/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(/datum/fish_trait/shiny_lover in fish_traits)
		return TRUE
	return FALSE

/obj/item/fishing_lure/algae
	name = "plastic algae lure"
	desc = "A soft clump of fake algae used to attract herbivore water critters."
	icon_state = "algae"
	spin_frequency = list(3 SECONDS, 5 SECONDS)

/obj/item/fishing_lure/algae/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(/datum/fish_trait/vegan in fish_traits)
		return TRUE
	return FALSE

/obj/item/fishing_lure/grub
	name = "\improper Twister Worm lure"
	desc = "A soft plastic lure with the body of a grub and a twisting tail. Good for panfish and other small omnivore fish."
	icon_state = "grub"
	spin_frequency = list(1 SECONDS, 2.7 SECONDS)

/obj/item/fishing_lure/grub/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	if(initial(fish_type.average_size) >= FISH_SIZE_SMALL_MAX)
		return FALSE
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(length(list(/datum/fish_trait/vegan, /datum/fish_trait/picky_eater) & fish_traits))
		return FALSE
	return TRUE

/obj/item/fishing_lure/buzzbait
	name = "\improper Electric-Buzz lure"
	desc = "A metallic, colored clanked attached to a series of cables that somehow attract shock-worthy fish."
	icon_state = "buzzbait"
	spin_frequency = list(0.8 SECONDS, 1.7 SECONDS)

/obj/item/fishing_lure/buzzbait/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(/datum/fish_trait/electrogenesis in fish_traits)
		return TRUE
	return FALSE

/obj/item/fishing_lure/spinnerbait
	name = "spinnerbait lure"
	desc = "A versatile lure, good for catching all sort of predatory freshwater fish."
	icon_state = "spinnerbait"
	spin_frequency = list(2 SECONDS, 4 SECONDS)

/obj/item/fishing_lure/spinnerbait/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(!(/datum/fish_trait/predator in fish_traits))
		return FALSE
	var/init_fluid_type = initial(fish_type.required_fluid_type)
	if(init_fluid_type == AQUARIUM_FLUID_FRESHWATER || init_fluid_type == AQUARIUM_FLUID_ANADROMOUS || init_fluid_type == AQUARIUM_FLUID_ANY_WATER)
		return TRUE
	if((/datum/fish_trait/amphibious in fish_traits) && init_fluid_type == AQUARIUM_FLUID_AIR) //fluid type is changed to freshwater on init
		return TRUE
	return FALSE

/obj/item/fishing_lure/daisy_chain
	name = "daisy chain lure"
	desc = "A lure resembling a small school of fish, good for catching several saltwater predators."
	icon_state = "daisy_chain"
	spin_frequency = list(2 SECONDS, 4 SECONDS)

/obj/item/fishing_lure/daisy_chain/is_catchable_fish(obj/item/fish/fish_type, list/fish_properties)
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]
	if(!(/datum/fish_trait/predator in fish_traits))
		return FALSE
	var/init_fluid_type = initial(fish_type.required_fluid_type)
	if(init_fluid_type == AQUARIUM_FLUID_SALTWATER || init_fluid_type == AQUARIUM_FLUID_ANADROMOUS || init_fluid_type == AQUARIUM_FLUID_ANY_WATER)
		return TRUE
	return FALSE
