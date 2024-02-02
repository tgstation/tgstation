///A global list of fish traits by their paths, which are singleton.
GLOBAL_LIST_INIT(fish_traits, init_subtypes_w_path_keys(/datum/fish_trait, list()))
/**
 * A nested list of fish types and traits and traits that they can spontaneously manifest with a 0 to 100 chance.
 * e.g. list(/obj/item/fish = list(/datum/fish_trait = 100), etc...)
 */
GLOBAL_LIST_INIT(spontaneous_fish_traits, populate_spontaneous_fish_traits())

/proc/populate_spontaneous_fish_traits()
	var/list/list = list()
	for(var/trait_path as anything in GLOB.fish_traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[trait_path]
		if(isnull(trait.spontaneous_manifest_types))
			continue
		var/list/trait_typecache = zebra_typecacheof(trait.spontaneous_manifest_types) - /obj/item/fish
		for(var/fish_type in trait_typecache)
			var/trait_prob = trait_typecache[fish_type]
			if(!trait_prob)
				continue
			LAZYSET(list[fish_type], trait_path, trait_typecache[fish_type])
	return list

/datum/fish_trait
	var/name = "Unnamed Trait"
	/// Description of the trait in the fishing catalog and scanner
	var/catalog_description = "Uh uh, someone has forgotten to set description to this trait. Yikes!"
	///A list of traits fish cannot have in conjunction with this trait.
	var/list/incompatible_traits
	/// The probability this trait can be inherited by offsprings when both mates have it
	var/inheritability = 100
	/// Same as above, but for when only one has it.
	var/diff_traits_inheritability = 50
	/// A list of fishes for which this trait can spontaneously manifest instead of being inherited, along with probabilities.
	var/list/spontaneous_manifest_types
	/// Depending on the value, fish with trait will be reported as more or less difficult in the catalog.
	var/added_difficulty = 0

/// Difficulty modifier from this mod, needs to return a list with two values
/datum/fish_trait/proc/difficulty_mod(obj/item/fishing_rod/rod, mob/fisherman)
	SHOULD_CALL_PARENT(TRUE) //Technically it doesn't but this makes it saner without custom unit test
	return list(ADDITIVE_FISHING_MOD = 0, MULTIPLICATIVE_FISHING_MOD = 1)

/// Catch weight table modifier from this mod, needs to return a list with two values
/datum/fish_trait/proc/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	SHOULD_CALL_PARENT(TRUE)
	return list(ADDITIVE_FISHING_MOD = 0, MULTIPLICATIVE_FISHING_MOD = 1)

/// Returns special minigame rules and effects applied by this trait
/datum/fish_trait/proc/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/minigame)
	return

/// Applies some special qualities to the fish that has been spawned
/datum/fish_trait/proc/apply_to_fish(obj/item/fish/fish)
	return

/// Proc used by both the predator and necrophage traits.
/datum/fish_trait/proc/eat_fish(obj/item/fish/predator, obj/item/fish/prey)
	predator.last_feeding = world.time
	var/message = prey.status == FISH_DEAD ? "[src] eats [prey]'s carcass." : "[src] hunts down and eats [prey]."
	predator.loc.visible_message(span_warning(message))
	SEND_SIGNAL(prey, COMSIG_FISH_EATEN_BY_OTHER_FISH, predator)
	qdel(prey)

/datum/fish_trait/wary
	name = "Wary"
	catalog_description = "This fish will avoid visible fish lines, cloaked line recommended."

/datum/fish_trait/wary/difficulty_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	// Wary fish require transparent line or they're harder
	if(!rod.line || !(rod.line.fishing_line_traits & FISHING_LINE_CLOAKED))
		.[ADDITIVE_FISHING_MOD] += FISH_TRAIT_MINOR_DIFFICULTY_BOOST

/datum/fish_trait/shiny_lover
	name = "Shiny Lover"
	catalog_description = "This fish loves shiny things, shiny lure recommended."

