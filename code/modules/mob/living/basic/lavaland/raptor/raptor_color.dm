GLOBAL_LIST_INIT(raptor_colors, init_raptor_colors())

/proc/init_raptor_colors()
	var/list/colors = list()
	for (var/datum/raptor_color/color_type as anything in subtypesof(/datum/raptor_color))
		colors[color_type] = new color_type()
	return colors

/datum/raptor_color
	/// Color name used for raptor name and icon
	var/color = "error"
	/// RaptorDex description for the raptor
	var/description = "Report this!"
	/// Raptor's health
	var/health = 200
	/// Raptor's speed
	var/speed = 0.5
	// Minimal and maximal damage for the raptor
	var/melee_damage_lower = 10
	var/melee_damage_upper = 15
	/// Does this raptor redirect projectile hits onto its rider?
	var/redirect_shots = TRUE
	/// Rideable component type to assign to the raptor
	var/rideable_component = /datum/component/riding/creature/raptor
	/// Guaranteed cross-breeding colors, other parent color -> child color
	var/guaranteed_crossbreeds = list()
	/// Type of AI controller the raptor uses
	var/datum/ai_controller/ai_controller = /datum/ai_controller/basic_controller/raptor
	/// Chance that a newborn baby raptor will be of this color
	var/spawn_chance = 33

/// Shared proc, only called once on raptor init for color-specific traits and properties
/datum/raptor_color/proc/setup_raptor(mob/living/basic/raptor/raptor)
	if (raptor.ai_controller)
		CRASH("setup_raptor called on a raptor ([raptor]) with a present AI controller! This is most likely a result of a second call to setup_raptor.")
	raptor.ai_controller = new ai_controller(raptor)

/datum/raptor_color/proc/setup_adult(mob/living/basic/raptor/raptor)
	var/datum/raptor_inheritance/stats = raptor.inherited_stats
	var/real_health = health + stats.health_modifier
	// If we grow up while damaged, keep the damage percentage the same
	raptor.health *= real_health / raptor.maxHealth
	raptor.maxHealth = real_health
	raptor.set_varspeed(speed - stats.speed_modifier)
	raptor.melee_damage_lower = melee_damage_lower + stats.attack_modifier
	raptor.melee_damage_upper = melee_damage_upper + stats.attack_modifier
	if (rideable_component)
		raptor.AddElement(/datum/element/ridable, rideable_component)
	setup_appearance(raptor)

/datum/raptor_color/proc/setup_young(mob/living/basic/raptor/raptor)
	var/datum/raptor_inheritance/stats = raptor.inherited_stats
	var/real_health = health + stats.health_modifier
	raptor.health *= real_health / 2 / raptor.maxHealth
	raptor.maxHealth = real_health / 2
	raptor.set_varspeed(speed - stats.speed_modifier)
	raptor.melee_damage_lower = floor((melee_damage_lower + stats.attack_modifier) / 2)
	raptor.melee_damage_upper = floor((melee_damage_upper + stats.attack_modifier) / 2)
	setup_appearance(raptor)

/datum/raptor_color/proc/setup_baby(mob/living/basic/raptor/raptor)
	var/datum/raptor_inheritance/stats = raptor.inherited_stats
	var/real_health = health + stats.health_modifier
	raptor.health *= real_health / 8 / raptor.maxHealth
	raptor.maxHealth = real_health / 8
	raptor.set_varspeed(speed + 4.5 - stats.speed_modifier)
	raptor.melee_damage_lower = floor((melee_damage_lower + stats.attack_modifier) / 3)
	raptor.melee_damage_upper = floor((melee_damage_upper + stats.attack_modifier) / 3)
	setup_appearance(raptor)

/datum/raptor_color/proc/setup_appearance(mob/living/basic/raptor/raptor)
	raptor.name = "[color] [raptor.name]"
	raptor.icon_state = "[raptor.base_icon_state]_[color]"
	raptor.held_state = "[raptor.base_icon_state]_[color]"
	raptor.icon_living = "[raptor.base_icon_state]_[color]"
	raptor.icon_dead = "[raptor.base_icon_state]_[color]_dead"
	raptor.update_appearance()

