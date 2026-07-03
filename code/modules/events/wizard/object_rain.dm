#define RAIN_TARGET_DEPARTMENTS list(\
	"Cargo Bay" = /area/station/cargo, \
	"Engineering Division" = /area/station/engineering, \
	"Medbay" = /area/station/medical, \
	"Recreation and Relaxation Division" = /area/station/commons, \
	"Science Division" = /area/station/science, \
	"Security Department" = /area/station/security, \
	"Station Corridors" = /area/station/hallway, \
)

/datum/round_event_control/wizard/object_rain
	name = "Indoor Weather: Cats and Dogs (and Frogs)"
	typepath = /datum/round_event/wizard/object_rain/animal
	description = "Small animals will rain from the sky."
	weight = 2
	max_occurrences = 2
	earliest_start = 0 MINUTES
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 2
	admin_setup = list(/datum/event_admin_setup/listed_options/object_rain)

/datum/round_event_control/wizard/object_rain/food
	name = "Indoor Weather: Chance of Meatballs"
	typepath = /datum/round_event/wizard/object_rain/food
	description = "Food will rain from the sky."

/datum/round_event_control/wizard/object_rain/cash
	name = "Indoor Weather: Loose Change"
	typepath = /datum/round_event/wizard/object_rain/cash
	description = "Money will rain from the sky."

/datum/round_event_control/wizard/object_rain/fish
	name = "Indoor Weather: Fish"
	typepath = /datum/round_event/wizard/object_rain/fish
	description = "Fish will rain from the sky."

/**
 * Event where some kind of object will fall from the sky in a random themed area of the station.
 * Generally this is to encourage people to break in to acquire the items, or just be kind of funny.
 * Can only be triggered by wizard events or admins.
 */
/datum/round_event/wizard/object_rain
	end_when = 20
	/// Where is it happening?
	var/target_region
	/// How many things at most should land per second?
	var/max_things_per_second = 3
	/// Places where things can land
	var/list/target_turfs = list()
	/// Places weather can happen and their friendly names.
	var/static/list/possible_regions = RAIN_TARGET_DEPARTMENTS

/datum/round_event/wizard/object_rain/setup()
	if (isnull(target_region))
		target_region = pick(possible_regions) // can't use get_safe_random_turfs because it disqualifies some of my areas
	target_turfs = list()
	for (var/turf/turf as anything in get_area_turfs(possible_regions[target_region], subtypes = TRUE))
		if (turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		target_turfs += turf

/datum/round_event/wizard/object_rain/tick()
	var/to_spawn = rand(0, max_things_per_second)
	while (to_spawn > 0)
		to_spawn--
		addtimer(CALLBACK(src, PROC_REF(drop_item)), rand(0, (1 SECONDS)))

/// Make something descend from above.
/datum/round_event/wizard/object_rain/proc/drop_item()
	if (length(target_turfs) == 0)
		return
	var/atom/landing_atom = get_item()
	if (!landing_atom)
		return
	podspawn(list(
		"target" = pick_n_take(target_turfs),
		"style" = /datum/pod_style/seethrough,
		"spawn" = landing_atom,
		"delays" = list(POD_TRANSIT = 0, POD_FALLING = (3 SECONDS), POD_OPENING = 0, POD_LEAVING = 0),
		"effectStealth" = TRUE,
		"effectQuiet" = TRUE,))

/datum/round_event/wizard/object_rain/announce(fake)
	priority_announce("Прогнозируются аномальные погодные явления в [target_region].", "Уведомление уборщиков")

/// Return whatever it is you want to rain from the sky here.
/datum/round_event/wizard/object_rain/proc/get_item()
	// Return something you want to fall from the sky from here

/// Spawns little animals
/datum/round_event/wizard/object_rain/animal
	end_when = 10 // These are mobs so don't make too many.

/datum/round_event/wizard/object_rain/animal/get_item()
	var/static/list/possible_paths = list(
		/mob/living/basic/pet/dog/corgi/puppy = 5,
		/mob/living/basic/pet/cat/kitten = 5,
		/mob/living/basic/frog = 5,
		/mob/living/basic/frog/rare = 1,
		/mob/living/basic/axolotl = 1,
		/mob/living/basic/pet/dog/corgi/puppy/void = 1,
		/mob/living/basic/pet/dog/corgi/puppy/slime = 1,
	)

	var/mob_path = pick_weight(possible_paths)
	return new mob_path(pick(target_turfs)) // Have to drop them on a tile for a frame before they go in a pod or the compiler complains

/// Spawns food
/datum/round_event/wizard/object_rain/food

/datum/round_event/wizard/object_rain/food/get_item()
	return get_random_food()

/// Spawns money
/datum/round_event/wizard/object_rain/cash

/datum/round_event/wizard/object_rain/cash/get_item()
	// Sad that I have to remake this list but this doesn't work if I use a spawner object
	var/static/list/possible_paths = list(
		/obj/item/coin/iron = 100,
		/obj/item/coin/plastic = 100,
		/obj/item/coin/silver = 60,
		/obj/item/coin/plasma = 30,
		/obj/item/coin/uranium = 30,
		/obj/item/coin/titanium = 30,
		/obj/item/coin/diamond = 20,
		/obj/item/coin/bananium = 20,
		/obj/item/coin/adamantine = 20,
		/obj/item/coin/mythril = 20,
		/obj/item/coin/runite = 20,
		/obj/item/coin/twoheaded = 10,
		/obj/item/coin/antagtoken = 10,
		/obj/item/stack/spacecash/c10 = 80,
		/obj/item/stack/spacecash/c20 = 50,
		/obj/item/stack/spacecash/c50 = 30,
		/obj/item/stack/spacecash/c100 = 10,
		/obj/item/stack/spacecash/c500 = 5,
		/obj/item/stack/spacecash/c1000 = 1,
	)
	var/cash_path = pick_weight(possible_paths)
	return new cash_path()

/// Spawns fish
/datum/round_event/wizard/object_rain/fish

/datum/round_event/wizard/object_rain/fish/get_item()
	var/fish_path = pick(subtypesof(/obj/item/fish))
	return new fish_path()

/// Admin configuration
/datum/event_admin_setup/listed_options/object_rain
	input_text = "Where should the rain fall?"
	normal_run_option = "Random"

/datum/event_admin_setup/listed_options/object_rain/get_list()
	return RAIN_TARGET_DEPARTMENTS // Have to keep making a new copy as this list gets mutated

/datum/event_admin_setup/listed_options/object_rain/apply_to_event(datum/round_event/wizard/object_rain/event)
	if (chosen != "Random")
		event.target_region = chosen

#undef RAIN_TARGET_DEPARTMENTS