/datum/fish_trait/shiny_lover/difficulty_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	// These fish are easier to catch with shiny lure
	if(rod.hook && rod.hook.fishing_hook_traits & FISHING_HOOK_SHINY)
		.[ADDITIVE_FISHING_MOD] -= FISH_TRAIT_MINOR_DIFFICULTY_BOOST

/datum/fish_trait/picky_eater
	name = "Picky Eater"
	catalog_description = "This fish is very picky and will ignore low quality bait."

/datum/fish_trait/picky_eater/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	if(!rod.bait)
		.[MULTIPLICATIVE_FISHING_MOD] = 0
		return
	if(HAS_TRAIT(rod.bait, TRAIT_OMNI_BAIT))
		return
	if(HAS_TRAIT(rod.bait, TRAIT_GOOD_QUALITY_BAIT) || HAS_TRAIT(rod.bait, TRAIT_GREAT_QUALITY_BAIT))
		.[MULTIPLICATIVE_FISHING_MOD] = 0


/datum/fish_trait/nocturnal
	name = "Nocturnal"
	catalog_description = "This fish avoids bright lights, fishing and storing in darkness recommended."

/datum/fish_trait/nocturnal/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	var/turf/turf = get_turf(fisherman)
	var/light_amount = turf.get_lumcount()
	if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD)
		.[MULTIPLICATIVE_FISHING_MOD] = 0

/datum/fish_trait/nocturnal/apply_to_fish(obj/item/fish/fish)
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(check_light))

/datum/fish_trait/nocturnal/proc/check_light(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(isturf(source.loc) || isaquarium(source))
		var/turf/turf = get_turf(source)
		var/light_amount = turf.get_lumcount()
		if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD)
			source.adjust_health(source.health - 0.5 * seconds_per_tick)

/datum/fish_trait/heavy
	name = "Heavy"
	catalog_description = "This fish tends to stay near the waterbed."

/datum/fish_trait/heavy/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/minigame)
	minigame.fish_idle_velocity -= 10

/datum/fish_trait/carnivore
	name = "Carnivore"
	catalog_description = "This fish can only be baited with meat."
	incompatible_traits = list(/datum/fish_trait/vegan)

/datum/fish_trait/carnivore/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	if(!rod.bait)
		.[MULTIPLICATIVE_FISHING_MOD] = 0
		return
	if(HAS_TRAIT(rod.bait, TRAIT_OMNI_BAIT))
		return
	if(!istype(rod.bait, /obj/item/food))
		.[MULTIPLICATIVE_FISHING_MOD] = 0
		return
	var/obj/item/food/food_bait = rod.bait
	if(!(food_bait.foodtypes & MEAT))
		.[MULTIPLICATIVE_FISHING_MOD] = 0

/datum/fish_trait/vegan
	name = "Herbivore"
	catalog_description = "This fish can only be baited with fresh produce."
	incompatible_traits = list(/datum/fish_trait/carnivore, /datum/fish_trait/predator, /datum/fish_trait/necrophage)

/datum/fish_trait/vegan/catch_weight_mod(obj/item/fishing_rod/rod, mob/fisherman)
	. = ..()
	if(!rod.bait)
		.[MULTIPLICATIVE_FISHING_MOD] = 0
		return
	if(HAS_TRAIT(rod.bait, TRAIT_OMNI_BAIT))
		return
	if(!istype(rod.bait, /obj/item/food/grown))
		.[MULTIPLICATIVE_FISHING_MOD] = 0

/datum/fish_trait/emulsijack
	name = "Emulsifier"
	catalog_description = "This fish emits an invisible toxin that emulsifies other fish for it to feed on."

/datum/fish_trait/emulsijack/apply_to_fish(obj/item/fish/fish)
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(emulsify))
	ADD_TRAIT(fish, TRAIT_RESIST_EMULSIFY, FISH_TRAIT_DATUM)