/datum/raptor_color/red
	color = "red"
	description = "A resilient breed of raptors, battle-tested and bred for the purpose of humbling its foes in combat, \
		This breed demonstrates higher combat capabilities than its peers and oozes ruthless aggression."
	melee_damage_lower = 15
	melee_damage_upper = 20
	health = 300
	rideable_component = /datum/component/riding/creature/raptor/combat
	redirect_shots = FALSE
	guaranteed_crossbreeds = list(
		/datum/raptor_color/green = /datum/raptor_color/yellow,
		/datum/raptor_color/blue = /datum/raptor_color/purple,
	)
	// Doesn't care for your excuses for friendly fire
	ai_controller = /datum/ai_controller/basic_controller/raptor/aggressive

/datum/raptor_color/purple
	color = "purple"
	description = "A small, nimble breed, these raptors have been bred as travel companions rather than mounts, capable of storing the owner's possessions and helping them escape from danger unscathed."
	health = 140 // smol
	guaranteed_crossbreeds = list(
		/datum/raptor_color/green = /datum/raptor_color/white,
		/datum/raptor_color/yellow = /datum/raptor_color/blue,
	)
	rideable_component = null

/datum/raptor_color/purple/setup_raptor(mob/living/basic/raptor/raptor)
	. = ..()
	RegisterSignal(raptor, COMSIG_LIVING_SCOOPED_UP, PROC_REF(on_picked_up))

/datum/raptor_color/purple/proc/on_picked_up(mob/living/basic/raptor/source, mob/living/user, obj/item/mob_holder/holder)
	SIGNAL_HANDLER

	RegisterSignal(holder, COMSIG_ITEM_EQUIPPED, PROC_REF(on_holder_equipped))
	RegisterSignals(holder, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING), PROC_REF(on_holder_dropped))

/datum/raptor_color/purple/proc/on_holder_equipped(obj/item/mob_holder/source, mob/equipper, slot)
	SIGNAL_HANDLER

	// When we are picked up or equipped as a backpack just allow all interactions to go through like we're a normal backpack
	var/mob/living/basic/raptor/raptor = source.held_mob
	raptor.atom_storage.insert_on_attack = TRUE

/datum/raptor_color/purple/proc/on_holder_dropped(obj/item/mob_holder/source, mob/dropper)
	SIGNAL_HANDLER

	var/mob/living/basic/raptor/raptor = source.held_mob
	raptor.atom_storage.insert_on_attack = FALSE

// Purple raptors never "fully" grow up, and remain usable as backpacks
/datum/raptor_color/purple/setup_adult(mob/living/basic/raptor/raptor)
	raptor.base_pixel_w = initial(raptor.base_pixel_w)
	raptor.can_be_held = TRUE
	raptor.density = FALSE
	raptor.move_resist = MOVE_RESIST_DEFAULT
	raptor.change_offsets = FALSE
	raptor.remove_offsets(RAPTOR_INNATE_SOURCE, FALSE)
	raptor.held_w_class = WEIGHT_CLASS_BULKY
	. = ..()
	if (raptor.atom_storage)
		return
	// A bit bigger (23 vs 21) than a backpack at max size, a bit less by default
	var/storage_volume = floor(19 * (1 + raptor.inherited_stats.ability_modifier))
	raptor.create_storage(
		max_total_storage = storage_volume,
		max_slots = storage_volume,
		storage_type = /datum/storage/raptor_storage,
	)

/datum/raptor_color/purple/setup_young(mob/living/basic/raptor/raptor)
	. = ..()
	if (raptor.atom_storage)
		return
	var/storage_volume = floor(19 * (1 + raptor.inherited_stats.ability_modifier))
	raptor.create_storage(
		max_total_storage = storage_volume,
		max_slots = storage_volume,
		storage_type = /datum/storage/raptor_storage,
	)

/datum/storage/raptor_storage
	animated = FALSE
	insert_on_attack = FALSE // should flip when worn on the back

/datum/storage/raptor_storage/on_mousedropped_onto(datum/source, obj/item/dropping, mob/user)
	return NONE

/datum/raptor_color/green
	color = "green"
	description = "A tough breed of raptor, made to withstand the harshest of punishment and to laugh in the face of pain, \
		this breed is able to withstand more punishment than its peers."
	health = 400
	// redirect_shots = FALSE // Need to figure out if I want this or not here
	guaranteed_crossbreeds = list(
		/datum/raptor_color/purple = /datum/raptor_color/white,
		/datum/raptor_color/red = /datum/raptor_color/yellow,
	)