/datum/fish_trait/emulsijack/proc/emulsify(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(!isaquarium(source.loc))
		return
	var/emulsified = FALSE
	for(var/obj/item/fish/victim in source.loc)
		if(HAS_TRAIT(victim, TRAIT_RESIST_EMULSIFY) || HAS_TRAIT(victim, TRAIT_FISH_TOXIN_IMMUNE)) //no team killing
			continue
		victim.adjust_health(victim.health - 3 * seconds_per_tick) //the victim may heal a bit but this will quickly kill
		emulsified = TRUE
	if(emulsified)
		source.adjust_health(source.health + 3 * seconds_per_tick)
		source.last_feeding = world.time //it feeds on the emulsion!

/datum/fish_trait/necrophage
	name = "Necrophage"
	catalog_description = "This fish will eat carcasses of dead fish when hungry."
	incompatible_traits = list(/datum/fish_trait/vegan)
	spontaneous_manifest_types = list(/obj/item/fish = 3)

/datum/fish_trait/necrophage/apply_to_fish(obj/item/fish/fish)
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(eat_dead_fishes))

/datum/fish_trait/necrophage/proc/eat_dead_fishes(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(!source.is_hungry() || !isaquarium(source.loc))
		return
	for(var/obj/item/fish/victim in source.loc)
		if(victim.status != FISH_DEAD || victim == source || HAS_TRAIT(victim, TRAIT_YUCKY_FISH))
			continue
		eat_fish(source, victim)
		return

/datum/fish_trait/parthenogenesis
	name = "Parthenogenesis"
	catalog_description = "This fish can reproduce asexually, without the need of a mate."
	inheritability = 80
	diff_traits_inheritability = 25

/datum/fish_trait/parthenogenesis/apply_to_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_SELF_REPRODUCE, FISH_TRAIT_DATUM)

/**
 * Useful for those species with the parthenogenesis trait if you don't want them to mate with each other,
 * or for similar shenanigeans, I don't know.
 * Otherwise you could just set the stable_population to 1.
 */
/datum/fish_trait/no_mating
	name = "Mateless"
	catalog_description = "This fish cannot reproduce with other fishes."
	incompatible_traits = list(/datum/fish_trait/crossbreeder)
	spontaneous_manifest_types = list(/obj/item/fish = 1)

/datum/fish_trait/no_mating/apply_to_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_NO_MATING, FISH_TRAIT_DATUM)

/datum/fish_trait/revival
	diff_traits_inheritability = 15
	name = "Self-Revival"
	catalog_description = "This fish shows a peculiar ability of reviving itself a minute or two after death."
	spontaneous_manifest_types = list(/obj/item/fish/boned = 100, /obj/item/fish/mastodon = 100)

/datum/fish_trait/revival/apply_to_fish(obj/item/fish/fish)
	RegisterSignal(fish, COMSIG_FISH_STATUS_CHANGED, PROC_REF(check_status))

/datum/fish_trait/revival/proc/check_status(obj/item/fish/source)
	SIGNAL_HANDLER
	if(source.status == FISH_DEAD)
		addtimer(CALLBACK(src, PROC_REF(revive), source), rand(1 MINUTES, 2 MINUTES))

/datum/fish_trait/revival/proc/revive(obj/item/fish/source)
	if(QDELETED(source) || source.status != FISH_DEAD)
		return
	source.set_status(FISH_ALIVE)
	var/message = span_nicegreen("[source] twitches. It's alive!")
	if(isaquarium(source.loc))
		source.loc.visible_message(message)
	else
		source.visible_message(message)

/datum/fish_trait/predator
	name = "Predator"
	catalog_description = "It's a predatory fish. It'll hunt down and eat live fishes of smaller size when hungry."
	incompatible_traits = list(/datum/fish_trait/vegan)

/datum/fish_trait/predator/apply_to_fish(obj/item/fish/fish)
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(eat_fishes))