/datum/raptor_color/green/setup_adult(mob/living/basic/raptor/raptor)
	. = ..()
	var/ability_scale = INVERSE_LERP(RAPTOR_INHERIT_MIN_MODIFIER, RAPTOR_INHERIT_MAX_MODIFIER, raptor.inherited_stats.ability_modifier)
	var/mining_mod = round(ability_scale * 0.1 SECONDS, 0.05 SECONDS)
	raptor.AddComponent(/datum/component/proficient_miner, mining_mod, TRUE)

/datum/raptor_color/white
	color = "white"
	description = "A loving sort, it cares for it peers and rushes to their aid with reckless abandon. It is able to heal any raptors' ailments."
	guaranteed_crossbreeds = list(
		/datum/raptor_color/blue = /datum/raptor_color/green,
		/datum/raptor_color/yellow = /datum/raptor_color/red,
	)

/datum/raptor_color/white/setup_young(mob/living/basic/raptor/raptor)
	. = ..()
	raptor.AddComponent( \
		/datum/component/healing_touch, \
		heal_brute = melee_damage_upper * 0.75 * (1 + raptor.inherited_stats.ability_modifier), \
		heal_burn = melee_damage_upper * 0.75 * (1 + raptor.inherited_stats.ability_modifier), \
		heal_time = 0, \
		valid_targets_typecache = typecacheof(list(/mob/living/basic/raptor)), \
	)

/datum/raptor_color/white/setup_adult(mob/living/basic/raptor/raptor)
	. = ..()
	qdel(raptor.GetComponent(/datum/component/healing_touch))
	raptor.AddComponent( \
		/datum/component/healing_touch, \
		heal_brute = melee_damage_upper * (1 + raptor.inherited_stats.ability_modifier), \
		heal_burn = melee_damage_upper * (1 + raptor.inherited_stats.ability_modifier), \
		heal_time = 0, \
		valid_targets_typecache = typecacheof(list(/mob/living/basic/raptor)), \
	)

/datum/raptor_color/yellow
	color = "yellow"
	description = "This breed possesses greasy fast speed, DEMON speed, making light work of long pilgrimages. \
		It's said that a thunderclap could be heard when this breed reaches its maximum speed."
	speed = 0
	guaranteed_crossbreeds = list(
		/datum/raptor_color/purple = /datum/raptor_color/blue,
		/datum/raptor_color/white = /datum/raptor_color/red,
	)

/datum/raptor_color/blue
	color = "blue"
	description = "Covered in tough, lava-resistant feathers with thick insulated fur underneath, this breed is capable of marching through lava and fire alike."
	guaranteed_crossbreeds = list(
		/datum/raptor_color/red = /datum/raptor_color/purple,
		/datum/raptor_color/white = /datum/raptor_color/green,
	)

/datum/raptor_color/blue/setup_raptor(mob/living/basic/raptor/raptor)
	. = ..()
	raptor.add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_NOFIRE_SPREAD), INNATE_TRAIT)

/datum/raptor_color/black
	color = "black"
	description = "An ultra rare breed. Due to its sparse nature, not much is known about this sort. However it is said to possess many of its peers' abilities."
	health = 400
	speed = 0
	melee_damage_lower = 20
	melee_damage_upper = 25
	redirect_shots = FALSE
	rideable_component = /datum/component/riding/creature/raptor/combat
	ai_controller = /datum/ai_controller/basic_controller/raptor/aggressive
	spawn_chance = 1 // 1 in 200 chance without modifiers

/datum/raptor_color/black/setup_raptor(mob/living/basic/raptor/raptor)
	. = ..()
	raptor.add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_NOFIRE_SPREAD), INNATE_TRAIT)

/datum/raptor_color/black/setup_adult(mob/living/basic/raptor/raptor)
	. = ..()
	// Slightly worse than greens at this
	var/ability_scale = INVERSE_LERP(RAPTOR_INHERIT_MIN_MODIFIER, RAPTOR_INHERIT_MAX_MODIFIER, raptor.inherited_stats.ability_modifier)
	var/mining_mod = round(ability_scale * 0.2 SECONDS, 0.05 SECONDS)
	raptor.AddComponent(/datum/component/proficient_miner, mining_mod, TRUE)