/datum/fish_trait/predator/proc/eat_fishes(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(!source.is_hungry() || !isaquarium(source.loc))
		return
	var/obj/structure/aquarium/aquarium = source.loc
	for(var/obj/item/fish/victim in aquarium.get_fishes(TRUE, source))
		if(victim.size < source.size * 0.75) // It's a big fish eat small fish world
			continue
		if(victim.status != FISH_ALIVE || victim == source || HAS_TRAIT(victim, TRAIT_YUCKY_FISH) || SPT_PROB(80, seconds_per_tick))
			continue
		eat_fish(source, victim)
		return

/datum/fish_trait/yucky
	name = "Yucky"
	catalog_description = "This fish tastes so repulsive, other fishes won't try to eat it."

/datum/fish_trait/yucky/apply_to_fish(obj/item/fish/fish)
	RegisterSignal(fish, COMSIG_ATOM_PROCESSED, PROC_REF(add_yuck))
	ADD_TRAIT(fish, TRAIT_YUCKY_FISH, FISH_TRAIT_DATUM)
	LAZYSET(fish.grind_results, /datum/reagent/yuck, 3)

/datum/fish_trait/yucky/proc/add_yuck(obj/item/fish/source, mob/living/user, obj/item/process_item, list/results)
	var/amount = source.grind_results[/datum/reagent/yuck] / length(results)
	for(var/atom/result as anything in results)
		result.reagents?.add_reagent(/datum/reagent/yuck, amount)

/datum/fish_trait/toxic
	name = "Toxic"
	catalog_description = "This fish contains toxins in its liver. letting other fishes or people eat it is not reccomended."
	diff_traits_inheritability = 25

/datum/fish_trait/toxic/apply_to_fish(obj/item/fish/fish)
	RegisterSignal(fish, COMSIG_ATOM_PROCESSED, PROC_REF(add_toxin))
	RegisterSignal(fish, COMSIG_FISH_EATEN_BY_OTHER_FISH, PROC_REF(on_eaten))
	LAZYSET(fish.grind_results, /datum/reagent/toxin/tetrodotoxin, 2.5)

/datum/fish_trait/toxic/proc/add_toxin(obj/item/fish/source, mob/living/user, obj/item/process_item, list/results)
	var/amount = source.grind_results[ /datum/reagent/toxin/tetrodotoxin] / length(results)
	for(var/atom/result as anything in results)
		result.reagents?.add_reagent( /datum/reagent/toxin/tetrodotoxin, amount)

/datum/fish_trait/toxic/proc/on_eaten(obj/item/fish/source, obj/item/fish/predator)
	if(HAS_TRAIT(predator, TRAIT_FISH_TOXIN_IMMUNE))
		return
	RegisterSignal(predator, COMSIG_FISH_LIFE, PROC_REF(damage_predator), TRUE)
	RegisterSignal(predator, COMSIG_FISH_STATUS_CHANGED, PROC_REF(stop_damaging), TRUE)

/datum/fish_trait/toxic/proc/damage_predator(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	source.adjust_health(source.health - 3 * seconds_per_tick)

/datum/fish_trait/toxic/proc/stop_damaging(obj/item/fish/source)
	SIGNAL_HANDLER
	if(source.status == FISH_DEAD)
		UnregisterSignal(source, list(COMSIG_FISH_LIFE, COMSIG_FISH_STATUS_CHANGED))

/datum/fish_trait/toxin_immunity
	name = "Toxin Immunity"
	catalog_description = "This fish has developed an ample-spected immunity to toxins."
	diff_traits_inheritability = 40
	spontaneous_manifest_types = list(/obj/item/fish = 4)

/datum/fish_trait/toxin_immunity/apply_to_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_TOXIN_IMMUNE, FISH_TRAIT_DATUM)

/datum/fish_trait/crossbreeder
	name = "Crossbreeder"
	catalog_description = "This fish's adaptive genetics allows it to crossbreed with other fish species."
	inheritability = 80
	diff_traits_inheritability = 20
	incompatible_traits = list(/datum/fish_trait/no_mating)
	spontaneous_manifest_types = list(
		/obj/item/fish = 3,
		/obj/item/fish/sludgefish = 0,
		/obj/item/fish/sludgefish/purple = 3,
	)

/datum/fish_trait/crossbreeder/apply_to_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_CROSSBREEDER, FISH_TRAIT_DATUM)

/datum/fish_trait/territorial
	name = "Territorial"
	inheritability = 80
	diff_traits_inheritability = 40
	catalog_description = "This fish is territorial, and will start attacking if there're too many fishes in the acquarium."
	spontaneous_manifest_types = list(
		/obj/item/fish = 6,
		/obj/item/fish/plasmatetra = 0,
		/obj/item/fish/needlefish = 0,
		/obj/item/fish/armorfish = 0,
	)

/datum/fish_trait/aggressive/apply_to_fish(obj/item/fish/fish)
	RegisterSignal(fish, COMSIG_FISH_LIFE, PROC_REF(try_attack_fish))

/datum/fish_trait/aggressive/proc/try_attack_fish(obj/item/fish/source, seconds_per_tick)
	SIGNAL_HANDLER
	if(!isaquarium(source.loc) || !SPT_PROB(2, seconds_per_tick))
		return
	var/obj/structure/aquarium/aquarium = source.loc
	var/list/fishes = aquarium.get_fishes(TRUE, source)
	if(length(fishes) <= 3) //If there're up to 3 fishes other than source in the aquarium, we chill.
		return
	for(var/obj/item/fish/victim as anything in aquarium.get_fishes(TRUE, source))
		if(victim.status != FISH_ALIVE)
			continue
		aquarium.visible_message(span_warning("[source] violently [pick("whips", "bites", "attacks", "slams")] [victim]"))
		var/damage = round(rand(4, 20) * (source.size / victim.size)) //smaller fishes take extra damage.
		victim.adjust_health(victim.health - damage)
		return

/datum/fish_trait/lubed
	name = "Lubed"
	inheritability = 90
	diff_traits_inheritability = 45
	spontaneous_manifest_types = list(/obj/item/fish/clownfish/lube = 100)
	catalog_description = "This fish exudes a viscous, slippery lubrificant. It's reccomended not to step on it."
	added_difficulty = 5

/datum/fish_trait/lubed/apply_to_fish(obj/item/fish/fish)
	fish.AddComponent(/datum/component/slippery, 8 SECONDS, SLIDE|GALOSHES_DONT_HELP)

/datum/fish_trait/lubed/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/minigame)
	minigame.reeling_velocity *= 1.4
	minigame.gravity_velocity *= 1.4

/datum/fish_trait/amphibious
	name = "Amphibious"
	inheritability = 80
	diff_traits_inheritability = 40
	catalog_description = "This fish has developed a primitive adaptation to life on both land and water."
	spontaneous_manifest_types = list(/obj/item/fish = 1, /obj/item/fish/chasm_crab = 4)

/datum/fish_trait/amphibious/apply_to_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_AMPHIBIOUS, FISH_TRAIT_DATUM)
	if(fish.required_fluid_type == AQUARIUM_FLUID_AIR)
		fish.required_fluid_type = AQUARIUM_FLUID_FRESHWATER

/datum/fish_trait/mixotroph
	name = "Mixotroph"
	inheritability = 75
	diff_traits_inheritability = 25
	catalog_description = "This fish is capable of substaining itself by producing its own sources of energy (food)."
	incompatible_traits = list(/datum/fish_trait/predator, /datum/fish_trait/necrophage)
	spontaneous_manifest_types = list(/obj/item/fish = 1)

/datum/fish_trait/antigrav/apply_to_fish(obj/item/fish/fish)
	ADD_TRAIT(fish, TRAIT_FISH_NO_HUNGER, FISH_TRAIT_DATUM)

/datum/fish_trait/antigrav
	name = "Anti-Gravity"
	inheritability = 75
	diff_traits_inheritability = 25
	catalog_description = "This fish will invert the gravity of the bait at random. May fall upward after being caught."
	added_difficulty = 15

/datum/fish_trait/antigrav/minigame_mod(obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/minigame)
	minigame.special_effects |= FISHING_MINIGAME_RULE_ANTIGRAV

/datum/fish_trait/antigrav/apply_to_fish(obj/item/fish/fish)
	fish.AddElement(/datum/element/forced_gravity, NEGATIVE_GRAVITY)
